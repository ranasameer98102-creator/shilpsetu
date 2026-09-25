// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Assamese (`as`).
class L10nAs extends L10n {
  L10nAs([String locale = 'as']) : super(locale);

  @override
  String get languageName => 'অসমীয়া';

  @override
  String get appTitle => 'শিল্পসেতু';

  @override
  String get tagline => 'প্ৰান্তীয় শিল্পীসকলৰ AI সহ-বিক্ৰেতা';

  @override
  String get heroLine =>
      'হাতৰ কামৰ পৰা শিৰোনামলৈ — প্ৰতিটো শিল্প, সদায় বজাৰত।';

  @override
  String get promise =>
      'এখন ফটো। এটা কোৱা বাক্য। ন্যায্য দামৰ, বিশ্বাসযোগ্য তালিকা — টাইপ নালাগে, দালাল নালাগে, ইংৰাজী নালাগে।';

  @override
  String get next => 'আগলৈ';

  @override
  String get back => 'উভতি যাওক';

  @override
  String get retry => 'আকৌ চেষ্টা কৰক';

  @override
  String get save => 'সাঁচি ৰাখক';

  @override
  String get cancel => 'বাতিল';

  @override
  String get done => 'হ\'ল';

  @override
  String get skip => 'এৰি দিয়ক';

  @override
  String get yes => 'হয়';

  @override
  String get no => 'নহয়';

  @override
  String get loading => 'অনুগ্ৰহ কৰি অপেক্ষা কৰক…';

  @override
  String get errorGeneric => 'কিবা ভুল হ\'ল। অনুগ্ৰহ কৰি আকৌ চেষ্টা কৰক।';

  @override
  String get errorNetwork => 'নেটৱৰ্ক নাই। আপোনাৰ কাম ফোনত সুৰক্ষিত আছে।';

  @override
  String get savedOnPhone => 'ফোনত সাঁচি ৰখা হ\'ল — নেটৱৰ্ক আহিলেই আপলোড হ\'ব';

  @override
  String get allSynced => 'সকলো আপলোড হ\'ল';

  @override
  String get syncing => 'আপলোড হৈ আছে…';

  @override
  String pendingCount(int count) {
    return '$countটা আপলোড বাকী';
  }

  @override
  String get chooseRole => 'আপুনি কোন?';

  @override
  String get roleArtisan => 'মই শিল্পসামগ্ৰী বনাওঁ';

  @override
  String get roleBuyer => 'মই কিনিব বিচাৰোঁ';

  @override
  String get roleKiosk => 'কিঅস্ক / CSC সহায়ক';

  @override
  String get chooseLanguage => 'আপোনাৰ ভাষা বাছক';

  @override
  String get tapToHear => 'শুনিবলৈ এবাৰ টিপক, বাছিবলৈ আকৌ টিপক';

  @override
  String get enterPhone => 'আপোনাৰ মোবাইল নম্বৰ';

  @override
  String get sendCode => 'ক\'ড পঠিয়াওক';

  @override
  String get enterCode => '6 অংকৰ ক\'ড দিয়ক';

  @override
  String codeSentTo(String phone) {
    return '$phoneলৈ ক\'ড পঠিওৱা হ\'ল';
  }

  @override
  String get verify => 'পৰীক্ষা কৰক';

  @override
  String get sayNumber => 'আপোনাৰ নম্বৰ কওক';

  @override
  String demoCode(String code) {
    return 'ডেমো ক\'ড: $code';
  }

  @override
  String get consentTitle => 'আপোনাৰ অনুমতি';

  @override
  String get consentBody =>
      'আপোনাৰ শিল্প বিক্ৰী কৰিবলৈ শিল্পসেতুৱে আপোনাৰ মাত, ফটো আৰু গাঁৱৰ ঠিকনা সাঁচি ৰাখিব। আপুনি যিকোনো সময়তে সেইবোৰ মচি পেলাব পাৰে।';

  @override
  String get consentVoice => 'মোৰ মাত সাঁচি ৰাখক';

  @override
  String get consentPhoto => 'মোৰ ফটো সাঁচি ৰাখক';

  @override
  String get consentLocation => 'মোৰ গাঁৱৰ ঠিকনা সাঁচি ৰাখক';

  @override
  String get iAgree => 'হয়, মই সন্মত';

  @override
  String get sayYesToAgree => 'বা সন্মতিৰ বাবে “হয়” কওক';

  @override
  String get profileTitle => 'আপোনাৰ বিষয়ে কওক';

  @override
  String get askName => 'আপোনাৰ নাম কি?';

  @override
  String get askVillage => 'আপুনি কোন গাঁও বা চহৰৰ?';

  @override
  String get askState => 'কোন জিলা আৰু ৰাজ্য?';

  @override
  String get askCraft => 'আপুনি কি শিল্প কৰে?';

  @override
  String get askYears => 'কিমান বছৰ ধৰি এই কাম কৰি আছে?';

  @override
  String get askStory => 'আপোনাৰ কাহিনী কওক — এই শিল্প কেনেকৈ শিকিলে?';

  @override
  String get askPehchan =>
      'পেহচান শিল্পী কাৰ্ড থাকিলে তাৰ নম্বৰ কওক। নহ\'লে এৰি দিয়ক টিপক।';

  @override
  String get tapMicToAnswer => 'মাইক টিপি উত্তৰ দিয়ক';

  @override
  String get weHeard => 'আমি শুনিলোঁ:';

  @override
  String get profileSaved => 'আপোনাৰ তথ্য সাঁচি ৰখা হ\'ল';

  @override
  String greeting(String name) {
    return 'নমস্কাৰ, $name';
  }

  @override
  String get tileAddProduct => 'সামগ্ৰী যোগ কৰক';

  @override
  String get tileMyProducts => 'মোৰ সামগ্ৰী';

  @override
  String get tileOrders => 'অৰ্ডাৰ';

  @override
  String get tileEarnings => 'উপাৰ্জন';

  @override
  String get tileHelp => 'সহায়';

  @override
  String earningsSummary(String amount, int count) {
    return 'এই মাহত $countটা অৰ্ডাৰৰ পৰা আপুনি $amount উপাৰ্জন কৰিলে';
  }

  @override
  String get addProductTitle => 'সামগ্ৰী যোগ কৰক';

  @override
  String get speakOwnLanguage => 'নিজৰ ভাষাত কওক';

  @override
  String listeningIn(String language) {
    return '$languageত শুনি আছোঁ…';
  }

  @override
  String get tapToSpeak => 'ক\'বলৈ টিপক, বা টিপি ধৰি ৰাখক';

  @override
  String get stopRecording => 'বন্ধ কৰিবলৈ টিপক';

  @override
  String get photoCaptured =>
      'ফটো লোৱা হ\'ল — পটভূমি আৰু পোহৰ নিজে নিজে ঠিক কৰা হৈছে';

  @override
  String get takePhoto => 'ফটো লওক';

  @override
  String get addMorePhotos => 'আৰু ফটো যোগ কৰক';

  @override
  String get makeListing => 'মোৰ তালিকা বনাওক';

  @override
  String get hintTooDark => 'অলপ আন্ধাৰ — পাৰিলে পোহৰৰ ফালে যাওক';

  @override
  String get hintTooBright => 'পোহৰ বেছি — অলপ ছাঁলৈ যাওক';

  @override
  String get hintMoveCloser => 'অলপ ওচৰলৈ আহক';

  @override
  String get hintBlurry => 'ফোনটো স্থিৰকৈ ধৰক';

  @override
  String get anyBackground => 'যিকোনো পোহৰ, যিকোনো পটভূমি চলিব';

  @override
  String get upTo60s => '60 ছেকেণ্ডলৈ';

  @override
  String get aiBuilding => 'AI-এ আপোনাৰ তালিকা বনাই আছে';

  @override
  String get stepAsr => 'আপোনাৰ মাত বুজি আছোঁ';

  @override
  String get stepNlu => 'তথ্য বিচাৰি আছোঁ';

  @override
  String get stepListing => 'নাম আৰু বিৱৰণ লিখি আছোঁ';

  @override
  String get stepTranslation => 'ক্ৰেতাৰ বাবে অনুবাদ কৰি আছোঁ';

  @override
  String get stepImage => 'আপোনাৰ ফটো উন্নত কৰি আছোঁ';

  @override
  String get stepPrice => 'ন্যায্য দাম হিচাপ কৰি আছোঁ';

  @override
  String get stepCertificate => 'আপোনাৰ প্ৰমাণপত্ৰ প্ৰস্তুত কৰি আছোঁ';

  @override
  String get quickQuestions => 'কেইটামান সৰু প্ৰশ্ন';

  @override
  String get answerBySpeaking => 'কৈ উত্তৰ দিয়ক';

  @override
  String get reviewTitle => 'চাই অনুমোদন দিয়ক';

  @override
  String get approve => 'অনুমোদন';

  @override
  String get changePrice => 'দাম সলনি কৰক';

  @override
  String get retakePhoto => 'আকৌ ফটো লওক';

  @override
  String get reRecord => 'আকৌ কওক';

  @override
  String get sayNewPrice => 'নতুন দাম কওক';

  @override
  String youGet(String amount, String pct) {
    return 'আপুনি পাব $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'বজাৰ দৰ $low – $high';
  }

  @override
  String get fairPrice => 'ন্যায্য দাম';

  @override
  String get category => 'শ্ৰেণী';

  @override
  String priceSpoken(String price, String amount) {
    return 'দাম $price। আপুনি পাব $amount।';
  }

  @override
  String get belowFairWage => 'এইটো আপোনাৰ পৰিশ্ৰমৰ ন্যায্য মজুৰিতকৈ কম';

  @override
  String get isLive => 'আপোনাৰ সামগ্ৰী এতিয়া বিক্ৰীত আছে!';

  @override
  String get onOndc => 'ONDC নেটৱৰ্কতো আছে';

  @override
  String get certificateReady => 'আপোনাৰ প্ৰমাণপত্ৰ সাজু';

  @override
  String get statusQueued => 'শাৰীত';

  @override
  String get statusUploading => 'আপলোড হৈ আছে';

  @override
  String get statusProcessing => 'প্ৰস্তুত হৈ আছে';

  @override
  String get statusNeedsReview => 'পৰীক্ষা লাগে';

  @override
  String get statusReady => 'অনুমোদনৰ বাবে সাজু';

  @override
  String get statusLive => 'বিক্ৰীত';

  @override
  String get statusFailed => 'মনোযোগ দিয়ক';

  @override
  String get statusUnpublished => 'লুকুৱাই ৰখা';

  @override
  String get noProducts => 'এতিয়ালৈ কোনো সামগ্ৰী নাই। সামগ্ৰী যোগ কৰক টিপক।';

  @override
  String get newOrder => 'নতুন অৰ্ডাৰ';

  @override
  String get accept => 'গ্ৰহণ কৰক';

  @override
  String get decline => 'নাকচ কৰক';

  @override
  String get markPacked => 'পেক হ\'ল';

  @override
  String get markShipped => 'পঠিওৱা হ\'ল';

  @override
  String get noOrders => 'এতিয়ালৈ কোনো অৰ্ডাৰ নাই';

  @override
  String get orderPlaced => 'নতুন';

  @override
  String get orderAccepted => 'গৃহীত';

  @override
  String get orderPacked => 'পেক কৰা';

  @override
  String get orderShipped => 'বাটত';

  @override
  String get orderDelivered => 'পালেগৈ';

  @override
  String get orderDeclined => 'নাকচ';

  @override
  String get orderCancelled => 'বাতিল';

  @override
  String get gross => 'বিক্ৰী';

  @override
  String get commission => 'প্লেটফৰ্ম মাচুল';

  @override
  String get logistics => 'পঠিওৱা খৰচ';

  @override
  String get net => 'আপুনি পালে';

  @override
  String get everyRupee => 'প্ৰতিটো টকাৰ হিচাপ';

  @override
  String get helpTitle => 'সহায়';

  @override
  String get callHelpline => 'হেল্পলাইনলৈ ফোন কৰক';

  @override
  String get requestCallback => 'সহায়কে মোক ফোন কৰক';

  @override
  String get callbackRequested => 'এজন সহায়কে সোনকালে আপোনাক ফোন কৰিব';

  @override
  String get howToUse => 'শিল্পসেতুৱে কেনেকৈ কাম কৰে';

  @override
  String get fiveSteps =>
      'কওক · ফটো লওক · AI-এ বনায় · আপুনি অনুমোদন দিয়ক · বিক্ৰীত';

  @override
  String get searchHint => 'Search crafts, states, artisans';

  @override
  String get freshFromLoom => 'Fresh from the loom & wheel';

  @override
  String get byCraft => 'By craft';

  @override
  String get byState => 'By state & cluster';

  @override
  String get womenLed => 'Women-led collectives';

  @override
  String get giTagged => 'GI-tagged crafts';

  @override
  String get nearYou => 'Near you';

  @override
  String get filters => 'Filters';

  @override
  String get verifiedOnly => 'Verified artisans only';

  @override
  String get giOnly => 'GI-tagged only';

  @override
  String get sortBy => 'Sort';

  @override
  String get sortRelevance => 'Best match';

  @override
  String get sortPriceLow => 'Price: low to high';

  @override
  String get sortPriceHigh => 'Price: high to low';

  @override
  String get sortNewest => 'Newest';

  @override
  String results(int count) {
    return '$count crafts';
  }

  @override
  String get addToCart => 'কাৰ্টত যোগ কৰক';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get scanCertificate => 'Scan for Artisan Provenance Certificate';

  @override
  String get certificateSub => 'Materials, story & fair-price basis';

  @override
  String get howPriceBuilt => 'এই দাম কেনেকৈ নিৰ্ধাৰণ হ\'ল';

  @override
  String goesToArtisan(String amount, String pct) {
    return 'ইয়াৰ পৰা $amount পোনপটীয়াকৈ শিল্পীলৈ যায় ($pct%)';
  }

  @override
  String get meetArtisan => 'শিল্পীক লগ কৰক';

  @override
  String get hearVoice => 'Hear their voice';

  @override
  String get moreFromArtisan => 'More from this artisan';

  @override
  String reviewsCount(int count) {
    return '($count reviews)';
  }

  @override
  String get verifiedArtisan => 'পৰীক্ষিত শিল্পী';

  @override
  String get cart => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get checkout => 'Checkout';

  @override
  String get placeOrder => 'Place order';

  @override
  String get payUpi => 'Pay by UPI';

  @override
  String get cod => 'Cash on delivery';

  @override
  String deliveryIn(int days) {
    return 'Delivery in about $days days';
  }

  @override
  String get shippingIncluded =>
      'Shipping & packing are included in the fair price';

  @override
  String get orderPlacedThanks => 'Thank you! Your order is placed.';

  @override
  String get myOrders => 'My orders';

  @override
  String get rateCraft => 'Rate this craft';

  @override
  String get scanQr => 'Scan a certificate QR';

  @override
  String get certValid => 'Genuine — verified by ShilpSetu';

  @override
  String get certInvalid => 'Not valid';

  @override
  String get name => 'নাম';

  @override
  String get address => 'ঠিকনা';

  @override
  String get city => 'চহৰ';

  @override
  String get state => 'ৰাজ্য';

  @override
  String get pincode => 'PIN code';

  @override
  String get phone => 'ফোন';

  @override
  String get total => 'মুঠ';

  @override
  String get kioskTitle => 'Kiosk';

  @override
  String get myArtisans => 'Artisans';

  @override
  String get onboardArtisan => 'Onboard an artisan';

  @override
  String captureFor(String name) {
    return 'Capture for $name';
  }

  @override
  String get batchMode => 'Exhibition batch mode';

  @override
  String get printTags => 'Print certificate tags';

  @override
  String get syncAll => 'Sync all';

  @override
  String get attestation =>
      'I checked their identity and recorded their spoken consent';

  @override
  String get recordConsent => 'Record the artisan saying they agree';

  @override
  String get about => 'পৰিচয়';

  @override
  String get logout => 'লগ আউট';

  @override
  String get lowBandwidth => 'কম ডাটা মোড';

  @override
  String get switchRole => 'মোড সলনি কৰক';

  @override
  String productsCount(int count) {
    return '$countটা সামগ্ৰী';
  }

  @override
  String get gender => 'লিংগ (ঐচ্ছিক)';

  @override
  String get genderFemale => 'মহিলা';

  @override
  String get genderMale => 'পুৰুষ';

  @override
  String get genderOther => 'অন্যান্য';

  @override
  String get genderPreferNot => 'ক\'ব নিবিচাৰোঁ';

  @override
  String get typeInstead => 'বা উত্তৰ লিখক';

  @override
  String get send => 'পঠিয়াওক';

  @override
  String get serverAddress => 'চাৰ্ভাৰৰ ঠিকনা';

  @override
  String get serverAddressHint => 'সহায়কে ক\'লেহে সলনি কৰক';

  @override
  String get saved => 'সাঁচি ৰখা হ\'ল';

  @override
  String get darkMode => 'ডাৰ্ক মোড';

  @override
  String get lightMode => 'লাইট মোড';

  @override
  String get productDetails => 'সামগ্ৰীৰ বিৱৰণ';

  @override
  String get aboutArtForm => 'এই কলাৰ বিষয়ে';

  @override
  String get howItsMade => 'কেনেকৈ বনোৱা হয়';

  @override
  String get didYouKnow => 'আপুনি জানেনে?';

  @override
  String yearsOfPractice(int count) {
    return '$count বছৰৰ অভিজ্ঞতা';
  }

  @override
  String get photoCredits => 'ফটোৰ স্বীকৃতি';

  @override
  String get photoCreditsSub =>
      'ৱিকিমিডিয়া কমন্সৰ পৰা প্ৰকৃত শিল্পৰ ফটো, অনুজ্ঞাপত্ৰ মতে';

  @override
  String get askShilpi => 'শিল্পীক সোধক';

  @override
  String get assistantName => 'শিল্পী';

  @override
  String get assistantTagline => 'আপোনাৰ শিল্পসেতু সহায়িকা';

  @override
  String get assistantThinking => 'ভাবি আছোঁ…';

  @override
  String get askAnything => 'যিকোনো কথা সোধক';

  @override
  String get close => 'বন্ধ কৰক';

  @override
  String get dayStreak => 'দিনৰ ধাৰা';

  @override
  String get todaysGoal => 'আজিৰ লক্ষ্য';

  @override
  String get craftOfTheDay => 'আজিৰ শিল্প';

  @override
  String get exploreCraft => 'চাওক';

  @override
  String get celebrateLive => 'আপোনাৰ সামগ্ৰী লাইভ হ\'ল!';

  @override
  String get micPermission =>
      'মাইকৰ অনুমতি দিয়ক: ছেটিংছ → এপ → শিল্পসেতু → অনুমতি → মাইক্ৰ\'ফোন।';

  @override
  String get micUnavailable =>
      'এই ফোনত কৈ লিখাৰ সুবিধা নাই। Google ভইচ টাইপিং অন কৰক, বা লিখি দিয়ক।';

  @override
  String get micInsecure =>
      'মাইক কেৱল শিল্পসেতু এপত বা সুৰক্ষিত https লিংকত চলে। অনুগ্ৰহ কৰি এপটো ব্যৱহাৰ কৰক।';

  @override
  String get micNoSpeech => 'শুনা নগ\'ল। মাইক টিপি অলপ ডাঙৰকৈ কওক।';

  @override
  String get micNetwork => 'কৈ লিখিবলৈ ইণ্টাৰনেট লাগে। সংযোগ চাওক।';

  @override
  String get pressBackAgain => 'ওলাবলৈ আকৌ পিছলৈ টিপক';
}
