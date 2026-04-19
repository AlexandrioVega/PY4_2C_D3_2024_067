import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'vision_controller.dart';
import 'damage_painter.dart';

// 🔥 IMPORT PROCESSING
import '../image_processing/presentation/processing_view.dart';
import '../image_processing/presentation/processing_controller.dart';

class VisionView extends StatefulWidget {
  const VisionView({super.key});

  @override
  State<VisionView> createState() => _VisionViewState();
}

class _VisionViewState extends State<VisionView> {
  late VisionController _visionController;

  @override
  void initState() {
    super.initState();
    _visionController = VisionController();
  }

  @override
  void dispose() {
    _visionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Smart-Patrol Vision"),
        backgroundColor: Colors.black,
      ),
      body: ListenableBuilder(
        listenable: _visionController,
        builder: (context, child) {

          // ❌ ERROR (NO CAMERA ACCESS)
          if (_visionController.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "No Camera Access",
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      openAppSettings();
                    },
                    child: const Text("Open Settings"),
                  )
                ],
              ),
            );
          }

          // ⏳ LOADING
          if (!_visionController.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.greenAccent),
                  SizedBox(height: 16),
                  Text(
                    "Menghubungkan ke Sensor Visual...",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          return _buildVisionStack();
        },
      ),
    );
  }

  // =========================
  // CONTROL PANEL
  // =========================
  Widget _buildControlPanel() {
    return ListenableBuilder(
      listenable: _visionController,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              // 🔦 FLASH
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _visionController.isFlashOn
                          ? Icons.flash_on
                          : Icons.flash_off,
                      color: _visionController.isFlashOn
                          ? Colors.yellowAccent
                          : Colors.white,
                    ),
                    onPressed: () {
                      _visionController.toggleFlash();
                    },
                  ),
                  const Text(
                    "Flash",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),

              // 🎯 OVERLAY
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: _visionController.isOverlayEnabled,
                    activeColor: Colors.greenAccent,
                    onChanged: (value) {
                      _visionController.toggleOverlay();
                    },
                  ),
                  const Text(
                    "Overlay",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // MAIN STACK
  // =========================
  Widget _buildVisionStack() {
    return Stack(
      fit: StackFit.expand,
      children: [

        // 📷 CAMERA LAYER
        Center(
          child: AspectRatio(
            aspectRatio:
                1 / _visionController.controller!.value.aspectRatio,
            child: CameraPreview(_visionController.controller!),
          ),
        ),

        // 🎯 OVERLAY (TIDAK BLOCK CLICK)
        Positioned.fill(
          child: IgnorePointer(
            child: _visionController.isOverlayEnabled
                ? CustomPaint(
                    painter: DamagePainter(_visionController.results),
                  )
                : const SizedBox(),
          ),
        ),

        // 📸 CAPTURE BUTTON
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              backgroundColor: Colors.greenAccent,
              onPressed: () async {
                final file = await _visionController.takePicture();

                if (file != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => ProcessingController(),
                        child: ProcessingView(imagePath: file.path),
                      ),
                    ),
                  );
                }
              },
              child: const Icon(Icons.camera),
            ),
          ),
        ),

        // 🧠 HUD STATUS
        Positioned(
          top: 40,
          left: 20,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: const Text(
              "SMART VISION ACTIVE",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // 🎛 CONTROL PANEL
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: _buildControlPanel(),
        ),
      ],
    );
  }
}