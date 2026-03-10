import 'package:flutter/material.dart';
import 'package:logbook_app_067/features/logbook/log_controller.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';
import 'package:logbook_app_067/helpers/datetime_helper.dart';

class LogItemCard extends StatelessWidget {
  final LogModel log;
  final LogController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool canEdit;    
  final bool canDelete;  

  const LogItemCard({
    Key? key,
    required this.log,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
    this.canEdit = true,
    this.canDelete = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(log.id.toString()),
      direction: canDelete
          ? DismissDirection.endToStart
          : DismissDirection.none, 
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        if (!canDelete) return false;
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Hapus Catatan?"),
                content: Text(
                  'Apakah Anda yakin ingin menghapus "${log.title}"?\n\nData ini akan dihapus dari Cloud secara permanen.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("Batal",
                        style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("Hapus",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          leading: Stack(
            children: [
              Icon(
                controller.getCategoryIcon(log.category),
                color: Colors.blue,
                size: 28,
              ),

              Positioned(
                right: 0,
                bottom: 0,
                child: Icon(
                  log.id != null
                      ? Icons.cloud_done
                      : Icons.cloud_upload_outlined,
                  size: 12,
                  color: log.id != null ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          title: Text(
            log.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: controller.getCategoryColor(log.category),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        log.category,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                    LogTimestamp(dateString: log.date),
                    const SizedBox(width: 8),
                    // [Task 5] Indikator privacy status
                    if (log.isPublic)
                      Tooltip(
                        message: "Catatan ini dibagikan dengan tim",
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            border: Border.all(color: Colors.blue.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.public, size: 10, color: Colors.blue.shade700),
                              const SizedBox(width: 3),
                              Text(
                                "Public",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Tooltip(
                        message: "Catatan ini hanya untuk Anda",
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock, size: 10, color: Colors.grey.shade700),
                              const SizedBox(width: 3),
                              Text(
                                "Private",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Indikator kepemilikan
                    if (log.authorId.isNotEmpty)
                      Text(
                        "· ${log.authorId}",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: "Edit Catatan",
                )
              else
                const SizedBox(width: 8),

              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: "Hapus Catatan",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Hapus Catatan?"),
                        content: Text(
                          'Apakah Anda yakin ingin menghapus "${log.title}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Batal"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDelete();
                            },
                            child: const Text(
                              "Hapus",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
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

class LogEmptyState extends StatelessWidget {
  final VoidCallback onCreateFirst;

  const LogEmptyState({Key? key, required this.onCreateFirst})
      : super(key: key);

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
              "Belum ada catatan di Cloud.\nMulai dokumentasikan aktivitasmu!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreateFirst,
              icon: const Icon(Icons.add),
              label: const Text("Buat Catatan Pertama"),
            ),
          ],
        ),
      ),
    );
  }
}


class LogFilterEmptyState extends StatelessWidget {
  final String searchQuery;

  const LogFilterEmptyState({Key? key, required this.searchQuery})
      : super(key: key);

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


class LogTimestamp extends StatelessWidget {
  final String dateString;
  final TextStyle? style;

  const LogTimestamp({Key? key, required this.dateString, this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      DateTimeHelper.formatRelativeTime(dateString),
      style: style ??
          const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }
}