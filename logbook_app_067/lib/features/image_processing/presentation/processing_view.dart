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
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
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
          // 🖼 IMAGE PREVIEW - Premium Design
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDarkMode ? Colors.black : Colors.white,
                    isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
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

          // 🎛 CONTROLS PANEL
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 📌 Section Title
                      Text(
                        "Filter",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 🎛 Filter Dropdown
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<ProcessingType>(
                            value: controller.currentType,
                            onChanged: (value) {
                              if (value != null) {
                                controller.setProcessing(value);
                              }
                            },
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: ProcessingType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type.displayName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.grey[800],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🎚 BRIGHTNESS SLIDER
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

                      // 🎚 GAMMA SLIDER
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

                      const SizedBox(height: 24),

                      // 🔄 ACTION BUTTONS
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
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Save feature coming soon!"),
                                      backgroundColor: Colors.blue.shade600,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
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

  /// 🎚 Build slider dengan styling elegan
  Widget _buildParameterSlider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    required String displayValue,
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
            divisions: ((max - min) * 2).toInt(),
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
}