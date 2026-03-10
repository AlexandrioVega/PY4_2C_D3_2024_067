import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';
import 'package:logbook_app_067/features/logbook/log_controller.dart';


class LogEditorPage extends StatefulWidget {
  final LogModel? log;       // null = mode tambah, tidak null = mode edit
  final String? logId;       // ID log yang akan diedit
  final LogController controller;
  final Map<String, String> currentUser;

  const LogEditorPage({
    super.key,
    this.log,
    this.logId,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String _selectedCategory = 'Pribadi';
  bool _isPublic = false; 
  bool _isSaving = false;

  bool get _isEditMode => widget.log != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(
      text: widget.log?.description ?? '',
    );
    if (_isEditMode) {
      _selectedCategory = widget.log!.category;
      _isPublic = widget.log!.isPublic; 
    }


    _descController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Judul dan isi tidak boleh kosong!"),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (!_isEditMode) {
        await widget.controller.addLog(
          title,
          desc,
          widget.currentUser['uid']!,
          widget.currentUser['teamId']!,
          category: _selectedCategory,
          isPublic: _isPublic, 
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("✅ Catatan berhasil disimpan!"),
              backgroundColor: Colors.green.shade600,
            ),
          );
        }
      } else {
        await widget.controller.updateLogById(
          widget.log!.id!,
          title,
          desc,
          category: _selectedCategory,
          isPublic: _isPublic,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("✅ Catatan berhasil diperbarui!"),
              backgroundColor: Colors.blue.shade600,
            ),
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Gagal menyimpan: $e"),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? "Edit Catatan" : "Catatan Baru"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.edit), text: "Editor"),
              Tab(icon: Icon(Icons.preview), text: "Pratinjau"),
            ],
          ),
          actions: [
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save),
                    tooltip: "Simpan",
                    onPressed: _save,
                  ),
          ],
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Judul Catatan",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Kategori",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: ['Pribadi', 'Pekerjaan', 'Urgent']
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // [Task 5] Toggle Privacy Setting
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Bagikan dengan Tim?",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _isPublic
                                  ? "Catatan ini terlihat untuk semua anggota tim"
                                  : "Hanya Anda yang bisa melihat catatan ini",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isPublic,
                          onChanged: (newValue) {
                            setState(() => _isPublic = newValue);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Hint Markdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: const Text(
                      "💡 Markdown: **bold**, *italic*, # Judul, `kode`, - list",
                      style: TextStyle(fontSize: 12, color: Colors.brown),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Area Teks (Flexibel)
                  Expanded(
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: "Tulis laporan dengan format Markdown...\n\n# Contoh\n**Tebal**, *miring*, `kode`",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _descController.text.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.preview, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "Belum ada teks untuk ditampilkan.\nMulai ketik di tab Editor.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Markdown(
                    data: _descController.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      code: TextStyle(
                        backgroundColor: Colors.grey.shade200,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isEditMode ? "Perbarui Catatan" : "Simpan Catatan"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}