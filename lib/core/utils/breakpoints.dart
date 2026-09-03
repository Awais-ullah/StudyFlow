/// Central width thresholds — every responsive decision in the app
/// should reference these constants rather than hardcoding pixel
/// values inline, so changing "what counts as a tablet" happens in
/// exactly one place.
class Breakpoints {
  Breakpoints._();

  static const double tablet = 600;
  static const double desktop = 1024;

  static bool isTablet(double width) => width >= tablet && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
  static bool isCompact(double width) => width < tablet;

  /// How many grid columns a card-based list should use at a given width.
  /// Centralizing this means Subjects, and any future grid screen, stay
  /// visually consistent without duplicating this exact math everywhere.
  static int gridColumns(double width) {
    if (isDesktop(width)) return 4;
    if (isTablet(width)) return 2;
    return 1;
  }
}