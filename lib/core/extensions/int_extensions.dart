extension IntExtensions on int {
  int get minorUnits => this;

  double toMajorUnits(int decimalDigits) {
    if (decimalDigits <= 0) return toDouble();
    return this / (10 * decimalDigits);
  }
}

extension StringExtensions on String {
  bool get isNullOrEmpty => isEmpty || this == 'null';
}
