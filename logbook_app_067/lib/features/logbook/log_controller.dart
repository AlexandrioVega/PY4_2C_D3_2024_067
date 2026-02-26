import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';

class LogController {
  final String username;
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);
  String _lastQuery = '';
  String get _storageKey => 'logs_$username';

  LogController(this.username);
  Future<void> init() async {
    await loadFromDisk();
    filteredLogs.value = logsNotifier.value;
  }

  void searchLog(String query) {
    _lastQuery = query;
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }


  void addLog(String title, String desc, String category) {
    final newLog = LogModel(title: title, description: desc, date: DateTime.now().toString(), category: category);
    logsNotifier.value = [...logsNotifier.value, newLog];
    saveToDisk();
    searchLog(_lastQuery);
  }

  void updateLog(int index, String title, String desc, String category) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs[index] = LogModel(title: title, description: desc, date: DateTime.now().toString(), category: category);
    logsNotifier.value = currentLogs;
    saveToDisk();
    searchLog(_lastQuery);
  }

  void removeLog(int index) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    saveToDisk();
    searchLog(_lastQuery);
  }

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(logsNotifier.value.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey) ?? '';
    
    if (data == null || data.isEmpty) {
      logsNotifier.value = [];
      return;
    }

    try {
      final List decoded = jsonDecode(data);
      logsNotifier.value =
          decoded.map((e) => LogModel.fromMap(e)).toList();
    } catch (e) {
      logsNotifier.value = [];
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Colors.blue.shade100;
      case 'Urgent':
        return Colors.red.shade100;
      case 'Pribadi':
      default:
        return Colors.green.shade100;
    }
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Icons.work;
      case 'Urgent':
        return Icons.priority_high;
      case 'Pribadi':
      default:
        return Icons.person;
    }
  }
}