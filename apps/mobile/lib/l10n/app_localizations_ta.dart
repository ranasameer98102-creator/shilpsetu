// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class L10nTa extends L10n {
  L10nTa([String locale = 'ta']) : super(locale);

  @override
  String get languageName => 'தமிழ்';

  @override
  String get appTitle => 'ஷில்ப்சேது';

  @override
  String get tagline => 'விளிம்புநிலை கைவினைஞர்களுக்கான AI இணை-விற்பனையாளர்';

  @override
  String get heroLine =>
      'கைவேலையிலிருந்து தலைப்புச் செய்தி வரை — ஒவ்வொரு கைவினையும், எப்போதும் சந்தையில்.';

  @override
  String get promise =>
      'ஒரு புகைப்படம். ஒரு பேசிய வாக்கியம். நியாயமான விலையில், நம்பகமான பட்டியல் — தட்டச்சு இல்லை, இடைத்தரகர் இல்லை, ஆங்கிலம் தேவையில்லை.';

  @override
  String get next => 'அடுத்து';

  @override
  String get back => 'பின்செல்';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get save => 'சேமி';

  @override
  String get cancel => 'ரத்து';

  @override
  String get done => 'முடிந்தது';

  @override
  String get skip => 'தவிர்';

  @override
  String get yes => 'ஆம்';

  @override
  String get no => 'இல்லை';

  @override
  String get loading => 'சற்று காத்திருக்கவும்…';

  @override
  String get errorGeneric => 'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorNetwork =>
      'இணையம் இல்லை. உங்கள் வேலை போனில் பாதுகாப்பாக உள்ளது.';

  @override
  String get savedOnPhone =>
      'போனில் சேமிக்கப்பட்டது — இணையம் வந்ததும் பதிவேற்றப்படும்';

  @override
  String get allSynced => 'அனைத்தும் பதிவேற்றப்பட்டன';

  @override
  String get syncing => 'பதிவேற்றுகிறது…';

  @override
  String pendingCount(int count) {
    return '$count பதிவேற்றக் காத்திருக்கின்றன';
  }

  @override
  String get chooseRole => 'நீங்கள் யார்?';

  @override
  String get roleArtisan => 'நான் கைவினைப் பொருட்கள் செய்கிறேன்';

  @override
  String get roleBuyer => 'நான் வாங்க விரும்புகிறேன்';

  @override
  String get roleKiosk => 'கியோஸ்க் / CSC உதவியாளர்';

  @override
  String get chooseLanguage => 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get tapToHear =>
      'கேட்க ஒருமுறை தொடவும், தேர்ந்தெடுக்க மீண்டும் தொடவும்';

  @override
  String get enterPhone => 'உங்கள் மொபைல் எண்';

  @override
  String get sendCode => 'குறியீட்டை அனுப்பு';

  @override
  String get enterCode => '6 இலக்கக் குறியீட்டை உள்ளிடவும்';

  @override
  String codeSentTo(String phone) {
    return '$phone எண்ணுக்குக் குறியீடு அனுப்பப்பட்டது';
  }

  @override
  String get verify => 'சரிபார்';

  @override
  String get sayNumber => 'உங்கள் எண்ணைச் சொல்லுங்கள்';

  @override
  String demoCode(String code) {
    return 'டெமோ குறியீடு: $code';
  }

  @override
  String get consentTitle => 'உங்கள் அனுமதி';

  @override
  String get consentBody =>
      'உங்கள் கைவினையை விற்க ஷில்ப்சேது உங்கள் குரல், புகைப்படங்கள் மற்றும் உங்கள் ஊரின் முகவரியைச் சேமிக்கும். எப்போது வேண்டுமானாலும் அவற்றை நீக்கலாம்.';

  @override
  String get consentVoice => 'என் குரலைச் சேமி';

  @override
  String get consentPhoto => 'என் புகைப்படங்களைச் சேமி';

  @override
  String get consentLocation => 'என் ஊரின் முகவரியைச் சேமி';

  @override
  String get iAgree => 'ஆம், நான் ஒப்புக்கொள்கிறேன்';

  @override
  String get sayYesToAgree => 'அல்லது ஒப்புக்கொள்ள “ஆம்” என்று சொல்லுங்கள்';

  @override
  String get profileTitle => 'உங்களைப் பற்றிச் சொல்லுங்கள்';

  @override
  String get askName => 'உங்கள் பெயர் என்ன?';

  @override
  String get askVillage => 'நீங்கள் எந்த ஊர் அல்லது நகரத்தைச் சேர்ந்தவர்?';

  @override
  String get askState => 'எந்த மாவட்டம், எந்த மாநிலம்?';

  @override
  String get askCraft => 'நீங்கள் என்ன கைவினை செய்கிறீர்கள்?';

  @override
  String get askYears => 'எத்தனை ஆண்டுகளாக இந்தக் கைவினையைச் செய்கிறீர்கள்?';

  @override
  String get askStory =>
      'உங்கள் கதையைச் சொல்லுங்கள் — இந்தக் கலையை எப்படிக் கற்றீர்கள்?';

  @override
  String get askPehchan =>
      'பெஹ்சான் கைவினைஞர் அட்டை இருந்தால் அதன் எண்ணைச் சொல்லுங்கள். இல்லையென்றால் தவிர் அழுத்தவும்.';

  @override
  String get tapMicToAnswer => 'மைக்கை அழுத்திப் பதில் சொல்லுங்கள்';

  @override
  String get weHeard => 'நாங்கள் கேட்டது:';

  @override
  String get profileSaved => 'உங்கள் விவரங்கள் சேமிக்கப்பட்டன';

  @override
  String greeting(String name) {
    return 'வணக்கம், $name';
  }

  @override
  String get tileAddProduct => 'பொருள் சேர்';

  @override
  String get tileMyProducts => 'என் பொருட்கள்';

  @override
  String get tileOrders => 'ஆர்டர்கள்';

  @override
  String get tileEarnings => 'வருமானம்';

  @override
  String get tileHelp => 'உதவி';

  @override
  String earningsSummary(String amount, int count) {
    return 'இந்த மாதம் $count ஆர்டர்களில் இருந்து நீங்கள் $amount சம்பாதித்தீர்கள்';
  }

  @override
  String get addProductTitle => 'பொருள் சேர்';

  @override
  String get speakOwnLanguage => 'உங்கள் சொந்த மொழியில் பேசுங்கள்';

  @override
  String listeningIn(String language) {
    return '$language மொழியில் கேட்கிறோம்…';
  }

  @override
  String get tapToSpeak => 'பேச அழுத்தவும், அல்லது அழுத்திப் பிடிக்கவும்';

  @override
  String get stopRecording => 'நிறுத்த அழுத்தவும்';

  @override
  String get photoCaptured =>
      'புகைப்படம் எடுக்கப்பட்டது — பின்னணியும் வெளிச்சமும் தானாகச் சரிசெய்யப்படுகின்றன';

  @override
  String get takePhoto => 'புகைப்படம் எடு';

  @override
  String get addMorePhotos => 'மேலும் புகைப்படங்கள் சேர்';

  @override
  String get makeListing => 'என் பட்டியலை உருவாக்கு';

  @override
  String get hintTooDark =>
      'சற்று இருட்டாக உள்ளது — முடிந்தால் வெளிச்சத்திற்குச் செல்லுங்கள்';

  @override
  String get hintTooBright => 'அதிக வெளிச்சம் — சற்று நிழலுக்குச் செல்லுங்கள்';

  @override
  String get hintMoveCloser => 'சற்று அருகில் வாருங்கள்';

  @override
  String get hintBlurry => 'போனை அசையாமல் பிடியுங்கள்';

  @override
  String get anyBackground => 'எந்த வெளிச்சமும், எந்தப் பின்னணியும் பரவாயில்லை';

  @override
  String get upTo60s => '60 வினாடிகள் வரை';

  @override
  String get aiBuilding => 'AI உங்கள் பட்டியலை உருவாக்குகிறது';

  @override
  String get stepAsr => 'உங்கள் குரலைப் புரிந்துகொள்கிறோம்';

  @override
  String get stepNlu => 'விவரங்களைக் கண்டறிகிறோம்';

  @override
  String get stepListing => 'பெயரும் விளக்கமும் எழுதுகிறோம்';

  @override
  String get stepTranslation => 'வாங்குபவர்களுக்காக மொழிபெயர்க்கிறோம்';

  @override
  String get stepImage => 'உங்கள் புகைப்படத்தைச் சீர்செய்கிறோம்';

  @override
  String get stepPrice => 'நியாயமான விலையைக் கணக்கிடுகிறோம்';

  @override
  String get stepCertificate => 'உங்கள் சான்றிதழைத் தயாரிக்கிறோம்';

  @override
  String get quickQuestions => 'சில சிறிய கேள்விகள்';

  @override
  String get answerBySpeaking => 'பேசிப் பதில் சொல்லுங்கள்';

  @override
  String get reviewTitle => 'சரிபார்த்து ஒப்புதல் தாருங்கள்';

  @override
  String get approve => 'ஒப்புதல்';

  @override
  String get changePrice => 'விலையை மாற்று';

  @override
  String get retakePhoto => 'மீண்டும் புகைப்படம் எடு';

  @override
  String get reRecord => 'மீண்டும் பேசு';

  @override
  String get sayNewPrice => 'புதிய விலையைச் சொல்லுங்கள்';

  @override
  String youGet(String amount, String pct) {
    return 'உங்களுக்குக் கிடைப்பது $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'சந்தை விலை $low – $high';
  }

  @override
  String get fairPrice => 'நியாயமான விலை';

  @override
  String get category => 'வகை';

  @override
  String priceSpoken(String price, String amount) {
    return 'விலை $price. உங்களுக்குக் கிடைப்பது $amount.';
  }

  @override
  String get belowFairWage =>
      'இது உங்கள் உழைப்பின் நியாயமான கூலியை விடக் குறைவு';

  @override
  String get isLive => 'உங்கள் பொருள் இப்போது விற்பனையில்!';

  @override
  String get onOndc => 'ONDC வலையமைப்பிலும் பட்டியலிடப்பட்டுள்ளது';

  @override
  String get certificateReady => 'உங்கள் சான்றிதழ் தயார்';

  @override
  String get statusQueued => 'வரிசையில்';

  @override
  String get statusUploading => 'பதிவேற்றுகிறது';

  @override
  String get statusProcessing => 'தயாராகிறது';

  @override
  String get statusNeedsReview => 'சரிபார்க்க வேண்டும்';

  @override
  String get statusReady => 'ஒப்புதலுக்குத் தயார்';

  @override
  String get statusLive => 'விற்பனையில்';

  @override
  String get statusFailed => 'கவனம் தேவை';

  @override
  String get statusUnpublished => 'மறைக்கப்பட்டது';

  @override
  String get noProducts => 'இன்னும் பொருட்கள் இல்லை. பொருள் சேர் அழுத்தவும்.';

  @override
  String get newOrder => 'புதிய ஆர்டர்';

  @override
  String get accept => 'ஏற்றுக்கொள்';

  @override
  String get decline => 'மறு';

  @override
  String get markPacked => 'பேக் செய்யப்பட்டது';

  @override
  String get markShipped => 'அனுப்பப்பட்டது';

  @override
  String get noOrders => 'இன்னும் ஆர்டர்கள் இல்லை';

  @override
  String get orderPlaced => 'புதியது';

  @override
  String get orderAccepted => 'ஏற்கப்பட்டது';

  @override
  String get orderPacked => 'பேக் செய்யப்பட்டது';

  @override
  String get orderShipped => 'வழியில்';

  @override
  String get orderDelivered => 'வந்து சேர்ந்தது';

  @override
  String get orderDeclined => 'மறுக்கப்பட்டது';

  @override
  String get orderCancelled => 'ரத்து';

  @override
  String get gross => 'விற்பனை';

  @override
  String get commission => 'தளக் கட்டணம்';

  @override
  String get logistics => 'அனுப்புதல்';

  @override
  String get net => 'உங்களுக்குக் கிடைத்தது';

  @override
  String get everyRupee => 'ஒவ்வொரு ரூபாய்க்கும் கணக்கு';

  @override
  String get helpTitle => 'உதவி';

  @override
  String get callHelpline => 'உதவி எண்ணை அழையுங்கள்';

  @override
  String get requestCallback => 'உதவியாளர் என்னை அழைக்கட்டும்';

  @override
  String get callbackRequested => 'உதவியாளர் விரைவில் உங்களை அழைப்பார்';

  @override
  String get howToUse => 'ஷில்ப்சேது எப்படி வேலை செய்கிறது';

  @override
  String get fiveSteps =>
      'பேசுங்கள் · படம் எடுங்கள் · AI உருவாக்கும் · நீங்கள் ஒப்புதல் தருங்கள் · விற்பனையில்';

  @override
  String get searchHint => 'கைவினைகள், மாநிலங்கள், கைவினைஞர்களைத் தேடுங்கள்';

  @override
  String get freshFromLoom => 'தறியிலிருந்தும் சக்கரத்திலிருந்தும் புதியவை';

  @override
  String get byCraft => 'கைவினை வாரியாக';

  @override
  String get byState => 'மாநிலம் மற்றும் குழுமம் வாரியாக';

  @override
  String get womenLed => 'பெண்கள் தலைமையிலான குழுக்கள்';

  @override
  String get giTagged => 'GI குறியிட்ட கைவினைகள்';

  @override
  String get nearYou => 'உங்கள் அருகில்';

  @override
  String get filters => 'வடிகட்டிகள்';

  @override
  String get verifiedOnly => 'சரிபார்க்கப்பட்ட கைவினைஞர்கள் மட்டும்';

  @override
  String get giOnly => 'GI குறியிட்டவை மட்டும்';

  @override
  String get sortBy => 'வரிசை';

  @override
  String get sortRelevance => 'மிகப் பொருத்தமானது';

  @override
  String get sortPriceLow => 'விலை: குறைவிலிருந்து அதிகம்';

  @override
  String get sortPriceHigh => 'விலை: அதிகத்திலிருந்து குறைவு';

  @override
  String get sortNewest => 'புதியவை';

  @override
  String results(int count) {
    return '$count கைவினைகள்';
  }

  @override
  String get addToCart => 'கூடையில் சேர்';

  @override
  String get addedToCart => 'கூடையில் சேர்க்கப்பட்டது';

  @override
  String get scanCertificate => 'கைவினைஞர் சான்றிதழுக்கு ஸ்கேன் செய்யுங்கள்';

  @override
  String get certificateSub => 'பொருட்கள், கதை மற்றும் விலையின் அடிப்படை';

  @override
  String get howPriceBuilt => 'இந்த விலை எப்படி உருவானது';

  @override
  String goesToArtisan(String amount, String pct) {
    return 'இதில் $amount நேரடியாகக் கைவினைஞருக்குச் செல்கிறது ($pct%)';
  }

  @override
  String get meetArtisan => 'கைவினைஞரைச் சந்தியுங்கள்';

  @override
  String get hearVoice => 'அவர்கள் குரலைக் கேளுங்கள்';

  @override
  String get moreFromArtisan => 'இந்தக் கைவினைஞரின் மேலும் படைப்புகள்';

  @override
  String reviewsCount(int count) {
    return '($count மதிப்புரைகள்)';
  }

  @override
  String get verifiedArtisan => 'சரிபார்க்கப்பட்ட கைவினைஞர்';

  @override
  String get cart => 'கூடை';

  @override
  String get cartEmpty => 'உங்கள் கூடை காலியாக உள்ளது';

  @override
  String get checkout => 'செக்அவுட்';

  @override
  String get placeOrder => 'ஆர்டர் செய்';

  @override
  String get payUpi => 'UPI மூலம் செலுத்து';

  @override
  String get cod => 'டெலிவரியின் போது பணம்';

  @override
  String deliveryIn(int days) {
    return 'சுமார் $days நாட்களில் டெலிவரி';
  }

  @override
  String get shippingIncluded =>
      'அனுப்புதலும் பேக்கிங்கும் நியாயமான விலையில் அடங்கும்';

  @override
  String get orderPlacedThanks => 'நன்றி! உங்கள் ஆர்டர் செய்யப்பட்டது.';

  @override
  String get myOrders => 'என் ஆர்டர்கள்';

  @override
  String get rateCraft => 'இந்தக் கைவினைக்கு மதிப்பீடு தாருங்கள்';

  @override
  String get scanQr => 'சான்றிதழ் QR ஸ்கேன் செய்யுங்கள்';

  @override
  String get certValid => 'உண்மையானது — ஷில்ப்சேது சரிபார்த்தது';

  @override
  String get certInvalid => 'செல்லாது';

  @override
  String get name => 'பெயர்';

  @override
  String get address => 'முகவரி';

  @override
  String get city => 'நகரம்';

  @override
  String get state => 'மாநிலம்';

  @override
  String get pincode => 'பின் கோடு';

  @override
  String get phone => 'தொலைபேசி';

  @override
  String get total => 'மொத்தம்';

  @override
  String get kioskTitle => 'கியோஸ்க்';

  @override
  String get myArtisans => 'கைவினைஞர்கள்';

  @override
  String get onboardArtisan => 'கைவினைஞரைச் சேர்';

  @override
  String captureFor(String name) {
    return '$name அவர்களுக்காக';
  }

  @override
  String get batchMode => 'கண்காட்சி தொகுப்பு முறை';

  @override
  String get printTags => 'சான்றிதழ் குறிச்சீட்டுகளை அச்சிடு';

  @override
  String get syncAll => 'அனைத்தையும் பதிவேற்று';

  @override
  String get attestation =>
      'அவரது அடையாளத்தைச் சரிபார்த்து, அவர் பேசிய ஒப்புதலைப் பதிவு செய்தேன்';

  @override
  String get recordConsent => 'கைவினைஞரின் ஒப்புதலைப் பதிவு செய்';

  @override
  String get about => 'அறிமுகம்';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get lowBandwidth => 'குறைந்த டேட்டா முறை';

  @override
  String get switchRole => 'முறையை மாற்று';

  @override
  String productsCount(int count) {
    return '$count பொருட்கள்';
  }

  @override
  String get gender => 'பாலினம் (விருப்பம்)';

  @override
  String get genderFemale => 'பெண்';

  @override
  String get genderMale => 'ஆண்';

  @override
  String get genderOther => 'மற்றவை';

  @override
  String get genderPreferNot => 'சொல்ல விரும்பவில்லை';

  @override
  String get typeInstead => 'அல்லது பதிலைத் தட்டச்சு செய்யுங்கள்';

  @override
  String get send => 'அனுப்பு';

  @override
  String get serverAddress => 'சர்வர் முகவரி';

  @override
  String get serverAddressHint => 'உதவியாளர் சொன்னால் மட்டும் மாற்றவும்';

  @override
  String get saved => 'சேமிக்கப்பட்டது';

  @override
  String get darkMode => 'டார்க் மோட்';

  @override
  String get lightMode => 'லைட் மோட்';

  @override
  String get productDetails => 'பொருள் விவரம்';

  @override
  String get aboutArtForm => 'இந்தக் கலை பற்றி';

  @override
  String get howItsMade => 'எப்படி செய்யப்படுகிறது';

  @override
  String get didYouKnow => 'உங்களுக்குத் தெரியுமா?';

  @override
  String yearsOfPractice(int count) {
    return '$count ஆண்டு அனுபவம்';
  }

  @override
  String get photoCredits => 'புகைப்பட நன்றி';

  @override
  String get photoCreditsSub =>
      'விக்கிமீடியா காமன்ஸிலிருந்து உண்மையான கைவினைப் படங்கள், உரிமப்படி';

  @override
  String get askShilpi => 'ஷில்பியிடம் கேளுங்கள்';

  @override
  String get assistantName => 'ஷில்பி';

  @override
  String get assistantTagline => 'உங்கள் ஷில்ப்சேது உதவியாளர்';

  @override
  String get assistantThinking => 'யோசிக்கிறேன்…';

  @override
  String get askAnything => 'எதையும் கேளுங்கள்';

  @override
  String get close => 'மூடு';

  @override
  String get dayStreak => 'நாள் தொடர்';

  @override
  String get todaysGoal => 'இன்றைய இலக்கு';

  @override
  String get craftOfTheDay => 'இன்றைய கலை';

  @override
  String get exploreCraft => 'பாருங்கள்';

  @override
  String get celebrateLive => 'உங்கள் பொருள் நேரலையில்!';

  @override
  String get micPermission =>
      'மைக் அனுமதி தாருங்கள்: அமைப்புகள் → ஆப்ஸ் → ஷில்ப்சேது → அனுமதிகள் → மைக்ரோஃபோன்.';

  @override
  String get micUnavailable =>
      'இந்த ஃபோனில் பேசி எழுதும் வசதி இல்லை. Google குரல் தட்டச்சை இயக்குங்கள், அல்லது தட்டச்சு செய்யுங்கள்.';

  @override
  String get micInsecure =>
      'மைக் ஷில்ப்சேது ஆப்பில் அல்லது பாதுகாப்பான https இணைப்பில் மட்டுமே வேலை செய்யும். ஆப்பைப் பயன்படுத்துங்கள்.';

  @override
  String get micNoSpeech =>
      'கேட்கவில்லை. மைக்கை அழுத்தி சற்று சத்தமாகப் பேசுங்கள்.';

  @override
  String get micNetwork => 'பேசி எழுத இணையம் தேவை. இணைப்பைச் சரிபாருங்கள்.';

  @override
  String get pressBackAgain => 'வெளியேற மீண்டும் பின் பொத்தானை அழுத்தவும்';
}
