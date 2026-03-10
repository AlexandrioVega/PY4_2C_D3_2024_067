import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logbook_app_067/features/logbook/log_controller.dart';
import 'package:logbook_app_067/features/logbook/log_editor_page.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';
import 'package:logbook_app_067/features/logbook/widgets/log_item_widget.dart';
import 'package:logbook_app_067/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_067/helpers/log_helper.dart';
import 'package:logbook_app_067/services/access_control_service.dart';

class LogView extends StatefulWidget {
  final Map<String, String> currentUser; 
  const LogView({super.key, required this.currentUser});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  final TextEditingController _searchController = TextEditingController();
  
  
  bool _isOnline = true;
  late final Stream<List<ConnectivityResult>> _connectivityStream;

  String get _currentRole => widget.currentUser['role'] ?? 'Anggota';
  String get _currentUid => widget.currentUser['uid'] ?? '';
  String get _currentTeamId => widget.currentUser['teamId'] ?? '';
  String get _currentUsername => widget.currentUser['username'] ?? '';

  @override
  void initState() {
    super.initState();
    _controller = LogController(
      userRole: _currentRole,
      userId: _currentUid,
    );

    
    _controller.loadLogs(_currentTeamId);

    
    _connectivityStream = Connectivity().onConnectivityChanged;
    _connectivityStream.listen((results) async {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (mounted) {
        setState(() => _isOnline = online);
      }

      
      if (online && mounted) {
        await LogHelper.writeLog(
          "CONNECTIVITY: Internet aktif — memulai background sync",
          source: "log_view.dart",
          level: 2,
        );
        await _controller.syncFromCloud(_currentTeamId);
      }
    });

    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  
  List<LogModel> _getFilteredLogs(List<LogModel> allLogs) {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return allLogs;
    return allLogs
        .where((log) => log.title.toLowerCase().contains(query))
        .toList();
  }

  
  List<LogModel> _getVisibleLogs(List<LogModel> allLogs) {
    return allLogs
        .where((log) =>
            log.authorId == _currentUid || 
            log.isPublic) 
        .toList();
  }

  
  void _goToEditor({LogModel? log}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogEditorPage(
          log: log,
          logId: log?.id,
          controller: _controller,
          currentUser: widget.currentUser,
        ),
      ),
    ).then((_) {
      
      _controller.loadLogs(_currentTeamId);
    });
  }

  void _showSnackBar({
    required String message,
    Color color = Colors.green,
    IconData icon = Icons.check_circle,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Logbook: $_currentUsername"),
            Text(
              "Role: $_currentRole · Tim: $_currentTeamId",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Tooltip(
            message: _isOnline ? "Online — tersinkron" : "Offline — data lokal",
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                _isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: _isOnline ? Colors.green : Colors.orange,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh dari Cloud",
            onPressed: () => _controller.loadLogs(_currentTeamId),
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Konfirmasi Logout"),
                  content: const Text(
                    "Apakah Anda yakin ingin keluar? Data yang belum tersinkron mungkin akan hilang.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const OnboardingView(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Ya, Keluar",
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

      body: Column(
        children: [
          if (!_isOnline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    "Mode Offline — Data tersimpan lokal, akan sinkron saat online.",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.logsNotifier,
              builder: (context, allLogs, _) {
                final visibleLogs = _getVisibleLogs(allLogs);
                final filteredLogs = _getFilteredLogs(visibleLogs);

                if (allLogs.isEmpty) {
                  return LogEmptyState(onCreateFirst: () => _goToEditor());
                }

                if (filteredLogs.isEmpty) {
                  return LogFilterEmptyState(
                    searchQuery: _searchController.text,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _controller.loadLogs(_currentTeamId),
                  child: ListView.builder(
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      final bool isOwner = log.authorId == _currentUid;
                      final bool canEdit = AccessControlService.canPerform(
                        _currentRole,
                        AccessControlService.actionUpdate,
                        isOwner: isOwner,
                      );
                      final bool canDelete = AccessControlService.canPerform(
                        _currentRole,
                        AccessControlService.actionDelete,
                        isOwner: isOwner,
                      );

                      return LogItemCard(
                        log: log,
                        controller: _controller,
                        canEdit: canEdit,
                        canDelete: canDelete,
                        onEdit: () => _goToEditor(log: log),
                        onDelete: () async {
                          try {
                            await _controller.removeLogById(log.id!);
                            _showSnackBar(
                              message: "Catatan '${log.title}' berhasil dihapus",
                              color: Colors.red.shade600,
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToEditor(),
        icon: const Icon(Icons.add),
        label: const Text("Tambah Catatan"),
      ),
    );
  }
}