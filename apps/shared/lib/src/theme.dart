import 'package:flutter/material.dart';

/// Design tokens: deep navy + cyan, with a light and a dark palette.
/// Colours are getters, so switch [dark] and rebuild the tree (the apps re-key their navigator) to repaint.
/// Names kept from the first palette; roles:
///   tealDeep/teal  navy panels and bars (always dark; text on them uses [cream]/[sand])
///   cream/sand     text and muted text on navy panels
///   marigold       cyan accent (on navy, progress, highlights) · ochre: accent icons on the page
///   maroon         primary actions and prices · danger: errors · heading: titles on the page
///   white          card surface · page: page background · sandLight: input fills, dividers
abstract final class SS {
  static bool dark = false;
  static Color _m(int light, int darkValue) => Color(dark ? darkValue : light);

  static Color get tealDeep => _m(0xFF0A1A33, 0xFF060D1A);
  static Color get teal => _m(0xFF0F2F57, 0xFF12305A);
  static const cream = Color(0xFFEEF6FC);
  static Color get sand => _m(0xFF9FB3CB, 0xFF7C93B0);
  static Color get sandLight => _m(0xFFE4ECF5, 0xFF1B2944);
  static const marigold = Color(0xFF22D3EE);
  static Color get ochre => _m(0xFF0E7490, 0xFF22C3E0);
  static Color get maroon => _m(0xFF0369A1, 0xFF0284C7);
  static Color get danger => _m(0xFFB91C1C, 0xFFF87171);
  static Color get heading => _m(0xFF0F2F57, 0xFF8BD8F8);
  static Color get ink => _m(0xFF0F1B2D, 0xFFE6EEF8);
  static Color get slate => _m(0xFF52627A, 0xFF9CAEC6);
  static Color get slateDark => _m(0xFF334155, 0xFFCBD5E1);
  static Color get verifiedGreen => _m(0xFF15803D, 0xFF22A55A);
  static Color get white => _m(0xFFFFFFFF, 0xFF13203A);
  static Color get page => _m(0xFFF2F6FB, 0xFF0A1220);

  /// Readable text/icon colour for any fill (tiles and badges keep their colour in both modes).
  static Color on(Color fill) => fill.computeLuminance() > 0.35 ? const Color(0xFF0A1A33) : cream;

  static const radius = 20.0;
  static const radiusSmall = 16.0;
  static const radiusLarge = 24.0;
  static const minTap = 56.0;

  static const _pkg = 'packages/shilpsetu_core/';
  static const poppins = '${_pkg}Poppins';
  static const lora = '${_pkg}Lora';

  /// Every Indic script falls back to its Noto face (§8.2).
  static const fontFallback = <String>[
    '${_pkg}NotoSansDevanagari',
    '${_pkg}NotoSansBengali',
    '${_pkg}NotoSansTamil',
    '${_pkg}NotoSansTelugu',
    '${_pkg}NotoSansGujarati',
    '${_pkg}NotoSansGurmukhi',
    '${_pkg}NotoSansKannada',
    '${_pkg}NotoSansMalayalam',
    '${_pkg}NotoSansOriya',
    '${_pkg}NotoSansOlChiki',
    '${_pkg}NotoNastaliqUrdu',
  ];

  static List<BoxShadow> get cardShadow =>
      [BoxShadow(color: Color(dark ? 0x66000000 : 0x140F2F57), blurRadius: 14, offset: const Offset(0, 4))];

  /// Serif storytelling text (artisan story, certificate narrative).
  static TextStyle story([double size = 17]) =>
      TextStyle(fontFamily: lora, fontFamilyFallback: fontFallback, fontSize: size, height: 1.55, color: ink);

  static ThemeData theme() {
    final scheme = ColorScheme(
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: maroon,
      onPrimary: Colors.white,
      secondary: marigold,
      onSecondary: tealDeep,
      tertiary: teal,
      onTertiary: cream,
      error: danger,
      onError: Colors.white,
      surface: page,
      onSurface: ink,
    );
    TextStyle t(double size, FontWeight w, [Color? c]) => TextStyle(
      fontFamily: poppins,
      fontFamilyFallback: fontFallback,
      fontSize: size,
      fontWeight: w,
      color: c ?? ink,
      height: 1.35,
    );
    final text = TextTheme(
      displaySmall: t(32, FontWeight.w700, heading),
      headlineMedium: t(26, FontWeight.w700, heading),
      headlineSmall: t(22, FontWeight.w700, heading),
      titleLarge: t(20, FontWeight.w600, heading),
      titleMedium: t(18, FontWeight.w600),
      titleSmall: t(16, FontWeight.w600),
      bodyLarge: t(17, FontWeight.w400),
      bodyMedium: t(16, FontWeight.w400), // minimum body size 16sp
      bodySmall: t(14, FontWeight.w400, slate),
      labelLarge: t(18, FontWeight.w600), // primary buttons 18sp+
      labelMedium: t(15, FontWeight.w500),
      labelSmall: t(13, FontWeight.w500, slate),
    );
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSmall));
    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: page,
      fontFamily: poppins,
      fontFamilyFallback: fontFallback,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: teal,
        foregroundColor: cream,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: t(20, FontWeight.w700, marigold),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: maroon,
          foregroundColor: Colors.white,
          minimumSize: const Size(minTap, minTap),
          textStyle: t(18, FontWeight.w600, Colors.white),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: heading,
          minimumSize: const Size(minTap, minTap),
          side: BorderSide(color: sand, width: 1.5),
          textStyle: t(17, FontWeight.w600, heading),
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: heading,
          minimumSize: const Size(48, 48),
          textStyle: t(16, FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sandLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusLarge), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: t(16, FontWeight.w400, slate),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: white,
        side: BorderSide(color: sand),
        labelStyle: t(14, FontWeight.w500),
        shape: const StadiumBorder(),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: page),
      dialogTheme: DialogThemeData(backgroundColor: white),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: page),
      listTileTheme: ListTileThemeData(textColor: ink, iconColor: slate),
      snackBarTheme: SnackBarThemeData(backgroundColor: tealDeep, contentTextStyle: t(16, FontWeight.w500, cream)),
      dividerTheme: DividerThemeData(color: sandLight, thickness: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: marigold),
    );
  }
}

/// ₹ formatting with Indian digit grouping (1,45,000).
String rupees(num? v) {
  if (v == null) return '—';
  final s = v.round().toString();
  if (s.length <= 3) return '₹$s';
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '₹${parts.join(',')},$last3';
}
