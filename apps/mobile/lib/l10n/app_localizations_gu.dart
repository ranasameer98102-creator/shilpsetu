// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class L10nGu extends L10n {
  L10nGu([String locale = 'gu']) : super(locale);

  @override
  String get languageName => 'ગુજરાતી';

  @override
  String get appTitle => 'શિલ્પસેતુ';

  @override
  String get tagline => 'વંચિત કારીગરો માટે AI સહ-વિક્રેતા';

  @override
  String get heroLine =>
      'હાથના હુનરથી હેડલાઇન સુધી — દરેક કળા, હંમેશા બજારમાં.';

  @override
  String get promise =>
      'એક ફોટો. એક બોલાયેલું વાક્ય. યોગ્ય ભાવવાળી, વિશ્વસનીય યાદી — ટાઇપિંગ નહીં, વચેટિયા નહીં, અંગ્રેજીની જરૂર નહીં.';

  @override
  String get next => 'આગળ';

  @override
  String get back => 'પાછા';

  @override
  String get retry => 'ફરી પ્રયાસ કરો';

  @override
  String get save => 'સાચવો';

  @override
  String get cancel => 'રદ કરો';

  @override
  String get done => 'થઈ ગયું';

  @override
  String get skip => 'છોડો';

  @override
  String get yes => 'હા';

  @override
  String get no => 'ના';

  @override
  String get loading => 'કૃપા કરી રાહ જુઓ…';

  @override
  String get errorGeneric => 'કંઈક ખોટું થયું. કૃપા કરી ફરી પ્રયાસ કરો.';

  @override
  String get errorNetwork => 'નેટવર્ક નથી. તમારું કામ ફોનમાં સુરક્ષિત છે.';

  @override
  String get savedOnPhone => 'ફોનમાં સાચવ્યું — નેટવર્ક આવતાં જ અપલોડ થશે';

  @override
  String get allSynced => 'બધું અપલોડ થઈ ગયું';

  @override
  String get syncing => 'અપલોડ થઈ રહ્યું છે…';

  @override
  String pendingCount(int count) {
    return '$count અપલોડ બાકી';
  }

  @override
  String get chooseRole => 'તમે કોણ છો?';

  @override
  String get roleArtisan => 'હું હસ્તકળા બનાવું છું';

  @override
  String get roleBuyer => 'મારે ખરીદવું છે';

  @override
  String get roleKiosk => 'કિઓસ્ક / CSC સહાયક';

  @override
  String get chooseLanguage => 'તમારી ભાષા પસંદ કરો';

  @override
  String get tapToHear => 'સાંભળવા એક વાર અડો, પસંદ કરવા ફરી અડો';

  @override
  String get enterPhone => 'તમારો મોબાઇલ નંબર';

  @override
  String get sendCode => 'કોડ મોકલો';

  @override
  String get enterCode => '6 અંકનો કોડ નાખો';

  @override
  String codeSentTo(String phone) {
    return '$phone પર કોડ મોકલ્યો';
  }

  @override
  String get verify => 'ખાતરી કરો';

  @override
  String get sayNumber => 'તમારો નંબર બોલો';

  @override
  String demoCode(String code) {
    return 'ડેમો કોડ: $code';
  }

  @override
  String get consentTitle => 'તમારી પરવાનગી';

  @override
  String get consentBody =>
      'તમારી કળા વેચવા માટે શિલ્પસેતુ તમારો અવાજ, તમારા ફોટા અને તમારા ગામનું સરનામું સાચવશે. તમે ગમે ત્યારે તે કાઢી શકો છો.';

  @override
  String get consentVoice => 'મારો અવાજ સાચવો';

  @override
  String get consentPhoto => 'મારા ફોટા સાચવો';

  @override
  String get consentLocation => 'મારા ગામનું સરનામું સાચવો';

  @override
  String get iAgree => 'હા, હું સંમત છું';

  @override
  String get sayYesToAgree => 'અથવા સંમતિ માટે “હા” બોલો';

  @override
  String get profileTitle => 'તમારા વિશે જણાવો';

  @override
  String get askName => 'તમારું નામ શું છે?';

  @override
  String get askVillage => 'તમે કયા ગામ કે શહેરના છો?';

  @override
  String get askState => 'કયો જિલ્લો અને રાજ્ય?';

  @override
  String get askCraft => 'તમે કઈ હસ્તકળા બનાવો છો?';

  @override
  String get askYears => 'કેટલા વર્ષથી આ કળા કરો છો?';

  @override
  String get askStory => 'તમારી વાત કહો — આ કળા તમે કેવી રીતે શીખ્યા?';

  @override
  String get askPehchan =>
      'પહચાન કારીગર કાર્ડ હોય તો તેનો નંબર બોલો. નહીંતર છોડો દબાવો.';

  @override
  String get tapMicToAnswer => 'માઇક દબાવી જવાબ આપો';

  @override
  String get weHeard => 'અમે સાંભળ્યું:';

  @override
  String get profileSaved => 'તમારી માહિતી સચવાઈ ગઈ';

  @override
  String greeting(String name) {
    return 'નમસ્તે, $name';
  }

  @override
  String get tileAddProduct => 'વસ્તુ ઉમેરો';

  @override
  String get tileMyProducts => 'મારી વસ્તુઓ';

  @override
  String get tileOrders => 'ઓર્ડર';

  @override
  String get tileEarnings => 'કમાણી';

  @override
  String get tileHelp => 'મદદ';

  @override
  String earningsSummary(String amount, int count) {
    return 'આ મહિને $count ઓર્ડરમાંથી તમે $amount કમાયા';
  }

  @override
  String get addProductTitle => 'વસ્તુ ઉમેરો';

  @override
  String get speakOwnLanguage => 'તમારી પોતાની ભાષામાં બોલો';

  @override
  String listeningIn(String language) {
    return '$languageમાં સાંભળી રહ્યા છીએ…';
  }

  @override
  String get tapToSpeak => 'બોલવા માટે દબાવો, અથવા દબાવી રાખો';

  @override
  String get stopRecording => 'રોકવા માટે દબાવો';

  @override
  String get photoCaptured =>
      'ફોટો લેવાયો — પૃષ્ઠભૂમિ અને પ્રકાશ આપમેળે સુધારાઈ રહ્યા છે';

  @override
  String get takePhoto => 'ફોટો લો';

  @override
  String get addMorePhotos => 'વધુ ફોટા ઉમેરો';

  @override
  String get makeListing => 'મારી યાદી બનાવો';

  @override
  String get hintTooDark => 'થોડું અંધારું છે — શક્ય હોય તો પ્રકાશ તરફ જાઓ';

  @override
  String get hintTooBright => 'ખૂબ પ્રકાશ છે — થોડી છાંયડીમાં જાઓ';

  @override
  String get hintMoveCloser => 'થોડા નજીક આવો';

  @override
  String get hintBlurry => 'ફોન સ્થિર રાખો';

  @override
  String get anyBackground => 'કોઈ પણ પ્રકાશ, કોઈ પણ પૃષ્ઠભૂમિ ચાલશે';

  @override
  String get upTo60s => '60 સેકન્ડ સુધી';

  @override
  String get aiBuilding => 'AI તમારી યાદી બનાવી રહ્યું છે';

  @override
  String get stepAsr => 'તમારો અવાજ સમજી રહ્યા છીએ';

  @override
  String get stepNlu => 'વિગતો શોધી રહ્યા છીએ';

  @override
  String get stepListing => 'નામ અને વર્ણન લખી રહ્યા છીએ';

  @override
  String get stepTranslation => 'ખરીદદારો માટે અનુવાદ કરી રહ્યા છીએ';

  @override
  String get stepImage => 'તમારો ફોટો સુધારી રહ્યા છીએ';

  @override
  String get stepPrice => 'યોગ્ય ભાવ ગણી રહ્યા છીએ';

  @override
  String get stepCertificate => 'તમારું પ્રમાણપત્ર તૈયાર કરી રહ્યા છીએ';

  @override
  String get quickQuestions => 'થોડા નાના પ્રશ્નો';

  @override
  String get answerBySpeaking => 'બોલીને જવાબ આપો';

  @override
  String get reviewTitle => 'તપાસો અને મંજૂર કરો';

  @override
  String get approve => 'મંજૂર કરો';

  @override
  String get changePrice => 'ભાવ બદલો';

  @override
  String get retakePhoto => 'ફરી ફોટો લો';

  @override
  String get reRecord => 'ફરી બોલો';

  @override
  String get sayNewPrice => 'નવો ભાવ બોલો';

  @override
  String youGet(String amount, String pct) {
    return 'તમને મળશે $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'બજાર ભાવ $low – $high';
  }

  @override
  String get fairPrice => 'યોગ્ય ભાવ';

  @override
  String get category => 'શ્રેણી';

  @override
  String priceSpoken(String price, String amount) {
    return 'ભાવ $price. તમને મળશે $amount.';
  }

  @override
  String get belowFairWage => 'આ તમારી મહેનતની યોગ્ય મજૂરી કરતાં ઓછું છે';

  @override
  String get isLive => 'તમારી વસ્તુ હવે વેચાણમાં છે!';

  @override
  String get onOndc => 'ONDC નેટવર્ક પર પણ દેખાય છે';

  @override
  String get certificateReady => 'તમારું પ્રમાણપત્ર તૈયાર છે';

  @override
  String get statusQueued => 'કતારમાં';

  @override
  String get statusUploading => 'અપલોડ થાય છે';

  @override
  String get statusProcessing => 'તૈયાર થાય છે';

  @override
  String get statusNeedsReview => 'તપાસ જરૂરી';

  @override
  String get statusReady => 'મંજૂરી માટે તૈયાર';

  @override
  String get statusLive => 'વેચાણમાં';

  @override
  String get statusFailed => 'ધ્યાન આપો';

  @override
  String get statusUnpublished => 'છુપાવેલું';

  @override
  String get noProducts => 'હજી કોઈ વસ્તુ નથી. વસ્તુ ઉમેરો દબાવો.';

  @override
  String get newOrder => 'નવો ઓર્ડર';

  @override
  String get accept => 'સ્વીકારો';

  @override
  String get decline => 'ના પાડો';

  @override
  String get markPacked => 'પેક થઈ ગયું';

  @override
  String get markShipped => 'મોકલી દીધું';

  @override
  String get noOrders => 'હજી કોઈ ઓર્ડર નથી';

  @override
  String get orderPlaced => 'નવો';

  @override
  String get orderAccepted => 'સ્વીકાર્યો';

  @override
  String get orderPacked => 'પેક થયો';

  @override
  String get orderShipped => 'રસ્તામાં';

  @override
  String get orderDelivered => 'પહોંચી ગયો';

  @override
  String get orderDeclined => 'ના પાડી';

  @override
  String get orderCancelled => 'રદ';

  @override
  String get gross => 'વેચાણ';

  @override
  String get commission => 'પ્લેટફોર્મ ફી';

  @override
  String get logistics => 'ડિલિવરી';

  @override
  String get net => 'તમને મળ્યા';

  @override
  String get everyRupee => 'દરેક રૂપિયાનો હિસાબ';

  @override
  String get helpTitle => 'મદદ';

  @override
  String get callHelpline => 'હેલ્પલાઇન પર ફોન કરો';

  @override
  String get requestCallback => 'સહાયક મને ફોન કરે';

  @override
  String get callbackRequested => 'એક સહાયક જલદી તમને ફોન કરશે';

  @override
  String get howToUse => 'શિલ્પસેતુ કેવી રીતે કામ કરે છે';

  @override
  String get fiveSteps =>
      'બોલો · ફોટો લો · AI બનાવે · તમે મંજૂર કરો · વેચાણમાં';

  @override
  String get searchHint => 'કળા, રાજ્ય, કારીગર શોધો';

  @override
  String get freshFromLoom => 'સાળ અને ચાકડેથી તાજું';

  @override
  String get byCraft => 'કળા પ્રમાણે';

  @override
  String get byState => 'રાજ્ય અને ક્લસ્ટર પ્રમાણે';

  @override
  String get womenLed => 'મહિલા-સંચાલિત જૂથો';

  @override
  String get giTagged => 'GI-ટેગ કળાઓ';

  @override
  String get nearYou => 'તમારી નજીક';

  @override
  String get filters => 'ફિલ્ટર';

  @override
  String get verifiedOnly => 'માત્ર ચકાસાયેલા કારીગરો';

  @override
  String get giOnly => 'માત્ર GI-ટેગ';

  @override
  String get sortBy => 'ક્રમ';

  @override
  String get sortRelevance => 'સૌથી યોગ્ય';

  @override
  String get sortPriceLow => 'ભાવ: ઓછાથી વધુ';

  @override
  String get sortPriceHigh => 'ભાવ: વધુથી ઓછા';

  @override
  String get sortNewest => 'સૌથી નવા';

  @override
  String results(int count) {
    return '$count કળાકૃતિઓ';
  }

  @override
  String get addToCart => 'કાર્ટમાં ઉમેરો';

  @override
  String get addedToCart => 'કાર્ટમાં ઉમેર્યું';

  @override
  String get scanCertificate => 'કારીગર પ્રમાણપત્ર માટે સ્કેન કરો';

  @override
  String get certificateSub => 'સામગ્રી, વાર્તા અને ભાવનો આધાર';

  @override
  String get howPriceBuilt => 'આ ભાવ કેવી રીતે બન્યો';

  @override
  String goesToArtisan(String amount, String pct) {
    return 'આમાંથી $amount સીધા કારીગરને જાય છે ($pct%)';
  }

  @override
  String get meetArtisan => 'કારીગરને મળો';

  @override
  String get hearVoice => 'તેમનો અવાજ સાંભળો';

  @override
  String get moreFromArtisan => 'આ કારીગરની વધુ કળાકૃતિઓ';

  @override
  String reviewsCount(int count) {
    return '($count સમીક્ષાઓ)';
  }

  @override
  String get verifiedArtisan => 'ચકાસાયેલ કારીગર';

  @override
  String get cart => 'કાર્ટ';

  @override
  String get cartEmpty => 'તમારું કાર્ટ ખાલી છે';

  @override
  String get checkout => 'ચેકઆઉટ';

  @override
  String get placeOrder => 'ઓર્ડર કરો';

  @override
  String get payUpi => 'UPIથી ચૂકવો';

  @override
  String get cod => 'ડિલિવરી વખતે રોકડ';

  @override
  String deliveryIn(int days) {
    return 'લગભગ $days દિવસમાં ડિલિવરી';
  }

  @override
  String get shippingIncluded => 'ડિલિવરી અને પેકિંગ યોગ્ય ભાવમાં સામેલ છે';

  @override
  String get orderPlacedThanks => 'આભાર! તમારો ઓર્ડર થઈ ગયો.';

  @override
  String get myOrders => 'મારા ઓર્ડર';

  @override
  String get rateCraft => 'આ કળાને રેટિંગ આપો';

  @override
  String get scanQr => 'પ્રમાણપત્ર QR સ્કેન કરો';

  @override
  String get certValid => 'અસલી — શિલ્પસેતુએ ચકાસ્યું';

  @override
  String get certInvalid => 'માન્ય નથી';

  @override
  String get name => 'નામ';

  @override
  String get address => 'સરનામું';

  @override
  String get city => 'શહેર';

  @override
  String get state => 'રાજ્ય';

  @override
  String get pincode => 'પિન કોડ';

  @override
  String get phone => 'ફોન';

  @override
  String get total => 'કુલ';

  @override
  String get kioskTitle => 'કિઓસ્ક';

  @override
  String get myArtisans => 'કારીગરો';

  @override
  String get onboardArtisan => 'કારીગર ઉમેરો';

  @override
  String captureFor(String name) {
    return '$name માટે';
  }

  @override
  String get batchMode => 'પ્રદર્શન બેચ મોડ';

  @override
  String get printTags => 'પ્રમાણપત્ર ટેગ છાપો';

  @override
  String get syncAll => 'બધું અપલોડ કરો';

  @override
  String get attestation =>
      'મેં તેમની ઓળખ ચકાસી અને તેમની બોલાયેલી સંમતિ રેકોર્ડ કરી';

  @override
  String get recordConsent => 'કારીગરની સંમતિ રેકોર્ડ કરો';

  @override
  String get about => 'પરિચય';

  @override
  String get logout => 'લૉગ આઉટ';

  @override
  String get lowBandwidth => 'ઓછા ડેટા મોડ';

  @override
  String get switchRole => 'મોડ બદલો';

  @override
  String productsCount(int count) {
    return '$count વસ્તુઓ';
  }

  @override
  String get gender => 'લિંગ (વૈકલ્પિક)';

  @override
  String get genderFemale => 'સ્ત્રી';

  @override
  String get genderMale => 'પુરુષ';

  @override
  String get genderOther => 'અન્ય';

  @override
  String get genderPreferNot => 'જણાવવું નથી';

  @override
  String get typeInstead => 'અથવા જવાબ લખો';

  @override
  String get send => 'મોકલો';

  @override
  String get serverAddress => 'સર્વરનું સરનામું';

  @override
  String get serverAddressHint => 'સહાયક કહે તો જ બદલો';

  @override
  String get saved => 'સાચવ્યું';

  @override
  String get darkMode => 'ડાર્ક મોડ';

  @override
  String get lightMode => 'લાઇટ મોડ';

  @override
  String get productDetails => 'વસ્તુની વિગત';

  @override
  String get aboutArtForm => 'આ કળા વિશે';

  @override
  String get howItsMade => 'કેવી રીતે બને છે';

  @override
  String get didYouKnow => 'શું તમે જાણો છો?';

  @override
  String yearsOfPractice(int count) {
    return '$count વર્ષનો અનુભવ';
  }

  @override
  String get photoCredits => 'ફોટો શ્રેય';

  @override
  String get photoCreditsSub =>
      'વિકિમીડિયા કોમન્સના અસલી હસ્તકળાના ફોટા, લાયસન્સ મુજબ';

  @override
  String get askShilpi => 'શિલ્પીને પૂછો';

  @override
  String get assistantName => 'શિલ્પી';

  @override
  String get assistantTagline => 'તમારી શિલ્પસેતુ સહાયક';

  @override
  String get assistantThinking => 'વિચારું છું…';

  @override
  String get askAnything => 'કંઈ પણ પૂછો';

  @override
  String get close => 'બંધ કરો';

  @override
  String get dayStreak => 'દિવસની સ્ટ્રીક';

  @override
  String get todaysGoal => 'આજનું લક્ષ્ય';

  @override
  String get craftOfTheDay => 'આજની કળા';

  @override
  String get exploreCraft => 'જુઓ';

  @override
  String get celebrateLive => 'તમારી વસ્તુ લાઇવ થઈ!';

  @override
  String get micPermission =>
      'કૃપા કરીને માઇકની પરવાનગી આપો: સેટિંગ્સ → ઍપ્સ → શિલ્પસેતુ → પરવાનગી → માઇક્રોફોન.';

  @override
  String get micUnavailable =>
      'આ ફોનમાં બોલીને લખવાની સુવિધા નથી. Google વૉઇસ ટાઇપિંગ ચાલુ કરો, અથવા લખીને જણાવો.';

  @override
  String get micInsecure =>
      'માઇક ફક્ત શિલ્પસેતુ ઍપમાં અથવા સુરક્ષિત https લિંક પર ચાલે છે. કૃપા કરીને ઍપ વાપરો.';

  @override
  String get micNoSpeech =>
      'અવાજ સંભળાયો નહીં. માઇક દબાવીને થોડું મોટેથી બોલો.';

  @override
  String get micNetwork => 'બોલીને લખવા માટે ઇન્ટરનેટ જોઈએ. નેટવર્ક તપાસો.';

  @override
  String get pressBackAgain => 'બંધ કરવા ફરી પાછળ દબાવો';
}
