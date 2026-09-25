import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_as.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_sat.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('as'),
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('or'),
    Locale('pa'),
    Locale('sat'),
    Locale('ta'),
    Locale('te'),
    Locale('ur'),
  ];

  /// No description provided for @languageName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ShilpSetu'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'AI Co-Seller for Marginalized Artisans'**
  String get tagline;

  /// No description provided for @heroLine.
  ///
  /// In en, this message translates to:
  /// **'From handmade to headline-worthy — every craft, always in market.'**
  String get heroLine;

  /// No description provided for @promise.
  ///
  /// In en, this message translates to:
  /// **'One photo. One spoken sentence. A fair-priced, trust-verified listing — no typing, no middleman, no English required.'**
  String get promise;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No network. Your work is saved on the phone.'**
  String get errorNetwork;

  /// No description provided for @savedOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Saved on phone — will upload when network returns'**
  String get savedOnPhone;

  /// No description provided for @allSynced.
  ///
  /// In en, this message translates to:
  /// **'All synced'**
  String get allSynced;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get syncing;

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting to upload'**
  String pendingCount(int count);

  /// No description provided for @chooseRole.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get chooseRole;

  /// No description provided for @roleArtisan.
  ///
  /// In en, this message translates to:
  /// **'I make crafts'**
  String get roleArtisan;

  /// No description provided for @roleBuyer.
  ///
  /// In en, this message translates to:
  /// **'I want to buy'**
  String get roleBuyer;

  /// No description provided for @roleKiosk.
  ///
  /// In en, this message translates to:
  /// **'Kiosk / CSC helper'**
  String get roleKiosk;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @tapToHear.
  ///
  /// In en, this message translates to:
  /// **'Tap once to hear, tap again to choose'**
  String get tapToHear;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Your mobile number'**
  String get enterPhone;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get enterCode;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String codeSentTo(String phone);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @sayNumber.
  ///
  /// In en, this message translates to:
  /// **'Say your number'**
  String get sayNumber;

  /// No description provided for @demoCode.
  ///
  /// In en, this message translates to:
  /// **'Demo code: {code}'**
  String demoCode(String code);

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Your permission'**
  String get consentTitle;

  /// No description provided for @consentBody.
  ///
  /// In en, this message translates to:
  /// **'ShilpSetu will save your voice, your photos and your village location so that it can sell your crafts. You can delete them at any time.'**
  String get consentBody;

  /// No description provided for @consentVoice.
  ///
  /// In en, this message translates to:
  /// **'Save my voice'**
  String get consentVoice;

  /// No description provided for @consentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Save my photos'**
  String get consentPhoto;

  /// No description provided for @consentLocation.
  ///
  /// In en, this message translates to:
  /// **'Save my village location'**
  String get consentLocation;

  /// No description provided for @iAgree.
  ///
  /// In en, this message translates to:
  /// **'Yes, I agree'**
  String get iAgree;

  /// No description provided for @sayYesToAgree.
  ///
  /// In en, this message translates to:
  /// **'Or say “yes” to agree'**
  String get sayYesToAgree;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get profileTitle;

  /// No description provided for @askName.
  ///
  /// In en, this message translates to:
  /// **'What is your name?'**
  String get askName;

  /// No description provided for @askVillage.
  ///
  /// In en, this message translates to:
  /// **'Which village or town are you from?'**
  String get askVillage;

  /// No description provided for @askState.
  ///
  /// In en, this message translates to:
  /// **'Which district and state?'**
  String get askState;

  /// No description provided for @askCraft.
  ///
  /// In en, this message translates to:
  /// **'What craft do you make?'**
  String get askCraft;

  /// No description provided for @askYears.
  ///
  /// In en, this message translates to:
  /// **'For how many years have you done this craft?'**
  String get askYears;

  /// No description provided for @askStory.
  ///
  /// In en, this message translates to:
  /// **'Tell us your story — how did you learn this craft?'**
  String get askStory;

  /// No description provided for @askPehchan.
  ///
  /// In en, this message translates to:
  /// **'If you have a Pehchan artisan card, say its number. Otherwise tap Skip.'**
  String get askPehchan;

  /// No description provided for @tapMicToAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic and answer'**
  String get tapMicToAnswer;

  /// No description provided for @weHeard.
  ///
  /// In en, this message translates to:
  /// **'We heard:'**
  String get weHeard;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Your profile is saved'**
  String get profileSaved;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste, {name}'**
  String greeting(String name);

  /// No description provided for @tileAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get tileAddProduct;

  /// No description provided for @tileMyProducts.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get tileMyProducts;

  /// No description provided for @tileOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get tileOrders;

  /// No description provided for @tileEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get tileEarnings;

  /// No description provided for @tileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get tileHelp;

  /// No description provided for @earningsSummary.
  ///
  /// In en, this message translates to:
  /// **'This month you earned {amount} from {count} orders'**
  String earningsSummary(String amount, int count);

  /// No description provided for @addProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a Product'**
  String get addProductTitle;

  /// No description provided for @speakOwnLanguage.
  ///
  /// In en, this message translates to:
  /// **'Speak in your own language'**
  String get speakOwnLanguage;

  /// No description provided for @listeningIn.
  ///
  /// In en, this message translates to:
  /// **'Listening in {language}…'**
  String listeningIn(String language);

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak, or hold to talk'**
  String get tapToSpeak;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop'**
  String get stopRecording;

  /// No description provided for @photoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Photo captured — enhancing background & light automatically'**
  String get photoCaptured;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @addMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'Add more photos'**
  String get addMorePhotos;

  /// No description provided for @makeListing.
  ///
  /// In en, this message translates to:
  /// **'Make my listing'**
  String get makeListing;

  /// No description provided for @hintTooDark.
  ///
  /// In en, this message translates to:
  /// **'It is a little dark — move towards the light if you can'**
  String get hintTooDark;

  /// No description provided for @hintTooBright.
  ///
  /// In en, this message translates to:
  /// **'Too much light — move to a little shade'**
  String get hintTooBright;

  /// No description provided for @hintMoveCloser.
  ///
  /// In en, this message translates to:
  /// **'Move a little closer'**
  String get hintMoveCloser;

  /// No description provided for @hintBlurry.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone steady'**
  String get hintBlurry;

  /// No description provided for @anyBackground.
  ///
  /// In en, this message translates to:
  /// **'Any light, any background is fine'**
  String get anyBackground;

  /// No description provided for @upTo60s.
  ///
  /// In en, this message translates to:
  /// **'Up to 60 seconds'**
  String get upTo60s;

  /// No description provided for @aiBuilding.
  ///
  /// In en, this message translates to:
  /// **'AI is building your listing'**
  String get aiBuilding;

  /// No description provided for @stepAsr.
  ///
  /// In en, this message translates to:
  /// **'Understanding your voice'**
  String get stepAsr;

  /// No description provided for @stepNlu.
  ///
  /// In en, this message translates to:
  /// **'Finding the details'**
  String get stepNlu;

  /// No description provided for @stepListing.
  ///
  /// In en, this message translates to:
  /// **'Writing title and description'**
  String get stepListing;

  /// No description provided for @stepTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translating for buyers'**
  String get stepTranslation;

  /// No description provided for @stepImage.
  ///
  /// In en, this message translates to:
  /// **'Cleaning up your photo'**
  String get stepImage;

  /// No description provided for @stepPrice.
  ///
  /// In en, this message translates to:
  /// **'Working out a fair price'**
  String get stepPrice;

  /// No description provided for @stepCertificate.
  ///
  /// In en, this message translates to:
  /// **'Preparing your certificate'**
  String get stepCertificate;

  /// No description provided for @quickQuestions.
  ///
  /// In en, this message translates to:
  /// **'A few quick questions'**
  String get quickQuestions;

  /// No description provided for @answerBySpeaking.
  ///
  /// In en, this message translates to:
  /// **'Answer by speaking'**
  String get answerBySpeaking;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Check and approve'**
  String get reviewTitle;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @changePrice.
  ///
  /// In en, this message translates to:
  /// **'Change price'**
  String get changePrice;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get retakePhoto;

  /// No description provided for @reRecord.
  ///
  /// In en, this message translates to:
  /// **'Re-record'**
  String get reRecord;

  /// No description provided for @sayNewPrice.
  ///
  /// In en, this message translates to:
  /// **'Say the new price'**
  String get sayNewPrice;

  /// No description provided for @youGet.
  ///
  /// In en, this message translates to:
  /// **'You get {amount} ({pct}%)'**
  String youGet(String amount, String pct);

  /// No description provided for @marketRate.
  ///
  /// In en, this message translates to:
  /// **'Market rate {low} – {high}'**
  String marketRate(String low, String high);

  /// No description provided for @fairPrice.
  ///
  /// In en, this message translates to:
  /// **'Fair price'**
  String get fairPrice;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @priceSpoken.
  ///
  /// In en, this message translates to:
  /// **'Price {price}. You get {amount}.'**
  String priceSpoken(String price, String amount);

  /// No description provided for @belowFairWage.
  ///
  /// In en, this message translates to:
  /// **'This is below a fair wage for your time'**
  String get belowFairWage;

  /// No description provided for @isLive.
  ///
  /// In en, this message translates to:
  /// **'Your product is live!'**
  String get isLive;

  /// No description provided for @onOndc.
  ///
  /// In en, this message translates to:
  /// **'Also listed on the ONDC network'**
  String get onOndc;

  /// No description provided for @certificateReady.
  ///
  /// In en, this message translates to:
  /// **'Your certificate is ready'**
  String get certificateReady;

  /// No description provided for @statusQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get statusQueued;

  /// No description provided for @statusUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get statusUploading;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get statusNeedsReview;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to approve'**
  String get statusReady;

  /// No description provided for @statusLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get statusLive;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get statusFailed;

  /// No description provided for @statusUnpublished.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get statusUnpublished;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet. Tap Add Product.'**
  String get noProducts;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get newOrder;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @markPacked.
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get markPacked;

  /// No description provided for @markShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get markShipped;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrders;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get orderPlaced;

  /// No description provided for @orderAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get orderAccepted;

  /// No description provided for @orderPacked.
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get orderPacked;

  /// No description provided for @orderShipped.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get orderShipped;

  /// No description provided for @orderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderDelivered;

  /// No description provided for @orderDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get orderDeclined;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderCancelled;

  /// No description provided for @gross.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get gross;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Platform fee'**
  String get commission;

  /// No description provided for @logistics.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get logistics;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'You received'**
  String get net;

  /// No description provided for @everyRupee.
  ///
  /// In en, this message translates to:
  /// **'Every rupee explained'**
  String get everyRupee;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @callHelpline.
  ///
  /// In en, this message translates to:
  /// **'Call the helpline'**
  String get callHelpline;

  /// No description provided for @requestCallback.
  ///
  /// In en, this message translates to:
  /// **'Ask a helper to call me'**
  String get requestCallback;

  /// No description provided for @callbackRequested.
  ///
  /// In en, this message translates to:
  /// **'A helper will call you soon'**
  String get callbackRequested;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How ShilpSetu works'**
  String get howToUse;

  /// No description provided for @fiveSteps.
  ///
  /// In en, this message translates to:
  /// **'Speak · Snap · AI builds it · You approve · Goes live'**
  String get fiveSteps;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search crafts, states, artisans'**
  String get searchHint;

  /// No description provided for @freshFromLoom.
  ///
  /// In en, this message translates to:
  /// **'Fresh from the loom & wheel'**
  String get freshFromLoom;

  /// No description provided for @byCraft.
  ///
  /// In en, this message translates to:
  /// **'By craft'**
  String get byCraft;

  /// No description provided for @byState.
  ///
  /// In en, this message translates to:
  /// **'By state & cluster'**
  String get byState;

  /// No description provided for @womenLed.
  ///
  /// In en, this message translates to:
  /// **'Women-led collectives'**
  String get womenLed;

  /// No description provided for @giTagged.
  ///
  /// In en, this message translates to:
  /// **'GI-tagged crafts'**
  String get giTagged;

  /// No description provided for @nearYou.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get nearYou;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @verifiedOnly.
  ///
  /// In en, this message translates to:
  /// **'Verified artisans only'**
  String get verifiedOnly;

  /// No description provided for @giOnly.
  ///
  /// In en, this message translates to:
  /// **'GI-tagged only'**
  String get giOnly;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortBy;

  /// No description provided for @sortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Best match'**
  String get sortRelevance;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get sortPriceHigh;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'{count} crafts'**
  String results(int count);

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @scanCertificate.
  ///
  /// In en, this message translates to:
  /// **'Scan for Artisan Provenance Certificate'**
  String get scanCertificate;

  /// No description provided for @certificateSub.
  ///
  /// In en, this message translates to:
  /// **'Materials, story & fair-price basis'**
  String get certificateSub;

  /// No description provided for @howPriceBuilt.
  ///
  /// In en, this message translates to:
  /// **'How this price is built'**
  String get howPriceBuilt;

  /// No description provided for @goesToArtisan.
  ///
  /// In en, this message translates to:
  /// **'{amount} of this goes directly to the artisan ({pct}%)'**
  String goesToArtisan(String amount, String pct);

  /// No description provided for @meetArtisan.
  ///
  /// In en, this message translates to:
  /// **'Meet the artisan'**
  String get meetArtisan;

  /// No description provided for @hearVoice.
  ///
  /// In en, this message translates to:
  /// **'Hear their voice'**
  String get hearVoice;

  /// No description provided for @moreFromArtisan.
  ///
  /// In en, this message translates to:
  /// **'More from this artisan'**
  String get moreFromArtisan;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'({count} reviews)'**
  String reviewsCount(int count);

  /// No description provided for @verifiedArtisan.
  ///
  /// In en, this message translates to:
  /// **'Verified Artisan'**
  String get verifiedArtisan;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @payUpi.
  ///
  /// In en, this message translates to:
  /// **'Pay by UPI'**
  String get payUpi;

  /// No description provided for @cod.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get cod;

  /// No description provided for @deliveryIn.
  ///
  /// In en, this message translates to:
  /// **'Delivery in about {days} days'**
  String deliveryIn(int days);

  /// No description provided for @shippingIncluded.
  ///
  /// In en, this message translates to:
  /// **'Shipping & packing are included in the fair price'**
  String get shippingIncluded;

  /// No description provided for @orderPlacedThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your order is placed.'**
  String get orderPlacedThanks;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get myOrders;

  /// No description provided for @rateCraft.
  ///
  /// In en, this message translates to:
  /// **'Rate this craft'**
  String get rateCraft;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan a certificate QR'**
  String get scanQr;

  /// No description provided for @certValid.
  ///
  /// In en, this message translates to:
  /// **'Genuine — verified by ShilpSetu'**
  String get certValid;

  /// No description provided for @certInvalid.
  ///
  /// In en, this message translates to:
  /// **'Not valid'**
  String get certInvalid;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get pincode;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @kioskTitle.
  ///
  /// In en, this message translates to:
  /// **'Kiosk'**
  String get kioskTitle;

  /// No description provided for @myArtisans.
  ///
  /// In en, this message translates to:
  /// **'Artisans'**
  String get myArtisans;

  /// No description provided for @onboardArtisan.
  ///
  /// In en, this message translates to:
  /// **'Onboard an artisan'**
  String get onboardArtisan;

  /// No description provided for @captureFor.
  ///
  /// In en, this message translates to:
  /// **'Capture for {name}'**
  String captureFor(String name);

  /// No description provided for @batchMode.
  ///
  /// In en, this message translates to:
  /// **'Exhibition batch mode'**
  String get batchMode;

  /// No description provided for @printTags.
  ///
  /// In en, this message translates to:
  /// **'Print certificate tags'**
  String get printTags;

  /// No description provided for @syncAll.
  ///
  /// In en, this message translates to:
  /// **'Sync all'**
  String get syncAll;

  /// No description provided for @attestation.
  ///
  /// In en, this message translates to:
  /// **'I checked their identity and recorded their spoken consent'**
  String get attestation;

  /// No description provided for @recordConsent.
  ///
  /// In en, this message translates to:
  /// **'Record the artisan saying they agree'**
  String get recordConsent;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @lowBandwidth.
  ///
  /// In en, this message translates to:
  /// **'Low-data mode'**
  String get lowBandwidth;

  /// No description provided for @switchRole.
  ///
  /// In en, this message translates to:
  /// **'Switch mode'**
  String get switchRole;

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String productsCount(int count);

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender (optional, self-declared)'**
  String get gender;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @genderPreferNot.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderPreferNot;

  /// No description provided for @typeInstead.
  ///
  /// In en, this message translates to:
  /// **'Or type the answer'**
  String get typeInstead;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverAddress;

  /// No description provided for @serverAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Only change this if a helper asks you to'**
  String get serverAddressHint;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get productDetails;

  /// No description provided for @aboutArtForm.
  ///
  /// In en, this message translates to:
  /// **'About this art form'**
  String get aboutArtForm;

  /// No description provided for @howItsMade.
  ///
  /// In en, this message translates to:
  /// **'How it\'s made'**
  String get howItsMade;

  /// No description provided for @didYouKnow.
  ///
  /// In en, this message translates to:
  /// **'Did you know?'**
  String get didYouKnow;

  /// No description provided for @yearsOfPractice.
  ///
  /// In en, this message translates to:
  /// **'{count} years of practice'**
  String yearsOfPractice(int count);

  /// No description provided for @photoCredits.
  ///
  /// In en, this message translates to:
  /// **'Photo credits'**
  String get photoCredits;

  /// No description provided for @photoCreditsSub.
  ///
  /// In en, this message translates to:
  /// **'Real craft photos from Wikimedia Commons, used under their licences'**
  String get photoCreditsSub;

  /// No description provided for @askShilpi.
  ///
  /// In en, this message translates to:
  /// **'Ask Shilpi'**
  String get askShilpi;

  /// No description provided for @assistantName.
  ///
  /// In en, this message translates to:
  /// **'Shilpi'**
  String get assistantName;

  /// No description provided for @assistantTagline.
  ///
  /// In en, this message translates to:
  /// **'Your ShilpSetu helper'**
  String get assistantTagline;

  /// No description provided for @assistantThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get assistantThinking;

  /// No description provided for @askAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything'**
  String get askAnything;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get dayStreak;

  /// No description provided for @todaysGoal.
  ///
  /// In en, this message translates to:
  /// **'today\'s goal'**
  String get todaysGoal;

  /// No description provided for @craftOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Craft of the day'**
  String get craftOfTheDay;

  /// No description provided for @exploreCraft.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreCraft;

  /// No description provided for @celebrateLive.
  ///
  /// In en, this message translates to:
  /// **'Your craft is live!'**
  String get celebrateLive;

  /// No description provided for @micPermission.
  ///
  /// In en, this message translates to:
  /// **'Please allow the microphone: Settings → Apps → ShilpSetu → Permissions → Microphone.'**
  String get micPermission;

  /// No description provided for @micUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This phone has no voice typing. Turn on Google voice typing (Speech Services by Google), or type instead.'**
  String get micUnavailable;

  /// No description provided for @micInsecure.
  ///
  /// In en, this message translates to:
  /// **'The microphone works only in the ShilpSetu app or on a secure https link. Please use the app.'**
  String get micInsecure;

  /// No description provided for @micNoSpeech.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t hear you. Tap the mic and speak a little louder.'**
  String get micNoSpeech;

  /// No description provided for @micNetwork.
  ///
  /// In en, this message translates to:
  /// **'Voice typing needs internet on this phone. Please check your connection.'**
  String get micNetwork;

  /// No description provided for @pressBackAgain.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackAgain;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'as',
    'bn',
    'en',
    'gu',
    'hi',
    'kn',
    'ml',
    'mr',
    'or',
    'pa',
    'sat',
    'ta',
    'te',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'as':
      return L10nAs();
    case 'bn':
      return L10nBn();
    case 'en':
      return L10nEn();
    case 'gu':
      return L10nGu();
    case 'hi':
      return L10nHi();
    case 'kn':
      return L10nKn();
    case 'ml':
      return L10nMl();
    case 'mr':
      return L10nMr();
    case 'or':
      return L10nOr();
    case 'pa':
      return L10nPa();
    case 'sat':
      return L10nSat();
    case 'ta':
      return L10nTa();
    case 'te':
      return L10nTe();
    case 'ur':
      return L10nUr();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
