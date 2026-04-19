import 'package:camera/camera.dart';
import 'detection_result.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class VisionController extends ChangeNotifier with WidgetsBindingObserver {
  List<DetectionResult> results = [];
  bool _isRunning = false;
  CameraController? controller;
  bool isInitialized = false;
  String? errorMessage;

  bool isFlashOn = false;
  bool isOverlayEnabled = true;


  VisionController() {
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage = "No camera detected on device.";
        notifyListeners();
        return;
      }

      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium, 
        enableAudio: false,      
      );

      await controller!.initialize();
      isInitialized = true;
      errorMessage = null;
    } catch (e) {
      errorMessage = "Failed to initialize camera: $e";
    }

    startMockDetection();
  }

  Future<void> toggleFlash() async {
    if (controller == null) return;

    try {
      if (isFlashOn) {
        await controller!.setFlashMode(FlashMode.off);
        isFlashOn = false;
      } else {
        await controller!.setFlashMode(FlashMode.torch);
        isFlashOn = true;
      }
      notifyListeners();
    } catch (e) {
      errorMessage = "Flash error: $e";
      notifyListeners();
    }
  }

  void toggleOverlay() {
    isOverlayEnabled = !isOverlayEnabled;
    notifyListeners();
  }


  void startMockDetection() {
    _isRunning = true;

    Future.doWhile(() async {
      if (!_isRunning) return false;

      await Future.delayed(const Duration(seconds: 3));

      generateRandomBox();

      return true;
    });
  }

  void stopMockDetection() {
    _isRunning = false;
  }

  void generateRandomBox() {
    final rand = Random();

    double w = 0.3;
    double h = 0.3;

    double x = rand.nextDouble() * (1 - w);
    double y = rand.nextDouble() * (1 - h);

    results = [
      DetectionResult(
        box: Rect.fromLTWH(x, y, w, h), 
        label: "D40",
        score: 0.9,
      ),
      DetectionResult(
        box: Rect.fromLTWH(x, y, w, h), 
        label: "D00",
        score: 0.9,
      ),
    ];

    print("Mock Box -> x:$x y:$y w:$w h:$h");

    notifyListeners();
  }

  Future<XFile?> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) return null;

    try {
      return await controller!.takePicture();
    } catch (e) {
      errorMessage = "Capture failed: $e";
      notifyListeners();
      return null;
    }
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      stopMockDetection();
      cameraController.dispose();
      isInitialized = false;
      notifyListeners();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  @override
  void dispose() {
    stopMockDetection();
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

}
