// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class L10nOr extends L10n {
  L10nOr([String locale = 'or']) : super(locale);

  @override
  String get languageName => 'ଓଡ଼ିଆ';

  @override
  String get appTitle => 'ଶିଳ୍ପସେତୁ';

  @override
  String get tagline => 'ଅବହେଳିତ କାରିଗରଙ୍କ AI ସହ-ବିକ୍ରେତା';

  @override
  String get heroLine =>
      'ହାତ କାମରୁ ଶିରୋନାମା ପର୍ଯ୍ୟନ୍ତ — ପ୍ରତ୍ୟେକ କଳା, ସବୁବେଳେ ବଜାରରେ।';

  @override
  String get promise =>
      'ଗୋଟିଏ ଫଟୋ। ଗୋଟିଏ କୁହା ବାକ୍ୟ। ଉଚିତ ଦରର, ବିଶ୍ୱସ୍ତ ତାଲିକା — ଟାଇପ୍ ନାହିଁ, ଦଲାଲ ନାହିଁ, ଇଂରାଜୀ ଦରକାର ନାହିଁ।';

  @override
  String get next => 'ଆଗକୁ';

  @override
  String get back => 'ପଛକୁ';

  @override
  String get retry => 'ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get save => 'ସଞ୍ଚୟ କରନ୍ତୁ';

  @override
  String get cancel => 'ବାତିଲ';

  @override
  String get done => 'ହୋଇଗଲା';

  @override
  String get skip => 'ଛାଡ଼ନ୍ତୁ';

  @override
  String get yes => 'ହଁ';

  @override
  String get no => 'ନା';

  @override
  String get loading => 'ଦୟାକରି ଅପେକ୍ଷା କରନ୍ତୁ…';

  @override
  String get errorGeneric => 'କିଛି ଭୁଲ ହେଲା। ଦୟାକରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get errorNetwork => 'ନେଟୱର୍କ ନାହିଁ। ଆପଣଙ୍କ କାମ ଫୋନରେ ସୁରକ୍ଷିତ ଅଛି।';

  @override
  String get savedOnPhone => 'ଫୋନରେ ସଞ୍ଚୟ ହେଲା — ନେଟୱର୍କ ଆସିଲେ ଅପଲୋଡ୍ ହେବ';

  @override
  String get allSynced => 'ସବୁ ଅପଲୋଡ୍ ହୋଇଗଲା';

  @override
  String get syncing => 'ଅପଲୋଡ୍ ହେଉଛି…';

  @override
  String pendingCount(int count) {
    return '$countଟି ଅପଲୋଡ୍ ବାକି';
  }

  @override
  String get chooseRole => 'ଆପଣ କିଏ?';

  @override
  String get roleArtisan => 'ମୁଁ ହସ୍ତଶିଳ୍ପ ତିଆରି କରେ';

  @override
  String get roleBuyer => 'ମୁଁ କିଣିବାକୁ ଚାହେଁ';

  @override
  String get roleKiosk => 'କିଓସ୍କ / CSC ସହାୟକ';

  @override
  String get chooseLanguage => 'ଆପଣଙ୍କ ଭାଷା ବାଛନ୍ତୁ';

  @override
  String get tapToHear => 'ଶୁଣିବାକୁ ଥରେ ଛୁଅଁନ୍ତୁ, ବାଛିବାକୁ ପୁଣି ଛୁଅଁନ୍ତୁ';

  @override
  String get enterPhone => 'ଆପଣଙ୍କ ମୋବାଇଲ୍ ନମ୍ବର';

  @override
  String get sendCode => 'କୋଡ୍ ପଠାନ୍ତୁ';

  @override
  String get enterCode => '6 ଅଙ୍କର କୋଡ୍ ଦିଅନ୍ତୁ';

  @override
  String codeSentTo(String phone) {
    return '$phoneକୁ କୋଡ୍ ପଠାଗଲା';
  }

  @override
  String get verify => 'ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get sayNumber => 'ଆପଣଙ୍କ ନମ୍ବର କୁହନ୍ତୁ';

  @override
  String demoCode(String code) {
    return 'ଡେମୋ କୋଡ୍: $code';
  }

  @override
  String get consentTitle => 'ଆପଣଙ୍କ ଅନୁମତି';

  @override
  String get consentBody =>
      'ଆପଣଙ୍କ ହସ୍ତଶିଳ୍ପ ବିକ୍ରି ପାଇଁ ଶିଳ୍ପସେତୁ ଆପଣଙ୍କ ସ୍ୱର, ଫଟୋ ଓ ଗାଁର ଠିକଣା ସଞ୍ଚୟ କରିବ। ଆପଣ ଯେକୌଣସି ସମୟରେ ସେଗୁଡ଼ିକୁ ହଟାଇ ପାରିବେ।';

  @override
  String get consentVoice => 'ମୋ ସ୍ୱର ସଞ୍ଚୟ କରନ୍ତୁ';

  @override
  String get consentPhoto => 'ମୋ ଫଟୋ ସଞ୍ଚୟ କରନ୍ତୁ';

  @override
  String get consentLocation => 'ମୋ ଗାଁର ଠିକଣା ସଞ୍ଚୟ କରନ୍ତୁ';

  @override
  String get iAgree => 'ହଁ, ମୁଁ ରାଜି';

  @override
  String get sayYesToAgree => 'କିମ୍ବା ରାଜି ହେବାକୁ “ହଁ” କୁହନ୍ତୁ';

  @override
  String get profileTitle => 'ଆପଣଙ୍କ ବିଷୟରେ କୁହନ୍ତୁ';

  @override
  String get askName => 'ଆପଣଙ୍କ ନାମ କ’ଣ?';

  @override
  String get askVillage => 'ଆପଣ କେଉଁ ଗାଁ ବା ସହରରୁ?';

  @override
  String get askState => 'କେଉଁ ଜିଲ୍ଲା ଓ ରାଜ୍ୟ?';

  @override
  String get askCraft => 'ଆପଣ କେଉଁ ହସ୍ତଶିଳ୍ପ କରନ୍ତି?';

  @override
  String get askYears => 'କେତେ ବର୍ଷ ହେଲା ଏହି କାମ କରୁଛନ୍ତି?';

  @override
  String get askStory => 'ଆପଣଙ୍କ କାହାଣୀ କୁହନ୍ତୁ — ଏହି କଳା କିପରି ଶିଖିଲେ?';

  @override
  String get askPehchan =>
      'ପହଚାନ କାରିଗର କାର୍ଡ ଥିଲେ ତା’ର ନମ୍ବର କୁହନ୍ତୁ। ନହେଲେ ଛାଡ଼ନ୍ତୁ ଦବାନ୍ତୁ।';

  @override
  String get tapMicToAnswer => 'ମାଇକ୍ ଦବାଇ ଉତ୍ତର ଦିଅନ୍ତୁ';

  @override
  String get weHeard => 'ଆମେ ଶୁଣିଲୁ:';

  @override
  String get profileSaved => 'ଆପଣଙ୍କ ତଥ୍ୟ ସଞ୍ଚୟ ହେଲା';

  @override
  String greeting(String name) {
    return 'ନମସ୍କାର, $name';
  }

  @override
  String get tileAddProduct => 'ଜିନିଷ ଯୋଡ଼ନ୍ତୁ';

  @override
  String get tileMyProducts => 'ମୋ ଜିନିଷ';

  @override
  String get tileOrders => 'ଅର୍ଡର';

  @override
  String get tileEarnings => 'ରୋଜଗାର';

  @override
  String get tileHelp => 'ସାହାଯ୍ୟ';

  @override
  String earningsSummary(String amount, int count) {
    return 'ଏହି ମାସରେ $countଟି ଅର୍ଡରରୁ ଆପଣ $amount ରୋଜଗାର କଲେ';
  }

  @override
  String get addProductTitle => 'ଜିନିଷ ଯୋଡ଼ନ୍ତୁ';

  @override
  String get speakOwnLanguage => 'ନିଜ ଭାଷାରେ କୁହନ୍ତୁ';

  @override
  String listeningIn(String language) {
    return '$languageରେ ଶୁଣୁଛୁ…';
  }

  @override
  String get tapToSpeak => 'କହିବାକୁ ଦବାନ୍ତୁ, କିମ୍ବା ଦବାଇ ଧରନ୍ତୁ';

  @override
  String get stopRecording => 'ବନ୍ଦ କରିବାକୁ ଦବାନ୍ତୁ';

  @override
  String get photoCaptured =>
      'ଫଟୋ ନିଆଗଲା — ପୃଷ୍ଠଭୂମି ଓ ଆଲୁଅ ଆପେ ଆପେ ଠିକ୍ ହେଉଛି';

  @override
  String get takePhoto => 'ଫଟୋ ନିଅନ୍ତୁ';

  @override
  String get addMorePhotos => 'ଆଉ ଫଟୋ ଯୋଡ଼ନ୍ତୁ';

  @override
  String get makeListing => 'ମୋ ତାଲିକା ତିଆରି କର';

  @override
  String get hintTooDark => 'ଟିକେ ଅନ୍ଧାର — ସମ୍ଭବ ହେଲେ ଆଲୁଅ ଆଡ଼କୁ ଯାଆନ୍ତୁ';

  @override
  String get hintTooBright => 'ଆଲୁଅ ବେଶି — ଟିକେ ଛାଇକୁ ଯାଆନ୍ତୁ';

  @override
  String get hintMoveCloser => 'ଟିକେ ପାଖକୁ ଆସନ୍ତୁ';

  @override
  String get hintBlurry => 'ଫୋନକୁ ସ୍ଥିର ଧରନ୍ତୁ';

  @override
  String get anyBackground => 'ଯେକୌଣସି ଆଲୁଅ, ଯେକୌଣସି ପୃଷ୍ଠଭୂମି ଚଳିବ';

  @override
  String get upTo60s => '60 ସେକେଣ୍ଡ ପର୍ଯ୍ୟନ୍ତ';

  @override
  String get aiBuilding => 'AI ଆପଣଙ୍କ ତାଲିକା ତିଆରି କରୁଛି';

  @override
  String get stepAsr => 'ଆପଣଙ୍କ ସ୍ୱର ବୁଝୁଛୁ';

  @override
  String get stepNlu => 'ତଥ୍ୟ ଖୋଜୁଛୁ';

  @override
  String get stepListing => 'ନାମ ଓ ବିବରଣୀ ଲେଖୁଛୁ';

  @override
  String get stepTranslation => 'କ୍ରେତାଙ୍କ ପାଇଁ ଅନୁବାଦ କରୁଛୁ';

  @override
  String get stepImage => 'ଆପଣଙ୍କ ଫଟୋ ସୁଧାରୁଛୁ';

  @override
  String get stepPrice => 'ଉଚିତ ଦର ହିସାବ କରୁଛୁ';

  @override
  String get stepCertificate => 'ଆପଣଙ୍କ ପ୍ରମାଣପତ୍ର ପ୍ରସ୍ତୁତ କରୁଛୁ';

  @override
  String get quickQuestions => 'କିଛି ଛୋଟ ପ୍ରଶ୍ନ';

  @override
  String get answerBySpeaking => 'କହି ଉତ୍ତର ଦିଅନ୍ତୁ';

  @override
  String get reviewTitle => 'ଦେଖି ଅନୁମୋଦନ କରନ୍ତୁ';

  @override
  String get approve => 'ଅନୁମୋଦନ';

  @override
  String get changePrice => 'ଦର ବଦଳାନ୍ତୁ';

  @override
  String get retakePhoto => 'ପୁଣି ଫଟୋ ନିଅନ୍ତୁ';

  @override
  String get reRecord => 'ପୁଣି କୁହନ୍ତୁ';

  @override
  String get sayNewPrice => 'ନୂଆ ଦର କୁହନ୍ତୁ';

  @override
  String youGet(String amount, String pct) {
    return 'ଆପଣ ପାଇବେ $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'ବଜାର ଦର $low – $high';
  }

  @override
  String get fairPrice => 'ଉଚିତ ଦର';

  @override
  String get category => 'ବର୍ଗ';

  @override
  String priceSpoken(String price, String amount) {
    return 'ଦର $price। ଆପଣ ପାଇବେ $amount।';
  }

  @override
  String get belowFairWage => 'ଏହା ଆପଣଙ୍କ ପରିଶ୍ରମର ଉଚିତ ମଜୁରିଠାରୁ କମ୍';

  @override
  String get isLive => 'ଆପଣଙ୍କ ଜିନିଷ ଏବେ ବିକ୍ରିରେ ଅଛି!';

  @override
  String get onOndc => 'ONDC ନେଟୱର୍କରେ ମଧ୍ୟ ଅଛି';

  @override
  String get certificateReady => 'ଆପଣଙ୍କ ପ୍ରମାଣପତ୍ର ପ୍ରସ୍ତୁତ';

  @override
  String get statusQueued => 'ଧାଡ଼ିରେ';

  @override
  String get statusUploading => 'ଅପଲୋଡ୍ ହେଉଛି';

  @override
  String get statusProcessing => 'ପ୍ରସ୍ତୁତ ହେଉଛି';

  @override
  String get statusNeedsReview => 'ଯାଞ୍ଚ ଦରକାର';

  @override
  String get statusReady => 'ଅନୁମୋଦନ ପାଇଁ ପ୍ରସ୍ତୁତ';

  @override
  String get statusLive => 'ବିକ୍ରିରେ';

  @override
  String get statusFailed => 'ଧ୍ୟାନ ଦିଅନ୍ତୁ';

  @override
  String get statusUnpublished => 'ଲୁଚାଯାଇଛି';

  @override
  String get noProducts =>
      'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ଜିନିଷ ନାହିଁ। ଜିନିଷ ଯୋଡ଼ନ୍ତୁ ଦବାନ୍ତୁ।';

  @override
  String get newOrder => 'ନୂଆ ଅର୍ଡର';

  @override
  String get accept => 'ଗ୍ରହଣ କରନ୍ତୁ';

  @override
  String get decline => 'ମନା କରନ୍ତୁ';

  @override
  String get markPacked => 'ପ୍ୟାକ୍ ହୋଇଗଲା';

  @override
  String get markShipped => 'ପଠାଗଲା';

  @override
  String get noOrders => 'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ଅର୍ଡର ନାହିଁ';

  @override
  String get orderPlaced => 'ନୂଆ';

  @override
  String get orderAccepted => 'ଗ୍ରହଣ';

  @override
  String get orderPacked => 'ପ୍ୟାକ୍';

  @override
  String get orderShipped => 'ବାଟରେ';

  @override
  String get orderDelivered => 'ପହଞ୍ଚିଲା';

  @override
  String get orderDeclined => 'ମନା';

  @override
  String get orderCancelled => 'ବାତିଲ';

  @override
  String get gross => 'ବିକ୍ରି';

  @override
  String get commission => 'ପ୍ଲାଟଫର୍ମ ଶୁଳ୍କ';

  @override
  String get logistics => 'ପଠାଇବା';

  @override
  String get net => 'ଆପଣ ପାଇଲେ';

  @override
  String get everyRupee => 'ପ୍ରତ୍ୟେକ ଟଙ୍କାର ହିସାବ';

  @override
  String get helpTitle => 'ସାହାଯ୍ୟ';

  @override
  String get callHelpline => 'ହେଲ୍ପଲାଇନକୁ ଫୋନ୍ କରନ୍ତୁ';

  @override
  String get requestCallback => 'ସହାୟକ ମୋତେ ଫୋନ୍ କରନ୍ତୁ';

  @override
  String get callbackRequested => 'ଜଣେ ସହାୟକ ଶୀଘ୍ର ଆପଣଙ୍କୁ ଫୋନ୍ କରିବେ';

  @override
  String get howToUse => 'ଶିଳ୍ପସେତୁ କିପରି କାମ କରେ';

  @override
  String get fiveSteps =>
      'କୁହନ୍ତୁ · ଫଟୋ ନିଅନ୍ତୁ · AI ତିଆରି କରେ · ଆପଣ ଅନୁମୋଦନ କରନ୍ତୁ · ବିକ୍ରିରେ';

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
  String get addToCart => 'କାର୍ଟରେ ଯୋଡ଼ନ୍ତୁ';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get scanCertificate => 'Scan for Artisan Provenance Certificate';

  @override
  String get certificateSub => 'Materials, story & fair-price basis';

  @override
  String get howPriceBuilt => 'ଏହି ଦର କିପରି ସ୍ଥିର ହେଲା';

  @override
  String goesToArtisan(String amount, String pct) {
    return 'ଏଥିରୁ $amount ସିଧା କାରିଗରଙ୍କ ପାଖକୁ ଯାଏ ($pct%)';
  }

  @override
  String get meetArtisan => 'କାରିଗରଙ୍କୁ ଭେଟନ୍ତୁ';

  @override
  String get hearVoice => 'Hear their voice';

  @override
  String get moreFromArtisan => 'More from this artisan';

  @override
  String reviewsCount(int count) {
    return '($count reviews)';
  }

  @override
  String get verifiedArtisan => 'ଯାଞ୍ଚିତ କାରିଗର';

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
  String get name => 'ନାମ';

  @override
  String get address => 'ଠିକଣା';

  @override
  String get city => 'ସହର';

  @override
  String get state => 'ରାଜ୍ୟ';

  @override
  String get pincode => 'PIN code';

  @override
  String get phone => 'ଫୋନ୍';

  @override
  String get total => 'ମୋଟ';

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
  String get about => 'ପରିଚୟ';

  @override
  String get logout => 'ଲଗ୍ ଆଉଟ୍';

  @override
  String get lowBandwidth => 'କମ୍ ଡାଟା ମୋଡ୍';

  @override
  String get switchRole => 'ମୋଡ୍ ବଦଳାନ୍ତୁ';

  @override
  String productsCount(int count) {
    return '$countଟି ଜିନିଷ';
  }

  @override
  String get gender => 'ଲିଙ୍ଗ (ଇଚ୍ଛାଧୀନ)';

  @override
  String get genderFemale => 'ମହିଳା';

  @override
  String get genderMale => 'ପୁରୁଷ';

  @override
  String get genderOther => 'ଅନ୍ୟ';

  @override
  String get genderPreferNot => 'କହିବାକୁ ଚାହେଁ ନାହିଁ';

  @override
  String get typeInstead => 'କିମ୍ବା ଉତ୍ତର ଲେଖନ୍ତୁ';

  @override
  String get send => 'ପଠାନ୍ତୁ';

  @override
  String get serverAddress => 'ସର୍ଭର ଠିକଣା';

  @override
  String get serverAddressHint => 'ସହାୟକ କହିଲେ ହିଁ ବଦଳାନ୍ତୁ';

  @override
  String get saved => 'ସଞ୍ଚୟ ହେଲା';

  @override
  String get darkMode => 'ଡାର୍କ ମୋଡ୍';

  @override
  String get lightMode => 'ଲାଇଟ୍ ମୋଡ୍';

  @override
  String get productDetails => 'ଜିନିଷର ବିବରଣୀ';

  @override
  String get aboutArtForm => 'ଏହି କଳା ବିଷୟରେ';

  @override
  String get howItsMade => 'କିପରି ତିଆରି ହୁଏ';

  @override
  String get didYouKnow => 'ଆପଣ ଜାଣନ୍ତି କି?';

  @override
  String yearsOfPractice(int count) {
    return '$count ବର୍ଷର ଅଭିଜ୍ଞତା';
  }

  @override
  String get photoCredits => 'ଫଟୋ ସ୍ୱୀକୃତି';

  @override
  String get photoCreditsSub =>
      'ଉଇକିମିଡିଆ କମନ୍ସରୁ ପ୍ରକୃତ ହସ୍ତଶିଳ୍ପ ଫଟୋ, ଲାଇସେନ୍ସ ଅନୁଯାୟୀ';

  @override
  String get askShilpi => 'ଶିଳ୍ପୀଙ୍କୁ ପଚାରନ୍ତୁ';

  @override
  String get assistantName => 'ଶିଳ୍ପୀ';

  @override
  String get assistantTagline => 'ଆପଣଙ୍କ ଶିଳ୍ପସେତୁ ସହାୟିକା';

  @override
  String get assistantThinking => 'ଭାବୁଛି…';

  @override
  String get askAnything => 'ଯାହା ଇଚ୍ଛା ପଚାରନ୍ତୁ';

  @override
  String get close => 'ବନ୍ଦ କରନ୍ତୁ';

  @override
  String get dayStreak => 'ଦିନର ଧାରା';

  @override
  String get todaysGoal => 'ଆଜିର ଲକ୍ଷ୍ୟ';

  @override
  String get craftOfTheDay => 'ଆଜିର କଳା';

  @override
  String get exploreCraft => 'ଦେଖନ୍ତୁ';

  @override
  String get celebrateLive => 'ଆପଣଙ୍କ ଜିନିଷ ଲାଇଭ୍ ହେଲା!';

  @override
  String get micPermission =>
      'ମାଇକ୍ ଅନୁମତି ଦିଅନ୍ତୁ: ସେଟିଂସ → ଆପ୍ସ → ଶିଳ୍ପସେତୁ → ଅନୁମତି → ମାଇକ୍ରୋଫୋନ୍।';

  @override
  String get micUnavailable =>
      'ଏହି ଫୋନରେ କହି ଲେଖିବା ସୁବିଧା ନାହିଁ। Google ଭଏସ୍ ଟାଇପିଂ ଚାଲୁ କରନ୍ତୁ, କିମ୍ବା ଲେଖନ୍ତୁ।';

  @override
  String get micInsecure =>
      'ମାଇକ୍ କେବଳ ଶିଳ୍ପସେତୁ ଆପରେ ବା ସୁରକ୍ଷିତ https ଲିଙ୍କରେ କାମ କରେ। ଦୟାକରି ଆପ୍ ବ୍ୟବହାର କରନ୍ତୁ।';

  @override
  String get micNoSpeech => 'ଶୁଣିପାରିଲି ନାହିଁ। ମାଇକ୍ ଦବାଇ ଟିକେ ଜୋରରେ କୁହନ୍ତୁ।';

  @override
  String get micNetwork => 'କହି ଲେଖିବାକୁ ଇଣ୍ଟରନେଟ ଦରକାର। ସଂଯୋଗ ଦେଖନ୍ତୁ।';

  @override
  String get pressBackAgain => 'ବାହାରିବାକୁ ପୁଣି ପଛକୁ ଦବାନ୍ତୁ';
}
