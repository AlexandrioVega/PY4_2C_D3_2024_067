// import 'package:mongo_dart/mongo_dart.dart';
// import 'package:logbook_app_067/services/i_mongo_service.dart';
// import 'package:logbook_app_067/features/logbook/models/log_model.dart';

// class MockMongoService implements IMongoService {
//   List<LogModel> fakeCloudData = [];
//   bool shouldFail = false;

//   @override
//   Future<void> connect() async {
//     if (shouldFail) throw Exception("Connect gagal");
//     // Mock connection
//   }

//   @override
//   Future<void> insertLog(LogModel log) async {
//     if (shouldFail) throw Exception("Insert gagal");
//     fakeCloudData.add(log);
//   }

//   @override
//   Future<void> upsertLog(LogModel log) async {
//     if (shouldFail) throw Exception("Upsert gagal");

//     final index = fakeCloudData.indexWhere((l) => l.id == log.id);
//     if (index == -1) {
//       fakeCloudData.add(log);
//     } else {
//       fakeCloudData[index] = log;
//     }
//   }

//   @override
//   Future<List<LogModel>> getLogs(String teamId) async {
//     if (shouldFail) throw Exception("Fetch gagal");
//     return fakeCloudData;
//   }

//   @override
//   Future<void> updateLog(LogModel log) async {
//     if (shouldFail) throw Exception("Update gagal");
//     final index = fakeCloudData.indexWhere((l) => l.id == log.id);
//     if (index != -1) {
//       fakeCloudData[index] = log;
//     }
//   }

//   @override
//   Future<void> deleteLog(ObjectId id) async {
//     if (shouldFail) throw Exception("Delete gagal");
//     fakeCloudData.removeWhere((l) => l.id == id.oid);
//   }
// }