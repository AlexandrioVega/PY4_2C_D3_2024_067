import 'package:flutter/material.dart';
import 'package:logbook_app_067/features/logbook/log_controller.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';
import 'package:logbook_app_067/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_067/helpers/log_helper.dart';
import 'package:logbook_app_067/helpers/app_exceptions.dart';
import 'package:logbook_app_067/services/mongo_service.dart';
import 'package:logbook_app_067/features/logbook/widgets/log_item_widget.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});
  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController(); // Filter berdasarkan judul
  String _selectedCategory = 'Pribadi';
  late GlobalKey<RefreshIndicatorState> _refreshKey;
  late Future<List<LogModel>> _futureLogsFromCloud; // ✅ Future sebagai state variable

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    _controller.logsNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = LogController(widget.username);
    _refreshKey = GlobalKey<RefreshIndicatorState>();
    _futureLogsFromCloud = _fetchLogsFromCloud(); 
  }

  Future<List<LogModel>> _fetchLogsFromCloud() async {
    try {
      await LogHelper.writeLog(
        "UI: Memulai fetch data dari Cloud...",
        source: "log_view.dart",
        level: 3,
      );

      // Koneksi ke MongoDB Atlas jika belum terhubung
      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          "Koneksi Cloud Timeout. Periksa sinyal/IP Whitelist.",
        ),
      );

      await LogHelper.writeLog(
        "UI: Koneksi MongoService BERHASIL.",
        source: "log_view.dart",
        level: 2,
      );

      final logs = await MongoService().getLogs();

      await LogHelper.writeLog(
        "UI: Data berhasil dimuat dari Cloud (${logs.length} logs).",
        source: "log_view.dart",
        level: 2,
      );

      return logs;
    } catch (e) {
      await LogHelper.writeLog(
        "UI: Error fetch dari Cloud - $e",
        source: "log_view.dart",
        level: 1,
      );
      rethrow;
    }
  }
  void _refreshDataFromCloud() {
    if (mounted) {
      setState(() {
        _futureLogsFromCloud = _fetchLogsFromCloud(); 
      });
    }
  }

  void _showAddLogDialog() {
    _selectedCategory = 'Pribadi';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Catatan Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Judul Catatan"),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: "Isi Deskripsi"),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: ['Pekerjaan', 'Pribadi', 'Urgent']
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
          ],
        ),
        
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text.trim();
              final desc = _contentController.text.trim();

              if (title.isEmpty || desc.isEmpty) {
                _showSnackBar(
                  message :"Judul dan Deskripsi tidak boleh kosong!",
                  color : Colors.red,
                  icon : Icons.error,
                );
                return;
              }
              _controller.addLog(
                _titleController.text, 
                _contentController.text,
                _selectedCategory,
              );

              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
              
              _refreshDataFromCloud();
              
              _showSnackBar(
                  message :"Catatan berhasil disimpan",
                  color : Colors.green,
                  icon : Icons.check_circle,
              );
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
    
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    _selectedCategory = log.category;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            TextField(controller: _contentController),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: ['Pekerjaan', 'Pribadi', 'Urgent']
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _selectedCategory = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final title = _titleController.text.trim();
              final desc = _contentController.text.trim();

              if (title.isEmpty || desc.isEmpty) {
                _showSnackBar(
                  message :"Judul dan Deskripsi tidak boleh kosong!",
                  color : Colors.red,
                  icon : Icons.error,
                );
                return;
              }
              
              try {
                await _controller.syncFromCloud();
                await _controller.updateLogById(
                  log.id!,
                  title,
                  desc,
                  _selectedCategory,
                );
                
                _titleController.clear();
                _contentController.clear();
                Navigator.pop(context);
                _refreshDataFromCloud();
                
                _showSnackBar(
                  message: "Catatan berhasil diupdate",
                  color: Colors.green,
                  icon: Icons.check_circle,
                );
              } catch (e) {
                _showSnackBar(
                  message: "Error: $e",
                  color: Colors.red,
                  icon: Icons.error,
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  List<LogModel> _getFilteredLogs(List<LogModel> allLogs) {
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isEmpty) {
      return allLogs;
    }
    return allLogs
        .where((log) => log.title.toLowerCase().contains(searchQuery))
        .toList();
  }

  Widget _buildErrorWidget(Object? error) {
    late String title;
    late String message;
    late IconData icon;
    late Color backgroundColor;
    late Function() onRetry;

    if (error is OfflineException) {
      title = "Internet Terputus";
      message = error.userFriendlyMessage;
      icon = Icons.wifi_off;
      backgroundColor = Colors.orange;
      onRetry = _refreshDataFromCloud;
    } else if (error is TimeoutException) {
      title = "Koneksi Lambat";
      message = error.userFriendlyMessage;
      icon = Icons.schedule;
      backgroundColor = Colors.amber;
      onRetry = _refreshDataFromCloud;
    } else if (error is AuthException) {
      title = "Autentikasi Gagal";
      message = error.userFriendlyMessage;
      icon = Icons.lock_outlined;
      backgroundColor = Colors.red;
      onRetry = _refreshDataFromCloud;
    } else if (error is ServerException) {
      title = "Server Error";
      message = error.userFriendlyMessage;
      icon = Icons.cloud_off;
      backgroundColor = Colors.red;
      onRetry = _refreshDataFromCloud;
    } else {
      title = "Terjadi Kesalahan";
      message = "Error: $error\n\nCoba lagi atau hubungi guru";
      icon = Icons.error_outline;
      backgroundColor = Colors.red;
      onRetry = _refreshDataFromCloud;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big Icon dengan background circle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: backgroundColor,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Retry button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: const Text(
                  "Coba Lagi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tips button
            TextButton.icon(
              onPressed: () => _showConnectionTips(context),
              icon: const Icon(Icons.info_outline),
              label: const Text("Tips Perbaikan"),
            ),
          ],
        ),
      ),
    );
  }

  /// Show helpful tips untuk fix koneksi
  void _showConnectionTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tips Perbaikan Koneksi"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(height: 12),
              Text(
                "📱 Koneksi Internet:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("• Aktifkan WiFi atau Mobile Data"),
              Text("• Pindah ke area dengan sinyal lebih baik"),
              Text("• Coba restart internet router/modem"),
              SizedBox(height: 16),
              Text(
                "🌐 MongoDB Whitelist:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("• Hubungi guru untuk add IP ke whitelist"),
              Text("• Format: 0.0.0.0/0 (allow all)"),
              SizedBox(height: 16),
              Text(
                "⚙️ Verifikasi Setup:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("• Cek .env: MONGODB_URI sudah benar"),
              Text("• Restart aplikasi"),
              Text("• Cek kembali internet status"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Mengerti"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text("Apakah Anda yakin? Data yang belum disimpan mungkin akan hilang."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); 
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const OnboardingView()),
                            (route) => false,
                          );
                        },
                        child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: "Cari berdasarkan judul...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // FutureBuilder untuk fetch dan tampilkan data dari Cloud
          Expanded(
            child: FutureBuilder<List<LogModel>>(
              future: _futureLogsFromCloud,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LogLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error);
                }

                final allLogs = snapshot.data ?? [];
                final filteredLogs = _getFilteredLogs(allLogs);

                if (allLogs.isEmpty) {
                  return LogEmptyState(
                    onCreateFirst: _showAddLogDialog,
                  );
                }

                if (filteredLogs.isEmpty) {
                  return LogFilterEmptyState(
                    searchQuery: _searchController.text,
                  );
                }

                return RefreshIndicator(
                  key: _refreshKey,
                  onRefresh: () async {
                    _refreshDataFromCloud();
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return LogItemCard(
                        log: log,
                        controller: _controller,
                        onEdit: () => _showEditLogDialog(0, log),
                        onDelete: () async {
                          try {
                            await _controller.syncFromCloud();
                            await _controller.removeLogById(log.id!);
                            _refreshDataFromCloud();
                            _showSnackBar(
                              message: "Catatan '${log.title}' berhasil dihapus",
                              color: Colors.red,
                              icon: Icons.delete_outline,
                            );
                          } catch (e) {
                            _showSnackBar(
                              message: "Error hapus: $e",
                              color: Colors.red,
                              icon: Icons.error,
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }}