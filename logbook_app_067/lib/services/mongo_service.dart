import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';
import 'package:logbook_app_067/helpers/log_helper.dart';
import 'package:logbook_app_067/helpers/app_exceptions.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();

  // Menggunakan nullable agar kita bisa mengecek status inisialisasi
  Db? _db;
  DbCollection? _collection;
  bool _isConnecting = false;

  final String _source = "mongo_service.dart";

  factory MongoService() => _instance;
  MongoService._internal();

  /// Fungsi Internal untuk memastikan koleksi siap digunakan (Anti-LateInitializationError)
  Future<DbCollection> _getSafeCollection() async {
    if (_db == null || !_db!.isConnected || _collection == null) {
      await LogHelper.writeLog(
        "INFO: Koleksi belum siap, mencoba rekoneksi...",
        source: _source,
        level: 3,
      );
      await connect();
    }
    return _collection!;
  }

  /// Inisialisasi Koneksi ke MongoDB Atlas (LAZY LOADING - Hanya saat dibutuhkan)
  Future<void> connect() async {
    // Prevent multiple simultaneous connection attempts
    if (_isConnecting) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_db != null && _db!.isConnected) return;
    }

    if (_db != null && _db!.isConnected) return; // Sudah terkoneksi

    _isConnecting = true;
    try {
      final dbUri = dotenv.env['MONGODB_URI'];
      if (dbUri == null || dbUri.isEmpty) {
        throw Exception("MONGODB_URI tidak ditemukan di .env");
      }

      await LogHelper.writeLog(
        "DATABASE: Mencoba koneksi ke MongoDB...",
        source: _source,
        level: 2,
      );

      _db = await Db.create(dbUri);

      // Timeout 15 detik agar lebih toleran terhadap jaringan seluler
      await _db!.open().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
            "Koneksi Timeout (15s). Cek:\n1. IP Whitelist (0.0.0.0/0)\n2. Sinyal/Internet\n3. MONGODB_URI di .env",
          );
        },
      );

      _collection = _db!.collection('logs');

      await LogHelper.writeLog(
        "DATABASE: Terhubung & Koleksi Siap ✓",
        source: _source,
        level: 2,
      );
    } catch (e) {
      _db = null;
      _collection = null;
      
      // Error detection & friendly message
      if (e is SocketException || e.toString().contains('Connection refused')) {
        await LogHelper.writeLog(
          "OFFLINE: Koneksi internet gagal - $e",
          source: _source,
          level: 1,
        );
        throw OfflineException(
          message: e.toString(),
          userFriendlyMessage: '❌ Internet terputus atau server tidak dapat dijangkau.',
        );
      } else if (e.toString().contains('timeout')) {
        await LogHelper.writeLog(
          "TIMEOUT: Koneksi lambat - $e",
          source: _source,
          level: 1,
        );
        throw TimeoutException(
          message: e.toString(),
          userFriendlyMessage: '⏱️ Koneksi sangat lambat. Periksa sinyal atau pindah lokasi.',
        );
      } else if (e.toString().contains('authentication') || e.toString().contains('unauthorized')) {
        await LogHelper.writeLog(
          "AUTH ERROR: Database authentication failed - $e",
          source: _source,
          level: 1,
        );
        throw AuthException(
          message: e.toString(),
          userFriendlyMessage: '🔒 Autentikasi database gagal. Hubungi guru.',
        );
      } else {
        await LogHelper.writeLog(
          "DATABASE: Gagal Koneksi - $e",
          source: _source,
          level: 1,
        );
        throw ServerException(
          message: e.toString(),
          userFriendlyMessage: '⚠️ Server MongoDB error.',
        );
      }
    } finally {
      _isConnecting = false;
    }
  }

  /// READ: Mengambil data dari Cloud
  Future<List<LogModel>> getLogs() async {
    try {
      final collection = await _getSafeCollection(); // Gunakan jalur aman

      await LogHelper.writeLog(
        "INFO: Fetching data from Cloud...",
        source: _source,
        level: 3,
      );

      final List<Map<String, dynamic>> data = await collection.find().toList();
      return data.map((json) => LogModel.fromMap(json)).toList();
    } on OfflineException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on ServerException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Fetch Failed - $e",
        source: _source,
        level: 1,
      );
      
      // Detect error type
      if (e.toString().contains('connection')) {
        throw OfflineException(message: e.toString());
      } else if (e.toString().contains('timeout')) {
        throw TimeoutException(message: e.toString());
      }
      
      throw ServerException(message: e.toString());
    }
  }

  /// CREATE: Menambahkan data baru
  Future<void> insertLog(LogModel log) async {
    try {
      final collection = await _getSafeCollection();
      await collection.insertOne(log.toMap());

      await LogHelper.writeLog(
        "SUCCESS: Data '${log.title}' Saved to Cloud",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Insert Failed - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  /// UPDATE: Memperbarui data berdasarkan ID
  Future<void> updateLog(LogModel log) async {
    try {
      final collection = await _getSafeCollection();
      if (log.id == null)
        throw Exception("ID Log tidak ditemukan untuk update");

      await collection.replaceOne(where.id(log.id!), log.toMap());

      await LogHelper.writeLog(
        "DATABASE: Update '${log.title}' Berhasil",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "DATABASE: Update Gagal - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  /// DELETE: Menghapus dokumen
  Future<void> deleteLog(ObjectId id) async {
    try {
      final collection = await _getSafeCollection();
      await collection.remove(where.id(id));

      await LogHelper.writeLog(
        "DATABASE: Hapus ID $id Berhasil",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "DATABASE: Hapus Gagal - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      _db = null;
      _collection = null;
      await LogHelper.writeLog(
        "DATABASE: Koneksi ditutup",
        source: _source,
        level: 2,
      );
    }
  }
}
