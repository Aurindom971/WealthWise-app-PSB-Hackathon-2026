import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('en'),
    Locale('hi'),
    Locale('pa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'WealthWise'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account securely'**
  String get signInTitle;

  /// No description provided for @customerId.
  ///
  /// In en, this message translates to:
  /// **'Customer ID'**
  String get customerId;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @accountPassword.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT PASSWORD'**
  String get accountPassword;

  /// No description provided for @signInSecurely.
  ///
  /// In en, this message translates to:
  /// **'Sign In Securely'**
  String get signInSecurely;

  /// No description provided for @signInFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Fingerprint'**
  String get signInFingerprint;

  /// No description provided for @forgotDetails.
  ///
  /// In en, this message translates to:
  /// **'Forgot details? Contact Bank'**
  String get forgotDetails;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get support;

  /// No description provided for @talkToSage.
  ///
  /// In en, this message translates to:
  /// **'Talk to SAGE'**
  String get talkToSage;

  /// No description provided for @findAtm.
  ///
  /// In en, this message translates to:
  /// **'Find ATM'**
  String get findAtm;

  /// No description provided for @helpDesk.
  ///
  /// In en, this message translates to:
  /// **'Help Desk'**
  String get helpDesk;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @guestModeBanner.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode — Sign in to access personalized financial insights.'**
  String get guestModeBanner;

  /// No description provided for @guestModeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m SAGE.\n\nI can help you with:\n• Account opening\n• Banking services\n• KYC\n• Fixed Deposits\n• Interest rates\n• Branch information\n• ATM services\n• UPI basics\n• Debit/Credit cards\n• Loans (general)\n• Security awareness\n• RBI guidelines\n• Banking FAQs\n\nPlease sign in for investment advice, account details, transactions, and personalized options.'**
  String get guestModeGreeting;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @investments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investments;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @cardsAndForex.
  ///
  /// In en, this message translates to:
  /// **'Cards & Forex'**
  String get cardsAndForex;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @loans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loans;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @insurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// No description provided for @billsAndRecharge.
  ///
  /// In en, this message translates to:
  /// **'Bills & Recharge'**
  String get billsAndRecharge;

  /// No description provided for @sendTransfer.
  ///
  /// In en, this message translates to:
  /// **'Send / Transfer'**
  String get sendTransfer;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @punjabi.
  ///
  /// In en, this message translates to:
  /// **'ਪੰਜਾਬੀ'**
  String get punjabi;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid Credentials'**
  String get invalidCredentials;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Password'**
  String get incorrectPassword;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please Wait'**
  String get pleaseWait;

  /// No description provided for @biometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication Failed'**
  String get biometricFailed;

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get otpInvalid;

  /// No description provided for @myAccounts.
  ///
  /// In en, this message translates to:
  /// **'My Accounts'**
  String get myAccounts;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'TOTAL BALANCE'**
  String get totalBalance;

  /// No description provided for @pullDownNext.
  ///
  /// In en, this message translates to:
  /// **'pull down to reveal next'**
  String get pullDownNext;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'NEED HELP?'**
  String get needHelp;

  /// No description provided for @sageTitle.
  ///
  /// In en, this message translates to:
  /// **'SAGE'**
  String get sageTitle;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get quickActions;

  /// No description provided for @sendMoney.
  ///
  /// In en, this message translates to:
  /// **'Send Money'**
  String get sendMoney;

  /// No description provided for @payUpi.
  ///
  /// In en, this message translates to:
  /// **'Pay UPI'**
  String get payUpi;

  /// No description provided for @smartLock.
  ///
  /// In en, this message translates to:
  /// **'Smart Lock'**
  String get smartLock;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @securityActivity.
  ///
  /// In en, this message translates to:
  /// **'Security Activity'**
  String get securityActivity;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @bankingHelp.
  ///
  /// In en, this message translates to:
  /// **'Banking Help'**
  String get bankingHelp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your secure session?'**
  String get logoutConfirm;

  /// No description provided for @kycVerification.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification (RBI Mandate)'**
  String get kycVerification;

  /// No description provided for @relationshipManager.
  ///
  /// In en, this message translates to:
  /// **'Relationship manager'**
  String get relationshipManager;

  /// No description provided for @personalFraudReport.
  ///
  /// In en, this message translates to:
  /// **'Personal Fraud Risk Report'**
  String get personalFraudReport;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get accountDetails;

  /// No description provided for @yourRequests.
  ///
  /// In en, this message translates to:
  /// **'Your requests'**
  String get yourRequests;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Condition'**
  String get termsConditions;

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get whatsNew;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version: 29.8.7'**
  String get appVersion;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @searchHere.
  ///
  /// In en, this message translates to:
  /// **'Search here...'**
  String get searchHere;

  /// No description provided for @orderChequeBook.
  ///
  /// In en, this message translates to:
  /// **'Order cheque book'**
  String get orderChequeBook;

  /// No description provided for @accountsServices.
  ///
  /// In en, this message translates to:
  /// **'Accounts services'**
  String get accountsServices;

  /// No description provided for @manageAutopay.
  ///
  /// In en, this message translates to:
  /// **'Manage autopay'**
  String get manageAutopay;

  /// No description provided for @cardsServices.
  ///
  /// In en, this message translates to:
  /// **'Cards services'**
  String get cardsServices;

  /// No description provided for @manageDeliverables.
  ///
  /// In en, this message translates to:
  /// **'Manage deliverables'**
  String get manageDeliverables;

  /// No description provided for @pinPasswords.
  ///
  /// In en, this message translates to:
  /// **'Pin and passwords management'**
  String get pinPasswords;

  /// No description provided for @reportSuspicious.
  ///
  /// In en, this message translates to:
  /// **'Report suspicious activities'**
  String get reportSuspicious;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'SAVINGS'**
  String get savings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'pa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'pa':
      return AppLocalizationsPa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
