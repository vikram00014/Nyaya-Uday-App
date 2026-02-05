import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nyaya-Uday'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Nyaya-Uday'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Path to the Bench Starts Here'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select Your State'**
  String get selectState;

  /// No description provided for @selectStateHint.
  ///
  /// In en, this message translates to:
  /// **'Choose your home state'**
  String get selectStateHint;

  /// No description provided for @selectEducation.
  ///
  /// In en, this message translates to:
  /// **'Your Education Level'**
  String get selectEducation;

  /// No description provided for @class10.
  ///
  /// In en, this message translates to:
  /// **'Class 10th'**
  String get class10;

  /// No description provided for @class12.
  ///
  /// In en, this message translates to:
  /// **'Class 12th'**
  String get class12;

  /// No description provided for @graduate.
  ///
  /// In en, this message translates to:
  /// **'Graduate'**
  String get graduate;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @yourRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Your Judicial Career Roadmap'**
  String get yourRoadmap;

  /// No description provided for @juniorJudge.
  ///
  /// In en, this message translates to:
  /// **'Junior Judge Simulation'**
  String get juniorJudge;

  /// No description provided for @trySimulation.
  ///
  /// In en, this message translates to:
  /// **'Experience Thinking Like a Judge'**
  String get trySimulation;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @whatIsJudge.
  ///
  /// In en, this message translates to:
  /// **'What Does a Judge Do?'**
  String get whatIsJudge;

  /// No description provided for @judgeRole.
  ///
  /// In en, this message translates to:
  /// **'A judge listens to both sides, examines evidence, and makes fair decisions based on law.'**
  String get judgeRole;

  /// No description provided for @aptitudeScore.
  ///
  /// In en, this message translates to:
  /// **'Judicial Aptitude Score'**
  String get aptitudeScore;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @caseScenarios.
  ///
  /// In en, this message translates to:
  /// **'Case Scenarios'**
  String get caseScenarios;

  /// No description provided for @solveCases.
  ///
  /// In en, this message translates to:
  /// **'Solve cases and earn points'**
  String get solveCases;

  /// No description provided for @makeJudgment.
  ///
  /// In en, this message translates to:
  /// **'Make Your Judgment'**
  String get makeJudgment;

  /// No description provided for @viewExplanation.
  ///
  /// In en, this message translates to:
  /// **'View Explanation'**
  String get viewExplanation;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @fairness.
  ///
  /// In en, this message translates to:
  /// **'Fairness'**
  String get fairness;

  /// No description provided for @evidenceBased.
  ///
  /// In en, this message translates to:
  /// **'Evidence-Based'**
  String get evidenceBased;

  /// No description provided for @biasAvoidance.
  ///
  /// In en, this message translates to:
  /// **'Bias Avoidance'**
  String get biasAvoidance;

  /// No description provided for @nextCase.
  ///
  /// In en, this message translates to:
  /// **'Next Case'**
  String get nextCase;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

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
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @roadmapStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Complete Current Education'**
  String get roadmapStep1Title;

  /// No description provided for @roadmapStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Law Entrance Exam'**
  String get roadmapStep2Title;

  /// No description provided for @roadmapStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Law Degree'**
  String get roadmapStep3Title;

  /// No description provided for @roadmapStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Judicial Services Exam'**
  String get roadmapStep4Title;

  /// No description provided for @roadmapStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Become a Judge'**
  String get roadmapStep5Title;

  /// No description provided for @yearsToComplete.
  ///
  /// In en, this message translates to:
  /// **'{years} years'**
  String yearsToComplete(int years);

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a question...'**
  String get askQuestion;

  /// No description provided for @voiceAssistant.
  ///
  /// In en, this message translates to:
  /// **'Voice Assistant'**
  String get voiceAssistant;

  /// No description provided for @legalLiteracy.
  ///
  /// In en, this message translates to:
  /// **'Legal Literacy'**
  String get legalLiteracy;

  /// No description provided for @shortModules.
  ///
  /// In en, this message translates to:
  /// **'Short 60-90 second modules'**
  String get shortModules;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @totalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get totalScore;

  /// No description provided for @casesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Cases Completed'**
  String get casesCompleted;

  /// No description provided for @stateRank.
  ///
  /// In en, this message translates to:
  /// **'State Rank'**
  String get stateRank;

  /// No description provided for @nationalRank.
  ///
  /// In en, this message translates to:
  /// **'National Rank'**
  String get nationalRank;
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
      <String>['en', 'hi'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
