// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class L10nMr extends L10n {
  L10nMr([String locale = 'mr']) : super(locale);

  @override
  String get languageName => 'मराठी';

  @override
  String get appTitle => 'शिल्पसेतु';

  @override
  String get tagline => 'उपेक्षित कारागिरांचा AI सह-विक्रेता';

  @override
  String get heroLine =>
      'हातच्या कलेपासून मथळ्यापर्यंत — प्रत्येक कला, नेहमी बाजारात.';

  @override
  String get promise =>
      'एक फोटो. एक बोललेले वाक्य. योग्य किमतीची, विश्वासार्ह यादी — टायपिंग नाही, दलाल नाही, इंग्रजीची गरज नाही.';

  @override
  String get next => 'पुढे';

  @override
  String get back => 'मागे';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get save => 'जतन करा';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get done => 'झाले';

  @override
  String get skip => 'वगळा';

  @override
  String get yes => 'हो';

  @override
  String get no => 'नाही';

  @override
  String get loading => 'कृपया थांबा…';

  @override
  String get errorGeneric => 'काहीतरी चूक झाली. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get errorNetwork => 'नेटवर्क नाही. तुमचे काम फोनमध्ये सुरक्षित आहे.';

  @override
  String get savedOnPhone => 'फोनमध्ये जतन केले — नेटवर्क आल्यावर अपलोड होईल';

  @override
  String get allSynced => 'सर्व अपलोड झाले';

  @override
  String get syncing => 'अपलोड होत आहे…';

  @override
  String pendingCount(int count) {
    return '$count अपलोड बाकी';
  }

  @override
  String get chooseRole => 'तुम्ही कोण आहात?';

  @override
  String get roleArtisan => 'मी कलाकृती बनवते/बनवतो';

  @override
  String get roleBuyer => 'मला खरेदी करायची आहे';

  @override
  String get roleKiosk => 'किओस्क / CSC मदतनीस';

  @override
  String get chooseLanguage => 'तुमची भाषा निवडा';

  @override
  String get tapToHear =>
      'ऐकण्यासाठी एकदा स्पर्श करा, निवडण्यासाठी पुन्हा स्पर्श करा';

  @override
  String get enterPhone => 'तुमचा मोबाईल नंबर';

  @override
  String get sendCode => 'कोड पाठवा';

  @override
  String get enterCode => '6 अंकी कोड टाका';

  @override
  String codeSentTo(String phone) {
    return '$phone वर कोड पाठवला';
  }

  @override
  String get verify => 'पडताळा';

  @override
  String get sayNumber => 'तुमचा नंबर बोला';

  @override
  String demoCode(String code) {
    return 'डेमो कोड: $code';
  }

  @override
  String get consentTitle => 'तुमची परवानगी';

  @override
  String get consentBody =>
      'तुमची कलाकृती विकण्यासाठी शिल्पसेतु तुमचा आवाज, तुमचे फोटो आणि तुमच्या गावाचा पत्ता जतन करेल. तुम्ही ते कधीही हटवू शकता.';

  @override
  String get consentVoice => 'माझा आवाज जतन करा';

  @override
  String get consentPhoto => 'माझे फोटो जतन करा';

  @override
  String get consentLocation => 'माझ्या गावाचा पत्ता जतन करा';

  @override
  String get iAgree => 'हो, मी सहमत आहे';

  @override
  String get sayYesToAgree => 'किंवा सहमतीसाठी “हो” म्हणा';

  @override
  String get profileTitle => 'तुमच्याबद्दल सांगा';

  @override
  String get askName => 'तुमचे नाव काय आहे?';

  @override
  String get askVillage => 'तुम्ही कोणत्या गावाचे किंवा शहराचे आहात?';

  @override
  String get askState => 'कोणता जिल्हा आणि राज्य?';

  @override
  String get askCraft => 'तुम्ही कोणती कला करता?';

  @override
  String get askYears => 'किती वर्षांपासून ही कला करत आहात?';

  @override
  String get askStory => 'तुमची कहाणी सांगा — ही कला कशी शिकलात?';

  @override
  String get askPehchan =>
      'तुमच्याकडे पहचान कारागीर कार्ड असल्यास त्याचा नंबर बोला. नसल्यास वगळा दाबा.';

  @override
  String get tapMicToAnswer => 'माईक दाबा आणि उत्तर द्या';

  @override
  String get weHeard => 'आम्ही ऐकले:';

  @override
  String get profileSaved => 'तुमची माहिती जतन झाली';

  @override
  String greeting(String name) {
    return 'नमस्कार, $name';
  }

  @override
  String get tileAddProduct => 'वस्तू जोडा';

  @override
  String get tileMyProducts => 'माझ्या वस्तू';

  @override
  String get tileOrders => 'ऑर्डर';

  @override
  String get tileEarnings => 'कमाई';

  @override
  String get tileHelp => 'मदत';

  @override
  String earningsSummary(String amount, int count) {
    return 'या महिन्यात तुम्ही $count ऑर्डरमधून $amount कमावले';
  }

  @override
  String get addProductTitle => 'वस्तू जोडा';

  @override
  String get speakOwnLanguage => 'तुमच्या भाषेत बोला';

  @override
  String listeningIn(String language) {
    return '$language मध्ये ऐकत आहोत…';
  }

  @override
  String get tapToSpeak => 'बोलण्यासाठी दाबा, किंवा दाबून ठेवा';

  @override
  String get stopRecording => 'थांबवण्यासाठी दाबा';

  @override
  String get photoCaptured =>
      'फोटो घेतला — पार्श्वभूमी आणि प्रकाश आपोआप सुधारत आहोत';

  @override
  String get takePhoto => 'फोटो घ्या';

  @override
  String get addMorePhotos => 'आणखी फोटो जोडा';

  @override
  String get makeListing => 'माझी यादी बनवा';

  @override
  String get hintTooDark => 'थोडा अंधार आहे — शक्य असल्यास प्रकाशाकडे जा';

  @override
  String get hintTooBright => 'खूप प्रकाश आहे — थोड्या सावलीत जा';

  @override
  String get hintMoveCloser => 'थोडे जवळ या';

  @override
  String get hintBlurry => 'फोन स्थिर धरा';

  @override
  String get anyBackground => 'कोणताही प्रकाश, कोणतीही पार्श्वभूमी चालेल';

  @override
  String get upTo60s => '60 सेकंदांपर्यंत';

  @override
  String get aiBuilding => 'AI तुमची यादी बनवत आहे';

  @override
  String get stepAsr => 'तुमचा आवाज समजून घेत आहोत';

  @override
  String get stepNlu => 'माहिती शोधत आहोत';

  @override
  String get stepListing => 'नाव आणि वर्णन लिहित आहोत';

  @override
  String get stepTranslation => 'खरेदीदारांसाठी भाषांतर करत आहोत';

  @override
  String get stepImage => 'तुमचा फोटो सुधारत आहोत';

  @override
  String get stepPrice => 'योग्य किंमत ठरवत आहोत';

  @override
  String get stepCertificate => 'तुमचे प्रमाणपत्र तयार करत आहोत';

  @override
  String get quickQuestions => 'काही छोटे प्रश्न';

  @override
  String get answerBySpeaking => 'बोलून उत्तर द्या';

  @override
  String get reviewTitle => 'तपासा आणि मंजूर करा';

  @override
  String get approve => 'मंजूर करा';

  @override
  String get changePrice => 'किंमत बदला';

  @override
  String get retakePhoto => 'पुन्हा फोटो घ्या';

  @override
  String get reRecord => 'पुन्हा बोला';

  @override
  String get sayNewPrice => 'नवीन किंमत बोला';

  @override
  String youGet(String amount, String pct) {
    return 'तुम्हाला मिळतील $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'बाजारभाव $low – $high';
  }

  @override
  String get fairPrice => 'योग्य किंमत';

  @override
  String get category => 'प्रकार';

  @override
  String priceSpoken(String price, String amount) {
    return 'किंमत $price. तुम्हाला मिळतील $amount.';
  }

  @override
  String get belowFairWage => 'हे तुमच्या कष्टाच्या योग्य मजुरीपेक्षा कमी आहे';

  @override
  String get isLive => 'तुमची वस्तू आता विक्रीला आहे!';

  @override
  String get onOndc => 'ONDC नेटवर्कवरही दिसते';

  @override
  String get certificateReady => 'तुमचे प्रमाणपत्र तयार आहे';

  @override
  String get statusQueued => 'रांगेत';

  @override
  String get statusUploading => 'अपलोड होत आहे';

  @override
  String get statusProcessing => 'तयार होत आहे';

  @override
  String get statusNeedsReview => 'तपासणी आवश्यक';

  @override
  String get statusReady => 'मंजुरीसाठी तयार';

  @override
  String get statusLive => 'विक्रीला';

  @override
  String get statusFailed => 'लक्ष द्या';

  @override
  String get statusUnpublished => 'लपवलेले';

  @override
  String get noProducts => 'अजून कोणतीही वस्तू नाही. वस्तू जोडा दाबा.';

  @override
  String get newOrder => 'नवीन ऑर्डर';

  @override
  String get accept => 'स्वीकारा';

  @override
  String get decline => 'नाकारा';

  @override
  String get markPacked => 'पॅक झाले';

  @override
  String get markShipped => 'पाठवले';

  @override
  String get noOrders => 'अजून कोणतीही ऑर्डर नाही';

  @override
  String get orderPlaced => 'नवीन';

  @override
  String get orderAccepted => 'स्वीकारली';

  @override
  String get orderPacked => 'पॅक केली';

  @override
  String get orderShipped => 'वाटेत';

  @override
  String get orderDelivered => 'पोहोचली';

  @override
  String get orderDeclined => 'नाकारली';

  @override
  String get orderCancelled => 'रद्द';

  @override
  String get gross => 'विक्री';

  @override
  String get commission => 'प्लॅटफॉर्म शुल्क';

  @override
  String get logistics => 'डिलिव्हरी';

  @override
  String get net => 'तुम्हाला मिळाले';

  @override
  String get everyRupee => 'प्रत्येक रुपयाचा हिशोब';

  @override
  String get helpTitle => 'मदत';

  @override
  String get callHelpline => 'हेल्पलाइनला फोन करा';

  @override
  String get requestCallback => 'मदतनीसाने मला फोन करावा';

  @override
  String get callbackRequested => 'एक मदतनीस लवकरच तुम्हाला फोन करेल';

  @override
  String get howToUse => 'शिल्पसेतु कसे काम करते';

  @override
  String get fiveSteps =>
      'बोला · फोटो घ्या · AI बनवते · तुम्ही मंजूर करा · विक्रीला';

  @override
  String get searchHint => 'कला, राज्य, कारागीर शोधा';

  @override
  String get freshFromLoom => 'मागावरून आणि चाकावरून ताजे';

  @override
  String get byCraft => 'कलेनुसार';

  @override
  String get byState => 'राज्य आणि क्लस्टरनुसार';

  @override
  String get womenLed => 'महिला-नेतृत्वाखालील गट';

  @override
  String get giTagged => 'GI-मानांकित कला';

  @override
  String get nearYou => 'तुमच्या जवळ';

  @override
  String get filters => 'फिल्टर';

  @override
  String get verifiedOnly => 'फक्त पडताळलेले कारागीर';

  @override
  String get giOnly => 'फक्त GI-मानांकित';

  @override
  String get sortBy => 'क्रम';

  @override
  String get sortRelevance => 'सर्वात योग्य';

  @override
  String get sortPriceLow => 'किंमत: कमी ते जास्त';

  @override
  String get sortPriceHigh => 'किंमत: जास्त ते कमी';

  @override
  String get sortNewest => 'सर्वात नवीन';

  @override
  String results(int count) {
    return '$count कलाकृती';
  }

  @override
  String get addToCart => 'कार्टमध्ये टाका';

  @override
  String get addedToCart => 'कार्टमध्ये टाकले';

  @override
  String get scanCertificate => 'कारागीर प्रमाणपत्रासाठी स्कॅन करा';

  @override
  String get certificateSub => 'साहित्य, कहाणी आणि किमतीचा आधार';

  @override
  String get howPriceBuilt => 'ही किंमत कशी ठरली';

  @override
  String goesToArtisan(String amount, String pct) {
    return 'यापैकी $amount थेट कारागिराला जातात ($pct%)';
  }

  @override
  String get meetArtisan => 'कारागिराला भेटा';

  @override
  String get hearVoice => 'त्यांचा आवाज ऐका';

  @override
  String get moreFromArtisan => 'या कारागिराच्या आणखी कलाकृती';

  @override
  String reviewsCount(int count) {
    return '($count पुनरावलोकने)';
  }

  @override
  String get verifiedArtisan => 'पडताळलेला कारागीर';

  @override
  String get cart => 'कार्ट';

  @override
  String get cartEmpty => 'तुमची कार्ट रिकामी आहे';

  @override
  String get checkout => 'चेकआउट';

  @override
  String get placeOrder => 'ऑर्डर करा';

  @override
  String get payUpi => 'UPI ने पैसे द्या';

  @override
  String get cod => 'डिलिव्हरीवर रोख';

  @override
  String deliveryIn(int days) {
    return 'सुमारे $days दिवसांत डिलिव्हरी';
  }

  @override
  String get shippingIncluded =>
      'डिलिव्हरी आणि पॅकिंग योग्य किमतीत समाविष्ट आहे';

  @override
  String get orderPlacedThanks => 'धन्यवाद! तुमची ऑर्डर झाली.';

  @override
  String get myOrders => 'माझ्या ऑर्डर';

  @override
  String get rateCraft => 'या कलाकृतीला रेटिंग द्या';

  @override
  String get scanQr => 'प्रमाणपत्र QR स्कॅन करा';

  @override
  String get certValid => 'अस्सल — शिल्पसेतुने पडताळलेले';

  @override
  String get certInvalid => 'वैध नाही';

  @override
  String get name => 'नाव';

  @override
  String get address => 'पत्ता';

  @override
  String get city => 'शहर';

  @override
  String get state => 'राज्य';

  @override
  String get pincode => 'पिन कोड';

  @override
  String get phone => 'फोन';

  @override
  String get total => 'एकूण';

  @override
  String get kioskTitle => 'किओस्क';

  @override
  String get myArtisans => 'कारागीर';

  @override
  String get onboardArtisan => 'कारागीर जोडा';

  @override
  String captureFor(String name) {
    return '$name साठी';
  }

  @override
  String get batchMode => 'प्रदर्शन बॅच मोड';

  @override
  String get printTags => 'प्रमाणपत्र टॅग छापा';

  @override
  String get syncAll => 'सर्व अपलोड करा';

  @override
  String get attestation =>
      'मी त्यांची ओळख तपासली आणि त्यांची बोललेली संमती रेकॉर्ड केली';

  @override
  String get recordConsent => 'कारागिराची संमती रेकॉर्ड करा';

  @override
  String get about => 'माहिती';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get lowBandwidth => 'कमी डेटा मोड';

  @override
  String get switchRole => 'मोड बदला';

  @override
  String productsCount(int count) {
    return '$count वस्तू';
  }

  @override
  String get gender => 'लिंग (ऐच्छिक)';

  @override
  String get genderFemale => 'स्त्री';

  @override
  String get genderMale => 'पुरुष';

  @override
  String get genderOther => 'इतर';

  @override
  String get genderPreferNot => 'सांगू इच्छित नाही';

  @override
  String get typeInstead => 'किंवा उत्तर लिहा';

  @override
  String get send => 'पाठवा';

  @override
  String get serverAddress => 'सर्व्हरचा पत्ता';

  @override
  String get serverAddressHint => 'मदतनीसाने सांगितले तरच बदला';

  @override
  String get saved => 'जतन केले';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get lightMode => 'लाइट मोड';

  @override
  String get productDetails => 'वस्तूची माहिती';

  @override
  String get aboutArtForm => 'या कलेविषयी';

  @override
  String get howItsMade => 'कशी बनते';

  @override
  String get didYouKnow => 'तुम्हाला माहीत आहे का?';

  @override
  String yearsOfPractice(int count) {
    return '$count वर्षांचा अनुभव';
  }

  @override
  String get photoCredits => 'फोटो श्रेय';

  @override
  String get photoCreditsSub =>
      'विकिमीडिया कॉमन्समधील खऱ्या कलाकृतींचे फोटो, परवान्यानुसार';

  @override
  String get askShilpi => 'शिल्पीला विचारा';

  @override
  String get assistantName => 'शिल्पी';

  @override
  String get assistantTagline => 'तुमची शिल्पसेतू मदतनीस';

  @override
  String get assistantThinking => 'विचार करते आहे…';

  @override
  String get askAnything => 'काहीही विचारा';

  @override
  String get close => 'बंद करा';

  @override
  String get dayStreak => 'दिवसांची मालिका';

  @override
  String get todaysGoal => 'आजचे ध्येय';

  @override
  String get craftOfTheDay => 'आजची कला';

  @override
  String get exploreCraft => 'पहा';

  @override
  String get celebrateLive => 'तुमची वस्तू लाइव्ह झाली!';

  @override
  String get micPermission =>
      'कृपया माइकची परवानगी द्या: सेटिंग्ज → ॲप्स → शिल्पसेतू → परवानग्या → मायक्रोफोन.';

  @override
  String get micUnavailable =>
      'या फोनमध्ये बोलून लिहिण्याची सोय नाही. Google व्हॉइस टायपिंग सुरू करा, किंवा लिहून सांगा.';

  @override
  String get micInsecure =>
      'माइक फक्त शिल्पसेतू ॲपमध्ये किंवा सुरक्षित https लिंकवर चालतो. कृपया ॲप वापरा.';

  @override
  String get micNoSpeech => 'आवाज ऐकू आला नाही. माइक दाबून थोडे मोठ्याने बोला.';

  @override
  String get micNetwork =>
      'बोलून लिहिण्यासाठी इंटरनेट लागते. कृपया नेटवर्क तपासा.';

  @override
  String get pressBackAgain => 'बंद करण्यासाठी पुन्हा मागे दाबा';
}
