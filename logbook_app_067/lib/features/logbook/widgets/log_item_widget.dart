import 'package:flutter/material.dart';
import 'package:logbook_app_067/features/logbook/log_controller.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';
import 'package:logbook_app_067/helpers/app_exceptions.dart';
import 'package:logbook_app_067/helpers/datetime_helper.dart';

/// Widget untuk menampilkan satu item catatan dalam list dengan Dismissible
class LogItemCard extends StatelessWidget {
  final LogModel log;
  final LogController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LogItemCard({
    Key? key,
    required this.log,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
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
        ) ?? false;
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: Icon(
            controller.getCategoryIcon(log.category),
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
                    backgroundColor: controller.getCategoryColor(log.category),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                  const SizedBox(width: 8),
                  LogTimestamp(dateString: log.date),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
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
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
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
  }
}

/// Widget untuk menampilkan state kosong (tidak ada catatan)
class LogEmptyState extends StatelessWidget {
  final VoidCallback onCreateFirst;

  const LogEmptyState({
    Key? key,
    required this.onCreateFirst,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Data Kosong",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Belum ada catatan di Cloud.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onCreateFirst,
              child: const Text("Buat Catatan Pertama"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan state search kosong
class LogFilterEmptyState extends StatelessWidget {
  final String searchQuery;

  const LogFilterEmptyState({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "Tidak Ada Hasil",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada catatan dengan judul "$searchQuery"',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Widget untuk menampilkan state loading
class LogLoadingState extends StatelessWidget {
  const LogLoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
/// Widget untuk menampilkan timestamp dengan format relatif atau absolut
/// Contoh: "2 menit yang lalu" atau "25 Jan 2026"
class LogTimestamp extends StatelessWidget {
  final String dateString;
  final TextStyle? style;

  const LogTimestamp({
    Key? key,
    required this.dateString,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateTimeHelper.formatRelativeTime(dateString);
    
    return Text(
      formattedTime,
      style: style ?? const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }
}