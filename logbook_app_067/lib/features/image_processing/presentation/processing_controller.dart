import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../domain/processing_type.dart';

class ProcessingController extends ChangeNotifier {
  img.Image? originalImage;
  img.Image? processedImage;
  
  Uint8List? _cachedImageBytes;
  bool _imageDirty = true;

  ProcessingType currentType = ProcessingType.none;

  double brightness = 0;     // -100 → 100
  double gammaValue = 1.0;   // 0.1 → 3.0

  void setImage(img.Image image) {
    originalImage = image;
    _imageDirty = true;
    _applyProcessing();
  }

  Uint8List? getImageBytes() {
    if (processedImage == null) return null;
    
    if (!_imageDirty && _cachedImageBytes != null) {
      return _cachedImageBytes;
    }
    _cachedImageBytes = Uint8List.fromList(img.encodeJpg(processedImage!));
    _imageDirty = false;
    return _cachedImageBytes;
  }

  void setProcessing(ProcessingType type) {
    currentType = type;
    _imageDirty = true;
    _applyProcessing();
  }

  void setBrightness(double value, double sliderValue) {
    brightness = value;
    _imageDirty = true;
    _applyProcessing();
  }

  void setGamma(double value, double sliderValue) {
    gammaValue = value;
    _imageDirty = true;
    _applyProcessing();
  }

  void reset() {
    currentType = ProcessingType.none;
    brightness = 0;
    gammaValue = 1.0;

    _imageDirty = true;
    _applyProcessing();
  }

  void _applyProcessing() {
    if (originalImage == null) return;

    img.Image temp = img.copyResize(
      originalImage!,
      width: originalImage!.width,
      height: originalImage!.height,
    );

    switch (currentType) {
      case ProcessingType.none:
        temp = originalImage!;
        break;

      case ProcessingType.grayscale:
        temp = img.grayscale(temp);
        break;

      case ProcessingType.invert:
        temp = img.invert(temp);
        break;

      case ProcessingType.brightness:
        final brightnessAdjustment = brightness.toInt();
        
        // Jika brightness = 0, tidak perlu process
        if (brightnessAdjustment == 0) {
          temp = originalImage!;
        } else {
          // Manual pixel adjustment dengan clamping
          temp = _adjustBrightnessManual(temp, brightnessAdjustment);
        }
        break;

      case ProcessingType.gamma:
        temp = img.gamma(temp, gamma: gammaValue);
        break;
    }

    processedImage = temp;
    notifyListeners();
  }

  img.Image _adjustBrightnessManual(img.Image image, int adjustment) {
    final result = img.Image(
      width: image.width,
      height: image.height,
      numChannels: image.numChannels,
    );

    final scaledAdjustment = adjustment;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixelSafe(x, y);
        
        final r = pixel.r as int;
        final g = pixel.g as int;
        final b = pixel.b as int;
        final a = pixel.a as int;

        final newR = (r + scaledAdjustment).clamp(0, 255).toInt();
        final newG = (g + scaledAdjustment).clamp(0, 255).toInt();
        final newB = (b + scaledAdjustment).clamp(0, 255).toInt();

        result.setPixelRgba(x, y, newR, newG, newB, a);
      }
    }

    return result;
  }
}