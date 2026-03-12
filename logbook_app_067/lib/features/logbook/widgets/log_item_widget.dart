import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: controller.getCategoryColor(log.category),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(controller.getCategoryIcon(log.category),
                        color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        log.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    log.id != null ? Icons.cloud_done : Icons.cloud_upload_outlined,
                    size: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: controller.getCategoryColor(log.category).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    controller.getCategoryIcon(log.category),
                    color: controller.getCategoryColor(log.category),
                    size: 28,
                  ),
                ),
              ),
              title: Text(
                log.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    log.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        LogTimestamp(dateString: log.date),
                        const SizedBox(width: 8),
                        if (log.isPublic)
                          Tooltip(
                            message: "Dibagikan dengan tim",
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                  Text("Public",
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
                            message: "Hanya untuk Anda",
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                  Text("Private",
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
                      icon: Icon(Icons.edit,
                        color: controller.getCategoryColor(log.category)),
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
                                child: const Text("Hapus",
                                  style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 280,
                child: SvgPicture.asset(
                  'assets/images/empty_clipboard.svg',
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    Colors.blue.shade300,
                    BlendMode.srcIn,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Belum ada catatan hari ini?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
              ),

              const SizedBox(height: 12),

              Text(
                'Mulai catat kemajuan proyek Anda sekarang dan lihat perkembangan tim dalam satu tempat!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: onCreateFirst,
                icon: const Icon(Icons.add),
                label: const Text('Buat Catatan Pertama'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class LogFilterEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const LogFilterEmptyState({
    Key? key,
    required this.searchQuery,
    this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 240,
                child: SvgPicture.asset(
                  'assets/images/search_not_found.svg',
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    Colors.orange.shade300,
                    BlendMode.srcIn,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Tidak ada hasil pencarian',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
              ),

              const SizedBox(height: 12),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                  children: [
                    const TextSpan(text: 'Tidak menemukan catatan dengan kata kunci '),
                    TextSpan(
                      text: '"$searchQuery"',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const TextSpan(text: '.\n\nCoba kata kunci lain atau lihat semua catatan.'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              if (onClearSearch != null)
                OutlinedButton.icon(
                  onPressed: onClearSearch,
                  icon: const Icon(Icons.clear),
                  label: const Text('Hapus Pencarian'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
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