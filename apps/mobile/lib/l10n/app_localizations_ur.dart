// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class L10nUr extends L10n {
  L10nUr([String locale = 'ur']) : super(locale);

  @override
  String get languageName => 'اردو';

  @override
  String get appTitle => 'شلپ سیتو';

  @override
  String get tagline => 'پسماندہ کاریگروں کا AI معاون فروخت کار';

  @override
  String get heroLine => 'ہاتھ کے ہنر سے سرخیوں تک — ہر فن، ہمیشہ بازار میں۔';

  @override
  String get promise =>
      'ایک تصویر۔ ایک بولا ہوا جملہ۔ مناسب قیمت والی، قابلِ اعتماد فہرست — نہ ٹائپنگ، نہ بچولیا، نہ انگریزی کی ضرورت۔';

  @override
  String get next => 'آگے';

  @override
  String get back => 'واپس';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get done => 'ہو گیا';

  @override
  String get skip => 'چھوڑیں';

  @override
  String get yes => 'ہاں';

  @override
  String get no => 'نہیں';

  @override
  String get loading => 'براہِ کرم انتظار کریں…';

  @override
  String get errorGeneric => 'کچھ غلط ہو گیا۔ براہِ کرم دوبارہ کوشش کریں۔';

  @override
  String get errorNetwork => 'نیٹ ورک نہیں ہے۔ آپ کا کام فون میں محفوظ ہے۔';

  @override
  String get savedOnPhone => 'فون میں محفوظ — نیٹ ورک آتے ہی اپ لوڈ ہو جائے گا';

  @override
  String get allSynced => 'سب اپ لوڈ ہو گیا';

  @override
  String get syncing => 'اپ لوڈ ہو رہا ہے…';

  @override
  String pendingCount(int count) {
    return '$count اپ لوڈ باقی';
  }

  @override
  String get chooseRole => 'آپ کون ہیں؟';

  @override
  String get roleArtisan => 'میں دستکاری بناتی/بناتا ہوں';

  @override
  String get roleBuyer => 'مجھے خریدنا ہے';

  @override
  String get roleKiosk => 'کیوسک / CSC معاون';

  @override
  String get chooseLanguage => 'اپنی زبان منتخب کریں';

  @override
  String get tapToHear =>
      'سننے کے لیے ایک بار چھوئیں، منتخب کرنے کے لیے دوبارہ چھوئیں';

  @override
  String get enterPhone => 'آپ کا موبائل نمبر';

  @override
  String get sendCode => 'کوڈ بھیجیں';

  @override
  String get enterCode => '6 ہندسوں کا کوڈ درج کریں';

  @override
  String codeSentTo(String phone) {
    return '$phone پر کوڈ بھیجا گیا';
  }

  @override
  String get verify => 'تصدیق کریں';

  @override
  String get sayNumber => 'اپنا نمبر بولیں';

  @override
  String demoCode(String code) {
    return 'ڈیمو کوڈ: $code';
  }

  @override
  String get consentTitle => 'آپ کی اجازت';

  @override
  String get consentBody =>
      'آپ کی دستکاری بیچنے کے لیے شلپ سیتو آپ کی آواز، آپ کی تصویریں اور آپ کے گاؤں کا پتہ محفوظ کرے گا۔ آپ انہیں کسی بھی وقت مٹا سکتے ہیں۔';

  @override
  String get consentVoice => 'میری آواز محفوظ کریں';

  @override
  String get consentPhoto => 'میری تصویریں محفوظ کریں';

  @override
  String get consentLocation => 'میرے گاؤں کا پتہ محفوظ کریں';

  @override
  String get iAgree => 'ہاں، میں متفق ہوں';

  @override
  String get sayYesToAgree => 'یا اتفاق کے لیے “ہاں” بولیں';

  @override
  String get profileTitle => 'اپنے بارے میں بتائیں';

  @override
  String get askName => 'آپ کا نام کیا ہے؟';

  @override
  String get askVillage => 'آپ کس گاؤں یا شہر سے ہیں؟';

  @override
  String get askState => 'کون سا ضلع اور ریاست؟';

  @override
  String get askCraft => 'آپ کون سی دستکاری کرتے ہیں؟';

  @override
  String get askYears => 'کتنے سال سے یہ کام کر رہے ہیں؟';

  @override
  String get askStory => 'اپنی کہانی سنائیں — یہ فن آپ نے کیسے سیکھا؟';

  @override
  String get askPehchan =>
      'اگر آپ کے پاس پہچان کاریگر کارڈ ہے تو اس کا نمبر بولیں۔ ورنہ چھوڑیں دبائیں۔';

  @override
  String get tapMicToAnswer => 'مائیک دبائیں اور جواب دیں';

  @override
  String get weHeard => 'ہم نے سنا:';

  @override
  String get profileSaved => 'آپ کی معلومات محفوظ ہو گئیں';

  @override
  String greeting(String name) {
    return 'آداب، $name';
  }

  @override
  String get tileAddProduct => 'چیز شامل کریں';

  @override
  String get tileMyProducts => 'میری چیزیں';

  @override
  String get tileOrders => 'آرڈر';

  @override
  String get tileEarnings => 'کمائی';

  @override
  String get tileHelp => 'مدد';

  @override
  String earningsSummary(String amount, int count) {
    return 'اس مہینے آپ نے $count آرڈر سے $amount کمائے';
  }

  @override
  String get addProductTitle => 'چیز شامل کریں';

  @override
  String get speakOwnLanguage => 'اپنی زبان میں بولیں';

  @override
  String listeningIn(String language) {
    return '$language میں سن رہے ہیں…';
  }

  @override
  String get tapToSpeak => 'بولنے کے لیے دبائیں، یا دبا کر رکھیں';

  @override
  String get stopRecording => 'روکنے کے لیے دبائیں';

  @override
  String get photoCaptured =>
      'تصویر لے لی — پس منظر اور روشنی خود بخود درست ہو رہی ہے';

  @override
  String get takePhoto => 'تصویر لیں';

  @override
  String get addMorePhotos => 'مزید تصویریں شامل کریں';

  @override
  String get makeListing => 'میری فہرست بنائیں';

  @override
  String get hintTooDark => 'تھوڑا اندھیرا ہے — ہو سکے تو روشنی کی طرف جائیں';

  @override
  String get hintTooBright => 'روشنی بہت زیادہ ہے — تھوڑا سائے میں جائیں';

  @override
  String get hintMoveCloser => 'تھوڑا قریب آئیں';

  @override
  String get hintBlurry => 'فون کو ساکن رکھیں';

  @override
  String get anyBackground => 'کوئی بھی روشنی، کوئی بھی پس منظر چلے گا';

  @override
  String get upTo60s => '60 سیکنڈ تک';

  @override
  String get aiBuilding => 'AI آپ کی فہرست بنا رہا ہے';

  @override
  String get stepAsr => 'آپ کی آواز سمجھ رہے ہیں';

  @override
  String get stepNlu => 'تفصیلات نکال رہے ہیں';

  @override
  String get stepListing => 'نام اور تفصیل لکھ رہے ہیں';

  @override
  String get stepTranslation => 'خریداروں کے لیے ترجمہ کر رہے ہیں';

  @override
  String get stepImage => 'آپ کی تصویر بہتر کر رہے ہیں';

  @override
  String get stepPrice => 'مناسب قیمت نکال رہے ہیں';

  @override
  String get stepCertificate => 'آپ کا سرٹیفکیٹ تیار کر رہے ہیں';

  @override
  String get quickQuestions => 'چند مختصر سوال';

  @override
  String get answerBySpeaking => 'بول کر جواب دیں';

  @override
  String get reviewTitle => 'جانچیں اور منظور کریں';

  @override
  String get approve => 'منظور کریں';

  @override
  String get changePrice => 'قیمت بدلیں';

  @override
  String get retakePhoto => 'دوبارہ تصویر لیں';

  @override
  String get reRecord => 'دوبارہ بولیں';

  @override
  String get sayNewPrice => 'نئی قیمت بولیں';

  @override
  String youGet(String amount, String pct) {
    return 'آپ کو ملیں گے $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'بازار بھاؤ $low – $high';
  }

  @override
  String get fairPrice => 'مناسب قیمت';

  @override
  String get category => 'زمرہ';

  @override
  String priceSpoken(String price, String amount) {
    return 'قیمت $price۔ آپ کو ملیں گے $amount۔';
  }

  @override
  String get belowFairWage => 'یہ آپ کی محنت کی مناسب اجرت سے کم ہے';

  @override
  String get isLive => 'آپ کی چیز اب فروخت پر ہے!';

  @override
  String get onOndc => 'ONDC نیٹ ورک پر بھی دستیاب ہے';

  @override
  String get certificateReady => 'آپ کا سرٹیفکیٹ تیار ہے';

  @override
  String get statusQueued => 'قطار میں';

  @override
  String get statusUploading => 'اپ لوڈ ہو رہا ہے';

  @override
  String get statusProcessing => 'تیار ہو رہا ہے';

  @override
  String get statusNeedsReview => 'جانچ ضروری';

  @override
  String get statusReady => 'منظوری کے لیے تیار';

  @override
  String get statusLive => 'فروخت پر';

  @override
  String get statusFailed => 'توجہ دیں';

  @override
  String get statusUnpublished => 'چھپا ہوا';

  @override
  String get noProducts => 'ابھی کوئی چیز نہیں۔ چیز شامل کریں دبائیں۔';

  @override
  String get newOrder => 'نیا آرڈر';

  @override
  String get accept => 'قبول کریں';

  @override
  String get decline => 'انکار کریں';

  @override
  String get markPacked => 'پیک ہو گیا';

  @override
  String get markShipped => 'بھیج دیا';

  @override
  String get noOrders => 'ابھی کوئی آرڈر نہیں';

  @override
  String get orderPlaced => 'نیا';

  @override
  String get orderAccepted => 'قبول';

  @override
  String get orderPacked => 'پیک';

  @override
  String get orderShipped => 'راستے میں';

  @override
  String get orderDelivered => 'پہنچ گیا';

  @override
  String get orderDeclined => 'انکار';

  @override
  String get orderCancelled => 'منسوخ';

  @override
  String get gross => 'فروخت';

  @override
  String get commission => 'پلیٹ فارم فیس';

  @override
  String get logistics => 'ترسیل';

  @override
  String get net => 'آپ کو ملے';

  @override
  String get everyRupee => 'ہر روپے کا حساب';

  @override
  String get helpTitle => 'مدد';

  @override
  String get callHelpline => 'ہیلپ لائن پر کال کریں';

  @override
  String get requestCallback => 'معاون مجھے کال کرے';

  @override
  String get callbackRequested => 'ایک معاون جلد آپ کو کال کرے گا';

  @override
  String get howToUse => 'شلپ سیتو کیسے کام کرتا ہے';

  @override
  String get fiveSteps =>
      'بولیں · تصویر لیں · AI بناتا ہے · آپ منظور کریں · فروخت پر';

  @override
  String get searchHint => 'دستکاری، ریاستیں، کاریگر تلاش کریں';

  @override
  String get freshFromLoom => 'کرگھے اور چاک سے تازہ';

  @override
  String get byCraft => 'فن کے لحاظ سے';

  @override
  String get byState => 'ریاست اور کلسٹر کے لحاظ سے';

  @override
  String get womenLed => 'خواتین کی قیادت والے گروپ';

  @override
  String get giTagged => 'GI ٹیگ والی دستکاری';

  @override
  String get nearYou => 'آپ کے قریب';

  @override
  String get filters => 'فلٹر';

  @override
  String get verifiedOnly => 'صرف تصدیق شدہ کاریگر';

  @override
  String get giOnly => 'صرف GI ٹیگ';

  @override
  String get sortBy => 'ترتیب';

  @override
  String get sortRelevance => 'سب سے موزوں';

  @override
  String get sortPriceLow => 'قیمت: کم سے زیادہ';

  @override
  String get sortPriceHigh => 'قیمت: زیادہ سے کم';

  @override
  String get sortNewest => 'سب سے نئے';

  @override
  String results(int count) {
    return '$count دستکاریاں';
  }

  @override
  String get addToCart => 'کارٹ میں ڈالیں';

  @override
  String get addedToCart => 'کارٹ میں ڈال دیا';

  @override
  String get scanCertificate => 'کاریگر سرٹیفکیٹ کے لیے اسکین کریں';

  @override
  String get certificateSub => 'سامان، کہانی اور قیمت کی بنیاد';

  @override
  String get howPriceBuilt => 'یہ قیمت کیسے بنی';

  @override
  String goesToArtisan(String amount, String pct) {
    return 'اس میں سے $amount سیدھے کاریگر کو جاتے ہیں ($pct%)';
  }

  @override
  String get meetArtisan => 'کاریگر سے ملیں';

  @override
  String get hearVoice => 'ان کی آواز سنیں';

  @override
  String get moreFromArtisan => 'اس کاریگر کی مزید چیزیں';

  @override
  String reviewsCount(int count) {
    return '($count جائزے)';
  }

  @override
  String get verifiedArtisan => 'تصدیق شدہ کاریگر';

  @override
  String get cart => 'کارٹ';

  @override
  String get cartEmpty => 'آپ کا کارٹ خالی ہے';

  @override
  String get checkout => 'ادائیگی';

  @override
  String get placeOrder => 'آرڈر کریں';

  @override
  String get payUpi => 'UPI سے ادا کریں';

  @override
  String get cod => 'ترسیل پر نقد';

  @override
  String deliveryIn(int days) {
    return 'تقریباً $days دن میں ترسیل';
  }

  @override
  String get shippingIncluded => 'ترسیل اور پیکنگ مناسب قیمت میں شامل ہے';

  @override
  String get orderPlacedThanks => 'شکریہ! آپ کا آرڈر ہو گیا۔';

  @override
  String get myOrders => 'میرے آرڈر';

  @override
  String get rateCraft => 'اس دستکاری کی درجہ بندی کریں';

  @override
  String get scanQr => 'سرٹیفکیٹ QR اسکین کریں';

  @override
  String get certValid => 'اصلی — شلپ سیتو سے تصدیق شدہ';

  @override
  String get certInvalid => 'درست نہیں';

  @override
  String get name => 'نام';

  @override
  String get address => 'پتہ';

  @override
  String get city => 'شہر';

  @override
  String get state => 'ریاست';

  @override
  String get pincode => 'پن کوڈ';

  @override
  String get phone => 'فون';

  @override
  String get total => 'کل';

  @override
  String get kioskTitle => 'کیوسک';

  @override
  String get myArtisans => 'کاریگر';

  @override
  String get onboardArtisan => 'کاریگر شامل کریں';

  @override
  String captureFor(String name) {
    return '$name کے لیے';
  }

  @override
  String get batchMode => 'نمائش بیچ موڈ';

  @override
  String get printTags => 'سرٹیفکیٹ ٹیگ چھاپیں';

  @override
  String get syncAll => 'سب اپ لوڈ کریں';

  @override
  String get attestation =>
      'میں نے ان کی شناخت جانچی اور ان کی زبانی رضامندی ریکارڈ کی';

  @override
  String get recordConsent => 'کاریگر کی رضامندی ریکارڈ کریں';

  @override
  String get about => 'تعارف';

  @override
  String get logout => 'لاگ آؤٹ';

  @override
  String get lowBandwidth => 'کم ڈیٹا موڈ';

  @override
  String get switchRole => 'موڈ بدلیں';

  @override
  String productsCount(int count) {
    return '$count چیزیں';
  }

  @override
  String get gender => 'جنس (اختیاری)';

  @override
  String get genderFemale => 'خاتون';

  @override
  String get genderMale => 'مرد';

  @override
  String get genderOther => 'دیگر';

  @override
  String get genderPreferNot => 'بتانا نہیں چاہتے';

  @override
  String get typeInstead => 'یا جواب لکھیں';

  @override
  String get send => 'بھیجیں';

  @override
  String get serverAddress => 'سرور کا پتہ';

  @override
  String get serverAddressHint => 'صرف معاون کے کہنے پر بدلیں';

  @override
  String get saved => 'محفوظ ہو گیا';

  @override
  String get darkMode => 'ڈارک موڈ';

  @override
  String get lightMode => 'لائٹ موڈ';

  @override
  String get productDetails => 'چیز کی تفصیل';

  @override
  String get aboutArtForm => 'اس فن کے بارے میں';

  @override
  String get howItsMade => 'کیسے بنتا ہے';

  @override
  String get didYouKnow => 'کیا آپ جانتے ہیں؟';

  @override
  String yearsOfPractice(int count) {
    return '$count سال کا تجربہ';
  }

  @override
  String get photoCredits => 'تصویری اعتراف';

  @override
  String get photoCreditsSub =>
      'وکی میڈیا کامنز سے اصل دستکاری کی تصاویر، لائسنس کے مطابق';

  @override
  String get askShilpi => 'شلپی سے پوچھیں';

  @override
  String get assistantName => 'شلپی';

  @override
  String get assistantTagline => 'آپ کی شلپ سیتو مددگار';

  @override
  String get assistantThinking => 'سوچ رہی ہوں…';

  @override
  String get askAnything => 'کچھ بھی پوچھیں';

  @override
  String get close => 'بند کریں';

  @override
  String get dayStreak => 'دن کا سلسلہ';

  @override
  String get todaysGoal => 'آج کا ہدف';

  @override
  String get craftOfTheDay => 'آج کا فن';

  @override
  String get exploreCraft => 'دیکھیں';

  @override
  String get celebrateLive => 'آپ کی چیز لائیو ہو گئی!';

  @override
  String get micPermission =>
      'براہ کرم مائیک کی اجازت دیں: سیٹنگز ← ایپس ← شلپ سیتو ← اجازتیں ← مائیکروفون۔';

  @override
  String get micUnavailable =>
      'اس فون میں بول کر لکھنے کی سہولت نہیں۔ Google وائس ٹائپنگ آن کریں، یا لکھ کر بتائیں۔';

  @override
  String get micInsecure =>
      'مائیک صرف شلپ سیتو ایپ میں یا محفوظ https لنک پر چلتا ہے۔ براہ کرم ایپ استعمال کریں۔';

  @override
  String get micNoSpeech =>
      'آواز سنائی نہیں دی۔ مائیک دبا کر تھوڑا اونچا بولیں۔';

  @override
  String get micNetwork => 'بول کر لکھنے کے لیے انٹرنیٹ چاہیے۔ کنکشن دیکھیں۔';

  @override
  String get pressBackAgain => 'بند کرنے کے لیے دوبارہ پیچھے دبائیں';
}
