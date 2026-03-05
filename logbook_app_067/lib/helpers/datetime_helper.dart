import 'package:intl/intl.dart';

class DateTimeHelper {
  static String formatRelativeTime(String dateString) {
    try {
      final datetime = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(datetime);

      if (diff.inMinutes < 1) {
        return "Baru saja";
      }

      if (diff.inMinutes < 60) {
        if (diff.inMinutes == 1) {
          return "1 menit yang lalu";
        }
        return "${diff.inMinutes} menit yang lalu";
      }

      if (diff.inHours < 24) {
        if (diff.inHours == 1) {
          return "1 jam yang lalu";
        }
        return "${diff.inHours} jam yang lalu";
      }

      if (diff.inDays < 7) {
        if (diff.inDays == 1) {
          return "Kemarin";
        }
        return "${diff.inDays} hari yang lalu";
      }

      return formatAbsoluteDateIndonesia(dateString);
    } catch (e) {
      return "Tanggal tidak valid";
    }
  }

  static String formatAbsoluteDateIndonesia(String dateString) {
    try {
      final datetime = DateTime.parse(dateString);
      try {
        return DateFormat('d MMM yyyy', 'id_ID').format(datetime);
      } catch (e) {
        return DateFormat('d MMM yyyy').format(datetime);
      }
    } catch (e) {
      return dateString;
    }
  }

  static String formatFullDateTimeIndonesia(String dateString) {
    try {
      final datetime = DateTime.parse(dateString);
      try {
        return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(datetime);
      } catch (e) {
        return DateFormat('d MMM yyyy, HH:mm').format(datetime);
      }
    } catch (e) {
      return dateString;
    }
  }

  static String formatTimeOnly(String dateString) {
    try {
      final datetime = DateTime.parse(dateString);
      return DateFormat('HH:mm').format(datetime);
    } catch (e) {
      return dateString;
    }
  }
}
