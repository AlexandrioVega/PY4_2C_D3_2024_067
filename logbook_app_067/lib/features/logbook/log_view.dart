import 'package:flutter/material.dart';
import 'package:logbook_app_067/features/logbook/log_controller.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';
import 'package:logbook_app_067/features/logbook/widgets/log_item_widget.dart';
import 'package:logbook_app_067/features/onboarding/onboarding_view.dart';

class LogView extends StatefulWidget {
  final String username;

  // Update Constructor agar mewajibkan (required) kiriman nama
  const LogView({super.key, required this.username});
  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = 'Pribadi'; 

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _controller.logsNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = LogController(widget.username);
    _controller.init();
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
                  try {
                    _selectedCategory = value;
                  } catch (e) {
                  }
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
              // Jalankan fungsi tambah di Controller
              _controller.addLog(
                _titleController.text, 
                _contentController.text,
                _selectedCategory,
              );

              // Bersihkan input dan tutup dialog
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
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
              _controller.updateLog(index, _titleController.text, _contentController.text, _selectedCategory);
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
              _showSnackBar(
                  message :"Catatan berhasil disimpan",
                  color : Colors.green,
                  icon : Icons.check_circle,
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  
  // untuk memunculkan snackbar 
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
      body: ValueListenableBuilder<List<LogModel>>(
        valueListenable: _controller.filteredLogs,
        builder: (context, currentLogs, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) => _controller.searchLog(value),
                  decoration: const InputDecoration(
                    labelText: "Cari Catatan...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: currentLogs.isEmpty
                    ? const LogEmptyState()
                    : ListView.builder(
                      itemCount: currentLogs.length,
                      itemBuilder: (context, index) {
                        final log = currentLogs[index];
                        return Dismissible(
                          key: Key(log.date),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            _controller.removeLog(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Catatan dihapus")),
                            );
                          },
                          child: LogItemCard(
                            log: log,
                            index: index,
                            controller: _controller,
                            onEdit: () => _showEditLogDialog(index, log),
                            onDelete: () => _controller.removeLog(index),
                          ),
                        );
                      },
                    ),
              ),
            ],
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
