enum CellShape {
  square,
  circle;

  String get displayName {
    switch (this) {
      case CellShape.square:
        return 'Square';
      case CellShape.circle:
        return 'Circle';
    }
  }
}
