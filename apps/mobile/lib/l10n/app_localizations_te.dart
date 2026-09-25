// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class L10nTe extends L10n {
  L10nTe([String locale = 'te']) : super(locale);

  @override
  String get languageName => 'తెలుగు';

  @override
  String get appTitle => 'శిల్ప్‌సేతు';

  @override
  String get tagline => 'అట్టడుగు కళాకారుల కోసం AI సహ-విక్రేత';

  @override
  String get heroLine =>
      'చేతి పని నుంచి పతాక శీర్షికల దాకా — ప్రతి కళ, ఎప్పుడూ మార్కెట్‌లో.';

  @override
  String get promise =>
      'ఒక ఫోటో. ఒక మాట. న్యాయమైన ధరతో, నమ్మదగిన జాబితా — టైపింగ్ లేదు, దళారీ లేరు, ఇంగ్లీష్ అక్కర్లేదు.';

  @override
  String get next => 'తరువాత';

  @override
  String get back => 'వెనక్కి';

  @override
  String get retry => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get save => 'సేవ్ చేయండి';

  @override
  String get cancel => 'రద్దు';

  @override
  String get done => 'అయిపోయింది';

  @override
  String get skip => 'దాటవేయండి';

  @override
  String get yes => 'అవును';

  @override
  String get no => 'కాదు';

  @override
  String get loading => 'దయచేసి ఆగండి…';

  @override
  String get errorGeneric => 'ఏదో తప్పు జరిగింది. మళ్లీ ప్రయత్నించండి.';

  @override
  String get errorNetwork => 'నెట్‌వర్క్ లేదు. మీ పని ఫోన్‌లో భద్రంగా ఉంది.';

  @override
  String get savedOnPhone =>
      'ఫోన్‌లో సేవ్ అయింది — నెట్‌వర్క్ రాగానే అప్‌లోడ్ అవుతుంది';

  @override
  String get allSynced => 'అన్నీ అప్‌లోడ్ అయ్యాయి';

  @override
  String get syncing => 'అప్‌లోడ్ అవుతోంది…';

  @override
  String pendingCount(int count) {
    return '$count అప్‌లోడ్ కావాల్సి ఉన్నాయి';
  }

  @override
  String get chooseRole => 'మీరు ఎవరు?';

  @override
  String get roleArtisan => 'నేను హస్తకళలు తయారు చేస్తాను';

  @override
  String get roleBuyer => 'నేను కొనాలనుకుంటున్నాను';

  @override
  String get roleKiosk => 'కియోస్క్ / CSC సహాయకులు';

  @override
  String get chooseLanguage => 'మీ భాషను ఎంచుకోండి';

  @override
  String get tapToHear => 'వినడానికి ఒకసారి తాకండి, ఎంచుకోవడానికి మళ్లీ తాకండి';

  @override
  String get enterPhone => 'మీ మొబైల్ నంబర్';

  @override
  String get sendCode => 'కోడ్ పంపండి';

  @override
  String get enterCode => '6 అంకెల కోడ్ నమోదు చేయండి';

  @override
  String codeSentTo(String phone) {
    return '$phoneకి కోడ్ పంపాం';
  }

  @override
  String get verify => 'ధృవీకరించండి';

  @override
  String get sayNumber => 'మీ నంబర్ చెప్పండి';

  @override
  String demoCode(String code) {
    return 'డెమో కోడ్: $code';
  }

  @override
  String get consentTitle => 'మీ అనుమతి';

  @override
  String get consentBody =>
      'మీ హస్తకళను అమ్మడానికి శిల్ప్‌సేతు మీ గొంతు, మీ ఫోటోలు, మీ ఊరి చిరునామాను సేవ్ చేస్తుంది. మీరు ఎప్పుడైనా వాటిని తొలగించవచ్చు.';

  @override
  String get consentVoice => 'నా గొంతును సేవ్ చేయండి';

  @override
  String get consentPhoto => 'నా ఫోటోలను సేవ్ చేయండి';

  @override
  String get consentLocation => 'నా ఊరి చిరునామాను సేవ్ చేయండి';

  @override
  String get iAgree => 'అవును, నేను అంగీకరిస్తున్నాను';

  @override
  String get sayYesToAgree => 'లేదా అంగీకరించడానికి “అవును” అని చెప్పండి';

  @override
  String get profileTitle => 'మీ గురించి చెప్పండి';

  @override
  String get askName => 'మీ పేరు ఏమిటి?';

  @override
  String get askVillage => 'మీది ఏ ఊరు లేదా పట్టణం?';

  @override
  String get askState => 'ఏ జిల్లా, ఏ రాష్ట్రం?';

  @override
  String get askCraft => 'మీరు ఏ హస్తకళ చేస్తారు?';

  @override
  String get askYears => 'ఎన్ని సంవత్సరాలుగా ఈ కళ చేస్తున్నారు?';

  @override
  String get askStory => 'మీ కథ చెప్పండి — ఈ కళను ఎలా నేర్చుకున్నారు?';

  @override
  String get askPehchan =>
      'పెహచాన్ కళాకారుల కార్డు ఉంటే దాని నంబర్ చెప్పండి. లేకపోతే దాటవేయండి నొక్కండి.';

  @override
  String get tapMicToAnswer => 'మైక్ నొక్కి జవాబు చెప్పండి';

  @override
  String get weHeard => 'మేము విన్నది:';

  @override
  String get profileSaved => 'మీ వివరాలు సేవ్ అయ్యాయి';

  @override
  String greeting(String name) {
    return 'నమస్తే, $name';
  }

  @override
  String get tileAddProduct => 'వస్తువు జోడించండి';

  @override
  String get tileMyProducts => 'నా వస్తువులు';

  @override
  String get tileOrders => 'ఆర్డర్లు';

  @override
  String get tileEarnings => 'సంపాదన';

  @override
  String get tileHelp => 'సహాయం';

  @override
  String earningsSummary(String amount, int count) {
    return 'ఈ నెల $count ఆర్డర్ల నుంచి మీరు $amount సంపాదించారు';
  }

  @override
  String get addProductTitle => 'వస్తువు జోడించండి';

  @override
  String get speakOwnLanguage => 'మీ సొంత భాషలో మాట్లాడండి';

  @override
  String listeningIn(String language) {
    return '$languageలో వింటున్నాం…';
  }

  @override
  String get tapToSpeak => 'మాట్లాడటానికి నొక్కండి, లేదా నొక్కి పట్టుకోండి';

  @override
  String get stopRecording => 'ఆపడానికి నొక్కండి';

  @override
  String get photoCaptured =>
      'ఫోటో తీశాం — నేపథ్యం, వెలుతురు ఆటోమేటిక్‌గా సరిచేస్తున్నాం';

  @override
  String get takePhoto => 'ఫోటో తీయండి';

  @override
  String get addMorePhotos => 'మరిన్ని ఫోటోలు జోడించండి';

  @override
  String get makeListing => 'నా జాబితా తయారు చేయి';

  @override
  String get hintTooDark =>
      'కొంచెం చీకటిగా ఉంది — వీలైతే వెలుతురు వైపు వెళ్లండి';

  @override
  String get hintTooBright => 'వెలుతురు ఎక్కువ — కొంచెం నీడలోకి వెళ్లండి';

  @override
  String get hintMoveCloser => 'కొంచెం దగ్గరికి రండి';

  @override
  String get hintBlurry => 'ఫోన్‌ను కదలకుండా పట్టుకోండి';

  @override
  String get anyBackground => 'ఏ వెలుతురైనా, ఏ నేపథ్యమైనా సరే';

  @override
  String get upTo60s => '60 సెకన్ల వరకు';

  @override
  String get aiBuilding => 'AI మీ జాబితాను తయారు చేస్తోంది';

  @override
  String get stepAsr => 'మీ మాటలు అర్థం చేసుకుంటున్నాం';

  @override
  String get stepNlu => 'వివరాలు కనుగొంటున్నాం';

  @override
  String get stepListing => 'పేరు, వివరణ రాస్తున్నాం';

  @override
  String get stepTranslation => 'కొనుగోలుదారుల కోసం అనువదిస్తున్నాం';

  @override
  String get stepImage => 'మీ ఫోటోను మెరుగుపరుస్తున్నాం';

  @override
  String get stepPrice => 'న్యాయమైన ధర లెక్కిస్తున్నాం';

  @override
  String get stepCertificate => 'మీ ధృవపత్రం తయారు చేస్తున్నాం';

  @override
  String get quickQuestions => 'కొన్ని చిన్న ప్రశ్నలు';

  @override
  String get answerBySpeaking => 'మాట్లాడి జవాబు చెప్పండి';

  @override
  String get reviewTitle => 'చూసి ఆమోదించండి';

  @override
  String get approve => 'ఆమోదించు';

  @override
  String get changePrice => 'ధర మార్చండి';

  @override
  String get retakePhoto => 'మళ్లీ ఫోటో తీయండి';

  @override
  String get reRecord => 'మళ్లీ చెప్పండి';

  @override
  String get sayNewPrice => 'కొత్త ధర చెప్పండి';

  @override
  String youGet(String amount, String pct) {
    return 'మీకు వచ్చేది $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'మార్కెట్ ధర $low – $high';
  }

  @override
  String get fairPrice => 'న్యాయమైన ధర';

  @override
  String get category => 'వర్గం';

  @override
  String priceSpoken(String price, String amount) {
    return 'ధర $price. మీకు వచ్చేది $amount.';
  }

  @override
  String get belowFairWage => 'ఇది మీ శ్రమకు న్యాయమైన కూలి కంటే తక్కువ';

  @override
  String get isLive => 'మీ వస్తువు ఇప్పుడు అమ్మకంలో ఉంది!';

  @override
  String get onOndc => 'ONDC నెట్‌వర్క్‌లో కూడా ఉంది';

  @override
  String get certificateReady => 'మీ ధృవపత్రం సిద్ధం';

  @override
  String get statusQueued => 'వరుసలో ఉంది';

  @override
  String get statusUploading => 'అప్‌లోడ్ అవుతోంది';

  @override
  String get statusProcessing => 'తయారవుతోంది';

  @override
  String get statusNeedsReview => 'పరిశీలన అవసరం';

  @override
  String get statusReady => 'ఆమోదానికి సిద్ధం';

  @override
  String get statusLive => 'అమ్మకంలో';

  @override
  String get statusFailed => 'గమనించండి';

  @override
  String get statusUnpublished => 'దాచబడింది';

  @override
  String get noProducts => 'ఇంకా వస్తువులు లేవు. వస్తువు జోడించండి నొక్కండి.';

  @override
  String get newOrder => 'కొత్త ఆర్డర్';

  @override
  String get accept => 'అంగీకరించు';

  @override
  String get decline => 'తిరస్కరించు';

  @override
  String get markPacked => 'ప్యాక్ అయింది';

  @override
  String get markShipped => 'పంపించాం';

  @override
  String get noOrders => 'ఇంకా ఆర్డర్లు లేవు';

  @override
  String get orderPlaced => 'కొత్తది';

  @override
  String get orderAccepted => 'అంగీకరించబడింది';

  @override
  String get orderPacked => 'ప్యాక్ అయింది';

  @override
  String get orderShipped => 'దారిలో ఉంది';

  @override
  String get orderDelivered => 'చేరింది';

  @override
  String get orderDeclined => 'తిరస్కరించబడింది';

  @override
  String get orderCancelled => 'రద్దయింది';

  @override
  String get gross => 'అమ్మకం';

  @override
  String get commission => 'ప్లాట్‌ఫామ్ రుసుము';

  @override
  String get logistics => 'డెలివరీ';

  @override
  String get net => 'మీకు వచ్చింది';

  @override
  String get everyRupee => 'ప్రతి రూపాయికీ లెక్క';

  @override
  String get helpTitle => 'సహాయం';

  @override
  String get callHelpline => 'హెల్ప్‌లైన్‌కు కాల్ చేయండి';

  @override
  String get requestCallback => 'సహాయకులు నాకు కాల్ చేయాలి';

  @override
  String get callbackRequested => 'సహాయకులు త్వరలో మీకు కాల్ చేస్తారు';

  @override
  String get howToUse => 'శిల్ప్‌సేతు ఎలా పనిచేస్తుంది';

  @override
  String get fiveSteps =>
      'మాట్లాడండి · ఫోటో తీయండి · AI తయారు చేస్తుంది · మీరు ఆమోదించండి · అమ్మకంలో';

  @override
  String get searchHint => 'హస్తకళలు, రాష్ట్రాలు, కళాకారులను వెతకండి';

  @override
  String get freshFromLoom => 'మగ్గం, సారె నుంచి తాజాగా';

  @override
  String get byCraft => 'కళ ప్రకారం';

  @override
  String get byState => 'రాష్ట్రం, క్లస్టర్ ప్రకారం';

  @override
  String get womenLed => 'మహిళల నేతృత్వంలోని సంఘాలు';

  @override
  String get giTagged => 'GI గుర్తింపు ఉన్న కళలు';

  @override
  String get nearYou => 'మీ దగ్గర';

  @override
  String get filters => 'ఫిల్టర్లు';

  @override
  String get verifiedOnly => 'ధృవీకరించిన కళాకారులు మాత్రమే';

  @override
  String get giOnly => 'GI గుర్తింపు ఉన్నవి మాత్రమే';

  @override
  String get sortBy => 'క్రమం';

  @override
  String get sortRelevance => 'అత్యంత సరిపోయేవి';

  @override
  String get sortPriceLow => 'ధర: తక్కువ నుంచి ఎక్కువ';

  @override
  String get sortPriceHigh => 'ధర: ఎక్కువ నుంచి తక్కువ';

  @override
  String get sortNewest => 'కొత్తవి';

  @override
  String results(int count) {
    return '$count హస్తకళలు';
  }

  @override
  String get addToCart => 'కార్ట్‌లో వేయండి';

  @override
  String get addedToCart => 'కార్ట్‌లో వేశాం';

  @override
  String get scanCertificate => 'కళాకారుల ధృవపత్రం కోసం స్కాన్ చేయండి';

  @override
  String get certificateSub => 'సామగ్రి, కథ, ధర ఆధారం';

  @override
  String get howPriceBuilt => 'ఈ ధర ఎలా నిర్ణయమైంది';

  @override
  String goesToArtisan(String amount, String pct) {
    return 'ఇందులో $amount నేరుగా కళాకారులకు వెళ్తుంది ($pct%)';
  }

  @override
  String get meetArtisan => 'కళాకారులను కలవండి';

  @override
  String get hearVoice => 'వారి గొంతు వినండి';

  @override
  String get moreFromArtisan => 'ఈ కళాకారుల మరిన్ని వస్తువులు';

  @override
  String reviewsCount(int count) {
    return '($count సమీక్షలు)';
  }

  @override
  String get verifiedArtisan => 'ధృవీకరించిన కళాకారులు';

  @override
  String get cart => 'కార్ట్';

  @override
  String get cartEmpty => 'మీ కార్ట్ ఖాళీగా ఉంది';

  @override
  String get checkout => 'చెక్అవుట్';

  @override
  String get placeOrder => 'ఆర్డర్ చేయండి';

  @override
  String get payUpi => 'UPIతో చెల్లించండి';

  @override
  String get cod => 'డెలివరీపై నగదు';

  @override
  String deliveryIn(int days) {
    return 'సుమారు $days రోజుల్లో డెలివరీ';
  }

  @override
  String get shippingIncluded => 'డెలివరీ, ప్యాకింగ్ న్యాయమైన ధరలోనే ఉన్నాయి';

  @override
  String get orderPlacedThanks => 'ధన్యవాదాలు! మీ ఆర్డర్ అయింది.';

  @override
  String get myOrders => 'నా ఆర్డర్లు';

  @override
  String get rateCraft => 'ఈ కళకు రేటింగ్ ఇవ్వండి';

  @override
  String get scanQr => 'ధృవపత్రం QR స్కాన్ చేయండి';

  @override
  String get certValid => 'అసలైనది — శిల్ప్‌సేతు ధృవీకరించింది';

  @override
  String get certInvalid => 'చెల్లదు';

  @override
  String get name => 'పేరు';

  @override
  String get address => 'చిరునామా';

  @override
  String get city => 'నగరం';

  @override
  String get state => 'రాష్ట్రం';

  @override
  String get pincode => 'పిన్ కోడ్';

  @override
  String get phone => 'ఫోన్';

  @override
  String get total => 'మొత్తం';

  @override
  String get kioskTitle => 'కియోస్క్';

  @override
  String get myArtisans => 'కళాకారులు';

  @override
  String get onboardArtisan => 'కళాకారులను చేర్చండి';

  @override
  String captureFor(String name) {
    return '$name కోసం';
  }

  @override
  String get batchMode => 'ప్రదర్శన బ్యాచ్ మోడ్';

  @override
  String get printTags => 'ధృవపత్రం ట్యాగ్‌లు ముద్రించండి';

  @override
  String get syncAll => 'అన్నీ అప్‌లోడ్ చేయండి';

  @override
  String get attestation =>
      'వారి గుర్తింపును పరిశీలించి, వారు మాటతో చెప్పిన అంగీకారాన్ని రికార్డ్ చేశాను';

  @override
  String get recordConsent => 'కళాకారుల అంగీకారాన్ని రికార్డ్ చేయండి';

  @override
  String get about => 'పరిచయం';

  @override
  String get logout => 'లాగ్ అవుట్';

  @override
  String get lowBandwidth => 'తక్కువ డేటా మోడ్';

  @override
  String get switchRole => 'మోడ్ మార్చండి';

  @override
  String productsCount(int count) {
    return '$count వస్తువులు';
  }

  @override
  String get gender => 'లింగం (ఐచ్ఛికం)';

  @override
  String get genderFemale => 'స్త్రీ';

  @override
  String get genderMale => 'పురుషుడు';

  @override
  String get genderOther => 'ఇతర';

  @override
  String get genderPreferNot => 'చెప్పదలచుకోలేదు';

  @override
  String get typeInstead => 'లేదా జవాబు టైప్ చేయండి';

  @override
  String get send => 'పంపండి';

  @override
  String get serverAddress => 'సర్వర్ చిరునామా';

  @override
  String get serverAddressHint => 'సహాయకులు చెబితేనే మార్చండి';

  @override
  String get saved => 'సేవ్ అయింది';

  @override
  String get darkMode => 'డార్క్ మోడ్';

  @override
  String get lightMode => 'లైట్ మోడ్';

  @override
  String get productDetails => 'వస్తువు వివరాలు';

  @override
  String get aboutArtForm => 'ఈ కళ గురించి';

  @override
  String get howItsMade => 'ఎలా తయారవుతుంది';

  @override
  String get didYouKnow => 'మీకు తెలుసా?';

  @override
  String yearsOfPractice(int count) {
    return '$count సంవత్సరాల అనుభవం';
  }

  @override
  String get photoCredits => 'ఫోటో కృతజ్ఞతలు';

  @override
  String get photoCreditsSub =>
      'వికీమీడియా కామన్స్ నుండి నిజమైన హస్తకళ ఫోటోలు, లైసెన్సు ప్రకారం';

  @override
  String get askShilpi => 'శిల్పిని అడగండి';

  @override
  String get assistantName => 'శిల్పి';

  @override
  String get assistantTagline => 'మీ శిల్పసేతు సహాయకురాలు';

  @override
  String get assistantThinking => 'ఆలోచిస్తున్నాను…';

  @override
  String get askAnything => 'ఏదైనా అడగండి';

  @override
  String get close => 'మూసివేయి';

  @override
  String get dayStreak => 'రోజుల వరుస';

  @override
  String get todaysGoal => 'నేటి లక్ష్యం';

  @override
  String get craftOfTheDay => 'నేటి కళ';

  @override
  String get exploreCraft => 'చూడండి';

  @override
  String get celebrateLive => 'మీ వస్తువు లైవ్ అయింది!';

  @override
  String get micPermission =>
      'మైక్ అనుమతి ఇవ్వండి: సెట్టింగ్‌లు → యాప్‌లు → శిల్పసేతు → అనుమతులు → మైక్రోఫోన్.';

  @override
  String get micUnavailable =>
      'ఈ ఫోన్‌లో మాట్లాడి రాసే సౌకర్యం లేదు. Google వాయిస్ టైపింగ్ ఆన్ చేయండి, లేదా టైప్ చేయండి.';

  @override
  String get micInsecure =>
      'మైక్ శిల్పసేతు యాప్‌లో లేదా సురక్షిత https లింక్‌లో మాత్రమే పనిచేస్తుంది. యాప్ వాడండి.';

  @override
  String get micNoSpeech => 'వినబడలేదు. మైక్ నొక్కి కొంచెం గట్టిగా మాట్లాడండి.';

  @override
  String get micNetwork =>
      'మాట్లాడి రాయడానికి ఇంటర్నెట్ కావాలి. కనెక్షన్ చూడండి.';

  @override
  String get pressBackAgain => 'బయటకు వెళ్లడానికి మళ్లీ వెనుకకు నొక్కండి';
}
