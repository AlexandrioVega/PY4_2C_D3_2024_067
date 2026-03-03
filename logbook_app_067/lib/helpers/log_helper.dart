import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown", // Menandakan file/proses asal
    int level = 2,
  }) async {
    try {
      // 1. Filter Konfigurasi (ENV)
      final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
      final String muteList = dotenv.env['LOG_MUTE'] ?? '';

      if (level > configLevel) return;
      if (muteList.split(',').contains(source)) return;

      // 2. Format Waktu untuk Konsol & File (Simple format tanpa intl)
      final now = DateTime.now();
      String timestamp = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      String dateForFile = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      String label = _getLabel(level);
      String color = _getColor(level);
      String logMessage = '[$timestamp][$label][$source] -> $message';

      // 3. Output ke VS Code Debug Console (Non-blocking)
      dev.log(message, name: source, time: now, level: level * 100);

      // 4. Output ke Terminal (Agar Bapak bisa lihat di PC saat flutter run)
      // Format: [14:30:05] [INFO] [log_view.dart] -> Database Terhubung
      print('$color$logMessage\x1B[0m');

      // 5. Output ke File (dd-mm-yyyy.log)
      await _writeToFile(dateForFile, logMessage);
    } catch (e) {
      try {
        dev.log("Logging failed: $e", name: "SYSTEM", level: 1000);
      } catch (_) {
        // Silent fail jika dev.log juga gagal
      }
    }
  }

  /// Fungsi helper untuk menulis ke file log
  static Future<void> _writeToFile(String dateForFile, String logMessage) async {
    try {
      // Dapatkan path untuk folder logs
      final appDir = Directory('logs');
      
      // Buat folder jika belum ada
      if (!appDir.existsSync()) {
        appDir.createSync(recursive: true);
      }

      // Buat file dengan nama dd-mm-yyyy.log
      final logFile = File('logs/$dateForFile.log');
      
      // Append message ke file
      await logFile.writeAsString(
        '$logMessage\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // Silent fail untuk file writing
      dev.log("Failed to write log file: $e", name: "SYSTEM", level: 1000);
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return "ERROR";
      case 2:
        return "INFO";
      case 3:
        return "VERBOSE";
      default:
        return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m'; // Merah
      case 2:
        return '\x1B[32m'; // Hijau
      case 3:
        return '\x1B[34m'; // Biru
      default:
        return '\x1B[0m';
    }
  }
}
