import 'package:flutter/material.dart';

/// BridgeInspect Pro design-system palette (restored navy + brand blue).
///
/// Primary  — deep navy + accent brand blue
/// Secondary — alert red (also used for sign-out)
/// Tertiary  — neutral grayscale
class AppColors {
  AppColors._();

  // ---------- Primary (navy + blue) ----------
  static const Color primaryDeep = Color(0xFF0A2540);   // deep navy header / shell
  static const Color primary = Color(0xFF1E5BB8);       // brand blue / CTAs
  static const Color primaryLight = Color(0xFFDCE7F8);
  static const Color primaryAccent = Color(0xFF2F80ED);

  // Back-compat alias used by older screens.
  static const Color primaryDark = primaryDeep;

  // ---------- Secondary (red — alerts + sign-out) ----------
  static const Color secondary = Color(0xFFDC2626);
  static const Color secondaryDark = Color(0xFFB91C1C);
  static const Color secondaryLight = Color(0xFFFEE2E2);
  static const Color red = secondary;

  // ---------- Tertiary (grayscale) ----------
  static const Color gray050 = Color(0xFFF5F7FA);
  static const Color gray100 = Color(0xFFE5E9EF);
  static const Color gray200 = Color(0xFFCBD2DC);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray800 = Color(0xFF1F2937);

  // ---------- Surfaces ----------
  static const Color background = Color(0xFFF3F5F9);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF5F7FA);
  static const Color border = Color(0xFFE5E9EF);
  static const Color divider = Color(0xFFEEF1F6);

  // ---------- Text ----------
  static const Color textPrimary = Color(0xFF0A2540);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Colors.white;

  // ---------- Status / chips ----------
  static const Color statusDraft = Color(0xFFF59E0B);
  static const Color statusDraftBg = Color(0xFFFEF3C7);
  static const Color statusSubmitted = primary;
  static const Color statusSubmittedBg = primaryLight;
  static const Color statusSynced = Color(0xFF16A34A);
  static const Color statusSyncedBg = Color(0xFFDCFCE7);

  // ---------- Severity / rating ----------
  static const Color severityLow = Color(0xFF16A34A);
  static const Color severityMedium = Color(0xFFF59E0B);
  static const Color severityHigh = Color(0xFFDC2626);
  static const Color severityCritical = Color(0xFF991B1B);

  // ---------- AI hint banner ----------
  static const Color aiAccent = primaryAccent;
  static const Color aiAccentBg = Color(0xFFE6EFFC);

  // ---------- Critical findings warning ----------
  static const Color warningBg = Color(0xFFFEE2E2);
  static const Color warningFg = Color(0xFFB91C1C);

  // ---------- Asset thumbnails ----------
  static const Color thumbnailNavy = primaryDeep;
  static const Color thumbnailMint = Color(0xFFDCE7F8);
  static const Color thumbnailTeal = primaryDeep;   // legacy alias
}
