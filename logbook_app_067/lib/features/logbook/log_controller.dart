import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';
import 'package:logbook_app_067/helpers/log_helper.dart';
import 'package:logbook_app_067/services/mongo_service.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);
  static const String _storageKey = 'user_logs_data';
  List<LogModel> get logs => logsNotifier.value;
  ValueNotifier<List<LogModel>> get filteredLogs => logsNotifier;
  LogController([String? username]) {
  }

  Future<void> addLog(String title, String desc, [String category = 'Pribadi']) async {
    final newLog = LogModel(
      id: ObjectId(),
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      category: category,
    );

    try {
      await MongoService().insertLog(newLog);
      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs.add(newLog);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Tambah data dengan ID lokal",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Add - $e", level: 1);
    }
  }

  Future<void> updateLog(int index, String newTitle, String newDesc, [String category = 'Pribadi']) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      title: newTitle,
      description: newDesc,
      date: DateTime.now().toString(),
      category: category,
    );

    try {
      await MongoService().updateLog(updatedLog);
      currentLogs[index] = updatedLog;
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Update - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }
  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    try {
      if (targetLog.id == null) {
        throw Exception(
          "ID Log tidak ditemukan, tidak bisa menghapus di Cloud.",
        );
      }
      await MongoService().deleteLog(targetLog.id!);
      currentLogs.removeAt(index);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Hapus '${targetLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Hapus - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> removeLogById(ObjectId id) async {
    try {
      await MongoService().deleteLog(id);
      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs.removeWhere((log) => log.id == id);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Hapus ID $id Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal hapus ID $id - $e",
        source: "log_controller.dart",
        level: 1,
      );
      rethrow;
    }
  }
  Future<void> updateLogById(ObjectId id, String newTitle, String newDesc, [String category = 'Pribadi']) async {
    try {
      final currentLogs = List<LogModel>.from(logsNotifier.value);
      final indexToUpdate = currentLogs.indexWhere((log) => log.id == id);
      if (indexToUpdate == -1) {
        throw Exception("Log dengan ID $id tidak ditemukan");
      }

      final oldLog = currentLogs[indexToUpdate];
      final updatedLog = LogModel(
        id: oldLog.id,
        title: newTitle,
        description: newDesc,
        date: DateTime.now().toString(),
        category: category,
      );
      await MongoService().updateLog(updatedLog);
      currentLogs[indexToUpdate] = updatedLog;
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Update ID $id Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal update ID - $e",
        source: "log_controller.dart",
        level: 1,
      );
      rethrow;
    }
  }

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    // Mengubah List of Object -> List of Map -> String JSON
    final String encodedData = jsonEncode(
      logsNotifier.value.map((log) => log.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  Future<void> loadFromDisk() async {
    final cloudData = await MongoService().getLogs();
    logsNotifier.value = cloudData;
  }

  Future<void> syncFromCloud() async {
    try {
      final freshData = await MongoService().getLogs();
      logsNotifier.value = freshData;
      await LogHelper.writeLog(
        "SYNC: logsNotifier updated dari Cloud (${freshData.length} items)",
        source: "log_controller.dart",
        level: 3,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "SYNC: Gagal sync dari Cloud - $e",
        source: "log_controller.dart",
        level: 1,
      );
      rethrow;
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
}
