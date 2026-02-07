// lib/providers/theme_provider.dart - CORRECTED VERSION
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Remove these imports - they don't exist:
// import '../theme/color_mode.dart';
// import '../theme/app_colors.dart';
// import '../theme/app_theme.dart';

enum ColorBlindMode { normal, protanopia, deuteranopia, tritanopia, achromatopsia }

const _kPrefsKey = 'color_blind_mode';

class AccessibleColors extends ThemeExtension<AccessibleColors> {
  final Color terracotta;
  final Color ivory;
  final Color silver;
  final Color coffee;
  final Color stone;

  const AccessibleColors({
    required this.terracotta,
    required this.ivory,
    required this.silver,
    required this.coffee,
    required this.stone,
  });

  @override
  AccessibleColors copyWith({
    Color? terracotta,
    Color? ivory,
    Color? silver,
    Color? coffee,
    Color? stone,
  }) => AccessibleColors(
        terracotta: terracotta ?? this.terracotta,
        ivory: ivory ?? this.ivory,
        silver: silver ?? this.silver,
        coffee: coffee ?? this.coffee,
        stone: stone ?? this.stone,
      );

  @override
  AccessibleColors lerp(ThemeExtension<AccessibleColors>? other, double t) {
    if (other is! AccessibleColors) return this;
    return AccessibleColors(
      terracotta: Color.lerp(terracotta, other.terracotta, t)!,
      ivory: Color.lerp(ivory, other.ivory, t)!,
      silver: Color.lerp(silver, other.silver, t)!,
      coffee: Color.lerp(coffee, other.coffee, t)!,
      stone: Color.lerp(stone, other.stone, t)!,
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadFromPrefs();
  }

  late SharedPreferences _prefs;
  ColorBlindMode _mode = ColorBlindMode.normal;

  ColorBlindMode get mode => _mode;

  AccessibleColors get colors => palettes[_mode]!;

  ThemeData get theme {
    final seed = colors.terracotta;
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colors.ivory,
      appBarTheme: AppBarTheme(backgroundColor: colors.terracotta, foregroundColor: colors.ivory),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: colors.terracotta, foregroundColor: colors.ivory),
      ),
      textTheme: Typography.material2021().englishLike.apply(bodyColor: colors.coffee),
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final idx = _prefs.getInt(_kPrefsKey);
    if (idx != null && idx >= 0 && idx < ColorBlindMode.values.length) {
      _mode = ColorBlindMode.values[idx];
    }
    notifyListeners();
  }

  Future<void> setMode(ColorBlindMode newMode) async {
    _mode = newMode;
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setInt(_kPrefsKey, newMode.index);
    notifyListeners();
  }

  static const AccessibleColors _normal = AccessibleColors(
    terracotta: Color(0xFFE44D2E),
    ivory: Color(0xFFF7F3E3),
    silver: Color(0xFFB3B6B7),
    coffee: Color(0xFF2B2118),
    stone: Color(0xFF5E574D),
  );

static const AccessibleColors _protanopia = AccessibleColors(
  terracotta: Color(0xFF2D7DD2),
  ivory: Color(0xFFF7F3E3),
  silver: Color(0xFFB3B6B7),
  coffee: Color(0xFF212118),
  stone: Color(0xFF57574D),
);


static const AccessibleColors _deuteranopia = AccessibleColors(
  terracotta: Color(0xFF2D7DD2), // blue accent (green-safe)

  ivory: Color(0xFFF7F3E3),
  silver: Color(0xFFB3B6B7),

  coffee: Color(0xFF23231B),
  stone: Color(0xFF5A5A50),
);

static const AccessibleColors _tritanopia = AccessibleColors(
  // Warm accent (orange-brown instead of blue)
  terracotta: Color(0xFFC97A3D),

  ivory: Color(0xFFF7F3E3),
  silver: Color(0xFFB3B6B7),

  coffee: Color(0xFF2B2118),
  stone: Color(0xFF5E574D),
);

static const AccessibleColors _achromatopsia = AccessibleColors(
  // Accent becomes high-contrast gray
  terracotta: Color(0xFF4A4A4A),

  ivory: Color(0xFFF5F5F5),
  silver: Color(0xFFB0B0B0),

  coffee: Color(0xFF1A1A1A),
  stone: Color(0xFF6E6E6E),
);
  static const Map<ColorBlindMode, AccessibleColors> palettes = {
    ColorBlindMode.normal: _normal,
    ColorBlindMode.protanopia: _protanopia,
    ColorBlindMode.deuteranopia: _deuteranopia,
    ColorBlindMode.tritanopia: _tritanopia,
    ColorBlindMode.achromatopsia: _achromatopsia,
  };

  static String modeLabel(ColorBlindMode m) {
    switch (m) {
      case ColorBlindMode.normal:
        return 'Normal';
      case ColorBlindMode.protanopia:
        return 'Protanopia';
      case ColorBlindMode.deuteranopia:
        return 'Deuteranopia';
      case ColorBlindMode.tritanopia:
        return 'Tritanopia';
      case ColorBlindMode.achromatopsia:
        return 'Achromatopsia';
    }
  }
}