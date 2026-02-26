import 'package:flutter/material.dart';
import 'package:logbook_app_067/features/logbook/log_controller.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';

/// Widget untuk menampilkan satu item catatan dalam list
class LogItemCard extends StatelessWidget {
  final LogModel log;
  final int index;
  final LogController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LogItemCard({
    Key? key,
    required this.log,
    required this.index,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: controller.getCategoryColor(log.category),
      child: ListTile(
        leading: Icon(controller.getCategoryIcon(log.category)),
        title: Text(log.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.description),
            const SizedBox(height: 4),
            Text(
              log.date,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Wrap(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan state kosong (tidak ada catatan)
class LogEmptyState extends StatelessWidget {
  const LogEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/empty.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada catatan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Mulai buat catatan baru dengan menekan tombol +",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
