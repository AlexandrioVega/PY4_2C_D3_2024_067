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

  // Sesi 1 parameters
  double brightness = 0;    
  double gammaValue = 1.0;  
  
  // Sesi 2 parameters
  int kernelSize = 3;       
  int medianRadius = 1; 
  double sharpenAmount = 1.0; 

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
    
    // Normalize parameter values based on filter type
    switch (type) {
      case ProcessingType.gaussian:
        // Gaussian max kernel = 5
        if (kernelSize > 5) kernelSize = 5;
        break;
      
      case ProcessingType.median:
        // Median max radius = 3
        if (medianRadius > 3) medianRadius = 3;
        break;
      
      default:
        break;
    }
    
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

  void setKernelSize(double value) {
    kernelSize = value.toInt();
    _imageDirty = true;
    _applyProcessing();
  }

  void setMedianRadius(double value) {
    medianRadius = value.toInt();
    _imageDirty = true;
    _applyProcessing();
  }

  void setSharpenAmount(double value) {
    sharpenAmount = value;
    _imageDirty = true;
    _applyProcessing();
  }

  void reset() {
    currentType = ProcessingType.none;
    brightness = 0;
    gammaValue = 1.0;
    kernelSize = 3;
    medianRadius = 1;
    sharpenAmount = 1.0;

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
          temp = _adjustBrightnessManual(temp, brightnessAdjustment);
        }
        break;

      case ProcessingType.gamma:
        temp = img.gamma(temp, gamma: gammaValue);
        break;

      // Sesi 2 - Filtering
      case ProcessingType.mean:
        temp = _applyMeanFilter(temp, kernelSize);
        break;

      case ProcessingType.gaussian:
        temp = img.gaussianBlur(temp, radius: kernelSize ~/ 2);
        break;

      case ProcessingType.median:
        temp = _applyMedianFilter(temp, medianRadius);
        break;

      case ProcessingType.highPass:
        temp = _applyHighPassFilter(temp);
        break;

      case ProcessingType.bandPass:
        temp = _applyBandPassFilter(temp, sharpenAmount);
        break;

      case ProcessingType.histogramEqualization:
        temp = _applyHistogramEqualization(temp);
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
  
  /// Mean Filter (Low-pass)
  img.Image _applyMeanFilter(img.Image image, int kernelSize) {
    final result = img.Image(
      width: image.width,
      height: image.height,
      numChannels: image.numChannels,
    );

    final offset = kernelSize ~/ 2;
    final total = kernelSize * kernelSize;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int sumR = 0, sumG = 0, sumB = 0;

        for (int ky = -offset; ky <= offset; ky++) {
          for (int kx = -offset; kx <= offset; kx++) {

            final px = (x + kx).clamp(0, image.width - 1).toInt();
            final py = (y + ky).clamp(0, image.height - 1).toInt();

            final pixel = image.getPixelSafe(px, py);

            sumR += pixel.r.toInt();
            sumG += pixel.g.toInt();
            sumB += pixel.b.toInt();
          }
        }

        final avgR = (sumR ~/ total).clamp(0, 255);
        final avgG = (sumG ~/ total).clamp(0, 255);
        final avgB = (sumB ~/ total).clamp(0, 255);

        final original = image.getPixelSafe(x, y);

        result.setPixelRgba(
          x,
          y,
          avgR,
          avgG,
          avgB,
          original.a.toInt(),
        );
      }
    }

    return result;
  }

  /// Median Filter - Non-linear filter untuk noise reduction (OPTIMIZED)
  img.Image _applyMedianFilter(img.Image image, int radius) {
    final result = img.Image(
      width: image.width,
      height: image.height,
      numChannels: image.numChannels,
    );

    // Limit radius untuk performa (max 3)
    final actualRadius = radius.clamp(1, 3);
    final offset = actualRadius;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        List<int> rValues = [], gValues = [], bValues = [];

        // Collect neighborhood values
        for (int ky = -offset; ky <= offset; ky++) {
          for (int kx = -offset; kx <= offset; kx++) {
            final px = (x + kx).clamp(0, image.width - 1);
            final py = (y + ky).clamp(0, image.height - 1);
            
            final pixel = image.getPixelSafe(px, py);
            rValues.add(pixel.r as int);
            gValues.add(pixel.g as int);
            bValues.add(pixel.b as int);
          }
        }

        // Sort dan ambil median (faster untuk small arrays)
        rValues.sort();
        gValues.sort();
        bValues.sort();
        
        final mid = rValues.length ~/ 2;
        final medianR = rValues[mid];
        final medianG = gValues[mid];
        final medianB = bValues[mid];

        final pixel = image.getPixelSafe(x, y);
        result.setPixelRgba(x, y, medianR, medianG, medianB, pixel.a as int);
      }
    }

    return result;
  }

  /// High-Pass Filter - Edge detection using Laplacian kernel
  img.Image _applyHighPassFilter(img.Image image) {
    // Convert to grayscale first untuk edge detection yang lebih akurat
    final gray = img.grayscale(image);
    
    final result = img.Image(
      width: gray.width,
      height: gray.height,
      numChannels: gray.numChannels,
    );

    const List<List<int>> kernel = [
      [-1, -1, -1],
      [-1,  8, -1],
      [-1, -1, -1],
    ];

    for (int y = 1; y < gray.height - 1; y++) {
      for (int x = 1; x < gray.width - 1; x++) {
        int sum = 0;

        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final pixel = gray.getPixelSafe(x + kx, y + ky);
            final kValue = kernel[ky + 1][kx + 1];
            sum += (pixel.r as int) * kValue;
          }
        }

        final value = sum.clamp(0, 255);
        final alphaPixel = image.getPixelSafe(x, y);
        result.setPixelRgba(x, y, value, value, value, alphaPixel.a as int);
      }
    }

    return result;
  }
  
  img.Image _applyBandPassFilter(img.Image image, double intensity) {
    final result = img.Image(
      width: image.width,
      height: image.height,
      numChannels: image.numChannels,
    );

    // Normalized sharpening kernel
    const List<List<int>> kernel = [
      [ 0, -1,  0],
      [-1,  5, -1],
      [ 0, -1,  0],
    ];

    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        double sumR = 0, sumG = 0, sumB = 0;

        // Apply kernel
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final pixel = image.getPixelSafe(x + kx, y + ky);
            final kValue = kernel[ky + 1][kx + 1];
            sumR += (pixel.r as int) * kValue;
            sumG += (pixel.g as int) * kValue;
            sumB += (pixel.b as int) * kValue;
          }
        }

        // Clamp kernel result
        final kernelR = sumR.clamp(0, 255);
        final kernelG = sumG.clamp(0, 255);
        final kernelB = sumB.clamp(0, 255);

        // Blend dengan original: output = original + intensity * (kernel - original)
        final original = image.getPixelSafe(x, y);
        final r = ((original.r as int) + intensity * (kernelR - (original.r as int))).clamp(0, 255).toInt();
        final g = ((original.g as int) + intensity * (kernelG - (original.g as int))).clamp(0, 255).toInt();
        final b = ((original.b as int) + intensity * (kernelB - (original.b as int))).clamp(0, 255).toInt();

        result.setPixelRgba(x, y, r, g, b, original.a as int);
      }
    }

    return result;
  }

  
  img.Image _applyHistogramEqualization(img.Image image) {
    final result = img.Image(
      width: image.width,
      height: image.height,
      numChannels: image.numChannels,
    );

    final int nG = 256; // Gray levels (0-255)
    final int totalPixels = image.width * image.height;
    final histogramY = List<int>.filled(nG, 0);

    
    final lookupCb = List<double>.filled(nG, 0);
    final lookupCr = List<double>.filled(nG, 0);
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixelSafe(x, y);
        final r = pixel.r as int;
        final g = pixel.g as int;
        final b = pixel.b as int;

        
        final yVal = (0.299 * r + 0.587 * g + 0.114 * b).round();
        histogramY[yVal]++;

        lookupCb[yVal] = 128.0 - 0.168736 * r - 0.331264 * g + 0.5 * b;
        lookupCr[yVal] = 128.0 + 0.5 * r - 0.418688 * g - 0.081312 * b;
      }
    }

    final lookupY = List<int>.filled(nG, 0);
    int cdfY = 0;

    for (int i = 0; i < nG; i++) {
      cdfY += histogramY[i];
      lookupY[i] = (((nG - 1) * cdfY) ~/ totalPixels).clamp(0, 255);
    }

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixelSafe(x, y);
        final r = pixel.r as int;
        final g = pixel.g as int;
        final b = pixel.b as int;

        final yVal = (0.299 * r + 0.587 * g + 0.114 * b).round();
        
        final yEqualized = lookupY[yVal];
        
        final cb = lookupCb[yVal];
        final cr = lookupCr[yVal];

        final outR = (yEqualized + 1.402 * (cr - 128.0)).clamp(0, 255).toInt();
        final outG = (yEqualized - 0.34414 * (cb - 128.0) - 0.71414 * (cr - 128.0))
            .clamp(0, 255)
            .toInt();
        final outB = (yEqualized + 1.772 * (cb - 128.0)).clamp(0, 255).toInt();

        result.setPixelRgba(x, y, outR, outG, outB, pixel.a as int);
      }
    }

    return result;
  }
}