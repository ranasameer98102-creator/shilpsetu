// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class L10nKn extends L10n {
  L10nKn([String locale = 'kn']) : super(locale);

  @override
  String get languageName => 'ಕನ್ನಡ';

  @override
  String get appTitle => 'ಶಿಲ್ಪಸೇತು';

  @override
  String get tagline => 'ಅಂಚಿನಲ್ಲಿರುವ ಕುಶಲಕರ್ಮಿಗಳ AI ಸಹ-ಮಾರಾಟಗಾರ';

  @override
  String get heroLine =>
      'ಕೈಕೆಲಸದಿಂದ ಮುಖ್ಯಾಂಶದವರೆಗೆ — ಪ್ರತಿ ಕರಕುಶಲ, ಯಾವಾಗಲೂ ಮಾರುಕಟ್ಟೆಯಲ್ಲಿ.';

  @override
  String get promise =>
      'ಒಂದು ಫೋಟೋ. ಒಂದು ಹೇಳಿದ ವಾಕ್ಯ. ನ್ಯಾಯಯುತ ಬೆಲೆಯ, ನಂಬಲರ್ಹ ಪಟ್ಟಿ — ಟೈಪಿಂಗ್ ಇಲ್ಲ, ಮಧ್ಯವರ್ತಿ ಇಲ್ಲ, ಇಂಗ್ಲಿಷ್ ಬೇಕಿಲ್ಲ.';

  @override
  String get next => 'ಮುಂದೆ';

  @override
  String get back => 'ಹಿಂದೆ';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get save => 'ಉಳಿಸಿ';

  @override
  String get cancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get done => 'ಆಯಿತು';

  @override
  String get skip => 'ಬಿಟ್ಟುಬಿಡಿ';

  @override
  String get yes => 'ಹೌದು';

  @override
  String get no => 'ಇಲ್ಲ';

  @override
  String get loading => 'ದಯವಿಟ್ಟು ಕಾಯಿರಿ…';

  @override
  String get errorGeneric => 'ಏನೋ ತಪ್ಪಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorNetwork =>
      'ನೆಟ್‌ವರ್ಕ್ ಇಲ್ಲ. ನಿಮ್ಮ ಕೆಲಸ ಫೋನ್‌ನಲ್ಲಿ ಸುರಕ್ಷಿತವಾಗಿದೆ.';

  @override
  String get savedOnPhone =>
      'ಫೋನ್‌ನಲ್ಲಿ ಉಳಿಸಲಾಗಿದೆ — ನೆಟ್‌ವರ್ಕ್ ಬಂದ ತಕ್ಷಣ ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತದೆ';

  @override
  String get allSynced => 'ಎಲ್ಲವೂ ಅಪ್‌ಲೋಡ್ ಆಗಿದೆ';

  @override
  String get syncing => 'ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String pendingCount(int count) {
    return '$count ಅಪ್‌ಲೋಡ್ ಬಾಕಿ';
  }

  @override
  String get chooseRole => 'ನೀವು ಯಾರು?';

  @override
  String get roleArtisan => 'ನಾನು ಕರಕುಶಲ ವಸ್ತು ತಯಾರಿಸುತ್ತೇನೆ';

  @override
  String get roleBuyer => 'ನಾನು ಖರೀದಿಸಬೇಕು';

  @override
  String get roleKiosk => 'ಕಿಯೋಸ್ಕ್ / CSC ಸಹಾಯಕ';

  @override
  String get chooseLanguage => 'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆರಿಸಿ';

  @override
  String get tapToHear => 'ಕೇಳಲು ಒಮ್ಮೆ ಮುಟ್ಟಿ, ಆರಿಸಲು ಮತ್ತೆ ಮುಟ್ಟಿ';

  @override
  String get enterPhone => 'ನಿಮ್ಮ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ';

  @override
  String get sendCode => 'ಕೋಡ್ ಕಳುಹಿಸಿ';

  @override
  String get enterCode => '6 ಅಂಕಿಯ ಕೋಡ್ ನಮೂದಿಸಿ';

  @override
  String codeSentTo(String phone) {
    return '$phoneಗೆ ಕೋಡ್ ಕಳುಹಿಸಲಾಗಿದೆ';
  }

  @override
  String get verify => 'ಪರಿಶೀಲಿಸಿ';

  @override
  String get sayNumber => 'ನಿಮ್ಮ ಸಂಖ್ಯೆ ಹೇಳಿ';

  @override
  String demoCode(String code) {
    return 'ಡೆಮೋ ಕೋಡ್: $code';
  }

  @override
  String get consentTitle => 'ನಿಮ್ಮ ಅನುಮತಿ';

  @override
  String get consentBody =>
      'ನಿಮ್ಮ ಕರಕುಶಲ ವಸ್ತು ಮಾರಲು ಶಿಲ್ಪಸೇತು ನಿಮ್ಮ ಧ್ವನಿ, ನಿಮ್ಮ ಫೋಟೋಗಳು ಮತ್ತು ನಿಮ್ಮ ಊರಿನ ವಿಳಾಸವನ್ನು ಉಳಿಸುತ್ತದೆ. ನೀವು ಯಾವಾಗ ಬೇಕಾದರೂ ಅವನ್ನು ಅಳಿಸಬಹುದು.';

  @override
  String get consentVoice => 'ನನ್ನ ಧ್ವನಿ ಉಳಿಸಿ';

  @override
  String get consentPhoto => 'ನನ್ನ ಫೋಟೋಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String get consentLocation => 'ನನ್ನ ಊರಿನ ವಿಳಾಸ ಉಳಿಸಿ';

  @override
  String get iAgree => 'ಹೌದು, ನಾನು ಒಪ್ಪುತ್ತೇನೆ';

  @override
  String get sayYesToAgree => 'ಅಥವಾ ಒಪ್ಪಲು “ಹೌದು” ಎಂದು ಹೇಳಿ';

  @override
  String get profileTitle => 'ನಿಮ್ಮ ಬಗ್ಗೆ ಹೇಳಿ';

  @override
  String get askName => 'ನಿಮ್ಮ ಹೆಸರೇನು?';

  @override
  String get askVillage => 'ನೀವು ಯಾವ ಊರು ಅಥವಾ ಪಟ್ಟಣದವರು?';

  @override
  String get askState => 'ಯಾವ ಜಿಲ್ಲೆ ಮತ್ತು ರಾಜ್ಯ?';

  @override
  String get askCraft => 'ನೀವು ಯಾವ ಕರಕುಶಲ ಮಾಡುತ್ತೀರಿ?';

  @override
  String get askYears => 'ಎಷ್ಟು ವರ್ಷಗಳಿಂದ ಈ ಕಲೆ ಮಾಡುತ್ತಿದ್ದೀರಿ?';

  @override
  String get askStory => 'ನಿಮ್ಮ ಕಥೆ ಹೇಳಿ — ಈ ಕಲೆಯನ್ನು ಹೇಗೆ ಕಲಿತಿರಿ?';

  @override
  String get askPehchan =>
      'ಪೆಹಚಾನ್ ಕುಶಲಕರ್ಮಿ ಕಾರ್ಡ್ ಇದ್ದರೆ ಅದರ ಸಂಖ್ಯೆ ಹೇಳಿ. ಇಲ್ಲದಿದ್ದರೆ ಬಿಟ್ಟುಬಿಡಿ ಒತ್ತಿ.';

  @override
  String get tapMicToAnswer => 'ಮೈಕ್ ಒತ್ತಿ ಉತ್ತರಿಸಿ';

  @override
  String get weHeard => 'ನಾವು ಕೇಳಿದ್ದು:';

  @override
  String get profileSaved => 'ನಿಮ್ಮ ವಿವರಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ';

  @override
  String greeting(String name) {
    return 'ನಮಸ್ಕಾರ, $name';
  }

  @override
  String get tileAddProduct => 'ವಸ್ತು ಸೇರಿಸಿ';

  @override
  String get tileMyProducts => 'ನನ್ನ ವಸ್ತುಗಳು';

  @override
  String get tileOrders => 'ಆರ್ಡರ್‌ಗಳು';

  @override
  String get tileEarnings => 'ಗಳಿಕೆ';

  @override
  String get tileHelp => 'ಸಹಾಯ';

  @override
  String earningsSummary(String amount, int count) {
    return 'ಈ ತಿಂಗಳು $count ಆರ್ಡರ್‌ಗಳಿಂದ ನೀವು $amount ಗಳಿಸಿದ್ದೀರಿ';
  }

  @override
  String get addProductTitle => 'ವಸ್ತು ಸೇರಿಸಿ';

  @override
  String get speakOwnLanguage => 'ನಿಮ್ಮ ಸ್ವಂತ ಭಾಷೆಯಲ್ಲಿ ಮಾತನಾಡಿ';

  @override
  String listeningIn(String language) {
    return '$languageದಲ್ಲಿ ಕೇಳುತ್ತಿದ್ದೇವೆ…';
  }

  @override
  String get tapToSpeak => 'ಮಾತನಾಡಲು ಒತ್ತಿ, ಅಥವಾ ಒತ್ತಿ ಹಿಡಿಯಿರಿ';

  @override
  String get stopRecording => 'ನಿಲ್ಲಿಸಲು ಒತ್ತಿ';

  @override
  String get photoCaptured =>
      'ಫೋಟೋ ತೆಗೆಯಲಾಗಿದೆ — ಹಿನ್ನೆಲೆ ಮತ್ತು ಬೆಳಕನ್ನು ತಾನಾಗಿ ಸರಿಪಡಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get takePhoto => 'ಫೋಟೋ ತೆಗೆಯಿರಿ';

  @override
  String get addMorePhotos => 'ಇನ್ನಷ್ಟು ಫೋಟೋ ಸೇರಿಸಿ';

  @override
  String get makeListing => 'ನನ್ನ ಪಟ್ಟಿ ಮಾಡಿ';

  @override
  String get hintTooDark => 'ಸ್ವಲ್ಪ ಕತ್ತಲಿದೆ — ಸಾಧ್ಯವಾದರೆ ಬೆಳಕಿನ ಕಡೆ ಹೋಗಿ';

  @override
  String get hintTooBright => 'ಬೆಳಕು ಹೆಚ್ಚಿದೆ — ಸ್ವಲ್ಪ ನೆರಳಿಗೆ ಹೋಗಿ';

  @override
  String get hintMoveCloser => 'ಸ್ವಲ್ಪ ಹತ್ತಿರ ಬನ್ನಿ';

  @override
  String get hintBlurry => 'ಫೋನ್ ಅಲುಗಾಡದಂತೆ ಹಿಡಿಯಿರಿ';

  @override
  String get anyBackground => 'ಯಾವುದೇ ಬೆಳಕು, ಯಾವುದೇ ಹಿನ್ನೆಲೆ ಆದೀತು';

  @override
  String get upTo60s => '60 ಸೆಕೆಂಡುಗಳವರೆಗೆ';

  @override
  String get aiBuilding => 'AI ನಿಮ್ಮ ಪಟ್ಟಿಯನ್ನು ತಯಾರಿಸುತ್ತಿದೆ';

  @override
  String get stepAsr => 'ನಿಮ್ಮ ಧ್ವನಿಯನ್ನು ಅರ್ಥಮಾಡಿಕೊಳ್ಳುತ್ತಿದ್ದೇವೆ';

  @override
  String get stepNlu => 'ವಿವರಗಳನ್ನು ಹುಡುಕುತ್ತಿದ್ದೇವೆ';

  @override
  String get stepListing => 'ಹೆಸರು ಮತ್ತು ವಿವರಣೆ ಬರೆಯುತ್ತಿದ್ದೇವೆ';

  @override
  String get stepTranslation => 'ಖರೀದಿದಾರರಿಗಾಗಿ ಅನುವಾದಿಸುತ್ತಿದ್ದೇವೆ';

  @override
  String get stepImage => 'ನಿಮ್ಮ ಫೋಟೋ ಸುಧಾರಿಸುತ್ತಿದ್ದೇವೆ';

  @override
  String get stepPrice => 'ನ್ಯಾಯಯುತ ಬೆಲೆ ಲೆಕ್ಕಹಾಕುತ್ತಿದ್ದೇವೆ';

  @override
  String get stepCertificate => 'ನಿಮ್ಮ ಪ್ರಮಾಣಪತ್ರ ತಯಾರಿಸುತ್ತಿದ್ದೇವೆ';

  @override
  String get quickQuestions => 'ಕೆಲವು ಸಣ್ಣ ಪ್ರಶ್ನೆಗಳು';

  @override
  String get answerBySpeaking => 'ಮಾತನಾಡಿ ಉತ್ತರಿಸಿ';

  @override
  String get reviewTitle => 'ಪರಿಶೀಲಿಸಿ ಅನುಮೋದಿಸಿ';

  @override
  String get approve => 'ಅನುಮೋದಿಸಿ';

  @override
  String get changePrice => 'ಬೆಲೆ ಬದಲಿಸಿ';

  @override
  String get retakePhoto => 'ಮತ್ತೆ ಫೋಟೋ ತೆಗೆಯಿರಿ';

  @override
  String get reRecord => 'ಮತ್ತೆ ಹೇಳಿ';

  @override
  String get sayNewPrice => 'ಹೊಸ ಬೆಲೆ ಹೇಳಿ';

  @override
  String youGet(String amount, String pct) {
    return 'ನಿಮಗೆ ಸಿಗುವುದು $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'ಮಾರುಕಟ್ಟೆ ದರ $low – $high';
  }

  @override
  String get fairPrice => 'ನ್ಯಾಯಯುತ ಬೆಲೆ';

  @override
  String get category => 'ವರ್ಗ';

  @override
  String priceSpoken(String price, String amount) {
    return 'ಬೆಲೆ $price. ನಿಮಗೆ ಸಿಗುವುದು $amount.';
  }

  @override
  String get belowFairWage => 'ಇದು ನಿಮ್ಮ ಶ್ರಮಕ್ಕೆ ನ್ಯಾಯಯುತ ಕೂಲಿಗಿಂತ ಕಡಿಮೆ';

  @override
  String get isLive => 'ನಿಮ್ಮ ವಸ್ತು ಈಗ ಮಾರಾಟದಲ್ಲಿದೆ!';

  @override
  String get onOndc => 'ONDC ಜಾಲದಲ್ಲೂ ಇದೆ';

  @override
  String get certificateReady => 'ನಿಮ್ಮ ಪ್ರಮಾಣಪತ್ರ ಸಿದ್ಧ';

  @override
  String get statusQueued => 'ಸರದಿಯಲ್ಲಿ';

  @override
  String get statusUploading => 'ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ';

  @override
  String get statusProcessing => 'ತಯಾರಾಗುತ್ತಿದೆ';

  @override
  String get statusNeedsReview => 'ಪರಿಶೀಲನೆ ಬೇಕು';

  @override
  String get statusReady => 'ಅನುಮೋದನೆಗೆ ಸಿದ್ಧ';

  @override
  String get statusLive => 'ಮಾರಾಟದಲ್ಲಿ';

  @override
  String get statusFailed => 'ಗಮನಿಸಿ';

  @override
  String get statusUnpublished => 'ಮರೆಮಾಡಲಾಗಿದೆ';

  @override
  String get noProducts => 'ಇನ್ನೂ ವಸ್ತುಗಳಿಲ್ಲ. ವಸ್ತು ಸೇರಿಸಿ ಒತ್ತಿ.';

  @override
  String get newOrder => 'ಹೊಸ ಆರ್ಡರ್';

  @override
  String get accept => 'ಸ್ವೀಕರಿಸಿ';

  @override
  String get decline => 'ನಿರಾಕರಿಸಿ';

  @override
  String get markPacked => 'ಪ್ಯಾಕ್ ಆಗಿದೆ';

  @override
  String get markShipped => 'ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get noOrders => 'ಇನ್ನೂ ಆರ್ಡರ್‌ಗಳಿಲ್ಲ';

  @override
  String get orderPlaced => 'ಹೊಸದು';

  @override
  String get orderAccepted => 'ಸ್ವೀಕರಿಸಲಾಗಿದೆ';

  @override
  String get orderPacked => 'ಪ್ಯಾಕ್ ಆಗಿದೆ';

  @override
  String get orderShipped => 'ದಾರಿಯಲ್ಲಿದೆ';

  @override
  String get orderDelivered => 'ತಲುಪಿದೆ';

  @override
  String get orderDeclined => 'ನಿರಾಕರಿಸಲಾಗಿದೆ';

  @override
  String get orderCancelled => 'ರದ್ದಾಗಿದೆ';

  @override
  String get gross => 'ಮಾರಾಟ';

  @override
  String get commission => 'ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಶುಲ್ಕ';

  @override
  String get logistics => 'ಸಾಗಣೆ';

  @override
  String get net => 'ನಿಮಗೆ ಸಿಕ್ಕಿದ್ದು';

  @override
  String get everyRupee => 'ಪ್ರತಿ ರೂಪಾಯಿಯ ಲೆಕ್ಕ';

  @override
  String get helpTitle => 'ಸಹಾಯ';

  @override
  String get callHelpline => 'ಸಹಾಯವಾಣಿಗೆ ಕರೆ ಮಾಡಿ';

  @override
  String get requestCallback => 'ಸಹಾಯಕರು ನನಗೆ ಕರೆ ಮಾಡಲಿ';

  @override
  String get callbackRequested => 'ಸಹಾಯಕರು ಶೀಘ್ರದಲ್ಲೇ ನಿಮಗೆ ಕರೆ ಮಾಡುತ್ತಾರೆ';

  @override
  String get howToUse => 'ಶಿಲ್ಪಸೇತು ಹೇಗೆ ಕೆಲಸ ಮಾಡುತ್ತದೆ';

  @override
  String get fiveSteps =>
      'ಮಾತನಾಡಿ · ಫೋಟೋ ತೆಗೆಯಿರಿ · AI ತಯಾರಿಸುತ್ತದೆ · ನೀವು ಅನುಮೋದಿಸಿ · ಮಾರಾಟದಲ್ಲಿ';

  @override
  String get searchHint => 'ಕರಕುಶಲ, ರಾಜ್ಯ, ಕುಶಲಕರ್ಮಿಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get freshFromLoom => 'ಮಗ್ಗ ಮತ್ತು ಚಕ್ರದಿಂದ ತಾಜಾ';

  @override
  String get byCraft => 'ಕರಕುಶಲದ ಪ್ರಕಾರ';

  @override
  String get byState => 'ರಾಜ್ಯ ಮತ್ತು ಕ್ಲಸ್ಟರ್ ಪ್ರಕಾರ';

  @override
  String get womenLed => 'ಮಹಿಳಾ ನೇತೃತ್ವದ ಗುಂಪುಗಳು';

  @override
  String get giTagged => 'GI ಗುರುತಿನ ಕರಕುಶಲಗಳು';

  @override
  String get nearYou => 'ನಿಮ್ಮ ಹತ್ತಿರ';

  @override
  String get filters => 'ಫಿಲ್ಟರ್‌ಗಳು';

  @override
  String get verifiedOnly => 'ಪರಿಶೀಲಿತ ಕುಶಲಕರ್ಮಿಗಳು ಮಾತ್ರ';

  @override
  String get giOnly => 'GI ಗುರುತಿನವು ಮಾತ್ರ';

  @override
  String get sortBy => 'ಕ್ರಮ';

  @override
  String get sortRelevance => 'ಅತ್ಯಂತ ಸೂಕ್ತ';

  @override
  String get sortPriceLow => 'ಬೆಲೆ: ಕಡಿಮೆಯಿಂದ ಹೆಚ್ಚು';

  @override
  String get sortPriceHigh => 'ಬೆಲೆ: ಹೆಚ್ಚಿನಿಂದ ಕಡಿಮೆ';

  @override
  String get sortNewest => 'ಹೊಸವು';

  @override
  String results(int count) {
    return '$count ಕರಕುಶಲ ವಸ್ತುಗಳು';
  }

  @override
  String get addToCart => 'ಕಾರ್ಟ್‌ಗೆ ಸೇರಿಸಿ';

  @override
  String get addedToCart => 'ಕಾರ್ಟ್‌ಗೆ ಸೇರಿಸಲಾಗಿದೆ';

  @override
  String get scanCertificate => 'ಕುಶಲಕರ್ಮಿ ಪ್ರಮಾಣಪತ್ರಕ್ಕಾಗಿ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ';

  @override
  String get certificateSub => 'ಸಾಮಗ್ರಿ, ಕಥೆ ಮತ್ತು ಬೆಲೆಯ ಆಧಾರ';

  @override
  String get howPriceBuilt => 'ಈ ಬೆಲೆ ಹೇಗೆ ನಿರ್ಧಾರವಾಯಿತು';

  @override
  String goesToArtisan(String amount, String pct) {
    return 'ಇದರಲ್ಲಿ $amount ನೇರವಾಗಿ ಕುಶಲಕರ್ಮಿಗೆ ಹೋಗುತ್ತದೆ ($pct%)';
  }

  @override
  String get meetArtisan => 'ಕುಶಲಕರ್ಮಿಯನ್ನು ಭೇಟಿಯಾಗಿ';

  @override
  String get hearVoice => 'ಅವರ ಧ್ವನಿ ಕೇಳಿ';

  @override
  String get moreFromArtisan => 'ಈ ಕುಶಲಕರ್ಮಿಯ ಇನ್ನಷ್ಟು ವಸ್ತುಗಳು';

  @override
  String reviewsCount(int count) {
    return '($count ವಿಮರ್ಶೆಗಳು)';
  }

  @override
  String get verifiedArtisan => 'ಪರಿಶೀಲಿತ ಕುಶಲಕರ್ಮಿ';

  @override
  String get cart => 'ಕಾರ್ಟ್';

  @override
  String get cartEmpty => 'ನಿಮ್ಮ ಕಾರ್ಟ್ ಖಾಲಿಯಾಗಿದೆ';

  @override
  String get checkout => 'ಚೆಕ್‌ಔಟ್';

  @override
  String get placeOrder => 'ಆರ್ಡರ್ ಮಾಡಿ';

  @override
  String get payUpi => 'UPI ಮೂಲಕ ಪಾವತಿಸಿ';

  @override
  String get cod => 'ತಲುಪಿದಾಗ ನಗದು';

  @override
  String deliveryIn(int days) {
    return 'ಸುಮಾರು $days ದಿನಗಳಲ್ಲಿ ತಲುಪುತ್ತದೆ';
  }

  @override
  String get shippingIncluded =>
      'ಸಾಗಣೆ ಮತ್ತು ಪ್ಯಾಕಿಂಗ್ ನ್ಯಾಯಯುತ ಬೆಲೆಯಲ್ಲೇ ಸೇರಿದೆ';

  @override
  String get orderPlacedThanks => 'ಧನ್ಯವಾದಗಳು! ನಿಮ್ಮ ಆರ್ಡರ್ ಆಗಿದೆ.';

  @override
  String get myOrders => 'ನನ್ನ ಆರ್ಡರ್‌ಗಳು';

  @override
  String get rateCraft => 'ಈ ಕರಕುಶಲಕ್ಕೆ ರೇಟಿಂಗ್ ನೀಡಿ';

  @override
  String get scanQr => 'ಪ್ರಮಾಣಪತ್ರ QR ಸ್ಕ್ಯಾನ್ ಮಾಡಿ';

  @override
  String get certValid => 'ಅಸಲಿ — ಶಿಲ್ಪಸೇತು ಪರಿಶೀಲಿಸಿದೆ';

  @override
  String get certInvalid => 'ಮಾನ್ಯವಲ್ಲ';

  @override
  String get name => 'ಹೆಸರು';

  @override
  String get address => 'ವಿಳಾಸ';

  @override
  String get city => 'ನಗರ';

  @override
  String get state => 'ರಾಜ್ಯ';

  @override
  String get pincode => 'ಪಿನ್ ಕೋಡ್';

  @override
  String get phone => 'ಫೋನ್';

  @override
  String get total => 'ಒಟ್ಟು';

  @override
  String get kioskTitle => 'ಕಿಯೋಸ್ಕ್';

  @override
  String get myArtisans => 'ಕುಶಲಕರ್ಮಿಗಳು';

  @override
  String get onboardArtisan => 'ಕುಶಲಕರ್ಮಿಯನ್ನು ಸೇರಿಸಿ';

  @override
  String captureFor(String name) {
    return '$name ಅವರಿಗಾಗಿ';
  }

  @override
  String get batchMode => 'ಪ್ರದರ್ಶನ ಬ್ಯಾಚ್ ಮೋಡ್';

  @override
  String get printTags => 'ಪ್ರಮಾಣಪತ್ರ ಟ್ಯಾಗ್ ಮುದ್ರಿಸಿ';

  @override
  String get syncAll => 'ಎಲ್ಲವನ್ನೂ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get attestation =>
      'ಅವರ ಗುರುತನ್ನು ಪರಿಶೀಲಿಸಿ, ಅವರು ಮಾತಿನಲ್ಲಿ ನೀಡಿದ ಒಪ್ಪಿಗೆಯನ್ನು ದಾಖಲಿಸಿದ್ದೇನೆ';

  @override
  String get recordConsent => 'ಕುಶಲಕರ್ಮಿಯ ಒಪ್ಪಿಗೆಯನ್ನು ದಾಖಲಿಸಿ';

  @override
  String get about => 'ಪರಿಚಯ';

  @override
  String get logout => 'ಲಾಗ್ ಔಟ್';

  @override
  String get lowBandwidth => 'ಕಡಿಮೆ ಡೇಟಾ ಮೋಡ್';

  @override
  String get switchRole => 'ಮೋಡ್ ಬದಲಿಸಿ';

  @override
  String productsCount(int count) {
    return '$count ವಸ್ತುಗಳು';
  }

  @override
  String get gender => 'ಲಿಂಗ (ಐಚ್ಛಿಕ)';

  @override
  String get genderFemale => 'ಮಹಿಳೆ';

  @override
  String get genderMale => 'ಪುರುಷ';

  @override
  String get genderOther => 'ಇತರೆ';

  @override
  String get genderPreferNot => 'ಹೇಳಲು ಇಷ್ಟವಿಲ್ಲ';

  @override
  String get typeInstead => 'ಅಥವಾ ಉತ್ತರ ಬರೆಯಿರಿ';

  @override
  String get send => 'ಕಳುಹಿಸಿ';

  @override
  String get serverAddress => 'ಸರ್ವರ್ ವಿಳಾಸ';

  @override
  String get serverAddressHint => 'ಸಹಾಯಕರು ಹೇಳಿದರೆ ಮಾತ್ರ ಬದಲಿಸಿ';

  @override
  String get saved => 'ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get darkMode => 'ಡಾರ್ಕ್ ಮೋಡ್';

  @override
  String get lightMode => 'ಲೈಟ್ ಮೋಡ್';

  @override
  String get productDetails => 'ವಸ್ತುವಿನ ವಿವರ';

  @override
  String get aboutArtForm => 'ಈ ಕಲೆಯ ಬಗ್ಗೆ';

  @override
  String get howItsMade => 'ಹೇಗೆ ತಯಾರಾಗುತ್ತದೆ';

  @override
  String get didYouKnow => 'ನಿಮಗೆ ಗೊತ್ತೇ?';

  @override
  String yearsOfPractice(int count) {
    return '$count ವರ್ಷಗಳ ಅನುಭವ';
  }

  @override
  String get photoCredits => 'ಫೋಟೋ ಕೃತಜ್ಞತೆ';

  @override
  String get photoCreditsSub =>
      'ವಿಕಿಮೀಡಿಯಾ ಕಾಮನ್ಸ್‌ನಿಂದ ನಿಜವಾದ ಕರಕುಶಲ ಫೋಟೋಗಳು, ಪರವಾನಗಿಯಂತೆ';

  @override
  String get askShilpi => 'ಶಿಲ್ಪಿಯನ್ನು ಕೇಳಿ';

  @override
  String get assistantName => 'ಶಿಲ್ಪಿ';

  @override
  String get assistantTagline => 'ನಿಮ್ಮ ಶಿಲ್ಪಸೇತು ಸಹಾಯಕಿ';

  @override
  String get assistantThinking => 'ಯೋಚಿಸುತ್ತಿದ್ದೇನೆ…';

  @override
  String get askAnything => 'ಏನನ್ನಾದರೂ ಕೇಳಿ';

  @override
  String get close => 'ಮುಚ್ಚಿ';

  @override
  String get dayStreak => 'ದಿನಗಳ ಸರಣಿ';

  @override
  String get todaysGoal => 'ಇಂದಿನ ಗುರಿ';

  @override
  String get craftOfTheDay => 'ಇಂದಿನ ಕಲೆ';

  @override
  String get exploreCraft => 'ನೋಡಿ';

  @override
  String get celebrateLive => 'ನಿಮ್ಮ ವಸ್ತು ಲೈವ್ ಆಗಿದೆ!';

  @override
  String get micPermission =>
      'ಮೈಕ್ ಅನುಮತಿ ನೀಡಿ: ಸೆಟ್ಟಿಂಗ್ಸ್ → ಆ್ಯಪ್‌ಗಳು → ಶಿಲ್ಪಸೇತು → ಅನುಮತಿಗಳು → ಮೈಕ್ರೊಫೋನ್.';

  @override
  String get micUnavailable =>
      'ಈ ಫೋನ್‌ನಲ್ಲಿ ಮಾತನಾಡಿ ಬರೆಯುವ ಸೌಲಭ್ಯ ಇಲ್ಲ. Google ಧ್ವನಿ ಟೈಪಿಂಗ್ ಆನ್ ಮಾಡಿ, ಅಥವಾ ಟೈಪ್ ಮಾಡಿ.';

  @override
  String get micInsecure =>
      'ಮೈಕ್ ಶಿಲ್ಪಸೇತು ಆ್ಯಪ್‌ನಲ್ಲಿ ಅಥವಾ ಸುರಕ್ಷಿತ https ಲಿಂಕ್‌ನಲ್ಲಿ ಮಾತ್ರ ಕೆಲಸ ಮಾಡುತ್ತದೆ. ಆ್ಯಪ್ ಬಳಸಿ.';

  @override
  String get micNoSpeech => 'ಕೇಳಿಸಲಿಲ್ಲ. ಮೈಕ್ ಒತ್ತಿ ಸ್ವಲ್ಪ ಜೋರಾಗಿ ಮಾತನಾಡಿ.';

  @override
  String get micNetwork => 'ಮಾತನಾಡಿ ಬರೆಯಲು ಇಂಟರ್ನೆಟ್ ಬೇಕು. ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get pressBackAgain => 'ಹೊರಬರಲು ಮತ್ತೆ ಹಿಂದೆ ಒತ್ತಿ';
}
