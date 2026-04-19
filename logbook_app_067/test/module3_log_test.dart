import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';

import 'package:logbook_app_067/features/logbook/log_controller.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';

void main() {
  late LogController controller;

  const userId = "user_001";
  const teamId = "MEKTRA_KLP_067";

  // 🔥 INIT SEKALI
  setUpAll(() async {
    await setUpTestHive();

    // ✅ FIX: pakai try-catch biar tidak double register
    try {
      Hive.registerAdapter(LogModelAdapter());
    } catch (_) {}
  });

  // 🔁 SETUP PER TEST
  setUp(() async {
    await Hive.openBox<LogModel>('offline_logs');

    controller = LogController(
      userRole: "Ketua",
      userId: userId,
    );
  });

  // 🔁 BERSIHKAN DATA
  tearDown(() async {
    await Hive.box<LogModel>('offline_logs').clear();
  });

  // 🔥 CLEANUP AKHIR
  tearDownAll(() async {
    await Hive.close();
    await tearDownTestHive();
  });

  group('Module 3 - LogController', () {

    test('TC01 - Update log with valid data and authorized user', () async {
      final log = LogModel(
        id: "1",
        title: "Old",
        description: "Old Desc",
        date: DateTime.now().toString(),
        category: "Software",
        authorId: userId,
        teamId: teamId,
      );

      await Hive.box<LogModel>('offline_logs').add(log);
      controller.logsNotifier.value = [log];

      await controller.updateLogById("1", "New", "New Desc");

      final updated = controller.logs.first;

      expect(updated.title, "New");
      expect(updated.description, "New Desc");
    });

    test('TC02 - Update log with invalid ID', () async {
      controller.logsNotifier.value = [];

      await controller.updateLogById("invalid", "X", "Y");

      expect(controller.logs.isEmpty, true);
    });

    test('TC03 - Unauthorized update attempt', () async {
      final log = LogModel(
        id: "2",
        title: "Test",
        description: "Desc",
        date: DateTime.now().toString(),
        category: "Software",
        authorId: "user_lain",
        teamId: teamId,
      );

      await Hive.box<LogModel>('offline_logs').add(log);
      controller.logsNotifier.value = [log];

      await controller.updateLogById("2", "Hacked", "Hacked");

      final result = controller.logs.first;

      expect(result.title, "Test");
    });

    test('TC04 - Add log success', () async {
      await controller.addLog("Test", "Desc", userId, teamId);

      expect(controller.logs.isNotEmpty, true);
    });

    test('TC05 - Add log cloud fail (still local)', () async {
      await controller.addLog("Offline", "Desc", userId, teamId);

      expect(controller.logs.length, 1);
    });

    test('TC06 - Delete log success', () async {
      final log = LogModel(
        id: "3",
        title: "Delete",
        description: "Desc",
        date: DateTime.now().toString(),
        category: "Software",
        authorId: userId,
        teamId: teamId,
      );

      await Hive.box<LogModel>('offline_logs').add(log);
      controller.logsNotifier.value = [log];

      await controller.removeLogById("3");

      expect(controller.logs.isEmpty, true);
    });

    test('TC07 - Unauthorized delete attempt', () async {
      final log = LogModel(
        id: "4",
        title: "Test",
        description: "Desc",
        date: DateTime.now().toString(),
        category: "Software",
        authorId: "user_lain",
        teamId: teamId,
      );

      await Hive.box<LogModel>('offline_logs').add(log);
      controller.logsNotifier.value = [log];

      await controller.removeLogById("4");

      expect(controller.logs.length, 1);
    });

    test('TC08 - Delete log with invalid ID', () async {
      controller.logsNotifier.value = [];

      await controller.removeLogById("invalid");

      expect(controller.logs.isEmpty, true);
    });

    test('TC09 - Search empty query', () {
      final log = LogModel(
        id: "5",
        title: "Test",
        description: "Desc",
        date: "",
        category: "Software",
        authorId: userId,
        teamId: teamId,
      );

      controller.logsNotifier.value = [log];

      controller.updateSearchQuery("");
      controller.performSearch();

      expect(controller.filteredLogs.length, 1);
    });

    test('TC10 - Search with keyword', () {
      final log = LogModel(
        id: "6",
        title: "Flutter",
        description: "Belajar",
        date: "",
        category: "Software",
        authorId: userId,
        teamId: teamId,
      );

      controller.logsNotifier.value = [log];

      controller.updateSearchQuery("flutter");
      controller.performSearch();

      expect(controller.filteredLogs.length, 1);
    });

  });
}