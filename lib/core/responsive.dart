import 'package:flutter/material.dart';

/// Breakpoints aligned with Material Design's qualifiers.
class Breakpoints {
  Breakpoints._();
  static const double tablet = 600;          // Material `sw600dp`
  static const double tabletLandscape = 800; // landscape phones / smaller tablets
  static const double large = 1100;
}

class Responsive {
  Responsive._();

  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide >= Breakpoints.tablet ||
        size.width >= Breakpoints.tabletLandscape;
  }

  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.large;

  static bool isLandscape(BuildContext context) {
    final s = MediaQuery.of(context).size;
    return s.width > s.height;
  }

  /// Maximum width for a single content column (used by [ContentColumn]).
  ///
  /// Previously this was capped at 720 dp on landscape tablets, which left
  /// huge empty side-margins on a 9–10" tablet. We now scale the cap up to
  /// roughly the full available width while keeping a small breathing
  /// margin so text lines never run edge-to-edge.
  ///
  ///   Phones / portrait               → full width (no cap)
  ///   Small tablet (landscape phone)  → width − 2 × side padding
  ///   Tablet 7"-10" landscape (9")    → width − 2 × side padding
  ///   Large tablet / desktop          → 1400 dp ceiling so super-wide
  ///                                      monitors don't stretch the text
  static double contentMaxWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1500) return 1400;     // ultra-wide cap
    return w;                        // everything else: use the full canvas
  }
}

/// Centers the child up to a content max width on tablets / iPads.
///
/// In v14 this widget added side-margins on landscape tablets because the
/// max-width was 720 dp regardless of available space. The cap is now
/// generous (see [Responsive.contentMaxWidth]) so screens *fill* the space
/// in landscape instead of centring inside a narrow column.
class ContentColumn extends StatelessWidget {
  const ContentColumn({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.maxWidth,
  });

  final Widget child;
  final EdgeInsets padding;
  /// Override the responsive cap if a particular screen really wants
  /// a narrow column (e.g. a settings form). Defaults to whatever
  /// [Responsive.contentMaxWidth] returns for the current window.
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final cap = maxWidth ?? Responsive.contentMaxWidth(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
