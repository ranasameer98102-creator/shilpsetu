// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class L10nHi extends L10n {
  L10nHi([String locale = 'hi']) : super(locale);

  @override
  String get languageName => 'हिन्दी';

  @override
  String get appTitle => 'शिल्पसेतु';

  @override
  String get tagline => 'हाशिये के कारीगरों का AI सह-विक्रेता';

  @override
  String get heroLine =>
      'हाथ के हुनर से सुर्ख़ियों तक — हर शिल्प, हमेशा बाज़ार में।';

  @override
  String get promise =>
      'एक फ़ोटो। एक बोला हुआ वाक्य। सही दाम वाली, भरोसेमंद लिस्टिंग — न टाइपिंग, न बिचौलिया, न अंग्रेज़ी की ज़रूरत।';

  @override
  String get next => 'आगे';

  @override
  String get back => 'वापस';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get done => 'हो गया';

  @override
  String get skip => 'छोड़ें';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get loading => 'कृपया रुकिए…';

  @override
  String get errorGeneric => 'कुछ गड़बड़ हो गई। कृपया फिर से कोशिश करें।';

  @override
  String get errorNetwork => 'नेटवर्क नहीं है। आपका काम फ़ोन में सुरक्षित है।';

  @override
  String get savedOnPhone =>
      'फ़ोन में सहेजा गया — नेटवर्क आते ही अपलोड हो जाएगा';

  @override
  String get allSynced => 'सब अपलोड हो गया';

  @override
  String get syncing => 'अपलोड हो रहा है…';

  @override
  String pendingCount(int count) {
    return '$count अपलोड होना बाकी';
  }

  @override
  String get chooseRole => 'आप कौन हैं?';

  @override
  String get roleArtisan => 'मैं शिल्प बनाती/बनाता हूँ';

  @override
  String get roleBuyer => 'मुझे ख़रीदना है';

  @override
  String get roleKiosk => 'कियोस्क / CSC सहायक';

  @override
  String get chooseLanguage => 'अपनी भाषा चुनें';

  @override
  String get tapToHear => 'सुनने के लिए एक बार छुएँ, चुनने के लिए दोबारा छुएँ';

  @override
  String get enterPhone => 'आपका मोबाइल नंबर';

  @override
  String get sendCode => 'कोड भेजें';

  @override
  String get enterCode => '6 अंकों का कोड डालें';

  @override
  String codeSentTo(String phone) {
    return '$phone पर कोड भेजा गया';
  }

  @override
  String get verify => 'पुष्टि करें';

  @override
  String get sayNumber => 'अपना नंबर बोलें';

  @override
  String demoCode(String code) {
    return 'डेमो कोड: $code';
  }

  @override
  String get consentTitle => 'आपकी अनुमति';

  @override
  String get consentBody =>
      'आपका शिल्प बेचने के लिए शिल्पसेतु आपकी आवाज़, आपकी फ़ोटो और आपके गाँव का पता सहेजेगा। आप इन्हें कभी भी मिटा सकती/सकते हैं।';

  @override
  String get consentVoice => 'मेरी आवाज़ सहेजें';

  @override
  String get consentPhoto => 'मेरी फ़ोटो सहेजें';

  @override
  String get consentLocation => 'मेरे गाँव का पता सहेजें';

  @override
  String get iAgree => 'हाँ, मैं सहमत हूँ';

  @override
  String get sayYesToAgree => 'या सहमति के लिए “हाँ” बोलें';

  @override
  String get profileTitle => 'अपने बारे में बताइए';

  @override
  String get askName => 'आपका नाम क्या है?';

  @override
  String get askVillage => 'आप किस गाँव या शहर से हैं?';

  @override
  String get askState => 'कौन सा ज़िला और राज्य?';

  @override
  String get askCraft => 'आप कौन सा शिल्प बनाती/बनाते हैं?';

  @override
  String get askYears => 'आप कितने साल से यह शिल्प कर रहे हैं?';

  @override
  String get askStory => 'अपनी कहानी बताइए — यह कला आपने कैसे सीखी?';

  @override
  String get askPehchan =>
      'अगर आपके पास पहचान कारीगर कार्ड है तो उसका नंबर बोलें। नहीं तो छोड़ें दबाएँ।';

  @override
  String get tapMicToAnswer => 'माइक दबाएँ और जवाब दें';

  @override
  String get weHeard => 'हमने सुना:';

  @override
  String get profileSaved => 'आपकी जानकारी सहेज ली गई';

  @override
  String greeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get tileAddProduct => 'उत्पाद जोड़ें';

  @override
  String get tileMyProducts => 'मेरे उत्पाद';

  @override
  String get tileOrders => 'ऑर्डर';

  @override
  String get tileEarnings => 'कमाई';

  @override
  String get tileHelp => 'मदद';

  @override
  String earningsSummary(String amount, int count) {
    return 'इस महीने आपने $count ऑर्डर से $amount कमाए';
  }

  @override
  String get addProductTitle => 'उत्पाद जोड़ें';

  @override
  String get speakOwnLanguage => 'अपनी भाषा में बोलिए';

  @override
  String listeningIn(String language) {
    return '$language में सुन रहे हैं…';
  }

  @override
  String get tapToSpeak => 'बोलने के लिए दबाएँ, या दबाकर रखें';

  @override
  String get stopRecording => 'रोकने के लिए दबाएँ';

  @override
  String get photoCaptured =>
      'फ़ोटो ले ली — पृष्ठभूमि और रोशनी अपने आप सुधारी जा रही है';

  @override
  String get takePhoto => 'फ़ोटो लें';

  @override
  String get addMorePhotos => 'और फ़ोटो जोड़ें';

  @override
  String get makeListing => 'मेरी लिस्टिंग बनाओ';

  @override
  String get hintTooDark => 'थोड़ा अँधेरा है — हो सके तो रोशनी की तरफ़ जाएँ';

  @override
  String get hintTooBright => 'बहुत ज़्यादा रोशनी है — थोड़ी छाँव में जाएँ';

  @override
  String get hintMoveCloser => 'थोड़ा पास आइए';

  @override
  String get hintBlurry => 'फ़ोन को स्थिर रखें';

  @override
  String get anyBackground => 'कोई भी रोशनी, कोई भी पृष्ठभूमि चलेगी';

  @override
  String get upTo60s => '60 सेकंड तक';

  @override
  String get aiBuilding => 'AI आपकी लिस्टिंग बना रहा है';

  @override
  String get stepAsr => 'आपकी आवाज़ समझ रहे हैं';

  @override
  String get stepNlu => 'जानकारी निकाल रहे हैं';

  @override
  String get stepListing => 'नाम और विवरण लिख रहे हैं';

  @override
  String get stepTranslation => 'ख़रीदारों के लिए अनुवाद कर रहे हैं';

  @override
  String get stepImage => 'आपकी फ़ोटो सुधार रहे हैं';

  @override
  String get stepPrice => 'सही दाम निकाल रहे हैं';

  @override
  String get stepCertificate => 'आपका प्रमाणपत्र तैयार कर रहे हैं';

  @override
  String get quickQuestions => 'कुछ छोटे सवाल';

  @override
  String get answerBySpeaking => 'बोलकर जवाब दें';

  @override
  String get reviewTitle => 'जाँचें और मंज़ूरी दें';

  @override
  String get approve => 'मंज़ूर करें';

  @override
  String get changePrice => 'दाम बदलें';

  @override
  String get retakePhoto => 'फ़ोटो दोबारा लें';

  @override
  String get reRecord => 'दोबारा बोलें';

  @override
  String get sayNewPrice => 'नया दाम बोलिए';

  @override
  String youGet(String amount, String pct) {
    return 'आपको मिलेंगे $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'बाज़ार भाव $low – $high';
  }

  @override
  String get fairPrice => 'सही दाम';

  @override
  String get category => 'श्रेणी';

  @override
  String priceSpoken(String price, String amount) {
    return 'दाम $price. आपको मिलेंगे $amount.';
  }

  @override
  String get belowFairWage => 'यह आपकी मेहनत की उचित मज़दूरी से कम है';

  @override
  String get isLive => 'आपका उत्पाद अब बिक्री पर है!';

  @override
  String get onOndc => 'ONDC नेटवर्क पर भी दिख रहा है';

  @override
  String get certificateReady => 'आपका प्रमाणपत्र तैयार है';

  @override
  String get statusQueued => 'कतार में';

  @override
  String get statusUploading => 'अपलोड हो रहा है';

  @override
  String get statusProcessing => 'तैयार हो रहा है';

  @override
  String get statusNeedsReview => 'जाँच ज़रूरी';

  @override
  String get statusReady => 'मंज़ूरी के लिए तैयार';

  @override
  String get statusLive => 'बिक्री पर';

  @override
  String get statusFailed => 'ध्यान दें';

  @override
  String get statusUnpublished => 'छिपा हुआ';

  @override
  String get noProducts => 'अभी कोई उत्पाद नहीं है। उत्पाद जोड़ें दबाएँ।';

  @override
  String get newOrder => 'नया ऑर्डर';

  @override
  String get accept => 'स्वीकार करें';

  @override
  String get decline => 'मना करें';

  @override
  String get markPacked => 'पैक हो गया';

  @override
  String get markShipped => 'भेज दिया';

  @override
  String get noOrders => 'अभी कोई ऑर्डर नहीं';

  @override
  String get orderPlaced => 'नया';

  @override
  String get orderAccepted => 'स्वीकार';

  @override
  String get orderPacked => 'पैक';

  @override
  String get orderShipped => 'रास्ते में';

  @override
  String get orderDelivered => 'पहुँच गया';

  @override
  String get orderDeclined => 'मना किया';

  @override
  String get orderCancelled => 'रद्द';

  @override
  String get gross => 'बिक्री';

  @override
  String get commission => 'प्लेटफ़ॉर्म शुल्क';

  @override
  String get logistics => 'डिलीवरी';

  @override
  String get net => 'आपको मिले';

  @override
  String get everyRupee => 'हर रुपये का हिसाब';

  @override
  String get helpTitle => 'मदद';

  @override
  String get callHelpline => 'हेल्पलाइन पर कॉल करें';

  @override
  String get requestCallback => 'सहायक मुझे कॉल करें';

  @override
  String get callbackRequested => 'एक सहायक जल्द ही आपको कॉल करेगा';

  @override
  String get howToUse => 'शिल्पसेतु कैसे काम करता है';

  @override
  String get fiveSteps =>
      'बोलिए · फ़ोटो लीजिए · AI बनाता है · आप मंज़ूर करें · बिक्री पर';

  @override
  String get searchHint => 'शिल्प, राज्य, कारीगर खोजें';

  @override
  String get freshFromLoom => 'करघे और चाक से ताज़ा';

  @override
  String get byCraft => 'शिल्प के अनुसार';

  @override
  String get byState => 'राज्य और क्लस्टर के अनुसार';

  @override
  String get womenLed => 'महिला-नेतृत्व समूह';

  @override
  String get giTagged => 'GI-टैग शिल्प';

  @override
  String get nearYou => 'आपके पास';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get verifiedOnly => 'सिर्फ़ सत्यापित कारीगर';

  @override
  String get giOnly => 'सिर्फ़ GI-टैग';

  @override
  String get sortBy => 'क्रम';

  @override
  String get sortRelevance => 'सबसे उपयुक्त';

  @override
  String get sortPriceLow => 'दाम: कम से ज़्यादा';

  @override
  String get sortPriceHigh => 'दाम: ज़्यादा से कम';

  @override
  String get sortNewest => 'सबसे नए';

  @override
  String results(int count) {
    return '$count शिल्प';
  }

  @override
  String get addToCart => 'कार्ट में डालें';

  @override
  String get addedToCart => 'कार्ट में डाल दिया';

  @override
  String get scanCertificate => 'कारीगर प्रमाणपत्र के लिए स्कैन करें';

  @override
  String get certificateSub => 'सामग्री, कहानी और दाम का आधार';

  @override
  String get howPriceBuilt => 'यह दाम कैसे बना';

  @override
  String goesToArtisan(String amount, String pct) {
    return 'इसमें से $amount सीधे कारीगर को ($pct%)';
  }

  @override
  String get meetArtisan => 'कारीगर से मिलिए';

  @override
  String get hearVoice => 'उनकी आवाज़ सुनिए';

  @override
  String get moreFromArtisan => 'इस कारीगर के और शिल्प';

  @override
  String reviewsCount(int count) {
    return '($count समीक्षाएँ)';
  }

  @override
  String get verifiedArtisan => 'सत्यापित कारीगर';

  @override
  String get cart => 'कार्ट';

  @override
  String get cartEmpty => 'आपका कार्ट खाली है';

  @override
  String get checkout => 'भुगतान';

  @override
  String get placeOrder => 'ऑर्डर करें';

  @override
  String get payUpi => 'UPI से भुगतान';

  @override
  String get cod => 'डिलीवरी पर नकद';

  @override
  String deliveryIn(int days) {
    return 'लगभग $days दिन में डिलीवरी';
  }

  @override
  String get shippingIncluded => 'डिलीवरी और पैकिंग सही दाम में शामिल है';

  @override
  String get orderPlacedThanks => 'धन्यवाद! आपका ऑर्डर हो गया।';

  @override
  String get myOrders => 'मेरे ऑर्डर';

  @override
  String get rateCraft => 'इस शिल्प को रेटिंग दें';

  @override
  String get scanQr => 'प्रमाणपत्र QR स्कैन करें';

  @override
  String get certValid => 'असली — शिल्पसेतु द्वारा सत्यापित';

  @override
  String get certInvalid => 'मान्य नहीं';

  @override
  String get name => 'नाम';

  @override
  String get address => 'पता';

  @override
  String get city => 'शहर';

  @override
  String get state => 'राज्य';

  @override
  String get pincode => 'पिन कोड';

  @override
  String get phone => 'फ़ोन';

  @override
  String get total => 'कुल';

  @override
  String get kioskTitle => 'कियोस्क';

  @override
  String get myArtisans => 'कारीगर';

  @override
  String get onboardArtisan => 'कारीगर जोड़ें';

  @override
  String captureFor(String name) {
    return '$name के लिए';
  }

  @override
  String get batchMode => 'प्रदर्शनी बैच मोड';

  @override
  String get printTags => 'प्रमाणपत्र टैग छापें';

  @override
  String get syncAll => 'सब अपलोड करें';

  @override
  String get attestation =>
      'मैंने उनकी पहचान जाँची और उनकी बोली गई सहमति रिकॉर्ड की';

  @override
  String get recordConsent => 'कारीगर की सहमति रिकॉर्ड करें';

  @override
  String get about => 'परिचय';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get lowBandwidth => 'कम डेटा मोड';

  @override
  String get switchRole => 'मोड बदलें';

  @override
  String productsCount(int count) {
    return '$count उत्पाद';
  }

  @override
  String get gender => 'लिंग (वैकल्पिक, स्वयं बताएँ)';

  @override
  String get genderFemale => 'महिला';

  @override
  String get genderMale => 'पुरुष';

  @override
  String get genderOther => 'अन्य';

  @override
  String get genderPreferNot => 'नहीं बताना चाहते';

  @override
  String get typeInstead => 'या जवाब लिखें';

  @override
  String get send => 'भेजें';

  @override
  String get serverAddress => 'सर्वर का पता';

  @override
  String get serverAddressHint => 'केवल सहायक के कहने पर बदलें';

  @override
  String get saved => 'सहेज लिया';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get lightMode => 'लाइट मोड';

  @override
  String get productDetails => 'उत्पाद की जानकारी';

  @override
  String get aboutArtForm => 'इस कला के बारे में';

  @override
  String get howItsMade => 'कैसे बनता है';

  @override
  String get didYouKnow => 'क्या आप जानते हैं?';

  @override
  String yearsOfPractice(int count) {
    return '$count साल का अनुभव';
  }

  @override
  String get photoCredits => 'फोटो आभार';

  @override
  String get photoCreditsSub =>
      'विकिमीडिया कॉमन्स से असली शिल्प की फोटो, उनकी लाइसेंस शर्तों के साथ';

  @override
  String get askShilpi => 'शिल्पी से पूछें';

  @override
  String get assistantName => 'शिल्पी';

  @override
  String get assistantTagline => 'आपकी शिल्पसेतु सहायक';

  @override
  String get assistantThinking => 'सोच रही हूँ…';

  @override
  String get askAnything => 'कुछ भी पूछिए';

  @override
  String get close => 'बंद करें';

  @override
  String get dayStreak => 'दिन की स्ट्रीक';

  @override
  String get todaysGoal => 'आज का लक्ष्य';

  @override
  String get craftOfTheDay => 'आज का शिल्प';

  @override
  String get exploreCraft => 'देखें';

  @override
  String get celebrateLive => 'आपका सामान लाइव हो गया!';

  @override
  String get micPermission =>
      'कृपया माइक की अनुमति दें: सेटिंग्स → ऐप्स → शिल्पसेतु → अनुमतियाँ → माइक्रोफ़ोन।';

  @override
  String get micUnavailable =>
      'इस फ़ोन में बोलकर लिखने की सुविधा नहीं है। Google वॉइस टाइपिंग चालू करें, या लिखकर बताएं।';

  @override
  String get micInsecure =>
      'माइक सिर्फ़ शिल्पसेतु ऐप में या सुरक्षित https लिंक पर चलता है। कृपया ऐप इस्तेमाल करें।';

  @override
  String get micNoSpeech =>
      'आवाज़ सुनाई नहीं दी। माइक दबाकर थोड़ा ज़ोर से बोलिए।';

  @override
  String get micNetwork =>
      'इस फ़ोन पर बोलकर लिखने के लिए इंटरनेट चाहिए। कृपया नेटवर्क देखें।';

  @override
  String get pressBackAgain => 'बंद करने के लिए फिर से पीछे दबाएँ';
}
