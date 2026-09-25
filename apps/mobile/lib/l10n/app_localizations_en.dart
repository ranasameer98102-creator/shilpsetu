// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get languageName => 'English';

  @override
  String get appTitle => 'ShilpSetu';

  @override
  String get tagline => 'AI Co-Seller for Marginalized Artisans';

  @override
  String get heroLine =>
      'From handmade to headline-worthy — every craft, always in market.';

  @override
  String get promise =>
      'One photo. One spoken sentence. A fair-priced, trust-verified listing — no typing, no middleman, no English required.';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get retry => 'Try again';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get skip => 'Skip';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Please wait…';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No network. Your work is saved on the phone.';

  @override
  String get savedOnPhone =>
      'Saved on phone — will upload when network returns';

  @override
  String get allSynced => 'All synced';

  @override
  String get syncing => 'Uploading…';

  @override
  String pendingCount(int count) {
    return '$count waiting to upload';
  }

  @override
  String get chooseRole => 'Who are you?';

  @override
  String get roleArtisan => 'I make crafts';

  @override
  String get roleBuyer => 'I want to buy';

  @override
  String get roleKiosk => 'Kiosk / CSC helper';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get tapToHear => 'Tap once to hear, tap again to choose';

  @override
  String get enterPhone => 'Your mobile number';

  @override
  String get sendCode => 'Send code';

  @override
  String get enterCode => 'Enter the 6-digit code';

  @override
  String codeSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get verify => 'Verify';

  @override
  String get sayNumber => 'Say your number';

  @override
  String demoCode(String code) {
    return 'Demo code: $code';
  }

  @override
  String get consentTitle => 'Your permission';

  @override
  String get consentBody =>
      'ShilpSetu will save your voice, your photos and your village location so that it can sell your crafts. You can delete them at any time.';

  @override
  String get consentVoice => 'Save my voice';

  @override
  String get consentPhoto => 'Save my photos';

  @override
  String get consentLocation => 'Save my village location';

  @override
  String get iAgree => 'Yes, I agree';

  @override
  String get sayYesToAgree => 'Or say “yes” to agree';

  @override
  String get profileTitle => 'Tell us about yourself';

  @override
  String get askName => 'What is your name?';

  @override
  String get askVillage => 'Which village or town are you from?';

  @override
  String get askState => 'Which district and state?';

  @override
  String get askCraft => 'What craft do you make?';

  @override
  String get askYears => 'For how many years have you done this craft?';

  @override
  String get askStory => 'Tell us your story — how did you learn this craft?';

  @override
  String get askPehchan =>
      'If you have a Pehchan artisan card, say its number. Otherwise tap Skip.';

  @override
  String get tapMicToAnswer => 'Tap the mic and answer';

  @override
  String get weHeard => 'We heard:';

  @override
  String get profileSaved => 'Your profile is saved';

  @override
  String greeting(String name) {
    return 'Namaste, $name';
  }

  @override
  String get tileAddProduct => 'Add Product';

  @override
  String get tileMyProducts => 'My Products';

  @override
  String get tileOrders => 'Orders';

  @override
  String get tileEarnings => 'Earnings';

  @override
  String get tileHelp => 'Help';

  @override
  String earningsSummary(String amount, int count) {
    return 'This month you earned $amount from $count orders';
  }

  @override
  String get addProductTitle => 'Add a Product';

  @override
  String get speakOwnLanguage => 'Speak in your own language';

  @override
  String listeningIn(String language) {
    return 'Listening in $language…';
  }

  @override
  String get tapToSpeak => 'Tap to speak, or hold to talk';

  @override
  String get stopRecording => 'Tap to stop';

  @override
  String get photoCaptured =>
      'Photo captured — enhancing background & light automatically';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get addMorePhotos => 'Add more photos';

  @override
  String get makeListing => 'Make my listing';

  @override
  String get hintTooDark =>
      'It is a little dark — move towards the light if you can';

  @override
  String get hintTooBright => 'Too much light — move to a little shade';

  @override
  String get hintMoveCloser => 'Move a little closer';

  @override
  String get hintBlurry => 'Hold the phone steady';

  @override
  String get anyBackground => 'Any light, any background is fine';

  @override
  String get upTo60s => 'Up to 60 seconds';

  @override
  String get aiBuilding => 'AI is building your listing';

  @override
  String get stepAsr => 'Understanding your voice';

  @override
  String get stepNlu => 'Finding the details';

  @override
  String get stepListing => 'Writing title and description';

  @override
  String get stepTranslation => 'Translating for buyers';

  @override
  String get stepImage => 'Cleaning up your photo';

  @override
  String get stepPrice => 'Working out a fair price';

  @override
  String get stepCertificate => 'Preparing your certificate';

  @override
  String get quickQuestions => 'A few quick questions';

  @override
  String get answerBySpeaking => 'Answer by speaking';

  @override
  String get reviewTitle => 'Check and approve';

  @override
  String get approve => 'Approve';

  @override
  String get changePrice => 'Change price';

  @override
  String get retakePhoto => 'Retake photo';

  @override
  String get reRecord => 'Re-record';

  @override
  String get sayNewPrice => 'Say the new price';

  @override
  String youGet(String amount, String pct) {
    return 'You get $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'Market rate $low – $high';
  }

  @override
  String get fairPrice => 'Fair price';

  @override
  String get category => 'Category';

  @override
  String priceSpoken(String price, String amount) {
    return 'Price $price. You get $amount.';
  }

  @override
  String get belowFairWage => 'This is below a fair wage for your time';

  @override
  String get isLive => 'Your product is live!';

  @override
  String get onOndc => 'Also listed on the ONDC network';

  @override
  String get certificateReady => 'Your certificate is ready';

  @override
  String get statusQueued => 'Queued';

  @override
  String get statusUploading => 'Uploading';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusNeedsReview => 'Needs review';

  @override
  String get statusReady => 'Ready to approve';

  @override
  String get statusLive => 'Live';

  @override
  String get statusFailed => 'Needs attention';

  @override
  String get statusUnpublished => 'Hidden';

  @override
  String get noProducts => 'No products yet. Tap Add Product.';

  @override
  String get newOrder => 'New order';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get markPacked => 'Packed';

  @override
  String get markShipped => 'Shipped';

  @override
  String get noOrders => 'No orders yet';

  @override
  String get orderPlaced => 'New';

  @override
  String get orderAccepted => 'Accepted';

  @override
  String get orderPacked => 'Packed';

  @override
  String get orderShipped => 'On the way';

  @override
  String get orderDelivered => 'Delivered';

  @override
  String get orderDeclined => 'Declined';

  @override
  String get orderCancelled => 'Cancelled';

  @override
  String get gross => 'Sale';

  @override
  String get commission => 'Platform fee';

  @override
  String get logistics => 'Shipping';

  @override
  String get net => 'You received';

  @override
  String get everyRupee => 'Every rupee explained';

  @override
  String get helpTitle => 'Help';

  @override
  String get callHelpline => 'Call the helpline';

  @override
  String get requestCallback => 'Ask a helper to call me';

  @override
  String get callbackRequested => 'A helper will call you soon';

  @override
  String get howToUse => 'How ShilpSetu works';

  @override
  String get fiveSteps =>
      'Speak · Snap · AI builds it · You approve · Goes live';

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
  String get addToCart => 'Add to Cart';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get scanCertificate => 'Scan for Artisan Provenance Certificate';

  @override
  String get certificateSub => 'Materials, story & fair-price basis';

  @override
  String get howPriceBuilt => 'How this price is built';

  @override
  String goesToArtisan(String amount, String pct) {
    return '$amount of this goes directly to the artisan ($pct%)';
  }

  @override
  String get meetArtisan => 'Meet the artisan';

  @override
  String get hearVoice => 'Hear their voice';

  @override
  String get moreFromArtisan => 'More from this artisan';

  @override
  String reviewsCount(int count) {
    return '($count reviews)';
  }

  @override
  String get verifiedArtisan => 'Verified Artisan';

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
  String get name => 'Name';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get state => 'State';

  @override
  String get pincode => 'PIN code';

  @override
  String get phone => 'Phone';

  @override
  String get total => 'Total';

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
  String get about => 'About';

  @override
  String get logout => 'Log out';

  @override
  String get lowBandwidth => 'Low-data mode';

  @override
  String get switchRole => 'Switch mode';

  @override
  String productsCount(int count) {
    return '$count products';
  }

  @override
  String get gender => 'Gender (optional, self-declared)';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderMale => 'Male';

  @override
  String get genderOther => 'Other';

  @override
  String get genderPreferNot => 'Prefer not to say';

  @override
  String get typeInstead => 'Or type the answer';

  @override
  String get send => 'Send';

  @override
  String get serverAddress => 'Server address';

  @override
  String get serverAddressHint => 'Only change this if a helper asks you to';

  @override
  String get saved => 'Saved';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get lightMode => 'Light mode';

  @override
  String get productDetails => 'Product details';

  @override
  String get aboutArtForm => 'About this art form';

  @override
  String get howItsMade => 'How it\'s made';

  @override
  String get didYouKnow => 'Did you know?';

  @override
  String yearsOfPractice(int count) {
    return '$count years of practice';
  }

  @override
  String get photoCredits => 'Photo credits';

  @override
  String get photoCreditsSub =>
      'Real craft photos from Wikimedia Commons, used under their licences';

  @override
  String get askShilpi => 'Ask Shilpi';

  @override
  String get assistantName => 'Shilpi';

  @override
  String get assistantTagline => 'Your ShilpSetu helper';

  @override
  String get assistantThinking => 'Thinking…';

  @override
  String get askAnything => 'Ask me anything';

  @override
  String get close => 'Close';

  @override
  String get dayStreak => 'day streak';

  @override
  String get todaysGoal => 'today\'s goal';

  @override
  String get craftOfTheDay => 'Craft of the day';

  @override
  String get exploreCraft => 'Explore';

  @override
  String get celebrateLive => 'Your craft is live!';

  @override
  String get micPermission =>
      'Please allow the microphone: Settings → Apps → ShilpSetu → Permissions → Microphone.';

  @override
  String get micUnavailable =>
      'This phone has no voice typing. Turn on Google voice typing (Speech Services by Google), or type instead.';

  @override
  String get micInsecure =>
      'The microphone works only in the ShilpSetu app or on a secure https link. Please use the app.';

  @override
  String get micNoSpeech =>
      'I couldn\'t hear you. Tap the mic and speak a little louder.';

  @override
  String get micNetwork =>
      'Voice typing needs internet on this phone. Please check your connection.';

  @override
  String get pressBackAgain => 'Press back again to exit';
}
