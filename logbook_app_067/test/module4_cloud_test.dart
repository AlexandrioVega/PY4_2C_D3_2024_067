import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';

import 'package:logbook_app_067/features/logbook/log_controller.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';

import 'mocks/mock_mongo_service.dart';

void main() {
  late LogController controller;
  late MockMongoService mockService;
  const userId = "user_001";
  const teamId = "MEKTRA_KLP_067";

  setUpAll(() async {
    await setUpTestHive();
    try {
      Hive.registerAdapter(LogModelAdapter());
    } catch (_) {}
  });


  setUp(() async {
    await Hive.openBox<LogModel>('offline_logs');

    mockService = MockMongoService();

    controller = LogController(
        userRole: "Ketua",
        userId: userId,
        mongoService: mockService, // 🔥 CAST FIX
    );

    controller.isTestMode = true;
  });

  tearDown(() async {
    await Hive.box<LogModel>('offline_logs').clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tearDownTestHive();
  });

  group('Cloud Test (Mock Mongo)', () {

    // TC01
    test('TC01 - Save to cloud SUCCESS', () async {
      await controller.addLog("Test", "Desc", userId, teamId);

      expect(mockService.fakeCloudData.length, 1);
    });

    // TC02
    test('TC02 - Save to cloud FAIL', () async {
      mockService.shouldFail = true;

      await controller.addLog("Test", "Desc", userId, teamId);

      expect(controller.logs.length, 1); // tetap lokal
    });

    // TC03
    test('TC03 - Sync from cloud SUCCESS', () async {
      mockService.fakeCloudData.add(
        LogModel(
          id: "1",
          title: "Cloud",
          description: "Desc",
          date: "",
          category: "Software",
          authorId: userId,
          teamId: teamId,
        ),
      );

      await controller.syncFromCloud(teamId);

      expect(controller.logs.length, 1);
    });

    // TC04
    test('TC04 - Sync FAIL (offline)', () async {
      mockService.shouldFail = true;

      await controller.syncFromCloud(teamId);

      expect(controller.logs.length >= 0, true); // tidak crash
    });

    // TC05
    test('TC05 - Upsert SUCCESS', () async {
      final log = LogModel(
        id: "1",
        title: "Upsert",
        description: "Desc",
        date: "",
        category: "Software",
        authorId: userId,
        teamId: teamId,
      );

      await mockService.upsertLog(log);

      expect(mockService.fakeCloudData.length, 1);
    });

  });
}