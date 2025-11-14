import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernTheme {
  // Colors
  static const Color primary = Color(0xFF4B39EF);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF059669);
  static const Color secondaryLight = Color(0xFF10B981);
  static const Color tertiary = Color(0xFFEF4444);
  static const Color tertiaryLight = Color(0xFFF87171);
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  
  // Background Colors
  static const Color background = Color(0xFFF1F4F8);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  
  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // Card Decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: cardShadow,
  );

  // Gradient Decorations
  static BoxDecoration primaryGradientDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [primary, primaryLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
  );

  static BoxDecoration secondaryGradientDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [secondary, secondaryLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
  );

  // Text Styles
  static TextStyle get headingLarge => GoogleFonts.notoSansMalayalam(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get headingMedium => GoogleFonts.notoSansMalayalam(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get headingSmall => GoogleFonts.notoSansMalayalam(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.notoSansMalayalam(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.notoSansMalayalam(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.notoSansMalayalam(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle get labelLarge => GoogleFonts.notoSansMalayalam(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle get labelMedium => GoogleFonts.notoSansMalayalam(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle get labelSmall => GoogleFonts.notoSansMalayalam(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
  );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primary,
    side: const BorderSide(color: border),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String labelText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: labelText,
    labelStyle: labelLarge,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primary, width: 2),
    ),
    filled: true,
    fillColor: surface,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: textSecondary) : null,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  // App Bar Theme
  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.notoSansMalayalam(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  // Card Theme
  static CardThemeData get cardTheme => CardThemeData(
    color: surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: EdgeInsets.zero,
  );

  // Floating Action Button Theme
  static FloatingActionButtonThemeData get fabTheme => FloatingActionButtonThemeData(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );

  // Theme Data
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: appBarTheme,
    cardTheme: cardTheme,
    floatingActionButtonTheme: fabTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
    textTheme: TextTheme(
      headlineLarge: headingLarge,
      headlineMedium: headingMedium,
      headlineSmall: headingSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    ),
  );

  // Utility Methods
  static Widget buildGradientContainer({
    required Widget child,
    List<Color>? colors,
    BorderRadius? borderRadius,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [primary, primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  static Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? extra,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor ?? border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: textSecondary),
              const SizedBox(width: 6),
              Text(title, style: labelSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: bodyMedium.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (extra != null) ...[
            const SizedBox(height: 2),
            Text(
              extra,
              style: labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  static Widget buildStatusChip({
    required String text,
    required Color color,
    double fontSize = 11,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.notoSansMalayalam(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}