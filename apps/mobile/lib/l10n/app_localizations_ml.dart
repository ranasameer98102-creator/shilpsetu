// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class L10nMl extends L10n {
  L10nMl([String locale = 'ml']) : super(locale);

  @override
  String get languageName => 'മലയാളം';

  @override
  String get appTitle => 'ശില്പസേതു';

  @override
  String get tagline =>
      'പാർശ്വവൽക്കരിക്കപ്പെട്ട കരകൗശല വിദഗ്ധരുടെ AI സഹ-വിൽപ്പനക്കാരൻ';

  @override
  String get heroLine =>
      'കൈപ്പണിയിൽ നിന്ന് തലക്കെട്ടുകളിലേക്ക് — ഓരോ കരകൗശലവും, എപ്പോഴും വിപണിയിൽ.';

  @override
  String get promise =>
      'ഒരു ഫോട്ടോ. പറഞ്ഞ ഒരു വാക്യം. ന്യായവിലയുള്ള, വിശ്വസനീയമായ ലിസ്റ്റിംഗ് — ടൈപ്പിംഗ് വേണ്ട, ഇടനിലക്കാരില്ല, ഇംഗ്ലീഷ് വേണ്ട.';

  @override
  String get next => 'അടുത്തത്';

  @override
  String get back => 'തിരികെ';

  @override
  String get retry => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get save => 'സൂക്ഷിക്കുക';

  @override
  String get cancel => 'റദ്ദാക്കുക';

  @override
  String get done => 'കഴിഞ്ഞു';

  @override
  String get skip => 'ഒഴിവാക്കുക';

  @override
  String get yes => 'അതെ';

  @override
  String get no => 'ഇല്ല';

  @override
  String get loading => 'ദയവായി കാത്തിരിക്കുക…';

  @override
  String get errorGeneric => 'എന്തോ പിശക് സംഭവിച്ചു. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get errorNetwork =>
      'നെറ്റ്‌വർക്ക് ഇല്ല. നിങ്ങളുടെ ജോലി ഫോണിൽ സുരക്ഷിതമാണ്.';

  @override
  String get savedOnPhone =>
      'ഫോണിൽ സൂക്ഷിച്ചു — നെറ്റ്‌വർക്ക് വന്നാലുടൻ അപ്‌ലോഡ് ചെയ്യും';

  @override
  String get allSynced => 'എല്ലാം അപ്‌ലോഡ് ചെയ്തു';

  @override
  String get syncing => 'അപ്‌ലോഡ് ചെയ്യുന്നു…';

  @override
  String pendingCount(int count) {
    return '$count എണ്ണം അപ്‌ലോഡ് ചെയ്യാനുണ്ട്';
  }

  @override
  String get chooseRole => 'നിങ്ങൾ ആരാണ്?';

  @override
  String get roleArtisan => 'ഞാൻ കരകൗശല വസ്തുക്കൾ ഉണ്ടാക്കുന്നു';

  @override
  String get roleBuyer => 'എനിക്ക് വാങ്ങണം';

  @override
  String get roleKiosk => 'കിയോസ്ക് / CSC സഹായി';

  @override
  String get chooseLanguage => 'നിങ്ങളുടെ ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get tapToHear =>
      'കേൾക്കാൻ ഒരിക്കൽ തൊടുക, തിരഞ്ഞെടുക്കാൻ വീണ്ടും തൊടുക';

  @override
  String get enterPhone => 'നിങ്ങളുടെ മൊബൈൽ നമ്പർ';

  @override
  String get sendCode => 'കോഡ് അയയ്ക്കുക';

  @override
  String get enterCode => '6 അക്ക കോഡ് നൽകുക';

  @override
  String codeSentTo(String phone) {
    return '$phone എന്ന നമ്പറിലേക്ക് കോഡ് അയച്ചു';
  }

  @override
  String get verify => 'സ്ഥിരീകരിക്കുക';

  @override
  String get sayNumber => 'നിങ്ങളുടെ നമ്പർ പറയുക';

  @override
  String demoCode(String code) {
    return 'ഡെമോ കോഡ്: $code';
  }

  @override
  String get consentTitle => 'നിങ്ങളുടെ അനുമതി';

  @override
  String get consentBody =>
      'നിങ്ങളുടെ കരകൗശല വസ്തു വിൽക്കാൻ ശില്പസേതു നിങ്ങളുടെ ശബ്ദം, ഫോട്ടോകൾ, നിങ്ങളുടെ ഗ്രാമത്തിന്റെ വിലാസം എന്നിവ സൂക്ഷിക്കും. എപ്പോൾ വേണമെങ്കിലും അവ മായ്ക്കാം.';

  @override
  String get consentVoice => 'എന്റെ ശബ്ദം സൂക്ഷിക്കുക';

  @override
  String get consentPhoto => 'എന്റെ ഫോട്ടോകൾ സൂക്ഷിക്കുക';

  @override
  String get consentLocation => 'എന്റെ ഗ്രാമത്തിന്റെ വിലാസം സൂക്ഷിക്കുക';

  @override
  String get iAgree => 'അതെ, ഞാൻ സമ്മതിക്കുന്നു';

  @override
  String get sayYesToAgree => 'അല്ലെങ്കിൽ സമ്മതിക്കാൻ “അതെ” എന്ന് പറയുക';

  @override
  String get profileTitle => 'നിങ്ങളെക്കുറിച്ച് പറയൂ';

  @override
  String get askName => 'നിങ്ങളുടെ പേര് എന്താണ്?';

  @override
  String get askVillage =>
      'നിങ്ങൾ ഏത് ഗ്രാമത്തിൽ നിന്നോ പട്ടണത്തിൽ നിന്നോ ആണ്?';

  @override
  String get askState => 'ഏത് ജില്ല, ഏത് സംസ്ഥാനം?';

  @override
  String get askCraft => 'നിങ്ങൾ ഏത് കരകൗശലമാണ് ചെയ്യുന്നത്?';

  @override
  String get askYears => 'എത്ര വർഷമായി ഈ കല ചെയ്യുന്നു?';

  @override
  String get askStory => 'നിങ്ങളുടെ കഥ പറയൂ — ഈ കല എങ്ങനെ പഠിച്ചു?';

  @override
  String get askPehchan =>
      'പെഹ്ചാൻ കരകൗശല കാർഡ് ഉണ്ടെങ്കിൽ അതിന്റെ നമ്പർ പറയുക. ഇല്ലെങ്കിൽ ഒഴിവാക്കുക അമർത്തുക.';

  @override
  String get tapMicToAnswer => 'മൈക്ക് അമർത്തി ഉത്തരം പറയുക';

  @override
  String get weHeard => 'ഞങ്ങൾ കേട്ടത്:';

  @override
  String get profileSaved => 'നിങ്ങളുടെ വിവരങ്ങൾ സൂക്ഷിച്ചു';

  @override
  String greeting(String name) {
    return 'നമസ്കാരം, $name';
  }

  @override
  String get tileAddProduct => 'ഉൽപ്പന്നം ചേർക്കുക';

  @override
  String get tileMyProducts => 'എന്റെ ഉൽപ്പന്നങ്ങൾ';

  @override
  String get tileOrders => 'ഓർഡറുകൾ';

  @override
  String get tileEarnings => 'വരുമാനം';

  @override
  String get tileHelp => 'സഹായം';

  @override
  String earningsSummary(String amount, int count) {
    return 'ഈ മാസം $count ഓർഡറുകളിൽ നിന്ന് നിങ്ങൾ $amount സമ്പാദിച്ചു';
  }

  @override
  String get addProductTitle => 'ഉൽപ്പന്നം ചേർക്കുക';

  @override
  String get speakOwnLanguage => 'നിങ്ങളുടെ സ്വന്തം ഭാഷയിൽ സംസാരിക്കൂ';

  @override
  String listeningIn(String language) {
    return '$languageയിൽ കേൾക്കുന്നു…';
  }

  @override
  String get tapToSpeak =>
      'സംസാരിക്കാൻ അമർത്തുക, അല്ലെങ്കിൽ അമർത്തിപ്പിടിക്കുക';

  @override
  String get stopRecording => 'നിർത്താൻ അമർത്തുക';

  @override
  String get photoCaptured =>
      'ഫോട്ടോ എടുത്തു — പശ്ചാത്തലവും വെളിച്ചവും സ്വയം ശരിയാക്കുന്നു';

  @override
  String get takePhoto => 'ഫോട്ടോ എടുക്കുക';

  @override
  String get addMorePhotos => 'കൂടുതൽ ഫോട്ടോകൾ ചേർക്കുക';

  @override
  String get makeListing => 'എന്റെ ലിസ്റ്റിംഗ് ഉണ്ടാക്കൂ';

  @override
  String get hintTooDark =>
      'അൽപ്പം ഇരുട്ടാണ് — കഴിയുമെങ്കിൽ വെളിച്ചത്തിലേക്ക് നീങ്ങുക';

  @override
  String get hintTooBright => 'വെളിച്ചം കൂടുതലാണ് — അൽപ്പം തണലിലേക്ക് മാറുക';

  @override
  String get hintMoveCloser => 'അൽപ്പം അടുത്തേക്ക് വരൂ';

  @override
  String get hintBlurry => 'ഫോൺ അനങ്ങാതെ പിടിക്കുക';

  @override
  String get anyBackground => 'ഏത് വെളിച്ചവും ഏത് പശ്ചാത്തലവും മതി';

  @override
  String get upTo60s => '60 സെക്കൻഡ് വരെ';

  @override
  String get aiBuilding => 'AI നിങ്ങളുടെ ലിസ്റ്റിംഗ് ഉണ്ടാക്കുന്നു';

  @override
  String get stepAsr => 'നിങ്ങളുടെ ശബ്ദം മനസ്സിലാക്കുന്നു';

  @override
  String get stepNlu => 'വിവരങ്ങൾ കണ്ടെത്തുന്നു';

  @override
  String get stepListing => 'പേരും വിവരണവും എഴുതുന്നു';

  @override
  String get stepTranslation => 'വാങ്ങുന്നവർക്കായി വിവർത്തനം ചെയ്യുന്നു';

  @override
  String get stepImage => 'നിങ്ങളുടെ ഫോട്ടോ മെച്ചപ്പെടുത്തുന്നു';

  @override
  String get stepPrice => 'ന്യായമായ വില കണക്കാക്കുന്നു';

  @override
  String get stepCertificate => 'നിങ്ങളുടെ സർട്ടിഫിക്കറ്റ് തയ്യാറാക്കുന്നു';

  @override
  String get quickQuestions => 'ചില ചെറിയ ചോദ്യങ്ങൾ';

  @override
  String get answerBySpeaking => 'സംസാരിച്ച് ഉത്തരം നൽകുക';

  @override
  String get reviewTitle => 'പരിശോധിച്ച് അംഗീകരിക്കുക';

  @override
  String get approve => 'അംഗീകരിക്കുക';

  @override
  String get changePrice => 'വില മാറ്റുക';

  @override
  String get retakePhoto => 'വീണ്ടും ഫോട്ടോ എടുക്കുക';

  @override
  String get reRecord => 'വീണ്ടും പറയുക';

  @override
  String get sayNewPrice => 'പുതിയ വില പറയുക';

  @override
  String youGet(String amount, String pct) {
    return 'നിങ്ങൾക്ക് ലഭിക്കുന്നത് $amount ($pct%)';
  }

  @override
  String marketRate(String low, String high) {
    return 'വിപണി വില $low – $high';
  }

  @override
  String get fairPrice => 'ന്യായവില';

  @override
  String get category => 'വിഭാഗം';

  @override
  String priceSpoken(String price, String amount) {
    return 'വില $price. നിങ്ങൾക്ക് ലഭിക്കുന്നത് $amount.';
  }

  @override
  String get belowFairWage =>
      'ഇത് നിങ്ങളുടെ അധ്വാനത്തിനുള്ള ന്യായമായ കൂലിയേക്കാൾ കുറവാണ്';

  @override
  String get isLive => 'നിങ്ങളുടെ ഉൽപ്പന്നം ഇപ്പോൾ വിൽപ്പനയിലാണ്!';

  @override
  String get onOndc => 'ONDC ശൃംഖലയിലും ലഭ്യമാണ്';

  @override
  String get certificateReady => 'നിങ്ങളുടെ സർട്ടിഫിക്കറ്റ് തയ്യാർ';

  @override
  String get statusQueued => 'ക്യൂവിൽ';

  @override
  String get statusUploading => 'അപ്‌ലോഡ് ചെയ്യുന്നു';

  @override
  String get statusProcessing => 'തയ്യാറാകുന്നു';

  @override
  String get statusNeedsReview => 'പരിശോധന വേണം';

  @override
  String get statusReady => 'അംഗീകാരത്തിന് തയ്യാർ';

  @override
  String get statusLive => 'വിൽപ്പനയിൽ';

  @override
  String get statusFailed => 'ശ്രദ്ധിക്കുക';

  @override
  String get statusUnpublished => 'മറച്ചിരിക്കുന്നു';

  @override
  String get noProducts =>
      'ഇതുവരെ ഉൽപ്പന്നങ്ങളില്ല. ഉൽപ്പന്നം ചേർക്കുക അമർത്തുക.';

  @override
  String get newOrder => 'പുതിയ ഓർഡർ';

  @override
  String get accept => 'സ്വീകരിക്കുക';

  @override
  String get decline => 'നിരസിക്കുക';

  @override
  String get markPacked => 'പാക്ക് ചെയ്തു';

  @override
  String get markShipped => 'അയച്ചു';

  @override
  String get noOrders => 'ഇതുവരെ ഓർഡറുകളില്ല';

  @override
  String get orderPlaced => 'പുതിയത്';

  @override
  String get orderAccepted => 'സ്വീകരിച്ചു';

  @override
  String get orderPacked => 'പാക്ക് ചെയ്തു';

  @override
  String get orderShipped => 'വഴിയിലാണ്';

  @override
  String get orderDelivered => 'എത്തി';

  @override
  String get orderDeclined => 'നിരസിച്ചു';

  @override
  String get orderCancelled => 'റദ്ദാക്കി';

  @override
  String get gross => 'വിൽപ്പന';

  @override
  String get commission => 'പ്ലാറ്റ്‌ഫോം ഫീസ്';

  @override
  String get logistics => 'ഷിപ്പിംഗ്';

  @override
  String get net => 'നിങ്ങൾക്ക് ലഭിച്ചത്';

  @override
  String get everyRupee => 'ഓരോ രൂപയുടെയും കണക്ക്';

  @override
  String get helpTitle => 'സഹായം';

  @override
  String get callHelpline => 'ഹെൽപ്പ്‌ലൈനിൽ വിളിക്കുക';

  @override
  String get requestCallback => 'സഹായി എന്നെ വിളിക്കട്ടെ';

  @override
  String get callbackRequested => 'ഒരു സഹായി ഉടൻ നിങ്ങളെ വിളിക്കും';

  @override
  String get howToUse => 'ശില്പസേതു എങ്ങനെ പ്രവർത്തിക്കുന്നു';

  @override
  String get fiveSteps =>
      'സംസാരിക്കൂ · ഫോട്ടോ എടുക്കൂ · AI ഉണ്ടാക്കും · നിങ്ങൾ അംഗീകരിക്കൂ · വിൽപ്പനയിൽ';

  @override
  String get searchHint => 'കരകൗശലം, സംസ്ഥാനം, കലാകാരന്മാരെ തിരയുക';

  @override
  String get freshFromLoom => 'തറിയിൽ നിന്നും ചക്രത്തിൽ നിന്നും പുതുതായി';

  @override
  String get byCraft => 'കരകൗശലം അനുസരിച്ച്';

  @override
  String get byState => 'സംസ്ഥാനവും ക്ലസ്റ്ററും അനുസരിച്ച്';

  @override
  String get womenLed => 'സ്ത്രീകൾ നയിക്കുന്ന കൂട്ടായ്മകൾ';

  @override
  String get giTagged => 'GI ടാഗുള്ള കരകൗശലങ്ങൾ';

  @override
  String get nearYou => 'നിങ്ങളുടെ അടുത്ത്';

  @override
  String get filters => 'ഫിൽട്ടറുകൾ';

  @override
  String get verifiedOnly => 'സ്ഥിരീകരിച്ച കലാകാരന്മാർ മാത്രം';

  @override
  String get giOnly => 'GI ടാഗുള്ളവ മാത്രം';

  @override
  String get sortBy => 'ക്രമം';

  @override
  String get sortRelevance => 'ഏറ്റവും അനുയോജ്യം';

  @override
  String get sortPriceLow => 'വില: കുറവിൽ നിന്ന് കൂടുതൽ';

  @override
  String get sortPriceHigh => 'വില: കൂടുതലിൽ നിന്ന് കുറവ്';

  @override
  String get sortNewest => 'ഏറ്റവും പുതിയത്';

  @override
  String results(int count) {
    return '$count കരകൗശല വസ്തുക്കൾ';
  }

  @override
  String get addToCart => 'കാർട്ടിൽ ചേർക്കുക';

  @override
  String get addedToCart => 'കാർട്ടിൽ ചേർത്തു';

  @override
  String get scanCertificate => 'കലാകാരന്റെ സർട്ടിഫിക്കറ്റിനായി സ്കാൻ ചെയ്യുക';

  @override
  String get certificateSub => 'സാമഗ്രികൾ, കഥ, വിലയുടെ അടിസ്ഥാനം';

  @override
  String get howPriceBuilt => 'ഈ വില എങ്ങനെ നിശ്ചയിച്ചു';

  @override
  String goesToArtisan(String amount, String pct) {
    return 'ഇതിൽ $amount നേരിട്ട് കലാകാരന് ലഭിക്കുന്നു ($pct%)';
  }

  @override
  String get meetArtisan => 'കലാകാരനെ പരിചയപ്പെടാം';

  @override
  String get hearVoice => 'അവരുടെ ശബ്ദം കേൾക്കുക';

  @override
  String get moreFromArtisan => 'ഈ കലാകാരന്റെ കൂടുതൽ സൃഷ്ടികൾ';

  @override
  String reviewsCount(int count) {
    return '($count അവലോകനങ്ങൾ)';
  }

  @override
  String get verifiedArtisan => 'സ്ഥിരീകരിച്ച കലാകാരൻ';

  @override
  String get cart => 'കാർട്ട്';

  @override
  String get cartEmpty => 'നിങ്ങളുടെ കാർട്ട് ശൂന്യമാണ്';

  @override
  String get checkout => 'ചെക്ക്ഔട്ട്';

  @override
  String get placeOrder => 'ഓർഡർ ചെയ്യുക';

  @override
  String get payUpi => 'UPI വഴി പണം നൽകുക';

  @override
  String get cod => 'ഡെലിവറി സമയത്ത് പണം';

  @override
  String deliveryIn(int days) {
    return 'ഏകദേശം $days ദിവസത്തിനുള്ളിൽ ഡെലിവറി';
  }

  @override
  String get shippingIncluded =>
      'ഷിപ്പിംഗും പാക്കിംഗും ന്യായവിലയിൽ ഉൾപ്പെടുന്നു';

  @override
  String get orderPlacedThanks => 'നന്ദി! നിങ്ങളുടെ ഓർഡർ ചെയ്തു.';

  @override
  String get myOrders => 'എന്റെ ഓർഡറുകൾ';

  @override
  String get rateCraft => 'ഈ കരകൗശലത്തിന് റേറ്റിംഗ് നൽകുക';

  @override
  String get scanQr => 'സർട്ടിഫിക്കറ്റ് QR സ്കാൻ ചെയ്യുക';

  @override
  String get certValid => 'യഥാർത്ഥം — ശില്പസേതു സ്ഥിരീകരിച്ചത്';

  @override
  String get certInvalid => 'സാധുവല്ല';

  @override
  String get name => 'പേര്';

  @override
  String get address => 'വിലാസം';

  @override
  String get city => 'നഗരം';

  @override
  String get state => 'സംസ്ഥാനം';

  @override
  String get pincode => 'പിൻ കോഡ്';

  @override
  String get phone => 'ഫോൺ';

  @override
  String get total => 'ആകെ';

  @override
  String get kioskTitle => 'കിയോസ്ക്';

  @override
  String get myArtisans => 'കലാകാരന്മാർ';

  @override
  String get onboardArtisan => 'കലാകാരനെ ചേർക്കുക';

  @override
  String captureFor(String name) {
    return '$name എന്നവർക്കായി';
  }

  @override
  String get batchMode => 'പ്രദർശന ബാച്ച് മോഡ്';

  @override
  String get printTags => 'സർട്ടിഫിക്കറ്റ് ടാഗുകൾ അച്ചടിക്കുക';

  @override
  String get syncAll => 'എല്ലാം അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get attestation =>
      'അവരുടെ തിരിച്ചറിയൽ പരിശോധിച്ച്, അവർ പറഞ്ഞ സമ്മതം രേഖപ്പെടുത്തി';

  @override
  String get recordConsent => 'കലാകാരന്റെ സമ്മതം രേഖപ്പെടുത്തുക';

  @override
  String get about => 'കുറിച്ച്';

  @override
  String get logout => 'ലോഗ് ഔട്ട്';

  @override
  String get lowBandwidth => 'കുറഞ്ഞ ഡാറ്റ മോഡ്';

  @override
  String get switchRole => 'മോഡ് മാറ്റുക';

  @override
  String productsCount(int count) {
    return '$count ഉൽപ്പന്നങ്ങൾ';
  }

  @override
  String get gender => 'ലിംഗം (ഐച്ഛികം)';

  @override
  String get genderFemale => 'സ്ത്രീ';

  @override
  String get genderMale => 'പുരുഷൻ';

  @override
  String get genderOther => 'മറ്റുള്ളവ';

  @override
  String get genderPreferNot => 'പറയാൻ താൽപ്പര്യമില്ല';

  @override
  String get typeInstead => 'അല്ലെങ്കിൽ ഉത്തരം ടൈപ്പ് ചെയ്യുക';

  @override
  String get send => 'അയയ്ക്കുക';

  @override
  String get serverAddress => 'സെർവർ വിലാസം';

  @override
  String get serverAddressHint => 'സഹായി പറഞ്ഞാൽ മാത്രം മാറ്റുക';

  @override
  String get saved => 'സൂക്ഷിച്ചു';

  @override
  String get darkMode => 'ഡാർക്ക് മോഡ്';

  @override
  String get lightMode => 'ലൈറ്റ് മോഡ്';

  @override
  String get productDetails => 'ഉൽപ്പന്ന വിവരം';

  @override
  String get aboutArtForm => 'ഈ കലയെക്കുറിച്ച്';

  @override
  String get howItsMade => 'എങ്ങനെ ഉണ്ടാക്കുന്നു';

  @override
  String get didYouKnow => 'നിങ്ങൾക്കറിയാമോ?';

  @override
  String yearsOfPractice(int count) {
    return '$count വർഷത്തെ അനുഭവം';
  }

  @override
  String get photoCredits => 'ഫോട്ടോ കടപ്പാട്';

  @override
  String get photoCreditsSub =>
      'വിക്കിമീഡിയ കോമൺസിൽ നിന്നുള്ള യഥാർത്ഥ കരകൗശല ഫോട്ടോകൾ, ലൈസൻസ് പ്രകാരം';

  @override
  String get askShilpi => 'ശില്പിയോട് ചോദിക്കൂ';

  @override
  String get assistantName => 'ശില്പി';

  @override
  String get assistantTagline => 'നിങ്ങളുടെ ശില്പസേതു സഹായി';

  @override
  String get assistantThinking => 'ആലോചിക്കുന്നു…';

  @override
  String get askAnything => 'എന്തും ചോദിക്കൂ';

  @override
  String get close => 'അടയ്ക്കുക';

  @override
  String get dayStreak => 'ദിവസ ശൃംഖല';

  @override
  String get todaysGoal => 'ഇന്നത്തെ ലക്ഷ്യം';

  @override
  String get craftOfTheDay => 'ഇന്നത്തെ കല';

  @override
  String get exploreCraft => 'കാണുക';

  @override
  String get celebrateLive => 'നിങ്ങളുടെ ഉൽപ്പന്നം ലൈവായി!';

  @override
  String get micPermission =>
      'മൈക്ക് അനുമതി നൽകുക: സെറ്റിംഗ്സ് → ആപ്പുകൾ → ശില്പസേതു → അനുമതികൾ → മൈക്രോഫോൺ.';

  @override
  String get micUnavailable =>
      'ഈ ഫോണിൽ സംസാരിച്ച് എഴുതാനുള്ള സൗകര്യമില്ല. Google വോയ്സ് ടൈപ്പിംഗ് ഓണാക്കുക, അല്ലെങ്കിൽ ടൈപ്പ് ചെയ്യുക.';

  @override
  String get micInsecure =>
      'മൈക്ക് ശില്പസേതു ആപ്പിലോ സുരക്ഷിത https ലിങ്കിലോ മാത്രമേ പ്രവർത്തിക്കൂ. ആപ്പ് ഉപയോഗിക്കുക.';

  @override
  String get micNoSpeech =>
      'കേട്ടില്ല. മൈക്ക് അമർത്തി അൽപ്പം ഉറക്കെ സംസാരിക്കുക.';

  @override
  String get micNetwork =>
      'സംസാരിച്ച് എഴുതാൻ ഇന്റർനെറ്റ് വേണം. കണക്ഷൻ നോക്കുക.';

  @override
  String get pressBackAgain => 'പുറത്തുകടക്കാൻ വീണ്ടും ബാക്ക് അമർത്തുക';
}
