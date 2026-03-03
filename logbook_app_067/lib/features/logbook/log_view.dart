import 'package:flutter/material.dart';
import 'package:logbook_app_067/features/logbook/log_controller.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';
import 'package:logbook_app_067/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_067/helpers/log_helper.dart';
import 'package:logbook_app_067/services/mongo_service.dart';

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
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Menghubungkan ke MongoDB Atlas..."),
                      ],
                    ),
                  );
                }

                // Error State
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          "Error: ${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshDataFromCloud,
                          child: const Text("Coba Lagi"),
                        ),
                      ],
                    ),
                  );
                }
                final allLogs = snapshot.data ?? [];
                final filteredLogs = _getFilteredLogs(allLogs);
                if (allLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text("Data Kosong: Belum ada catatan di Cloud."),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _showAddLogDialog,
                          child: const Text("Buat Catatan Pertama"),
                        ),
                      ],
                    ),
                  );
                }
                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada catatan dengan judul "${_searchController.text}"',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
                      final originalIndex = allLogs.indexOf(log);
                      
                      return Dismissible(
                        key: Key(log.id.toString()),
                        direction: DismissDirection.endToStart, 
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        onDismissed: (direction) async {
                          try {
                            await _controller.syncFromCloud();
                            await _controller.removeLogById(log.id!);
                            _showSnackBar(
                              message: "Catatan '${log.title}' berhasil dihapus",
                              color: Colors.red,
                              icon: Icons.delete_outline,
                            );
                            await Future.delayed(const Duration(milliseconds: 500));
                            _refreshDataFromCloud();
                          } catch (e) {
                            _showSnackBar(
                              message: "Error hapus: $e",
                              color: Colors.red,
                              icon: Icons.error,
                            );
                          }
                        },
                        confirmDismiss: (direction) {
                          return showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Hapus Catatan?"),
                                content: Text(
                                  'Apakah Anda yakin ingin menghapus "${log.title}"?\n\nData ini akan dihapus dari Cloud secara permanen.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              _controller.getCategoryIcon(log.category),
                              color: Colors.blue,
                            ),
                            title: Text(log.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                        log.category,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      backgroundColor: _controller.getCategoryColor(log.category),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      log.date.split(' ')[0],
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditLogDialog(originalIndex, log),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Hapus Catatan?"),
                                        content: Text(
                                          'Apakah Anda yakin ingin menghapus "${log.title}"?\n\nData ini akan dihapus dari Cloud secara permanen.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
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
                                            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                ),
                              ],
                            ),
                          ),
                        ),
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