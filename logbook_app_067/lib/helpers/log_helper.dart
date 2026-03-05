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
      Directory? targetDir;
      
      // Strategy 1: Coba relative path 'logs' (untuk flutter test)
      try {
        final relativeDir = Directory('logs');
        if (!relativeDir.existsSync()) {
          relativeDir.createSync(recursive: true);
        }
        
        final logFile = File('logs/$dateForFile.log');
        await logFile.writeAsString('$logMessage\n', mode: FileMode.append);
        return; // Success!
      } catch (e) {
        print('[LOG_WARNING] Relative path gagal: $e');
      }
      
      // Strategy 2: Coba absolute path project (Windows)
      try {
        final absolutePath = 'c:\\PY4_2C_D3_2024_067\\logbook_app_067\\logs';
        final absDir = Directory(absolutePath);
        if (!absDir.existsSync()) {
          absDir.createSync(recursive: true);
        }
        
        final logFile = File('$absolutePath\\$dateForFile.log');
        await logFile.writeAsString('$logMessage\n', mode: FileMode.append);
        print('[LOG_INFO] Logs ditulis ke: $absolutePath');
        return; // Success!
      } catch (e) {
        print('[LOG_WARNING] Absolute path gagal: $e');
      }
      
      // Strategy 3: Coba temp directory
      try {
        final tempDir = Directory.systemTemp;
        final logsDir = Directory('${tempDir.path}/logbook_logs');
        if (!logsDir.existsSync()) {
          logsDir.createSync(recursive: true);
        }
        
        final logFile = File('${logsDir.path}/$dateForFile.log');
        await logFile.writeAsString('$logMessage\n', mode: FileMode.append);
        print('[LOG_INFO] Logs ditulis ke temp: ${logsDir.path}');
        return; // Success!
      } catch (e) {
        print('[LOG_ERROR] Semua path gagal: $e');
      }
      
    } catch (e) {
      print('[LOG_ERROR] File write error: $e');
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
