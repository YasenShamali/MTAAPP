import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens for the MTA app (refined modern palette).
class AppColors {
  // Brand palette — refined for accessibility and modern feel.
  static const Color primary = Color(0xFF15579E);
  static const Color primaryDark = Color(0xFF0D3E73);
  static const Color primaryLight = Color(0xFF2B78BF);
  static const Color primaryTint = Color(0xFFEAF1FA);
  static const Color primaryContainer = Color(0xFFD6E4F5);
  static const Color teal = Color(0xFF39AE50);
  static const Color tealLight = Color(0xFF5AC76D);
  static const Color tealTint = Color(0xFFE8F6EC);

  // Surface / canvas
  static const Color canvas = Color(0xFFF6F8FB);
  static const Color canvasDark = Color(0xFF0D1219);

  // Semantic status colors (WCAG AA compliant)
  static const Color success = Color(0xFF1F9D57);
  static const Color successBg = Color(0xFFE7F7EE);
  static const Color successBgDark = Color(0xFF0E2D1B);

  static const Color warning = Color(0xFFB25E00);
  static const Color warningBg = Color(0xFFFFF3E1);
  static const Color warningBgDark = Color(0xFF3D2A00);

  static const Color danger = Color(0xFFFF3B30);
  static const Color dangerBg = Color(0xFFFFEBEA);
  static const Color dangerBgDark = Color(0xFF3D0E0E);

  static const Color info = Color(0xFF007AFF);
  static const Color infoBg = Color(0xFFEAF2FA);
  static const Color infoBgDark = Color(0xFF0E1A3D);

  // Neutral
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color divider = Color(0xFFDCE3EB);
  static const Color dividerDark = Color(0xFF344354);

  // Surface containers
  static const Color surfaceContainerLow = Color(0xFFFAFAFA);
  static const Color surfaceContainer = Color(0xFFF5F5F7);
  static const Color surfaceContainerHigh = Color(0xFFEEF0F3);
  static const Color surfaceContainerHighest = Color(0xFFE8EBEF);

  static const Color surfaceContainerLowDark = Color(0xFF131B25);
  static const Color surfaceContainerDark = Color(0xFF18222D);
  static const Color surfaceContainerHighDark = Color(0xFF1E2A38);
  static const Color surfaceContainerHighestDark = Color(0xFF202B38);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

class AppRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double xxl = 26;
  static const double full = 999;
}

/// Curated shadow levels for the visual system.
class AppShadows {
  static const List<BoxShadow> none = [];

  static List<BoxShadow> sm({bool dark = false}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: dark ? 0.30 : 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> md({bool dark = false}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: dark ? 0.36 : 0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> lg({bool dark = false}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: dark ? 0.42 : 0.10),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}

/// Maps an offer status to its foreground / background colors.
class StatusColors {
  static Color foreground(String status, {bool isDark = false}) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'rejected':
      case 'cancelled':
        return AppColors.danger;
      case 'pending_factory':
      case 'pending_installation':
      case 'in_progress':
      case 'pending_resubmission':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  static Color background(String status, {bool isDark = false}) {
    switch (status) {
      case 'completed':
        return isDark ? AppColors.successBgDark : AppColors.successBg;
      case 'rejected':
      case 'cancelled':
        return isDark ? AppColors.dangerBgDark : AppColors.dangerBg;
      case 'pending_factory':
      case 'pending_installation':
      case 'in_progress':
      case 'pending_resubmission':
        return isDark ? AppColors.warningBgDark : AppColors.warningBg;
      default:
        return isDark ? AppColors.infoBgDark : AppColors.infoBg;
    }
  }
}

class AppTheme {
  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );
    final scheme = base.copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.teal,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.tealTint,
      onSecondaryContainer: const Color(0xFF0E3B18),
      tertiary: AppColors.warning,
      onTertiary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      error: AppColors.danger,
      onError: Colors.white,
      outline: AppColors.divider,
      outlineVariant: const Color(0xFFF0F0F2),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
    );
    return _build(scheme, Brightness.light);
  }

  static ThemeData dark() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );
    final scheme = base.copyWith(
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF24456B),
      onPrimaryContainer: const Color(0xFFD6E4F5),
      secondary: AppColors.tealLight,
      onSecondary: const Color(0xFF061B0B),
      secondaryContainer: const Color(0xFF1C4A2B),
      onSecondaryContainer: const Color(0xFFC8EFD2),
      tertiary: AppColors.warning,
      onTertiary: const Color(0xFF061B0B),
      surface: AppColors.canvasDark,
      onSurface: const Color(0xFFF4F7FA),
      onSurfaceVariant: const Color(0xFFA6AEB9),
      error: const Color(0xFFFF453A),
      onError: Colors.white,
      outline: AppColors.dividerDark,
      outlineVariant: const Color(0xFF263443),
      surfaceContainerLowest: AppColors.canvasDark,
      surfaceContainerLow: AppColors.surfaceContainerLowDark,
      surfaceContainer: AppColors.surfaceContainerDark,
      surfaceContainerHigh: AppColors.surfaceContainerHighDark,
      surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
    );
    return _build(scheme, Brightness.dark);
  }

static ThemeData _build(ColorScheme scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    // iOS "systemGroupedBackground" — the canvas the glass sits on.
    final scaffoldBg = isDark ? AppColors.canvasDark : AppColors.canvas;
    final textTheme = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: scaffoldBg,
      textTheme: textTheme,
      fontFamily: 'Tajawal',
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface.withValues(alpha: isDark ? 0.68 : 0.8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: isDark
              ? Brightness.dark
              : Brightness.light,
          systemNavigationBarColor: isDark
              ? AppColors.canvasDark
              : AppColors.canvas,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface.withValues(alpha: isDark ? 0.72 : 0.85),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(
            color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.4),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        textColor: scheme.onSurface,
        titleTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 13,
          color: scheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.dividerDark : AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1B232E) : AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF98989E) : AppColors.textSecondary,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFF98989E) : AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: scheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: isDark
            ? const Color(0xFF98989E)
            : AppColors.textSecondary,
        suffixIconColor: isDark
            ? const Color(0xFF98989E)
            : AppColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 48),
          side: BorderSide(color: scheme.outline, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? const Color(0xFF1C1C1E)
            : AppColors.surfaceContainer,
        selectedColor: scheme.primary.withValues(alpha: 0.16),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFFF2F2F7) : AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(color: scheme.primary, fontSize: 13),
        checkmarkColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface.withValues(alpha: isDark ? 0.72 : 0.82),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: scheme.primary.withValues(alpha: isDark ? 0.25 : 0.14),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 3,
        focusElevation: 3,
        highlightElevation: 3,
        hoverElevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFF1C1C1E),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        elevation: 6,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? const Color(0xFF1C1C1E)
            : const Color(0xFFF9F9F9),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        iconColor: scheme.primary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark
            ? const Color(0xFF1C1C1E)
            : const Color(0xFFF9F9F9),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        elevation: 8,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
        circularTrackColor: scheme.primaryContainer,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : Colors.transparent,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
        side: BorderSide(color: scheme.outline, width: 1.5),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return isDark ? const Color(0xFF98989E) : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return isDark ? const Color(0xFF3A3A3C) : AppColors.divider;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.outline;
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: TextStyle(color: scheme.onSurface, fontSize: 15),
        elevation: 4,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: isDark
            ? const Color(0xFF1C1C1E)
            : const Color(0xFFF9F9F9),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
        headerBackgroundColor: scheme.primary,
        headerForegroundColor: Colors.white,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return scheme.onSurface;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return Colors.transparent;
        }),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: isDark
            ? const Color(0xFF1C1C1E)
            : const Color(0xFFF9F9F9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
        hourMinuteTextColor: scheme.onSurface,
        dayPeriodTextColor: scheme.onSurfaceVariant,
        dialBackgroundColor: scheme.surfaceContainerHighest,
        dialHandColor: scheme.primary,
        dialTextColor: scheme.onSurface,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    final base = scheme.brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;
    return base.copyWith(
      displayLarge: TextStyle(
        color: scheme.onSurface,
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w800,
      ),
      displayMedium: TextStyle(
        color: scheme.onSurface,
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w800,
      ),
      displaySmall: TextStyle(
        color: scheme.onSurface,
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        color: scheme.onSurface,
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        color: scheme.onSurface,
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: scheme.onSurface,
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        color: scheme.onSurface,
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: scheme.onSurface,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: scheme.onSurface,
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        color: scheme.onPrimary,
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: TextStyle(
        color: scheme.onSurface,
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 11,
        height: 1.3,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
