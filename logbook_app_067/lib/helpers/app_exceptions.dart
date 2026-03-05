class OfflineException implements Exception {
  final String message;
  final String userFriendlyMessage;
  
  OfflineException({
    required this.message,
    this.userFriendlyMessage = 'Internet tidak tersedia. Periksa WiFi atau Mobile Data Anda.',
  });

  @override
  String toString() => message;
}

class TimeoutException implements Exception {
  final String message;
  final String userFriendlyMessage;
  
  TimeoutException({
    required this.message,
    this.userFriendlyMessage = 'Koneksi sangat lambat (timeout 15 detik). Coba lagi atau pindah ke lokasi dengan sinyal lebih baik.',
  });

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  final String userFriendlyMessage;
  
  ServerException({
    required this.message,
    this.userFriendlyMessage = 'Server MongoDB tidak merespons. Hubungi guru untuk verifikasi koneksi.',
  });

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  final String userFriendlyMessage;
  
  AuthException({
    required this.message,
    this.userFriendlyMessage = 'Authentication gagal. Verifikasi MONGODB_URI di .env.',
  });

  @override
  String toString() => message;
}
