import 'package:flutter_dotenv/flutter_dotenv.dart';

/// [Task 3 - RBAC Gatekeeper]
/// Centralized Security Policy — semua logika izin dipusatkan di sini.
/// Mengikuti prinsip Open-Closed: mudah ditambah rule baru tanpa ubah UI.
class AccessControlService {
  // Mengambil roles dari .env di root
  static List<String> get availableRoles =>
      dotenv.env['APP_ROLES']?.split(',') ?? ['Anggota'];

  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  // Matrix perizinan yang tetap fleksibel
  static final Map<String, List<String>> _rolePermissions = {
    'Ketua': [actionCreate, actionRead, actionUpdate, actionDelete],
    'Anggota': [actionCreate, actionRead],
    'Asisten': [actionRead, actionUpdate],
  };

  /// Cek apakah [role] boleh melakukan [action].
  /// [isOwner] = true jika user adalah pemilik data (authorId == currentUserId).
  /// 
  /// [Task 5 - Data Privacy & Sovereignty]:
  /// Edit dan Delete HANYA untuk owner, regardless of role.
  /// Ini memastikan data privacy: even Ketua (team lead) tidak bisa edit/delete logs orang lain.
  static bool canPerform(String role, String action, {bool isOwner = false}) {
    // Edit dan Delete hanya untuk owner (strict ownership-based), bukan role-based
    if (action == actionUpdate || action == actionDelete) {
      return isOwner;
    }

    // Untuk action lain (create, read), gunakan role-based permissions
    final permissions = _rolePermissions[role] ?? [];
    return permissions.contains(action);
  }
}