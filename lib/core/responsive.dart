import 'package:flutter/material.dart';

/// Breakpoints aligned with Material Design's qualifiers.
///
/// `sw600dp` — Material's tablet threshold; matches a 7"+ device. Many 9"
/// tablets in landscape report a shortest-side of ~600dp, so 720dp is too
/// strict. We trigger tablet layout if either is true:
///   * `shortestSide >= 600` (sw600dp), OR
///   * `width >= 800` (handles landscape phones / smaller tablets).
class Breakpoints {
  Breakpoints._();
  static const double tablet = 600;     // Material sw600dp
  static const double tabletLandscape = 800;
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

  /// Maximum width for a content column on tablets / iPads.
  static double contentMaxWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1400) return 1100;
    if (w >= Breakpoints.large) return 920;
    if (w >= Breakpoints.tabletLandscape) return 720;
    return w;
  }
}

/// Centers the child up to a content max width on tablets / iPads.
class ContentColumn extends StatelessWidget {
  const ContentColumn({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.maxWidth,
  });

  final Widget child;
  final EdgeInsets padding;
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
