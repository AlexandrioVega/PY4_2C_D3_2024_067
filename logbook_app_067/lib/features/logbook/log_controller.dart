import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'package:logbook_app_067/features/logbook/models/log_model.dart';
import 'package:logbook_app_067/helpers/log_helper.dart';
import 'package:logbook_app_067/services/access_control_service.dart';
import 'package:logbook_app_067/services/mongo_service.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  // Hive box untuk penyimpanan lokal (Offline-First)
  late final Box<LogModel> _myBox;

  // Identitas pengguna yang sedang login
  final String userRole;
  final String userId;

  List<LogModel> get logs => logsNotifier.value;

  LogController({
    required this.userRole,
    required this.userId,
  }) {
    // Ambil box yang sudah dibuka di main.dart
    _myBox = Hive.box<LogModel>('offline_logs');
  }

  Future<void> loadLogs(String teamId) async {
    logsNotifier.value = _myBox.values.toList();

    await LogHelper.writeLog(
      "HIVE: Memuat ${_myBox.length} data dari lokal",
      source: "log_controller.dart",
      level: 2,
    );

    
    try {
      final cloudData = await MongoService().getLogs(teamId);

      
      await _myBox.clear();
      await _myBox.addAll(cloudData);

      
      logsNotifier.value = cloudData;

      await LogHelper.writeLog(
        "SYNC: Data berhasil diperbarui dari Atlas (${cloudData.length} items)",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "OFFLINE: Menggunakan data cache lokal — $e",
        source: "log_controller.dart",
        level: 2,
      );
    }
  }

  Future<void> addLog(
    String title,
    String desc,
    String authorId,
    String teamId, {
    String category = 'Pribadi',
    bool isPublic = false, 
  }) async {
    final newLog = LogModel(
      id: ObjectId().oid, 
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      category: category,
      authorId: authorId,
      teamId: teamId,
      isPublic: isPublic, 
    );

  
    await _myBox.add(newLog);
    logsNotifier.value = [...logsNotifier.value, newLog];

    await LogHelper.writeLog(
      "HIVE: Log baru tersimpan lokal — '${newLog.title}'",
      source: "log_controller.dart",
      level: 2,
    );

    
    try {
      await MongoService().insertLog(newLog);
      await LogHelper.writeLog(
        "CLOUD: Data '${newLog.title}' tersinkron ke Atlas",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "WARNING: Data tersimpan lokal, akan sinkron saat online — $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }


  Future<void> updateLogById(
    String id,
    String newTitle,
    String newDesc, {
    String category = 'Pribadi',
    bool? isPublic, 
  }) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final index = currentLogs.indexWhere((log) => log.id == id);

    if (index == -1) {
      await LogHelper.writeLog(
        "ERROR: Log dengan ID $id tidak ditemukan",
        source: "log_controller.dart",
        level: 1,
      );
      return;
    }

    final oldLog = currentLogs[index];

    
    final bool isOwner = oldLog.authorId == userId;
    if (!AccessControlService.canPerform(
      userRole,
      AccessControlService.actionUpdate,
      isOwner: isOwner,
    )) {
      await LogHelper.writeLog(
        "SECURITY BREACH: Unauthorized update attempt oleh $userId (role: $userRole)",
        source: "log_controller.dart",
        level: 1,
      );
      return;
    }

    final updatedLog = LogModel(
      id: oldLog.id,
      title: newTitle,
      description: newDesc,
      date: DateTime.now().toString(),
      category: category,
      authorId: oldLog.authorId,
      teamId: oldLog.teamId,
      isPublic: isPublic ?? oldLog.isPublic, 
    );

    // Update Hive
    final hiveKey = _myBox.keyAt(_myBox.values.toList().indexWhere((l) => l.id == id));
    await _myBox.put(hiveKey, updatedLog);
    currentLogs[index] = updatedLog;
    logsNotifier.value = currentLogs;


    try {
      await MongoService().updateLog(updatedLog);
      await LogHelper.writeLog(
        "SUCCESS: Update '${updatedLog.title}' berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal update ke Cloud — $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> removeLogById(String id) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final index = currentLogs.indexWhere((log) => log.id == id);

    if (index == -1) return;

    final targetLog = currentLogs[index];

    final bool isOwner = targetLog.authorId == userId;
    if (!AccessControlService.canPerform(
      userRole,
      AccessControlService.actionDelete,
      isOwner: isOwner,
    )) {
      await LogHelper.writeLog(
        "SECURITY BREACH: Unauthorized delete attempt oleh $userId (role: $userRole)",
        source: "log_controller.dart",
        level: 1,
      );
      return;
    }

    // Hapus dari Hive
    final hiveIndex = _myBox.values.toList().indexWhere((l) => l.id == id);
    if (hiveIndex != -1) {
      await _myBox.deleteAt(hiveIndex);
    }
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;

    // Hapus dari Cloud
    try {
      if (targetLog.id != null) {
        await MongoService().deleteLog(ObjectId.fromHexString(targetLog.id!));
      }
      await LogHelper.writeLog(
        "SUCCESS: Hapus '${targetLog.title}' berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal hapus dari Cloud — $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }


  Future<void> syncFromCloud(String teamId) async {
    try {
      await _uploadPendingData();

      final freshData = await MongoService().getLogs(teamId);
      await _myBox.clear();
      await _myBox.addAll(freshData);
      logsNotifier.value = freshData;

      await LogHelper.writeLog(
        "SYNC: logsNotifier diperbarui dari Cloud (${freshData.length} items)",
        source: "log_controller.dart",
        level: 3,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "SYNC: Gagal sync dari Cloud — $e",
        source: "log_controller.dart",
        level: 1,
      );
      rethrow;
    }
  }

  Future<void> _uploadPendingData() async {
    final allLocalLogs = _myBox.values.toList();
    
    if (allLocalLogs.isEmpty) {
      await LogHelper.writeLog(
        "PENDING: Tidak ada data lokal untuk di-upload",
        source: "log_controller.dart",
        level: 3,
      );
      return;
    }

    int successCount = 0;
    int failCount = 0;

    for (var log in allLocalLogs) {
      try {
        await MongoService().upsertLog(log);
        successCount++;
        
        await LogHelper.writeLog(
          "PENDING UPLOAD: '${log.title}' berhasil di-upsert",
          source: "log_controller.dart",
          level: 3,
        );
      } catch (e) {
        failCount++;
        await LogHelper.writeLog(
          "PENDING UPLOAD ERROR: Gagal upsert '${log.title}' - $e",
          source: "log_controller.dart",
          level: 1,
        );
      }
    }

    if (failCount == 0) {
      await LogHelper.writeLog(
        "PENDING UPLOAD: Semua $successCount data berhasil di-upload ✓",
        source: "log_controller.dart",
        level: 2,
      );
    } else {
      await LogHelper.writeLog(
        "PENDING UPLOAD: $successCount berhasil, $failCount gagal",
        source: "log_controller.dart",
        level: 2,
      );
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Colors.blue.shade100;
      case 'Pribadi':
        return Colors.green.shade100;
      case 'Urgent':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  // Helper: Ikon kategori
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Icons.work;
      case 'Pribadi':
        return Icons.person;
      case 'Urgent':
        return Icons.warning;
      default:
        return Icons.note;
    }
  }

  void dispose() {
    logsNotifier.dispose();
  }
}