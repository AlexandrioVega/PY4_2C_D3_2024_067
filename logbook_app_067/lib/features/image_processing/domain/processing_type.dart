enum ProcessingType {
  none('Original', 'No filter applied'),
  brightness('Brightness', 'Adjust brightness level'),
  invert('Invert', 'Invert image colors'),
  grayscale('Grayscale', 'Convert to grayscale'),
  gamma('Gamma', 'Gamma correction'),
  mean('Mean Filter', 'Blur using mean kernel (Low-pass)'),
  gaussian('Gaussian Blur', 'Smooth using Gaussian kernel'),
  median('Median Filter', 'Non-linear denoise filter'),
  highPass('Edge Detection', 'High-pass filter for edges'),
  bandPass('Sharpening', 'Band-pass filter for sharpen'),
  histogramEqualization('Histogram Equalization', 'Enhance contrast using histogram equalization');

  final String displayName;
  final String description;

  const ProcessingType(this.displayName, this.description);
}