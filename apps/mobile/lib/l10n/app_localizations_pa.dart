// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class L10nPa extends L10n {
  L10nPa([String locale = 'pa']) : super(locale);

  @override
  String get languageName => 'ਪੰਜਾਬੀ';

  @override
  String get appTitle => 'ਸ਼ਿਲਪਸੇਤੂ';

  @override
  String get tagline => 'ਹਾਸ਼ੀਏ ਦੇ ਕਾਰੀਗਰਾਂ ਦਾ AI ਸਹਿ-ਵਿਕਰੇਤਾ';

  @override
  String get heroLine =>
      'ਹੱਥ ਦੇ ਹੁਨਰ ਤੋਂ ਸੁਰਖੀਆਂ ਤੱਕ — ਹਰ ਕਲਾ, ਹਮੇਸ਼ਾ ਬਾਜ਼ਾਰ ਵਿੱਚ।';

  @override
  String get promise =>
      'ਇੱਕ ਫ਼ੋਟੋ। ਇੱਕ ਬੋਲਿਆ ਵਾਕ। ਸਹੀ ਮੁੱਲ ਵਾਲੀ, ਭਰੋਸੇਯੋਗ ਸੂਚੀ — ਨਾ ਟਾਈਪਿੰਗ, ਨਾ ਵਿਚੋਲਾ, ਨਾ ਅੰਗਰੇਜ਼ੀ ਦੀ ਲੋੜ।';

  @override
  String get next => 'ਅੱਗੇ';

  @override
  String get back => 'ਪਿੱਛੇ';

  @override
  String get retry => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get save => 'ਸੰਭਾਲੋ';

  @override
  String get cancel => 'ਰੱਦ ਕਰੋ';

  @override
  String get done => 'ਹੋ ਗਿਆ';

  @override
  String get skip => 'ਛੱਡੋ';

  @override
  String get yes => 'ਹਾਂ';

  @override
  String get no => 'ਨਹੀਂ';

  @override
  String get loading => 'ਕਿਰਪਾ ਕਰਕੇ ਉਡੀਕ ਕਰੋ…';

  @override
  String get errorGeneric => 'ਕੁਝ ਗਲਤ ਹੋ ਗਿਆ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get errorNetwork =>
      'ਨੈੱਟਵਰਕ ਨਹੀਂ ਹੈ। ਤੁਹਾਡਾ ਕੰਮ ਫ਼ੋਨ ਵਿੱਚ ਸੁਰੱਖਿਅਤ ਹੈ।';

  @override
  String get savedOnPhone =>
      'ਫ਼ੋਨ ਵਿੱਚ ਸੰਭਾਲਿਆ — ਨੈੱਟਵਰਕ ਆਉਂਦੇ ਹੀ ਅੱਪਲੋਡ ਹੋ ਜਾਵੇਗਾ';

  @override
  String get allSynced => 'ਸਭ ਅੱਪਲੋਡ ਹੋ ਗਿਆ';

  @override
  String get syncing => 'ਅੱਪਲੋਡ ਹੋ ਰਿਹਾ ਹੈ…';

  @override
  String pendingCount(int count) {
    return '$count ਅੱਪਲੋਡ ਬਾਕੀ';
  }

  @override
  String get chooseRole => 'ਤੁਸੀਂ ਕੌਣ ਹੋ?';

  @override
  String get roleArtisan => 'ਮੈਂ ਦਸਤਕਾਰੀ ਬਣਾਉਂਦੀ/ਬਣਾਉਂਦਾ ਹਾਂ';

  @override
  String get roleBuyer => 'ਮੈਂ ਖਰੀਦਣਾ ਚਾਹੁੰਦਾ/ਚਾਹੁੰਦੀ ਹਾਂ';

  @override
  String get roleKiosk => 'ਕਿਓਸਕ / CSC ਸਹਾਇਕ';

  @override
  String get chooseLanguage => 'ਆਪਣੀ ਭਾਸ਼ਾ ਚੁਣੋ';

  @override
  String get tapToHear => 'ਸੁਣਨ ਲਈ ਇੱਕ ਵਾਰ ਛੂਹੋ, ਚੁਣਨ ਲਈ ਦੁਬਾਰਾ ਛੂਹੋ';

  @override
  String get enterPhone => 'ਤੁਹਾਡਾ ਮੋਬਾਈਲ ਨੰਬਰ';

  @override
  String get sendCode => 'ਕੋਡ ਭੇਜੋ';

  @override
  String get enterCode => '6 ਅੰਕਾਂ ਦਾ ਕੋਡ ਪਾਓ';

  @override
  String codeSentTo(String phone) {
    return '$phone ਤੇ ਕੋਡ ਭੇਜਿਆ';
  }

  @override
  String get verify => 'ਪੁਸ਼ਟੀ ਕਰੋ';

  @override
  String get sayNumber => 'ਆਪਣਾ ਨੰਬਰ ਬੋਲੋ';

  @override
  String demoCode(String code) {
    return 'ਡੈਮੋ ਕੋਡ: $code';
  }

  @override
  String get consentTitle => 'ਤੁਹਾਡੀ ਇਜਾਜ਼ਤ';

  @override
  String get consentBody =>
      'ਤੁਹਾਡੀ ਦਸਤਕਾਰੀ ਵੇਚਣ ਲਈ ਸ਼ਿਲਪਸੇਤੂ ਤੁਹਾਡੀ ਆਵਾਜ਼, ਤੁਹਾਡੀਆਂ ਫ਼ੋਟੋਆਂ ਅਤੇ ਤੁਹਾਡੇ ਪਿੰਡ ਦਾ ਪਤਾ ਸੰਭਾਲੇਗਾ। ਤੁਸੀਂ ਇਹਨਾਂ ਨੂੰ ਕਦੇ ਵੀ ਮਿਟਾ ਸਕਦੇ ਹੋ।';

  @override
  String get consentVoice => 'ਮੇਰੀ ਆਵਾਜ਼ ਸੰਭਾਲੋ';

  @override
  String get consentPhoto => 'ਮੇਰੀਆਂ ਫ਼ੋਟੋਆਂ ਸੰਭਾਲੋ';

  @override
  String get consentLocation => 'ਮੇਰੇ ਪਿੰਡ ਦਾ ਪਤਾ ਸੰਭਾਲੋ';

  @override
  String get iAgree => 'ਹਾਂ, ਮੈਂ ਸਹਿਮਤ ਹਾਂ';

  @override
  String get sayYesToAgree => 'ਜਾਂ ਸਹਿਮਤੀ ਲਈ “ਹਾਂ” ਬੋਲੋ';

  @override
  String get profileTitle => 'ਆਪਣੇ ਬਾਰੇ ਦੱਸੋ';

  @override
  String get askName => 'ਤੁਹਾਡਾ ਨਾਮ ਕੀ ਹੈ?';

  @override
  String get askVillage => 'ਤੁਸੀਂ ਕਿਹੜੇ ਪਿੰਡ ਜਾਂ ਸ਼ਹਿਰ ਤੋਂ ਹੋ?';

  @override
  String get askState => 'ਕਿਹੜਾ ਜ਼ਿਲ੍ਹਾ ਅਤੇ ਰਾਜ?';

  @override
  String get askCraft => 'ਤੁਸੀਂ ਕਿਹੜੀ ਦਸਤਕਾਰੀ ਕਰਦੇ ਹੋ?';

  @override
  String get askYears => 'ਕਿੰਨੇ ਸਾਲਾਂ ਤੋਂ ਇਹ ਕੰਮ ਕਰ ਰਹੇ ਹੋ?';

  @override
  String get askStory => 'ਆਪਣੀ ਕਹਾਣੀ ਦੱਸੋ — ਇਹ ਕਲਾ ਕਿਵੇਂ ਸਿੱਖੀ?';

  @override
  String get askPehchan =>
      'ਜੇ ਤੁਹਾਡੇ ਕੋਲ ਪਹਿਚਾਣ ਕਾਰੀਗਰ ਕਾਰਡ ਹੈ ਤਾਂ ਉਸਦਾ ਨੰਬਰ ਬੋਲੋ। ਨਹੀਂ ਤਾਂ ਛੱਡੋ ਦਬਾਓ।';

  @override
  String get tapMicToAnswer => 'ਮਾਈਕ ਦਬਾਓ ਅਤੇ ਜਵਾਬ ਦਿਓ';

  @override
  String get weHeard => 'ਅਸੀਂ ਸੁਣਿਆ:';

  @override
  String get profileSaved => 'ਤੁਹਾਡੀ ਜਾਣਕਾਰੀ ਸੰਭਾਲ ਲਈ ਗਈ';

  @override
  String greeting(String name) {
    return 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ, $name';
  }

  @override
  String get tileAddProduct => 'ਚੀਜ਼ ਜੋੜੋ';

  @override
  String get tileMyProducts => 'ਮੇਰੀਆਂ ਚੀਜ਼ਾਂ';

  @override
  String get tileOrders => 'ਆਰਡਰ';

  @override
  String get tileEarnings => 'ਕਮਾਈ';

  @override
  String get tileHelp => 'ਮਦਦ';

  @override
  String earningsSummary(String amount, int count) {
    return 'ਇਸ ਮਹੀਨੇ ਤੁਸੀਂ $count ਆਰਡਰਾਂ ਤੋਂ $amount ਕਮਾਏ';
  }

  @override
  String get addProductTitle => 'ਚੀਜ਼ ਜੋੜੋ';

  @override
  String get speakOwnLanguage => 'ਆਪਣੀ ਭਾਸ਼ਾ ਵਿੱਚ ਬੋਲੋ';

  @override
  String listeningIn(String language) {
    return '$language ਵਿੱਚ ਸੁਣ ਰਹੇ ਹਾਂ…';
  }

  @override
  String get tapToSpeak => 'ਬੋਲਣ ਲਈ ਦਬਾਓ, ਜਾਂ ਦਬਾ ਕੇ ਰੱਖੋ';

  @override
  String get stopRecording => 'ਰੋਕਣ ਲਈ ਦਬਾਓ';

  @override
  String get photoCaptured =>
      'ਫ਼ੋਟੋ ਲੈ ਲਈ — ਪਿਛੋਕੜ ਅਤੇ ਰੋਸ਼ਨੀ ਆਪਣੇ ਆਪ ਠੀਕ ਹੋ ਰਹੀ ਹੈ';

  @override
  String get takePhoto => 'ਫ਼ੋਟੋ ਲਓ';

  @override
  String get addMorePhotos => 'ਹੋਰ ਫ਼ੋਟੋਆਂ ਜੋੜੋ';

  @override
  String get makeListing => 'ਮੇਰੀ ਸੂਚੀ ਬਣਾਓ';

  @override
  String get hintTooDark => 'ਥੋੜ੍ਹਾ ਹਨੇਰਾ ਹੈ — ਹੋ ਸਕੇ ਤਾਂ ਰੋਸ਼ਨੀ ਵੱਲ ਜਾਓ';

  @override
  String get hintTooBright => 'ਰੋਸ਼ਨੀ ਬਹੁਤ ਹੈ — ਥੋੜ੍ਹੀ ਛਾਂ ਵਿੱਚ ਜਾਓ';

  @override
  String get hintMoveCloser => 'ਥੋੜ੍ਹਾ ਨੇੜੇ ਆਓ';

  @override
  String get hintBlurry => 'ਫ਼ੋਨ ਨੂੰ ਸਥਿਰ ਰੱਖੋ';

  @override
  String get anyBackground => 'ਕੋਈ ਵੀ ਰੋਸ਼ਨੀ, ਕੋਈ ਵੀ ਪਿਛੋਕੜ ਚੱਲੇਗਾ';

  @override
  String get upTo60s => '60 ਸਕਿੰਟ ਤੱਕ';

  @override
  String get aiBuilding => 'AI ਤੁਹਾਡੀ ਸੂਚੀ ਬਣਾ ਰਿਹਾ ਹੈ';

  @override
  String get stepAsr => 'ਤੁਹਾਡੀ ਆਵਾਜ਼ ਸਮਝ ਰਹੇ ਹਾਂ';

  @override
  String get stepNlu => 'ਵੇਰਵੇ ਲੱਭ ਰਹੇ ਹਾਂ';

  @override
  String get stepListing => 'ਨਾਮ ਅਤੇ ਵੇਰਵਾ ਲਿਖ ਰਹੇ ਹਾਂ';

  @override
  String get stepTranslation => 'ਖਰੀਦਦਾਰਾਂ ਲਈ ਅਨੁਵਾਦ ਕਰ ਰਹੇ ਹਾਂ';

  @override
  String get stepImage => 'ਤੁਹਾਡੀ ਫ਼ੋਟੋ ਸੁਧਾਰ ਰਹੇ ਹਾਂ';

  @override
  String get stepPrice => 'ਸਹੀ ਮੁੱਲ ਕੱਢ ਰਹੇ ਹਾਂ';

  @override
  String get stepCertificate => 'ਤੁਹਾਡਾ ਸਰਟੀਫ਼ਿਕੇਟ ਤਿਆਰ ਕਰ ਰਹੇ ਹਾਂ';

  @override
  String get quickQuestions => 'ਕੁਝ ਛੋਟੇ ਸਵਾਲ';

  @override
  String get answerBySpeaking => 'ਬੋਲ ਕੇ ਜਵਾਬ ਦਿਓ';

  @override
  String get reviewTitle => 'ਜਾਂਚੋ ਅਤੇ ਮਨਜ਼ੂਰ ਕਰੋ';

  @override
  String get approve => 'ਮਨਜ਼ੂਰ ਕਰੋ';

  @override
  String get changePrice => 'ਮੁੱਲ ਬਦਲੋ';

  @override
  String get retakePhoto => 'ਦੁਬਾਰਾ ਫ਼ੋਟੋ ਲਓ';

  @override
  String get reRecord => 'ਦੁਬਾਰਾ ਬੋਲੋ';

  @override
  String get sayNewPrice => 'ਨਵਾਂ ਮੁੱਲ ਬੋਲੋ';

  @override
  String youGet(String amount, String pct) {
    return 'ਤੁਹਾਨੂੰ ਮਿਲਣਗੇ $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'ਬਾਜ਼ਾਰ ਭਾਅ $low – $high';
  }

  @override
  String get fairPrice => 'ਸਹੀ ਮੁੱਲ';

  @override
  String get category => 'ਸ਼੍ਰੇਣੀ';

  @override
  String priceSpoken(String price, String amount) {
    return 'ਮੁੱਲ $price। ਤੁਹਾਨੂੰ ਮਿਲਣਗੇ $amount।';
  }

  @override
  String get belowFairWage => 'ਇਹ ਤੁਹਾਡੀ ਮਿਹਨਤ ਦੀ ਸਹੀ ਮਜ਼ਦੂਰੀ ਤੋਂ ਘੱਟ ਹੈ';

  @override
  String get isLive => 'ਤੁਹਾਡੀ ਚੀਜ਼ ਹੁਣ ਵਿਕਰੀ ਤੇ ਹੈ!';

  @override
  String get onOndc => 'ONDC ਨੈੱਟਵਰਕ ਤੇ ਵੀ ਹੈ';

  @override
  String get certificateReady => 'ਤੁਹਾਡਾ ਸਰਟੀਫ਼ਿਕੇਟ ਤਿਆਰ ਹੈ';

  @override
  String get statusQueued => 'ਕਤਾਰ ਵਿੱਚ';

  @override
  String get statusUploading => 'ਅੱਪਲੋਡ ਹੋ ਰਿਹਾ';

  @override
  String get statusProcessing => 'ਤਿਆਰ ਹੋ ਰਿਹਾ';

  @override
  String get statusNeedsReview => 'ਜਾਂਚ ਜ਼ਰੂਰੀ';

  @override
  String get statusReady => 'ਮਨਜ਼ੂਰੀ ਲਈ ਤਿਆਰ';

  @override
  String get statusLive => 'ਵਿਕਰੀ ਤੇ';

  @override
  String get statusFailed => 'ਧਿਆਨ ਦਿਓ';

  @override
  String get statusUnpublished => 'ਲੁਕਿਆ ਹੋਇਆ';

  @override
  String get noProducts => 'ਹਾਲੇ ਕੋਈ ਚੀਜ਼ ਨਹੀਂ। ਚੀਜ਼ ਜੋੜੋ ਦਬਾਓ।';

  @override
  String get newOrder => 'ਨਵਾਂ ਆਰਡਰ';

  @override
  String get accept => 'ਸਵੀਕਾਰ ਕਰੋ';

  @override
  String get decline => 'ਇਨਕਾਰ ਕਰੋ';

  @override
  String get markPacked => 'ਪੈਕ ਹੋ ਗਿਆ';

  @override
  String get markShipped => 'ਭੇਜ ਦਿੱਤਾ';

  @override
  String get noOrders => 'ਹਾਲੇ ਕੋਈ ਆਰਡਰ ਨਹੀਂ';

  @override
  String get orderPlaced => 'ਨਵਾਂ';

  @override
  String get orderAccepted => 'ਸਵੀਕਾਰ';

  @override
  String get orderPacked => 'ਪੈਕ';

  @override
  String get orderShipped => 'ਰਸਤੇ ਵਿੱਚ';

  @override
  String get orderDelivered => 'ਪਹੁੰਚ ਗਿਆ';

  @override
  String get orderDeclined => 'ਇਨਕਾਰ';

  @override
  String get orderCancelled => 'ਰੱਦ';

  @override
  String get gross => 'ਵਿਕਰੀ';

  @override
  String get commission => 'ਪਲੇਟਫ਼ਾਰਮ ਫ਼ੀਸ';

  @override
  String get logistics => 'ਡਿਲੀਵਰੀ';

  @override
  String get net => 'ਤੁਹਾਨੂੰ ਮਿਲੇ';

  @override
  String get everyRupee => 'ਹਰ ਰੁਪਏ ਦਾ ਹਿਸਾਬ';

  @override
  String get helpTitle => 'ਮਦਦ';

  @override
  String get callHelpline => 'ਹੈਲਪਲਾਈਨ ਤੇ ਫ਼ੋਨ ਕਰੋ';

  @override
  String get requestCallback => 'ਸਹਾਇਕ ਮੈਨੂੰ ਫ਼ੋਨ ਕਰੇ';

  @override
  String get callbackRequested => 'ਇੱਕ ਸਹਾਇਕ ਜਲਦੀ ਤੁਹਾਨੂੰ ਫ਼ੋਨ ਕਰੇਗਾ';

  @override
  String get howToUse => 'ਸ਼ਿਲਪਸੇਤੂ ਕਿਵੇਂ ਕੰਮ ਕਰਦਾ ਹੈ';

  @override
  String get fiveSteps =>
      'ਬੋਲੋ · ਫ਼ੋਟੋ ਲਓ · AI ਬਣਾਉਂਦਾ ਹੈ · ਤੁਸੀਂ ਮਨਜ਼ੂਰ ਕਰੋ · ਵਿਕਰੀ ਤੇ';

  @override
  String get searchHint => 'ਦਸਤਕਾਰੀ, ਰਾਜ, ਕਾਰੀਗਰ ਖੋਜੋ';

  @override
  String get freshFromLoom => 'ਖੱਡੀ ਅਤੇ ਚੱਕ ਤੋਂ ਤਾਜ਼ਾ';

  @override
  String get byCraft => 'ਕਲਾ ਅਨੁਸਾਰ';

  @override
  String get byState => 'ਰਾਜ ਅਤੇ ਕਲੱਸਟਰ ਅਨੁਸਾਰ';

  @override
  String get womenLed => 'ਔਰਤਾਂ ਦੀ ਅਗਵਾਈ ਵਾਲੇ ਸਮੂਹ';

  @override
  String get giTagged => 'GI-ਟੈਗ ਵਾਲੀ ਦਸਤਕਾਰੀ';

  @override
  String get nearYou => 'ਤੁਹਾਡੇ ਨੇੜੇ';

  @override
  String get filters => 'ਫ਼ਿਲਟਰ';

  @override
  String get verifiedOnly => 'ਸਿਰਫ਼ ਤਸਦੀਕਸ਼ੁਦਾ ਕਾਰੀਗਰ';

  @override
  String get giOnly => 'ਸਿਰਫ਼ GI-ਟੈਗ';

  @override
  String get sortBy => 'ਤਰਤੀਬ';

  @override
  String get sortRelevance => 'ਸਭ ਤੋਂ ਢੁਕਵਾਂ';

  @override
  String get sortPriceLow => 'ਮੁੱਲ: ਘੱਟ ਤੋਂ ਵੱਧ';

  @override
  String get sortPriceHigh => 'ਮੁੱਲ: ਵੱਧ ਤੋਂ ਘੱਟ';

  @override
  String get sortNewest => 'ਸਭ ਤੋਂ ਨਵੇਂ';

  @override
  String results(int count) {
    return '$count ਦਸਤਕਾਰੀਆਂ';
  }

  @override
  String get addToCart => 'ਕਾਰਟ ਵਿੱਚ ਪਾਓ';

  @override
  String get addedToCart => 'ਕਾਰਟ ਵਿੱਚ ਪਾ ਦਿੱਤਾ';

  @override
  String get scanCertificate => 'ਕਾਰੀਗਰ ਸਰਟੀਫ਼ਿਕੇਟ ਲਈ ਸਕੈਨ ਕਰੋ';

  @override
  String get certificateSub => 'ਸਮੱਗਰੀ, ਕਹਾਣੀ ਅਤੇ ਮੁੱਲ ਦਾ ਆਧਾਰ';

  @override
  String get howPriceBuilt => 'ਇਹ ਮੁੱਲ ਕਿਵੇਂ ਬਣਿਆ';

  @override
  String goesToArtisan(String amount, String pct) {
    return 'ਇਸ ਵਿੱਚੋਂ $amount ਸਿੱਧੇ ਕਾਰੀਗਰ ਨੂੰ ਜਾਂਦੇ ਹਨ ($pct%)';
  }

  @override
  String get meetArtisan => 'ਕਾਰੀਗਰ ਨੂੰ ਮਿਲੋ';

  @override
  String get hearVoice => 'ਉਹਨਾਂ ਦੀ ਆਵਾਜ਼ ਸੁਣੋ';

  @override
  String get moreFromArtisan => 'ਇਸ ਕਾਰੀਗਰ ਦੀਆਂ ਹੋਰ ਚੀਜ਼ਾਂ';

  @override
  String reviewsCount(int count) {
    return '($count ਸਮੀਖਿਆਵਾਂ)';
  }

  @override
  String get verifiedArtisan => 'ਤਸਦੀਕਸ਼ੁਦਾ ਕਾਰੀਗਰ';

  @override
  String get cart => 'ਕਾਰਟ';

  @override
  String get cartEmpty => 'ਤੁਹਾਡਾ ਕਾਰਟ ਖਾਲੀ ਹੈ';

  @override
  String get checkout => 'ਚੈੱਕਆਊਟ';

  @override
  String get placeOrder => 'ਆਰਡਰ ਕਰੋ';

  @override
  String get payUpi => 'UPI ਨਾਲ ਭੁਗਤਾਨ';

  @override
  String get cod => 'ਡਿਲੀਵਰੀ ਤੇ ਨਕਦ';

  @override
  String deliveryIn(int days) {
    return 'ਲਗਭਗ $days ਦਿਨਾਂ ਵਿੱਚ ਡਿਲੀਵਰੀ';
  }

  @override
  String get shippingIncluded => 'ਡਿਲੀਵਰੀ ਅਤੇ ਪੈਕਿੰਗ ਸਹੀ ਮੁੱਲ ਵਿੱਚ ਸ਼ਾਮਲ ਹੈ';

  @override
  String get orderPlacedThanks => 'ਧੰਨਵਾਦ! ਤੁਹਾਡਾ ਆਰਡਰ ਹੋ ਗਿਆ।';

  @override
  String get myOrders => 'ਮੇਰੇ ਆਰਡਰ';

  @override
  String get rateCraft => 'ਇਸ ਦਸਤਕਾਰੀ ਨੂੰ ਰੇਟਿੰਗ ਦਿਓ';

  @override
  String get scanQr => 'ਸਰਟੀਫ਼ਿਕੇਟ QR ਸਕੈਨ ਕਰੋ';

  @override
  String get certValid => 'ਅਸਲੀ — ਸ਼ਿਲਪਸੇਤੂ ਵੱਲੋਂ ਤਸਦੀਕਸ਼ੁਦਾ';

  @override
  String get certInvalid => 'ਜਾਇਜ਼ ਨਹੀਂ';

  @override
  String get name => 'ਨਾਮ';

  @override
  String get address => 'ਪਤਾ';

  @override
  String get city => 'ਸ਼ਹਿਰ';

  @override
  String get state => 'ਰਾਜ';

  @override
  String get pincode => 'ਪਿੰਨ ਕੋਡ';

  @override
  String get phone => 'ਫ਼ੋਨ';

  @override
  String get total => 'ਕੁੱਲ';

  @override
  String get kioskTitle => 'ਕਿਓਸਕ';

  @override
  String get myArtisans => 'ਕਾਰੀਗਰ';

  @override
  String get onboardArtisan => 'ਕਾਰੀਗਰ ਜੋੜੋ';

  @override
  String captureFor(String name) {
    return '$name ਲਈ';
  }

  @override
  String get batchMode => 'ਪ੍ਰਦਰਸ਼ਨੀ ਬੈਚ ਮੋਡ';

  @override
  String get printTags => 'ਸਰਟੀਫ਼ਿਕੇਟ ਟੈਗ ਛਾਪੋ';

  @override
  String get syncAll => 'ਸਭ ਅੱਪਲੋਡ ਕਰੋ';

  @override
  String get attestation =>
      'ਮੈਂ ਉਹਨਾਂ ਦੀ ਪਛਾਣ ਜਾਂਚੀ ਅਤੇ ਉਹਨਾਂ ਦੀ ਬੋਲੀ ਸਹਿਮਤੀ ਰਿਕਾਰਡ ਕੀਤੀ';

  @override
  String get recordConsent => 'ਕਾਰੀਗਰ ਦੀ ਸਹਿਮਤੀ ਰਿਕਾਰਡ ਕਰੋ';

  @override
  String get about => 'ਜਾਣ-ਪਛਾਣ';

  @override
  String get logout => 'ਲੌਗ ਆਊਟ';

  @override
  String get lowBandwidth => 'ਘੱਟ ਡਾਟਾ ਮੋਡ';

  @override
  String get switchRole => 'ਮੋਡ ਬਦਲੋ';

  @override
  String productsCount(int count) {
    return '$count ਚੀਜ਼ਾਂ';
  }

  @override
  String get gender => 'ਲਿੰਗ (ਵਿਕਲਪਿਕ)';

  @override
  String get genderFemale => 'ਔਰਤ';

  @override
  String get genderMale => 'ਮਰਦ';

  @override
  String get genderOther => 'ਹੋਰ';

  @override
  String get genderPreferNot => 'ਨਹੀਂ ਦੱਸਣਾ';

  @override
  String get typeInstead => 'ਜਾਂ ਜਵਾਬ ਲਿਖੋ';

  @override
  String get send => 'ਭੇਜੋ';

  @override
  String get serverAddress => 'ਸਰਵਰ ਦਾ ਪਤਾ';

  @override
  String get serverAddressHint => 'ਸਿਰਫ਼ ਸਹਾਇਕ ਦੇ ਕਹਿਣ \'ਤੇ ਬਦਲੋ';

  @override
  String get saved => 'ਸੰਭਾਲਿਆ';

  @override
  String get darkMode => 'ਡਾਰਕ ਮੋਡ';

  @override
  String get lightMode => 'ਲਾਈਟ ਮੋਡ';

  @override
  String get productDetails => 'ਚੀਜ਼ ਦੀ ਜਾਣਕਾਰੀ';

  @override
  String get aboutArtForm => 'ਇਸ ਕਲਾ ਬਾਰੇ';

  @override
  String get howItsMade => 'ਕਿਵੇਂ ਬਣਦੀ ਹੈ';

  @override
  String get didYouKnow => 'ਕੀ ਤੁਸੀਂ ਜਾਣਦੇ ਹੋ?';

  @override
  String yearsOfPractice(int count) {
    return '$count ਸਾਲ ਦਾ ਤਜਰਬਾ';
  }

  @override
  String get photoCredits => 'ਫੋਟੋ ਧੰਨਵਾਦ';

  @override
  String get photoCreditsSub =>
      'ਵਿਕੀਮੀਡੀਆ ਕਾਮਨਜ਼ ਤੋਂ ਅਸਲ ਦਸਤਕਾਰੀ ਦੀਆਂ ਫੋਟੋਆਂ, ਲਾਇਸੈਂਸ ਮੁਤਾਬਕ';

  @override
  String get askShilpi => 'ਸ਼ਿਲਪੀ ਨੂੰ ਪੁੱਛੋ';

  @override
  String get assistantName => 'ਸ਼ਿਲਪੀ';

  @override
  String get assistantTagline => 'ਤੁਹਾਡੀ ਸ਼ਿਲਪਸੇਤੂ ਸਹਾਇਕ';

  @override
  String get assistantThinking => 'ਸੋਚ ਰਹੀ ਹਾਂ…';

  @override
  String get askAnything => 'ਕੁਝ ਵੀ ਪੁੱਛੋ';

  @override
  String get close => 'ਬੰਦ ਕਰੋ';

  @override
  String get dayStreak => 'ਦਿਨਾਂ ਦੀ ਲੜੀ';

  @override
  String get todaysGoal => 'ਅੱਜ ਦਾ ਟੀਚਾ';

  @override
  String get craftOfTheDay => 'ਅੱਜ ਦੀ ਕਲਾ';

  @override
  String get exploreCraft => 'ਵੇਖੋ';

  @override
  String get celebrateLive => 'ਤੁਹਾਡੀ ਚੀਜ਼ ਲਾਈਵ ਹੋ ਗਈ!';

  @override
  String get micPermission =>
      'ਕਿਰਪਾ ਕਰਕੇ ਮਾਈਕ ਦੀ ਇਜਾਜ਼ਤ ਦਿਓ: ਸੈਟਿੰਗਾਂ → ਐਪਾਂ → ਸ਼ਿਲਪਸੇਤੂ → ਇਜਾਜ਼ਤਾਂ → ਮਾਈਕ੍ਰੋਫ਼ੋਨ।';

  @override
  String get micUnavailable =>
      'ਇਸ ਫ਼ੋਨ ਵਿੱਚ ਬੋਲ ਕੇ ਲਿਖਣ ਦੀ ਸਹੂਲਤ ਨਹੀਂ। Google ਵੌਇਸ ਟਾਈਪਿੰਗ ਚਾਲੂ ਕਰੋ, ਜਾਂ ਲਿਖ ਕੇ ਦੱਸੋ।';

  @override
  String get micInsecure =>
      'ਮਾਈਕ ਸਿਰਫ਼ ਸ਼ਿਲਪਸੇਤੂ ਐਪ ਵਿੱਚ ਜਾਂ ਸੁਰੱਖਿਅਤ https ਲਿੰਕ \'ਤੇ ਚੱਲਦਾ ਹੈ। ਕਿਰਪਾ ਕਰਕੇ ਐਪ ਵਰਤੋ।';

  @override
  String get micNoSpeech => 'ਆਵਾਜ਼ ਨਹੀਂ ਸੁਣੀ। ਮਾਈਕ ਦਬਾ ਕੇ ਥੋੜ੍ਹਾ ਉੱਚਾ ਬੋਲੋ।';

  @override
  String get micNetwork => 'ਬੋਲ ਕੇ ਲਿਖਣ ਲਈ ਇੰਟਰਨੈੱਟ ਚਾਹੀਦਾ ਹੈ। ਕਨੈਕਸ਼ਨ ਵੇਖੋ।';

  @override
  String get pressBackAgain => 'ਬੰਦ ਕਰਨ ਲਈ ਦੁਬਾਰਾ ਪਿੱਛੇ ਦਬਾਓ';
}
