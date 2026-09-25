// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class L10nBn extends L10n {
  L10nBn([String locale = 'bn']) : super(locale);

  @override
  String get languageName => 'বাংলা';

  @override
  String get appTitle => 'শিল্পসেতু';

  @override
  String get tagline => 'প্রান্তিক কারিগরদের AI সহ-বিক্রেতা';

  @override
  String get heroLine =>
      'হাতের কাজ থেকে শিরোনামে — প্রতিটি শিল্প, সবসময় বাজারে।';

  @override
  String get promise =>
      'একটি ছবি। একটি বলা বাক্য। ন্যায্য দামে, বিশ্বস্ত তালিকা — টাইপ নেই, দালাল নেই, ইংরেজি লাগে না।';

  @override
  String get next => 'এগিয়ে যান';

  @override
  String get back => 'ফিরে যান';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get save => 'সংরক্ষণ করুন';

  @override
  String get cancel => 'বাতিল';

  @override
  String get done => 'হয়ে গেছে';

  @override
  String get skip => 'বাদ দিন';

  @override
  String get yes => 'হ্যাঁ';

  @override
  String get no => 'না';

  @override
  String get loading => 'একটু অপেক্ষা করুন…';

  @override
  String get errorGeneric => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get errorNetwork => 'নেটওয়ার্ক নেই। আপনার কাজ ফোনে রাখা আছে।';

  @override
  String get savedOnPhone => 'ফোনে রাখা হয়েছে — নেটওয়ার্ক এলেই আপলোড হবে';

  @override
  String get allSynced => 'সব আপলোড হয়ে গেছে';

  @override
  String get syncing => 'আপলোড হচ্ছে…';

  @override
  String pendingCount(int count) {
    return '$countটি আপলোডের অপেক্ষায়';
  }

  @override
  String get chooseRole => 'আপনি কে?';

  @override
  String get roleArtisan => 'আমি শিল্প তৈরি করি';

  @override
  String get roleBuyer => 'আমি কিনতে চাই';

  @override
  String get roleKiosk => 'কিয়স্ক / CSC সহায়ক';

  @override
  String get chooseLanguage => 'আপনার ভাষা বেছে নিন';

  @override
  String get tapToHear => 'শুনতে একবার ছুঁয়ে দিন, বেছে নিতে আবার ছুঁয়ে দিন';

  @override
  String get enterPhone => 'আপনার মোবাইল নম্বর';

  @override
  String get sendCode => 'কোড পাঠান';

  @override
  String get enterCode => '৬ সংখ্যার কোড দিন';

  @override
  String codeSentTo(String phone) {
    return '$phone নম্বরে কোড পাঠানো হয়েছে';
  }

  @override
  String get verify => 'যাচাই করুন';

  @override
  String get sayNumber => 'আপনার নম্বর বলুন';

  @override
  String demoCode(String code) {
    return 'ডেমো কোড: $code';
  }

  @override
  String get consentTitle => 'আপনার অনুমতি';

  @override
  String get consentBody =>
      'আপনার শিল্প বিক্রি করার জন্য শিল্পসেতু আপনার কণ্ঠস্বর, আপনার ছবি আর আপনার গ্রামের ঠিকানা রাখবে। আপনি যেকোনো সময় এগুলো মুছে দিতে পারেন।';

  @override
  String get consentVoice => 'আমার কণ্ঠস্বর রাখুন';

  @override
  String get consentPhoto => 'আমার ছবি রাখুন';

  @override
  String get consentLocation => 'আমার গ্রামের ঠিকানা রাখুন';

  @override
  String get iAgree => 'হ্যাঁ, আমি রাজি';

  @override
  String get sayYesToAgree => 'অথবা রাজি হতে “হ্যাঁ” বলুন';

  @override
  String get profileTitle => 'আপনার সম্পর্কে বলুন';

  @override
  String get askName => 'আপনার নাম কী?';

  @override
  String get askVillage => 'আপনি কোন গ্রাম বা শহর থেকে?';

  @override
  String get askState => 'কোন জেলা আর রাজ্য?';

  @override
  String get askCraft => 'আপনি কোন শিল্প তৈরি করেন?';

  @override
  String get askYears => 'কত বছর ধরে এই কাজ করছেন?';

  @override
  String get askStory => 'আপনার গল্প বলুন — এই কাজ কীভাবে শিখলেন?';

  @override
  String get askPehchan =>
      'পহেচান কারিগর কার্ড থাকলে তার নম্বর বলুন। না থাকলে বাদ দিন চাপুন।';

  @override
  String get tapMicToAnswer => 'মাইক চেপে উত্তর দিন';

  @override
  String get weHeard => 'আমরা শুনলাম:';

  @override
  String get profileSaved => 'আপনার তথ্য রাখা হয়েছে';

  @override
  String greeting(String name) {
    return 'নমস্কার, $name';
  }

  @override
  String get tileAddProduct => 'পণ্য যোগ করুন';

  @override
  String get tileMyProducts => 'আমার পণ্য';

  @override
  String get tileOrders => 'অর্ডার';

  @override
  String get tileEarnings => 'আয়';

  @override
  String get tileHelp => 'সাহায্য';

  @override
  String earningsSummary(String amount, int count) {
    return 'এই মাসে $countটি অর্ডার থেকে আপনি $amount আয় করেছেন';
  }

  @override
  String get addProductTitle => 'পণ্য যোগ করুন';

  @override
  String get speakOwnLanguage => 'নিজের ভাষায় বলুন';

  @override
  String listeningIn(String language) {
    return '$language-য় শুনছি…';
  }

  @override
  String get tapToSpeak => 'বলতে চাপুন, বা চেপে ধরে রাখুন';

  @override
  String get stopRecording => 'থামাতে চাপুন';

  @override
  String get photoCaptured =>
      'ছবি তোলা হয়েছে — পটভূমি আর আলো আপনা থেকেই ঠিক করা হচ্ছে';

  @override
  String get takePhoto => 'ছবি তুলুন';

  @override
  String get addMorePhotos => 'আরও ছবি যোগ করুন';

  @override
  String get makeListing => 'আমার তালিকা তৈরি করো';

  @override
  String get hintTooDark => 'একটু অন্ধকার — পারলে আলোর দিকে যান';

  @override
  String get hintTooBright => 'আলো বেশি — একটু ছায়ায় যান';

  @override
  String get hintMoveCloser => 'একটু কাছে আসুন';

  @override
  String get hintBlurry => 'ফোন স্থির রাখুন';

  @override
  String get anyBackground => 'যেকোনো আলো, যেকোনো পটভূমি চলবে';

  @override
  String get upTo60s => '৬০ সেকেন্ড পর্যন্ত';

  @override
  String get aiBuilding => 'AI আপনার তালিকা তৈরি করছে';

  @override
  String get stepAsr => 'আপনার কথা বুঝছি';

  @override
  String get stepNlu => 'তথ্য খুঁজছি';

  @override
  String get stepListing => 'নাম আর বিবরণ লিখছি';

  @override
  String get stepTranslation => 'ক্রেতাদের জন্য অনুবাদ করছি';

  @override
  String get stepImage => 'আপনার ছবি সুন্দর করছি';

  @override
  String get stepPrice => 'ন্যায্য দাম হিসেব করছি';

  @override
  String get stepCertificate => 'আপনার সার্টিফিকেট তৈরি করছি';

  @override
  String get quickQuestions => 'কয়েকটা ছোট প্রশ্ন';

  @override
  String get answerBySpeaking => 'বলে উত্তর দিন';

  @override
  String get reviewTitle => 'দেখে অনুমোদন দিন';

  @override
  String get approve => 'অনুমোদন';

  @override
  String get changePrice => 'দাম বদলান';

  @override
  String get retakePhoto => 'আবার ছবি তুলুন';

  @override
  String get reRecord => 'আবার বলুন';

  @override
  String get sayNewPrice => 'নতুন দাম বলুন';

  @override
  String youGet(String amount, String pct) {
    return 'আপনি পাবেন $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'বাজার দর $low – $high';
  }

  @override
  String get fairPrice => 'ন্যায্য দাম';

  @override
  String get category => 'বিভাগ';

  @override
  String priceSpoken(String price, String amount) {
    return 'দাম $price. আপনি পাবেন $amount.';
  }

  @override
  String get belowFairWage => 'এটা আপনার পরিশ্রমের ন্যায্য মজুরির চেয়ে কম';

  @override
  String get isLive => 'আপনার পণ্য এখন বিক্রিতে!';

  @override
  String get onOndc => 'ONDC নেটওয়ার্কেও দেখা যাচ্ছে';

  @override
  String get certificateReady => 'আপনার সার্টিফিকেট তৈরি';

  @override
  String get statusQueued => 'লাইনে আছে';

  @override
  String get statusUploading => 'আপলোড হচ্ছে';

  @override
  String get statusProcessing => 'তৈরি হচ্ছে';

  @override
  String get statusNeedsReview => 'দেখা দরকার';

  @override
  String get statusReady => 'অনুমোদনের জন্য তৈরি';

  @override
  String get statusLive => 'বিক্রিতে';

  @override
  String get statusFailed => 'মনোযোগ দিন';

  @override
  String get statusUnpublished => 'লুকানো';

  @override
  String get noProducts => 'এখনও কোনো পণ্য নেই। পণ্য যোগ করুন চাপুন।';

  @override
  String get newOrder => 'নতুন অর্ডার';

  @override
  String get accept => 'গ্রহণ করুন';

  @override
  String get decline => 'না বলুন';

  @override
  String get markPacked => 'প্যাক হয়েছে';

  @override
  String get markShipped => 'পাঠানো হয়েছে';

  @override
  String get noOrders => 'এখনও কোনো অর্ডার নেই';

  @override
  String get orderPlaced => 'নতুন';

  @override
  String get orderAccepted => 'গৃহীত';

  @override
  String get orderPacked => 'প্যাক করা';

  @override
  String get orderShipped => 'পথে';

  @override
  String get orderDelivered => 'পৌঁছে গেছে';

  @override
  String get orderDeclined => 'প্রত্যাখ্যাত';

  @override
  String get orderCancelled => 'বাতিল';

  @override
  String get gross => 'বিক্রি';

  @override
  String get commission => 'প্ল্যাটফর্ম ফি';

  @override
  String get logistics => 'ডেলিভারি';

  @override
  String get net => 'আপনি পেয়েছেন';

  @override
  String get everyRupee => 'প্রতিটি টাকার হিসেব';

  @override
  String get helpTitle => 'সাহায্য';

  @override
  String get callHelpline => 'হেল্পলাইনে ফোন করুন';

  @override
  String get requestCallback => 'সহায়ক আমাকে ফোন করুন';

  @override
  String get callbackRequested => 'একজন সহায়ক শীঘ্রই আপনাকে ফোন করবেন';

  @override
  String get howToUse => 'শিল্পসেতু কীভাবে কাজ করে';

  @override
  String get fiveSteps =>
      'বলুন · ছবি তুলুন · AI তৈরি করে · আপনি অনুমোদন দিন · বিক্রিতে';

  @override
  String get searchHint => 'শিল্প, রাজ্য, কারিগর খুঁজুন';

  @override
  String get freshFromLoom => 'তাঁত আর চাক থেকে টাটকা';

  @override
  String get byCraft => 'শিল্প অনুযায়ী';

  @override
  String get byState => 'রাজ্য আর ক্লাস্টার অনুযায়ী';

  @override
  String get womenLed => 'মহিলা-নেতৃত্বাধীন গোষ্ঠী';

  @override
  String get giTagged => 'GI-চিহ্নিত শিল্প';

  @override
  String get nearYou => 'আপনার কাছে';

  @override
  String get filters => 'ফিল্টার';

  @override
  String get verifiedOnly => 'শুধু যাচাই করা কারিগর';

  @override
  String get giOnly => 'শুধু GI-চিহ্নিত';

  @override
  String get sortBy => 'সাজান';

  @override
  String get sortRelevance => 'সবচেয়ে মানানসই';

  @override
  String get sortPriceLow => 'দাম: কম থেকে বেশি';

  @override
  String get sortPriceHigh => 'দাম: বেশি থেকে কম';

  @override
  String get sortNewest => 'সবচেয়ে নতুন';

  @override
  String results(int count) {
    return '$countটি শিল্প';
  }

  @override
  String get addToCart => 'কার্টে যোগ করুন';

  @override
  String get addedToCart => 'কার্টে যোগ হয়েছে';

  @override
  String get scanCertificate => 'কারিগর সার্টিফিকেটের জন্য স্ক্যান করুন';

  @override
  String get certificateSub => 'উপকরণ, গল্প আর দামের ভিত্তি';

  @override
  String get howPriceBuilt => 'এই দাম কীভাবে তৈরি';

  @override
  String goesToArtisan(String amount, String pct) {
    return 'এর মধ্যে $amount সরাসরি কারিগরের কাছে যায় ($pct%)';
  }

  @override
  String get meetArtisan => 'কারিগরের সঙ্গে পরিচয়';

  @override
  String get hearVoice => 'তাঁর কণ্ঠ শুনুন';

  @override
  String get moreFromArtisan => 'এই কারিগরের আরও কাজ';

  @override
  String reviewsCount(int count) {
    return '($countটি রিভিউ)';
  }

  @override
  String get verifiedArtisan => 'যাচাই করা কারিগর';

  @override
  String get cart => 'কার্ট';

  @override
  String get cartEmpty => 'আপনার কার্ট খালি';

  @override
  String get checkout => 'চেকআউট';

  @override
  String get placeOrder => 'অর্ডার দিন';

  @override
  String get payUpi => 'UPI-তে টাকা দিন';

  @override
  String get cod => 'ডেলিভারিতে নগদ';

  @override
  String deliveryIn(int days) {
    return 'প্রায় $days দিনে ডেলিভারি';
  }

  @override
  String get shippingIncluded => 'ডেলিভারি আর প্যাকিং ন্যায্য দামের মধ্যেই আছে';

  @override
  String get orderPlacedThanks => 'ধন্যবাদ! আপনার অর্ডার হয়ে গেছে।';

  @override
  String get myOrders => 'আমার অর্ডার';

  @override
  String get rateCraft => 'এই শিল্পকে রেটিং দিন';

  @override
  String get scanQr => 'সার্টিফিকেট QR স্ক্যান করুন';

  @override
  String get certValid => 'খাঁটি — শিল্পসেতু দ্বারা যাচাই করা';

  @override
  String get certInvalid => 'বৈধ নয়';

  @override
  String get name => 'নাম';

  @override
  String get address => 'ঠিকানা';

  @override
  String get city => 'শহর';

  @override
  String get state => 'রাজ্য';

  @override
  String get pincode => 'পিন কোড';

  @override
  String get phone => 'ফোন';

  @override
  String get total => 'মোট';

  @override
  String get kioskTitle => 'কিয়স্ক';

  @override
  String get myArtisans => 'কারিগর';

  @override
  String get onboardArtisan => 'কারিগর যোগ করুন';

  @override
  String captureFor(String name) {
    return '$name-এর জন্য';
  }

  @override
  String get batchMode => 'প্রদর্শনী ব্যাচ মোড';

  @override
  String get printTags => 'সার্টিফিকেট ট্যাগ ছাপুন';

  @override
  String get syncAll => 'সব আপলোড করুন';

  @override
  String get attestation =>
      'আমি তাঁর পরিচয় যাচাই করেছি আর তাঁর মুখে বলা সম্মতি রেকর্ড করেছি';

  @override
  String get recordConsent => 'কারিগরের সম্মতি রেকর্ড করুন';

  @override
  String get about => 'পরিচিতি';

  @override
  String get logout => 'লগ আউট';

  @override
  String get lowBandwidth => 'কম ডেটা মোড';

  @override
  String get switchRole => 'মোড বদলান';

  @override
  String productsCount(int count) {
    return '$countটি পণ্য';
  }

  @override
  String get gender => 'লিঙ্গ (ঐচ্ছিক)';

  @override
  String get genderFemale => 'মহিলা';

  @override
  String get genderMale => 'পুরুষ';

  @override
  String get genderOther => 'অন্যান্য';

  @override
  String get genderPreferNot => 'বলতে চাই না';

  @override
  String get typeInstead => 'অথবা উত্তর লিখুন';

  @override
  String get send => 'পাঠান';

  @override
  String get serverAddress => 'সার্ভারের ঠিকানা';

  @override
  String get serverAddressHint => 'সহায়ক বললে তবেই বদলান';

  @override
  String get saved => 'রাখা হয়েছে';

  @override
  String get darkMode => 'ডার্ক মোড';

  @override
  String get lightMode => 'লাইট মোড';

  @override
  String get productDetails => 'পণ্যের বিবরণ';

  @override
  String get aboutArtForm => 'এই শিল্প সম্পর্কে';

  @override
  String get howItsMade => 'কীভাবে তৈরি হয়';

  @override
  String get didYouKnow => 'আপনি কি জানেন?';

  @override
  String yearsOfPractice(int count) {
    return '$count বছরের অভিজ্ঞতা';
  }

  @override
  String get photoCredits => 'ছবির স্বীকৃতি';

  @override
  String get photoCreditsSub =>
      'উইকিমিডিয়া কমন্স থেকে আসল শিল্পের ছবি, লাইসেন্স মেনে';

  @override
  String get askShilpi => 'শিল্পীকে জিজ্ঞাসা করুন';

  @override
  String get assistantName => 'শিল্পী';

  @override
  String get assistantTagline => 'আপনার শিল্পসেতু সহায়ক';

  @override
  String get assistantThinking => 'ভাবছি…';

  @override
  String get askAnything => 'যা খুশি জিজ্ঞাসা করুন';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get dayStreak => 'দিনের ধারা';

  @override
  String get todaysGoal => 'আজকের লক্ষ্য';

  @override
  String get craftOfTheDay => 'আজকের শিল্প';

  @override
  String get exploreCraft => 'দেখুন';

  @override
  String get celebrateLive => 'আপনার পণ্য লাইভ হয়েছে!';

  @override
  String get micPermission =>
      'মাইকের অনুমতি দিন: সেটিংস → অ্যাপস → শিল্পসেতু → অনুমতি → মাইক্রোফোন।';

  @override
  String get micUnavailable =>
      'এই ফোনে বলে লেখার সুবিধা নেই। Google ভয়েস টাইপিং চালু করুন, বা লিখে দিন।';

  @override
  String get micInsecure =>
      'মাইক শুধু শিল্পসেতু অ্যাপে বা নিরাপদ https লিঙ্কে কাজ করে। অ্যাপটি ব্যবহার করুন।';

  @override
  String get micNoSpeech => 'শুনতে পাইনি। মাইক টিপে একটু জোরে বলুন।';

  @override
  String get micNetwork => 'বলে লেখার জন্য ইন্টারনেট দরকার। সংযোগ দেখুন।';

  @override
  String get pressBackAgain => 'বন্ধ করতে আবার পিছনে টিপুন';
}
