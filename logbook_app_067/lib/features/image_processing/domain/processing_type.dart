enum ProcessingType {
  none('Original', 'No filter applied'),
  brightness('Brightness', 'Adjust brightness level'),
  invert('Invert', 'Invert image colors'),
  grayscale('Grayscale', 'Convert to grayscale'),
  gamma('Gamma', 'Gamma correction');

  final String displayName;
  final String description;

  const ProcessingType(this.displayName, this.description);
}