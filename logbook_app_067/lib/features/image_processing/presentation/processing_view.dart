import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import 'processing_controller.dart';
import '../domain/processing_type.dart';

class ProcessingView extends StatefulWidget {
  final String imagePath;

  const ProcessingView({super.key, required this.imagePath});

  @override
  State<ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<ProcessingView> {
  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    final bytes = await File(widget.imagePath).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image != null) {
      context.read<ProcessingController>().setImage(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProcessingController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: const Text(
          "Image Processing",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.grey[900]!,
                  ],
                ),
              ),
              child: Center(
                child: controller.getImageBytes() == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Processing Image...",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              controller.getImageBytes()!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400.withOpacity(0.1),
                              Colors.blue.shade600.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.blue.shade200.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getFilterIcon(controller.currentType),
                                  size: 16,
                                  color: Colors.blue.shade300,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.currentType.displayName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue.shade300,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      Text(
                                        controller.currentType.description,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey[500],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        "FILTER",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[400],
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),

                      SizedBox(
                        height: 78,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          itemCount: ProcessingType.values.length,
                          itemBuilder: (context, index) {
                            final type = ProcessingType.values[index];
                            final isSelected = controller.currentType == type;
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () {
                                  controller.setProcessing(type);
                                },
                                child: Column(
                                  children: [
                                    // Filter Icon/Badge
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  Colors.blue.shade400,
                                                  Colors.blue.shade600,
                                                ],
                                              )
                                            : LinearGradient(
                                                colors: [
                                                  Colors.grey[700]!,
                                                  Colors.grey[800]!,
                                                ],
                                              ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.blue.shade300
                                                      .withOpacity(0.3),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _getFilterIcon(type),
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey[400],
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // Filter Name
                                    SizedBox(
                                      width: 54,
                                      child: Text(
                                        type.displayName,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.blue.shade300
                                              : Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (controller.currentType == ProcessingType.brightness)
                        _buildParameterSlider(
                          context,
                          label: "Brightness",
                          value: controller.brightness,
                          min: -100,
                          max: 100,
                          onChanged: (value) {
                            controller.setBrightness(value, value);
                          },
                          displayValue: controller.brightness.toStringAsFixed(0),
                        ),

                      if (controller.currentType == ProcessingType.gamma)
                        _buildParameterSlider(
                          context,
                          label: "Gamma Correction",
                          value: controller.gammaValue,
                          min: 0.1,
                          max: 3.0,
                          onChanged: (value) {
                            controller.setGamma(value, value);
                          },
                          displayValue: controller.gammaValue.toStringAsFixed(2),
                        ),

                      if (controller.currentType == ProcessingType.mean)
                        _buildKernelSizeButtons(
                          context,
                          label: "Kernel Size",
                          sizes: [3, 5, 7, 9],
                          currentSize: controller.kernelSize,
                          onSelect: (size) {
                            controller.setKernelSize(size.toDouble());
                          },
                        ),

                      if (controller.currentType == ProcessingType.gaussian)
                        _buildKernelSizeButtons(
                          context,
                          label: "Blur Radius",
                          sizes: [1, 2, 3, 4, 5],
                          currentSize: controller.kernelSize,
                          onSelect: (size) {
                            controller.setKernelSize(size.toDouble());
                          },
                        ),

                      if (controller.currentType == ProcessingType.median)
                        _buildKernelSizeButtons(
                          context,
                          label: "Filter Radius",
                          sizes: [1, 2, 3],
                          currentSize: controller.medianRadius,
                          onSelect: (size) {
                            controller.setMedianRadius(size.toDouble());
                          },
                        ),

                      if (controller.currentType == ProcessingType.highPass)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            "Edge Detection: Laplacian Kernel Applied",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      if (controller.currentType == ProcessingType.bandPass)
                        _buildSharpenButtons(
                          context,
                          currentIntensity: controller.sharpenAmount,
                          onSelect: (intensity) {
                            controller.setSharpenAmount(intensity);
                          },
                        ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          // Reset Button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  controller.reset();
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.refresh,
                                        size: 18,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.grey[800],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Reset",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.grey[800],
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Save Button (Future use)
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _saveImage(context, controller),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.blue.shade600,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.shade300
                                            .withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.download,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Save",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterSlider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    required String displayValue,
    int? divisions,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: RoundSliderThumbShape(
              elevation: 4,
              enabledThumbRadius: 12,
              pressedElevation: 8,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: 20,
            ),
            activeTrackColor: Colors.blue.shade400,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.blue.shade500,
            overlayColor: Colors.blue.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            divisions: divisions ?? ((max - min) * 2).toInt(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              min.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
              ),
            ),
            Text(
              max.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKernelSizeButtons(
    BuildContext context, {
    required String label,
    required List<int> sizes,
    required int currentSize,
    required Function(int) onSelect,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sizes.map((size) {
            final isSelected = size == currentSize;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(size),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue.shade400
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1.5,
                    ),
                    color: isSelected
                        ? Colors.blue.shade50
                        : (isDarkMode ? Colors.grey[800] : Colors.grey[50]),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.shade200.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    "${size}×${size}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.blue.shade600
                          : (isDarkMode ? Colors.white : Colors.grey[700]),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSharpenButtons(
    BuildContext context, {
    required double currentIntensity,
    required Function(double) onSelect,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final intensities = [0.5, 1.0, 1.5, 2.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sharpen Intensity",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: intensities.map((intensity) {
            final isSelected = (intensity - currentIntensity).abs() < 0.01;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(intensity),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue.shade400
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1.5,
                    ),
                    color: isSelected
                        ? Colors.blue.shade50
                        : (isDarkMode ? Colors.grey[800] : Colors.grey[50]),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.shade200.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    intensity.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.blue.shade600
                          : (isDarkMode ? Colors.white : Colors.grey[700]),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Get icon untuk setiap filter type
  IconData _getFilterIcon(ProcessingType type) {
    switch (type) {
      case ProcessingType.none:
        return Icons.image;
      case ProcessingType.brightness:
        return Icons.brightness_6;
      case ProcessingType.invert:
        return Icons.invert_colors;
      case ProcessingType.grayscale:
        return Icons.monochrome_photos;
      case ProcessingType.gamma:
        return Icons.lightbulb;
      case ProcessingType.mean:
        return Icons.blur_on;
      case ProcessingType.gaussian:
        return Icons.blur_on;
      case ProcessingType.median:
        return Icons.blur_on;
      case ProcessingType.highPass:
        return Icons.auto_fix_high;
      case ProcessingType.bandPass:
        return Icons.auto_fix_high;
      case ProcessingType.histogramEqualization:
        return Icons.equalizer;
    }
  }

  Future<void> _saveImage(
    BuildContext context,
    ProcessingController controller,
  ) async {
    try {
      final imageBytes = controller.getImageBytes();
      if (imageBytes == null) {
        _showErrorSnackbar(context, "Image not ready yet");
        return;
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filterName = controller.currentType.displayName.replaceAll(' ', '_');
      final filename = 'Smart-Patrol_${filterName}_$timestamp.jpg';

      final directory = Directory('/storage/emulated/0/DCIM/Camera');
      
      if (!await directory.exists()) {
        final tempDir = Directory('/data/data');
        final savedFile = File('${tempDir.path}/$filename');
        await savedFile.writeAsBytes(imageBytes);
        _showSuccessSnackbar(
          context,
          "Gambar disimpan ke:\n${savedFile.path}",
        );
      } else {
        final savedFile = File('${directory.path}/$filename');
        await savedFile.writeAsBytes(imageBytes);
        _showSuccessSnackbar(
          context,
          "Gambar disimpan ke:\nDCIM/Camera/$filename",
        );
      }
    } catch (e) {
      _showErrorSnackbar(context, "Gagal menyimpan: $e");
    }
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "OK",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "OK",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}