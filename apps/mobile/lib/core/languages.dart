import 'package:flutter/widgets.dart';

/// A language the artisan can use. [native] is the name in its own script (shown on the picker tiles).
class AppLanguage {
  const AppLanguage(this.code, this.native, this.english, this.ttsLocale, this.sttLocale, {this.rtl = false, this.ui = true});
  final String code;
  final String native;
  final String english;
  final String ttsLocale;
  final String sttLocale;
  final bool rtl;

  /// Whether the app UI is translated into this language (the architecture accepts all 22).
  final bool ui;

  Locale get locale => Locale(code);
}

/// The 14 launch languages (§9.1) first, then the remaining scheduled languages of the Constitution.
const appLanguages = <AppLanguage>[
  AppLanguage('hi', 'हिन्दी', 'Hindi', 'hi-IN', 'hi_IN'),
  AppLanguage('en', 'English', 'English', 'en-IN', 'en_IN'),
  AppLanguage('bn', 'বাংলা', 'Bengali', 'bn-IN', 'bn_IN'),
  AppLanguage('mr', 'मराठी', 'Marathi', 'mr-IN', 'mr_IN'),
  AppLanguage('te', 'తెలుగు', 'Telugu', 'te-IN', 'te_IN'),
  AppLanguage('ta', 'தமிழ்', 'Tamil', 'ta-IN', 'ta_IN'),
  AppLanguage('gu', 'ગુજરાતી', 'Gujarati', 'gu-IN', 'gu_IN'),
  AppLanguage('ur', 'اردو', 'Urdu', 'ur-IN', 'ur_IN', rtl: true),
  AppLanguage('kn', 'ಕನ್ನಡ', 'Kannada', 'kn-IN', 'kn_IN'),
  AppLanguage('or', 'ଓଡ଼ିଆ', 'Odia', 'or-IN', 'or_IN'),
  AppLanguage('ml', 'മലയാളം', 'Malayalam', 'ml-IN', 'ml_IN'),
  AppLanguage('pa', 'ਪੰਜਾਬੀ', 'Punjabi', 'pa-IN', 'pa_IN'),
  AppLanguage('as', 'অসমীয়া', 'Assamese', 'as-IN', 'as_IN'),
  AppLanguage('sat', 'ᱥᱟᱱᱛᱟᱲᱤ', 'Santali', 'hi-IN', 'hi_IN'),
  // Remaining scheduled languages: voice pipeline supported via Bhashini; UI falls back to Hindi/English.
  AppLanguage('brx', 'बड़ो', 'Bodo', 'hi-IN', 'hi_IN', ui: false),
  AppLanguage('doi', 'डोगरी', 'Dogri', 'hi-IN', 'hi_IN', ui: false),
  AppLanguage('ks', 'کٲشُر', 'Kashmiri', 'ur-IN', 'ur_IN', rtl: true, ui: false),
  AppLanguage('kok', 'कोंकणी', 'Konkani', 'mr-IN', 'mr_IN', ui: false),
  AppLanguage('mai', 'मैथिली', 'Maithili', 'hi-IN', 'hi_IN', ui: false),
  AppLanguage('mni', 'মৈতৈলোন্', 'Manipuri', 'bn-IN', 'bn_IN', ui: false),
  AppLanguage('ne', 'नेपाली', 'Nepali', 'ne-NP', 'ne_NP', ui: false),
  AppLanguage('sa', 'संस्कृतम्', 'Sanskrit', 'hi-IN', 'hi_IN', ui: false),
  AppLanguage('sd', 'سنڌي', 'Sindhi', 'ur-IN', 'ur_IN', rtl: true, ui: false),
];

AppLanguage languageFor(String code) =>
    appLanguages.firstWhere((l) => l.code == code, orElse: () => appLanguages.first);

/// UI locale for a language: untranslated scheduled languages fall back to Hindi (or Urdu for RTL scripts).
Locale uiLocaleFor(String code) {
  final l = languageFor(code);
  if (l.ui) return l.locale;
  return l.rtl ? const Locale('ur') : const Locale('hi');
}
