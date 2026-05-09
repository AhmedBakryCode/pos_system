import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _primaryLight = Color(0xFF4B3FDC);
const _onPrimaryLight = Color(0xFFFFFFFF);
const _primaryContainerLight = Color(0xFFE7E3FF);
const _onPrimaryContainerLight = Color(0xFF1C1460);

const _secondaryLight = Color(0xFF6E7FAF);
const _onSecondaryLight = Color(0xFFFFFFFF);
const _secondaryContainerLight = Color(0xFFE7ECF7);
const _onSecondaryContainerLight = Color(0xFF22304D);

const _tertiaryLight = Color(0xFF6A8DFF);
const _backgroundLight = Color(0xFFF9F9F9);
const _surfaceLight = Color(0xFFFFFFFF);
const _surfaceVariantLight = Color(0xFFF1F3F7);
const _outlineLight = Color(0xFFD6DBE6);
const _outlineVariantLight = Color(0xFFE5E9F0);

const _primaryDark = Color(0xFF9A8CFF);
const _onPrimaryDark = Color(0xFF1A133D);
const _primaryContainerDark = Color(0xFF31256F);
const _onPrimaryContainerDark = Color(0xFFE9E4FF);

const _secondaryDark = Color(0xFFAEB9D6);
const _onSecondaryDark = Color(0xFF1F293D);
const _secondaryContainerDark = Color(0xFF33415C);
const _onSecondaryContainerDark = Color(0xFFE8EDF8);

const _backgroundDark = Color(0xFF111318);
const _surfaceDark = Color(0xFF171A21);
const _surfaceVariantDark = Color(0xFF222734);
const _outlineDark = Color(0xFF4A5364);
const _outlineVariantDark = Color(0xFF313846);

class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.lowStock,
    required this.pending,
    required this.approved,
    required this.draft,
  });

  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color lowStock;
  final Color pending;
  final Color approved;
  final Color draft;

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? lowStock,
    Color? pending,
    Color? approved,
    Color? draft,
  }) {
    return AppStatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      lowStock: lowStock ?? this.lowStock,
      pending: pending ?? this.pending,
      approved: approved ?? this.approved,
      draft: draft ?? this.draft,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) {
      return this;
    }

    return AppStatusColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
      info: Color.lerp(info, other.info, t) ?? info,
      lowStock: Color.lerp(lowStock, other.lowStock, t) ?? lowStock,
      pending: Color.lerp(pending, other.pending, t) ?? pending,
      approved: Color.lerp(approved, other.approved, t) ?? approved,
      draft: Color.lerp(draft, other.draft, t) ?? draft,
    );
  }
}

ThemeData buildLightAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: _primaryLight,
    onPrimary: _onPrimaryLight,
    primaryContainer: _primaryContainerLight,
    onPrimaryContainer: _onPrimaryContainerLight,
    secondary: _secondaryLight,
    onSecondary: _onSecondaryLight,
    secondaryContainer: _secondaryContainerLight,
    onSecondaryContainer: _onSecondaryContainerLight,
    tertiary: _tertiaryLight,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFDDE6FF),
    onTertiaryContainer: Color(0xFF1B3A8A),
    error: Color(0xFFC93C3C),
    onError: Colors.white,
    errorContainer: Color(0xFFFDE2E2),
    onErrorContainer: Color(0xFF6C1414),
    surface: _surfaceLight,
    onSurface: Color(0xFF1A1D29),
    onSurfaceVariant: Color(0xFF5A6475),
    outline: _outlineLight,
    outlineVariant: _outlineVariantLight,
    shadow: Color(0x140D1321),
    scrim: Color(0x520D1321),
    inverseSurface: Color(0xFF1D2230),
    onInverseSurface: Color(0xFFF5F7FB),
    inversePrimary: Color(0xFFC7BEFF),
    surfaceTint: _primaryLight,
  );

  return _buildTheme(
    scheme: scheme,
    background: _backgroundLight,
    surfaceVariant: _surfaceVariantLight,
    isDark: false,
    statusColors: const AppStatusColors(
      success: Color(0xFF1F8A5B),
      warning: Color(0xFFD98E04),
      error: Color(0xFFC93C3C),
      info: Color(0xFF3B82C4),
      lowStock: Color(0xFFC98A14),
      pending: Color(0xFFD98E04),
      approved: Color(0xFF1F8A5B),
      draft: Color(0xFF7A869A),
    ),
  );
}

ThemeData buildDarkAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: _primaryDark,
    onPrimary: _onPrimaryDark,
    primaryContainer: _primaryContainerDark,
    onPrimaryContainer: _onPrimaryContainerDark,
    secondary: _secondaryDark,
    onSecondary: _onSecondaryDark,
    secondaryContainer: _secondaryContainerDark,
    onSecondaryContainer: _onSecondaryContainerDark,
    tertiary: Color(0xFF8CA7FF),
    onTertiary: Color(0xFF142C5F),
    tertiaryContainer: Color(0xFF233A72),
    onTertiaryContainer: Color(0xFFDDE6FF),
    error: Color(0xFFF06A6A),
    onError: Color(0xFF4F1010),
    errorContainer: Color(0xFF6D1E1E),
    onErrorContainer: Color(0xFFFDE2E2),
    surface: _surfaceDark,
    onSurface: Color(0xFFF2F4F8),
    onSurfaceVariant: Color(0xFFAFB7C6),
    outline: _outlineDark,
    outlineVariant: _outlineVariantDark,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFF2F4F8),
    onInverseSurface: Color(0xFF161A20),
    inversePrimary: _primaryLight,
    surfaceTint: _primaryDark,
  );

  return _buildTheme(
    scheme: scheme,
    background: _backgroundDark,
    surfaceVariant: _surfaceVariantDark,
    isDark: true,
    statusColors: const AppStatusColors(
      success: Color(0xFF3DBA7A),
      warning: Color(0xFFF3B63F),
      error: Color(0xFFF06A6A),
      info: Color(0xFF68A7FF),
      lowStock: Color(0xFFF0B44D),
      pending: Color(0xFFF3B63F),
      approved: Color(0xFF3DBA7A),
      draft: Color(0xFF9BA7BD),
    ),
  );
}

ThemeData _buildTheme({
  required ColorScheme scheme,
  required Color background,
  required Color surfaceVariant,
  required bool isDark,
  required AppStatusColors statusColors,
}) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    fontFamily: 'Segoe UI',
    extensions: [statusColors],
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        height: 1.4,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      shadowColor: scheme.shadow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Segoe UI',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Segoe UI',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error, width: 1.4),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: surfaceVariant,
      selectedColor: scheme.primaryContainer,
      secondarySelectedColor: scheme.secondaryContainer,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: TextStyle(
        fontFamily: 'Segoe UI',
        fontWeight: FontWeight.w600,
        color: scheme.onSurfaceVariant,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: isDark ? const Color(0xFF131722) : const Color(0xFF161B2A),
      selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
      unselectedIconTheme: const IconThemeData(color: Colors.white70),
      selectedLabelTextStyle: TextStyle(
        fontFamily: 'Segoe UI',
        fontWeight: FontWeight.w600,
        color: scheme.onPrimaryContainer,
      ),
      unselectedLabelTextStyle: const TextStyle(
        fontFamily: 'Segoe UI',
        color: Colors.white70,
      ),
      indicatorColor: scheme.primaryContainer,
    ),
  );
}
