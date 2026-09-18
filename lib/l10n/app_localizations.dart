import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'API Scout'**
  String get appTitle;

  /// App display name
  ///
  /// In en, this message translates to:
  /// **'Reqistry'**
  String get appName;

  /// App description for sharing
  ///
  /// In en, this message translates to:
  /// **'API Scout - Discover and explore APIs'**
  String get appDescription;

  /// Bottom navigation tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation tab label
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// Bottom navigation tab label
  ///
  /// In en, this message translates to:
  /// **'Intelligence'**
  String get navIntelligence;

  /// Bottom navigation tab label
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// Bottom navigation tab label
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get navYou;

  /// Discover tab title in app bar
  ///
  /// In en, this message translates to:
  /// **'DISCOVER'**
  String get tabDiscover;

  /// Search tab title
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get tabSearch;

  /// Bookmarks/favorites tab title
  ///
  /// In en, this message translates to:
  /// **'BOOKMARKS'**
  String get tabBookmarks;

  /// Intelligence tab title
  ///
  /// In en, this message translates to:
  /// **'INTELLIGENCE'**
  String get tabIntelligence;

  /// Account settings tab title
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get tabAccount;

  /// App settings tab title
  ///
  /// In en, this message translates to:
  /// **'APP SETTINGS'**
  String get tabAppSettings;

  /// Submit API tab title
  ///
  /// In en, this message translates to:
  /// **'SUBMIT API'**
  String get tabSubmitApi;

  /// Profile section header
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get tabProfile;

  /// User profile tab title
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get tabYou;

  /// App settings section header
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get sectionPreferences;

  /// Data management section header
  ///
  /// In en, this message translates to:
  /// **'DATA MANAGEMENT'**
  String get sectionDataManagement;

  /// My section header in settings
  ///
  /// In en, this message translates to:
  /// **'MY'**
  String get sectionMy;

  /// Manage section header
  ///
  /// In en, this message translates to:
  /// **'MANAGE'**
  String get sectionManage;

  /// Info section header
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get sectionInfo;

  /// Account info section header
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT INFORMATION'**
  String get sectionAccountInformation;

  /// Link account section header
  ///
  /// In en, this message translates to:
  /// **'LINK YOUR ACCOUNT'**
  String get sectionLinkYourAccount;

  /// User activity stats section
  ///
  /// In en, this message translates to:
  /// **'YOUR STATS'**
  String get sectionYourStats;

  /// Continue work section
  ///
  /// In en, this message translates to:
  /// **'CONTINUE YOUR WORK'**
  String get sectionContinueYourWork;

  /// Recommended APIs section
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED FOR YOU'**
  String get sectionRecommendedForYou;

  /// Latest added APIs section
  ///
  /// In en, this message translates to:
  /// **'LATEST ADDED'**
  String get sectionLatestAdded;

  /// Quick facts section
  ///
  /// In en, this message translates to:
  /// **'QUICK FACTS'**
  String get sectionQuickFacts;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get sectionAbout;

  /// Requirements section
  ///
  /// In en, this message translates to:
  /// **'REQUIREMENTS & LIMITATIONS'**
  String get sectionRequirementsAndLimitations;

  /// Data confidence section
  ///
  /// In en, this message translates to:
  /// **'DATA CONFIDENCE'**
  String get sectionDataConfidence;

  /// Similar APIs section
  ///
  /// In en, this message translates to:
  /// **'SIMILAR APIs'**
  String get sectionSimilarApis;

  /// Browse by category section
  ///
  /// In en, this message translates to:
  /// **'BROWSE BY CATEGORY'**
  String get sectionBrowseByCategory;

  /// Registry intelligence header
  ///
  /// In en, this message translates to:
  /// **'REQISTRY INTELLIGENCE'**
  String get sectionRegistryIntelligence;

  /// Upcoming features section
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get sectionUpcoming;

  /// Add to project section header
  ///
  /// In en, this message translates to:
  /// **'ADD TO PROJECT'**
  String get sectionAddToProject;

  /// Recently used projects label
  ///
  /// In en, this message translates to:
  /// **'Recently used'**
  String get sectionRecentlyUsed;

  /// All projects label
  ///
  /// In en, this message translates to:
  /// **'All projects'**
  String get sectionAllProjects;

  /// All projects view title
  ///
  /// In en, this message translates to:
  /// **'ALL PROJECTS'**
  String get sectionAllProjectsView;

  /// Filters button label
  ///
  /// In en, this message translates to:
  /// **'FILTERS'**
  String get sectionFilters;

  /// Retry action button
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get actionRetry;

  /// Save action button
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get actionSave;

  /// Cancel action button
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get actionCancel;

  /// Confirm action button
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get actionConfirm;

  /// Delete action button
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get actionDelete;

  /// Continue action button
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get actionContinue;

  /// Submit action button
  ///
  /// In en, this message translates to:
  /// **'SUBMIT'**
  String get actionSubmit;

  /// Create action button
  ///
  /// In en, this message translates to:
  /// **'CREATE'**
  String get actionCreate;

  /// Modify action button
  ///
  /// In en, this message translates to:
  /// **'MODIFY'**
  String get actionModify;

  /// Sign out action button
  ///
  /// In en, this message translates to:
  /// **'SIGN OUT'**
  String get actionSignOut;

  /// Delete account button
  ///
  /// In en, this message translates to:
  /// **'DELETE ACCOUNT'**
  String get actionDeleteAccount;

  /// Apply filters button
  ///
  /// In en, this message translates to:
  /// **'APPLY FILTERS & SEARCH'**
  String get actionApplyFiltersAndSearch;

  /// Reset all filters button
  ///
  /// In en, this message translates to:
  /// **'RESET ALL'**
  String get actionResetAll;

  /// Load more results button
  ///
  /// In en, this message translates to:
  /// **'LOAD MORE'**
  String get actionLoadMore;

  /// Remove response time limit
  ///
  /// In en, this message translates to:
  /// **'REMOVE LIMIT'**
  String get actionRemoveLimit;

  /// Go home button on error page
  ///
  /// In en, this message translates to:
  /// **'GO HOME'**
  String get actionGoHome;

  /// Refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// View all button
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get actionViewAll;

  /// Add to project action
  ///
  /// In en, this message translates to:
  /// **'Add to project'**
  String get actionAddToProject;

  /// Share action
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// Open homepage action
  ///
  /// In en, this message translates to:
  /// **'Open homepage'**
  String get actionOpenHomepage;

  /// Report problem action
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get actionReportAProblem;

  /// Submit report button
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get actionSubmitReport;

  /// Sort action label
  ///
  /// In en, this message translates to:
  /// **'SORT'**
  String get actionSort;

  /// Rename context menu item
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// Delete context menu item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDeleteProject;

  /// Link account dialog button
  ///
  /// In en, this message translates to:
  /// **'LINK ACCOUNT'**
  String get actionLinkAccount;

  /// Create project action
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get actionCreateProject;

  /// Open documentation button
  ///
  /// In en, this message translates to:
  /// **'Open docs'**
  String get actionOpenDocs;

  /// Open website button
  ///
  /// In en, this message translates to:
  /// **'Open website'**
  String get actionOpenWebsite;

  /// Search input hint text
  ///
  /// In en, this message translates to:
  /// **'Search APIs (e.g., weather, payment...)'**
  String get formSearchHint;

  /// Category filter hint
  ///
  /// In en, this message translates to:
  /// **'Filter categories...'**
  String get formFilterCategoriesHint;

  /// Name input hint text
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get formYourName;

  /// Display name label
  ///
  /// In en, this message translates to:
  /// **'DISPLAY NAME'**
  String get formDisplayName;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get formEmail;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get formPassword;

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get formTitle;

  /// Project name hint
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get formProjectName;

  /// API name field label
  ///
  /// In en, this message translates to:
  /// **'API NAME'**
  String get formApiName;

  /// API link field label
  ///
  /// In en, this message translates to:
  /// **'API LINK (HTTPS://...)'**
  String get formApiLink;

  /// Optional note label
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get formOptionalNote;

  /// Report issue question
  ///
  /// In en, this message translates to:
  /// **'WHAT IS INCORRECT?'**
  String get formWhatIsIncorrect;

  /// Icon field label
  ///
  /// In en, this message translates to:
  /// **'ICON'**
  String get formIcon;

  /// Project title input label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get formProjectTitleLabel;

  /// Sort option: name ascending
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get sortNameAsc;

  /// Sort option: name descending
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get sortNameDesc;

  /// Sort option: fastest first
  ///
  /// In en, this message translates to:
  /// **'Fastest First'**
  String get sortFastestFirst;

  /// Sort option: slowest first
  ///
  /// In en, this message translates to:
  /// **'Slowest First'**
  String get sortSlowestFirst;

  /// Sort option: category ascending
  ///
  /// In en, this message translates to:
  /// **'Category (A-Z)'**
  String get sortCategoryAsc;

  /// Advanced filters sheet title
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get filterAdvancedFilters;

  /// Categories filter section
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get filterCategories;

  /// Pricing filter section
  ///
  /// In en, this message translates to:
  /// **'PRICING'**
  String get filterPricing;

  /// Authentication filter section
  ///
  /// In en, this message translates to:
  /// **'AUTHENTICATION'**
  String get filterAuthentication;

  /// API type filter section
  ///
  /// In en, this message translates to:
  /// **'API TYPE'**
  String get filterApiType;

  /// HTTPS support filter
  ///
  /// In en, this message translates to:
  /// **'HTTPS SUPPORT'**
  String get filterHttpsSupport;

  /// CORS support filter
  ///
  /// In en, this message translates to:
  /// **'CORS SUPPORT'**
  String get filterCorsSupport;

  /// API status filter
  ///
  /// In en, this message translates to:
  /// **'API STATUS'**
  String get filterApiStatus;

  /// Max response time filter
  ///
  /// In en, this message translates to:
  /// **'MAX RESPONSE TIME'**
  String get filterMaxResponseTime;

  /// HTTPS only filter option
  ///
  /// In en, this message translates to:
  /// **'HTTPS ONLY'**
  String get filterHttpsOnly;

  /// HTTP only filter option
  ///
  /// In en, this message translates to:
  /// **'HTTP ONLY'**
  String get filterHttpOnly;

  /// Working only filter option
  ///
  /// In en, this message translates to:
  /// **'WORKING ONLY'**
  String get filterWorkingOnly;

  /// Down only filter option
  ///
  /// In en, this message translates to:
  /// **'DOWN ONLY'**
  String get filterDownOnly;

  /// No auth filter option
  ///
  /// In en, this message translates to:
  /// **'NO AUTH'**
  String get filterNoAuth;

  /// Enabled filter option
  ///
  /// In en, this message translates to:
  /// **'ENABLED'**
  String get filterEnabled;

  /// Disabled filter option
  ///
  /// In en, this message translates to:
  /// **'DISABLED'**
  String get filterDisabled;

  /// Unknown filter option
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get filterUnknown;

  /// No limit label for response time
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// Search results count
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCount(int count);

  /// Generic loading state
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get stateLoading;

  /// Syncing overlay label
  ///
  /// In en, this message translates to:
  /// **'SYNCING'**
  String get stateSyncing;

  /// Loading categories message
  ///
  /// In en, this message translates to:
  /// **'Loading categories'**
  String get stateLoadingCategories;

  /// Loading more results
  ///
  /// In en, this message translates to:
  /// **'Loading more'**
  String get stateLoadingMore;

  /// Loading project APIs
  ///
  /// In en, this message translates to:
  /// **'Loading project APIs'**
  String get stateLoadingProjectApis;

  /// Loading projects message
  ///
  /// In en, this message translates to:
  /// **'Loading projects'**
  String get stateLoadingProjects;

  /// Loading stats message
  ///
  /// In en, this message translates to:
  /// **'Loading stats'**
  String get stateLoadingStats;

  /// Loading with dynamic title
  ///
  /// In en, this message translates to:
  /// **'Loading {title}'**
  String stateLoadingTitle(String title);

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get stateNothingHereYet;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'Check back later or pull to refresh.'**
  String get stateCheckBackLater;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get stateError;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get stateSomethingWentWrong;

  /// Category load error
  ///
  /// In en, this message translates to:
  /// **'Could not load categories'**
  String get stateCouldNotLoadCategories;

  /// Empty browse state
  ///
  /// In en, this message translates to:
  /// **'Nothing to browse yet'**
  String get stateNothingToBrowseYet;

  /// API load error
  ///
  /// In en, this message translates to:
  /// **'Could not load APIs'**
  String get stateCouldNotLoadApis;

  /// No APIs empty state
  ///
  /// In en, this message translates to:
  /// **'No APIs'**
  String get stateNoApis;

  /// Pull to refresh message
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh and try again.'**
  String get statePullToRefresh;

  /// No bookmarks state
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get stateNoBookmarksYet;

  /// No projects state
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get stateNoProjectsYet;

  /// No APIs in project
  ///
  /// In en, this message translates to:
  /// **'No APIs in this project'**
  String get stateNoApisInProject;

  /// Project load error
  ///
  /// In en, this message translates to:
  /// **'Could not load project'**
  String get stateCouldNotLoadProject;

  /// No search match
  ///
  /// In en, this message translates to:
  /// **'No match'**
  String get stateNoMatch;

  /// Search no results title
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get stateNoMatchFound;

  /// Search no results suggestion
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword or loosen your filters to discover more APIs.'**
  String get stateTryDifferentKeyword;

  /// Searching APIs loading message
  ///
  /// In en, this message translates to:
  /// **'Searching APIs'**
  String get stateSearchingApis;

  /// No categories match filter message
  ///
  /// In en, this message translates to:
  /// **'No categories match \"{query}\". Try a different search.'**
  String stateNoCategoriesMatch(String query);

  /// No recommendations
  ///
  /// In en, this message translates to:
  /// **'No recommendations yet'**
  String get stateNoRecommendationsYet;

  /// Recommendations empty message
  ///
  /// In en, this message translates to:
  /// **'Recommendations will appear as you use the catalog.'**
  String get stateRecommendationsWillAppear;

  /// No recent APIs
  ///
  /// In en, this message translates to:
  /// **'No recent APIs'**
  String get stateNoRecentApis;

  /// New additions message
  ///
  /// In en, this message translates to:
  /// **'New catalog additions will appear here.'**
  String get stateNewCatalogAdditions;

  /// Unavailable state
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get stateUnavailable;

  /// Trending badge
  ///
  /// In en, this message translates to:
  /// **'TRENDING'**
  String get stateTrending;

  /// New badge
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get stateNew;

  /// API unavailable state
  ///
  /// In en, this message translates to:
  /// **'API unavailable'**
  String get stateApiUnavailable;

  /// API load failure message
  ///
  /// In en, this message translates to:
  /// **'Failed to load this API'**
  String get stateFailedToLoadApi;

  /// No health data message
  ///
  /// In en, this message translates to:
  /// **'No recent health result is available'**
  String get stateNoRecentHealthResult;

  /// Create first project prompt
  ///
  /// In en, this message translates to:
  /// **'Create your first project'**
  String get stateCreateYourFirstProject;

  /// Organize APIs prompt
  ///
  /// In en, this message translates to:
  /// **'Organize APIs you discover into projects to keep them handy.'**
  String get stateOrganizeApisMessage;

  /// Search failure message
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get stateSearchFailed;

  /// Request failure fallback
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get stateRequestFailed;

  /// Network error fallback
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get stateNetworkError;

  /// Sign out dialog title
  ///
  /// In en, this message translates to:
  /// **'SIGN OUT'**
  String get dialogSignOutTitle;

  /// Sign out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get dialogSignOutMessage;

  /// Delete account dialog title
  ///
  /// In en, this message translates to:
  /// **'DELETE ACCOUNT'**
  String get dialogDeleteAccountTitle;

  /// Delete account confirmation message
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all associated data including bookmarks, projects, and FCM tokens. This action is irreversible.'**
  String get dialogDeleteAccountMessage;

  /// Rename project dialog title
  ///
  /// In en, this message translates to:
  /// **'RENAME PROJECT'**
  String get dialogRenameProjectTitle;

  /// Delete project dialog title
  ///
  /// In en, this message translates to:
  /// **'DELETE PROJECT'**
  String get dialogDeleteProjectTitle;

  /// Delete project confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\" and its saved API links?'**
  String dialogDeleteProjectMessage(String title);

  /// Create project dialog title
  ///
  /// In en, this message translates to:
  /// **'CREATE PROJECT'**
  String get dialogCreateProjectTitle;

  /// Submit API dialog title
  ///
  /// In en, this message translates to:
  /// **'SUBMIT AN API'**
  String get dialogSubmitAnApiTitle;

  /// Clear data dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear local data'**
  String get dialogClearLocalDataTitle;

  /// Clear data confirmation
  ///
  /// In en, this message translates to:
  /// **'Remove local cache, settings, tokens, and saved state.'**
  String get dialogClearLocalDataMessage;

  /// Link account dialog title
  ///
  /// In en, this message translates to:
  /// **'LINK ACCOUNT'**
  String get dialogLinkAccountTitle;

  /// Set name dialog title
  ///
  /// In en, this message translates to:
  /// **'SET NAME'**
  String get dialogSetNameTitle;

  /// No internet snackbar title
  ///
  /// In en, this message translates to:
  /// **'NO INTERNET'**
  String get snackbarNoInternetTitle;

  /// No internet message
  ///
  /// In en, this message translates to:
  /// **'You are offline. Check your connection and try again.'**
  String get snackbarNoInternetMessage;

  /// Back online snackbar title
  ///
  /// In en, this message translates to:
  /// **'BACK ONLINE'**
  String get snackbarBackOnlineTitle;

  /// Back online message
  ///
  /// In en, this message translates to:
  /// **'Connection restored'**
  String get snackbarBackOnlineMessage;

  /// Request failed title
  ///
  /// In en, this message translates to:
  /// **'REQUEST FAILED'**
  String get snackbarRequestFailedTitle;

  /// Request failed message
  ///
  /// In en, this message translates to:
  /// **'The request could not be completed. Please try again.'**
  String get snackbarRequestFailedMessage;

  /// Bookmark success title
  ///
  /// In en, this message translates to:
  /// **'Bookmarked'**
  String get snackbarBookmarkedTitle;

  /// Bookmark error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get snackbarBookmarkErrorTitle;

  /// Bookmark error message
  ///
  /// In en, this message translates to:
  /// **'This API cannot be bookmarked yet.'**
  String get snackbarBookmarkErrorMessage;

  /// Bookmark failure message
  ///
  /// In en, this message translates to:
  /// **'Failed to bookmark API'**
  String get snackbarFailedToBookmark;

  /// Removed success title
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get snackbarRemovedTitle;

  /// Bookmark removed message
  ///
  /// In en, this message translates to:
  /// **'Bookmark removed'**
  String get snackbarBookmarkRemoved;

  /// Remove bookmark failure
  ///
  /// In en, this message translates to:
  /// **'Failed to remove bookmark'**
  String get snackbarFailedToRemoveBookmark;

  /// Project created title
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get snackbarProjectCreatedTitle;

  /// Project created message
  ///
  /// In en, this message translates to:
  /// **'Project \"{title}\" created'**
  String snackbarProjectCreatedMessage(String title);

  /// Create project failure
  ///
  /// In en, this message translates to:
  /// **'Failed to create project'**
  String get snackbarFailedToCreateProject;

  /// Updated success title
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get snackbarUpdatedTitle;

  /// Project updated message
  ///
  /// In en, this message translates to:
  /// **'Project updated'**
  String get snackbarProjectUpdated;

  /// Update project failure
  ///
  /// In en, this message translates to:
  /// **'Failed to update project'**
  String get snackbarFailedToUpdateProject;

  /// Deleted success title
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get snackbarDeletedTitle;

  /// Project deleted message
  ///
  /// In en, this message translates to:
  /// **'Project deleted'**
  String get snackbarProjectDeleted;

  /// Delete project failure
  ///
  /// In en, this message translates to:
  /// **'Failed to delete project'**
  String get snackbarFailedToDeleteProject;

  /// Added success title
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get snackbarAddedTitle;

  /// Added to project message
  ///
  /// In en, this message translates to:
  /// **'Added to {title}'**
  String snackbarAddedToProject(String title);

  /// Add to project failure
  ///
  /// In en, this message translates to:
  /// **'Could not add this API to {title}'**
  String snackbarCouldNotAddToProject(String title);

  /// API removed from project
  ///
  /// In en, this message translates to:
  /// **'API removed from project'**
  String get snackbarApiRemovedFromProject;

  /// Remove from project failure
  ///
  /// In en, this message translates to:
  /// **'Failed to remove API from project'**
  String get snackbarFailedToRemoveFromProject;

  /// Cannot add to project
  ///
  /// In en, this message translates to:
  /// **'This API cannot be added to a project yet.'**
  String get snackbarCannotAddToProject;

  /// Submission received title
  ///
  /// In en, this message translates to:
  /// **'Submission received'**
  String get snackbarSubmissionReceivedTitle;

  /// Submission received message
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your API was submitted for review.'**
  String get snackbarSubmissionReceivedMessage;

  /// Submission failed title
  ///
  /// In en, this message translates to:
  /// **'Submission failed'**
  String get snackbarSubmissionFailedTitle;

  /// Submission failed message
  ///
  /// In en, this message translates to:
  /// **'Unable to submit right now. Please try again.'**
  String get snackbarSubmissionFailedMessage;

  /// Search error title
  ///
  /// In en, this message translates to:
  /// **'Search Error'**
  String get snackbarSearchErrorTitle;

  /// Saved success title
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get snackbarSavedTitle;

  /// Search token saved message
  ///
  /// In en, this message translates to:
  /// **'Search token saved'**
  String get snackbarSearchTokenSaved;

  /// Save error title
  ///
  /// In en, this message translates to:
  /// **'Save Error'**
  String get snackbarSaveErrorTitle;

  /// Save token failure
  ///
  /// In en, this message translates to:
  /// **'Could not save token'**
  String get snackbarCouldNotSaveToken;

  /// No bookmarks title
  ///
  /// In en, this message translates to:
  /// **'No bookmarks'**
  String get snackbarNoBookmarksTitle;

  /// No bookmarks message
  ///
  /// In en, this message translates to:
  /// **'You have no bookmarks to export.'**
  String get snackbarNoBookmarksMessage;

  /// Export failed title
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get snackbarExportFailedTitle;

  /// Export failed message
  ///
  /// In en, this message translates to:
  /// **'Could not export bookmarks.'**
  String get snackbarExportFailedMessage;

  /// Data cleared title
  ///
  /// In en, this message translates to:
  /// **'Local data cleared'**
  String get snackbarLocalDataClearedTitle;

  /// Clear failed title
  ///
  /// In en, this message translates to:
  /// **'Clear failed'**
  String get snackbarClearFailedTitle;

  /// Clear failed message
  ///
  /// In en, this message translates to:
  /// **'Unable to clear local data right now.'**
  String get snackbarClearFailedMessage;

  /// Startup updated title
  ///
  /// In en, this message translates to:
  /// **'Startup updated'**
  String get snackbarStartupUpdatedTitle;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, try again'**
  String get snackbarSomethingWentWrong;

  /// Guest continue failure
  ///
  /// In en, this message translates to:
  /// **'Unable to continue as guest'**
  String get snackbarUnableToContinueAsGuest;

  /// Auth snackbar title
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get snackbarAuthenticationTitle;

  /// Health data updated title
  ///
  /// In en, this message translates to:
  /// **'Health data updated'**
  String get snackbarHealthDataUpdated;

  /// URL copied message
  ///
  /// In en, this message translates to:
  /// **'Base URL copied'**
  String get snackbarBaseUrlCopied;

  /// Share failed title
  ///
  /// In en, this message translates to:
  /// **'Share failed'**
  String get snackbarShareFailedTitle;

  /// Share failed message
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get snackbarShareFailedMessage;

  /// Open link failure
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get snackbarCouldNotOpenLink;

  /// Report submitted title
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get snackbarReportSubmittedTitle;

  /// Report submitted message
  ///
  /// In en, this message translates to:
  /// **'Thanks. Reqistry will review this information.'**
  String get snackbarReportSubmittedMessage;

  /// Bookmark unavailable title
  ///
  /// In en, this message translates to:
  /// **'Bookmark unavailable'**
  String get snackbarBookmarkUnavailable;

  /// Bookmark unavailable message
  ///
  /// In en, this message translates to:
  /// **'This API is missing a backend ID.'**
  String get snackbarBookmarkUnavailableMessage;

  /// Save unavailable title
  ///
  /// In en, this message translates to:
  /// **'Save unavailable'**
  String get snackbarSaveUnavailable;

  /// Save unavailable message
  ///
  /// In en, this message translates to:
  /// **'This alternative has no backend ID.'**
  String get snackbarSaveUnavailableMessage;

  /// Opened snackbar title
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get snackbarOpenedTitle;

  /// Unavailable snackbar title
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get snackbarUnavailableTitle;

  /// Could not open URL message
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String snackbarCouldNotOpenUrl(String url);

  /// Submitted snackbar title
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get snackbarSubmittedTitle;

  /// Submitted message
  ///
  /// In en, this message translates to:
  /// **'Thanks! We\'ll review \"{name}\" soon.'**
  String snackbarSubmittedMessage(String name);

  /// Name required title
  ///
  /// In en, this message translates to:
  /// **'Name required'**
  String get snackbarNameRequiredTitle;

  /// Name required message
  ///
  /// In en, this message translates to:
  /// **'Enter a name to update your profile.'**
  String get snackbarNameRequiredMessage;

  /// Name too long title
  ///
  /// In en, this message translates to:
  /// **'Name too long'**
  String get snackbarNameTooLongTitle;

  /// Name too long message
  ///
  /// In en, this message translates to:
  /// **'Use 100 characters or less.'**
  String get snackbarNameTooLongMessage;

  /// Privacy policy error
  ///
  /// In en, this message translates to:
  /// **'Unable to open privacy policy'**
  String get snackbarUnableToOpenPrivacy;

  /// Error snackbar title
  ///
  /// In en, this message translates to:
  /// **'ERROR'**
  String get snackbarErrorTitle;

  /// Fill all fields message
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get snackbarFillAllFields;

  /// Developer website error
  ///
  /// In en, this message translates to:
  /// **'Could not open developer website.'**
  String get snackbarCouldNotLoadDeveloperWebsite;

  /// Load projects failure
  ///
  /// In en, this message translates to:
  /// **'Failed to load projects'**
  String get snackbarFailedToLoadProjects;

  /// Added to bookmarks message
  ///
  /// In en, this message translates to:
  /// **'{name} added to bookmarks'**
  String snackbarAddedToBookmarks(String name);

  /// Guest continue success
  ///
  /// In en, this message translates to:
  /// **'Continuing as guest'**
  String get snackbarContinuingAsGuest;

  /// Sign in success
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get snackbarSignedIn;

  /// Link account success
  ///
  /// In en, this message translates to:
  /// **'Account linked successfully'**
  String get snackbarAccountLinkedSuccessfully;

  /// Sign out failure
  ///
  /// In en, this message translates to:
  /// **'Sign out failed'**
  String get snackbarSignOutFailed;

  /// Delete account failure
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get snackbarFailedToDeleteAccount;

  /// Delete account success
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get snackbarAccountDeleted;

  /// Profile update success
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get snackbarProfileUpdated;

  /// Profile update failure
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get snackbarFailedToUpdateProfile;

  /// HTTPS capability label
  ///
  /// In en, this message translates to:
  /// **'HTTPS'**
  String get apiDetailHttps;

  /// HTTP capability label
  ///
  /// In en, this message translates to:
  /// **'HTTP'**
  String get apiDetailHttp;

  /// CORS capability label
  ///
  /// In en, this message translates to:
  /// **'CORS'**
  String get apiDetailCors;

  /// Alive status label
  ///
  /// In en, this message translates to:
  /// **'ALIVE'**
  String get apiDetailAlive;

  /// Down status label
  ///
  /// In en, this message translates to:
  /// **'DOWN'**
  String get apiDetailDown;

  /// REST protocol label
  ///
  /// In en, this message translates to:
  /// **'REST'**
  String get apiDetailRest;

  /// SOAP protocol label
  ///
  /// In en, this message translates to:
  /// **'SOAP'**
  String get apiDetailSoap;

  /// GraphQL protocol label
  ///
  /// In en, this message translates to:
  /// **'GraphQL'**
  String get apiDetailGraphql;

  /// WebSocket protocol label
  ///
  /// In en, this message translates to:
  /// **'WebSocket'**
  String get apiDetailWebsocket;

  /// gRPC protocol label
  ///
  /// In en, this message translates to:
  /// **'gRPC'**
  String get apiDetailGrpc;

  /// Health label
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get apiDetailHealth;

  /// Pricing label
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get apiDetailPricing;

  /// Authentication label
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get apiDetailAuthentication;

  /// Operational health status
  ///
  /// In en, this message translates to:
  /// **'Operational'**
  String get apiDetailOperational;

  /// Reachable auth status
  ///
  /// In en, this message translates to:
  /// **'Reachable - authentication required'**
  String get apiDetailReachableAuthRequired;

  /// Reachable rate limited
  ///
  /// In en, this message translates to:
  /// **'Reachable - rate limited'**
  String get apiDetailReachableRateLimited;

  /// Slow response status
  ///
  /// In en, this message translates to:
  /// **'Slow response'**
  String get apiDetailSlowResponse;

  /// Currently unavailable
  ///
  /// In en, this message translates to:
  /// **'Currently unavailable'**
  String get apiDetailCurrentlyUnavailable;

  /// Status not verified
  ///
  /// In en, this message translates to:
  /// **'Status not verified'**
  String get apiDetailStatusNotVerified;

  /// Health check timestamp
  ///
  /// In en, this message translates to:
  /// **'Checked {time}'**
  String apiDetailCheckedAgo(String time);

  /// Website info subtitle
  ///
  /// In en, this message translates to:
  /// **'Website information · metadata'**
  String get apiDetailWebsiteInformation;

  /// Saved in project label
  ///
  /// In en, this message translates to:
  /// **'Saved in {title}'**
  String apiDetailSavedInProject(String title);

  /// Already added to project
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get apiDetailAlreadyAdded;

  /// API count label
  ///
  /// In en, this message translates to:
  /// **'{count} APIs'**
  String apiDetailApiCount(int count);

  /// Documentation link label
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get apiDetailDocumentation;

  /// Homepage link label
  ///
  /// In en, this message translates to:
  /// **'Homepage'**
  String get apiDetailHomepage;

  /// Status page link label
  ///
  /// In en, this message translates to:
  /// **'Status page'**
  String get apiDetailStatusPage;

  /// Terms link label
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get apiDetailTerms;

  /// Bookmark API tooltip
  ///
  /// In en, this message translates to:
  /// **'Bookmark API'**
  String get apiDetailBookmarkApi;

  /// Remove bookmark tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get apiDetailRemoveBookmark;

  /// More actions tooltip
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get apiDetailMoreActions;

  /// Save alternative tooltip
  ///
  /// In en, this message translates to:
  /// **'Save {name}'**
  String apiDetailSaveAlternative(String name);

  /// API count stat label
  ///
  /// In en, this message translates to:
  /// **'APIS'**
  String get categoryApis;

  /// Alive count stat label
  ///
  /// In en, this message translates to:
  /// **'ALIVE'**
  String get categoryAlive;

  /// HTTPS count stat label
  ///
  /// In en, this message translates to:
  /// **'HTTPS'**
  String get categoryHttps;

  /// No auth count stat label
  ///
  /// In en, this message translates to:
  /// **'NO AUTH'**
  String get categoryNoAuth;

  /// Avg response stat label
  ///
  /// In en, this message translates to:
  /// **'AVG RESPONSE'**
  String get categoryAvgResponse;

  /// Catalog total stat label
  ///
  /// In en, this message translates to:
  /// **'CATALOG TOTAL'**
  String get categoryCatalogTotal;

  /// Intelligence feature
  ///
  /// In en, this message translates to:
  /// **'Compare APIs side by side'**
  String get intelligenceCompareApis;

  /// Compare card title
  ///
  /// In en, this message translates to:
  /// **'Compare APIs'**
  String get intelligenceCompareTitle;

  /// Compare card subtitle
  ///
  /// In en, this message translates to:
  /// **'Side-by-side trust, pricing and health for up to 4 APIs.'**
  String get intelligenceCompareSubtitle;

  /// Open API picker button
  ///
  /// In en, this message translates to:
  /// **'Choose APIs'**
  String get intelligenceChooseApis;

  /// Run comparison button
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get intelligenceCompareNow;

  /// Change feed section title
  ///
  /// In en, this message translates to:
  /// **'REGISTRY CHANGES'**
  String get intelligenceChangeFeed;

  /// Empty change feed message
  ///
  /// In en, this message translates to:
  /// **'No recent changes.'**
  String get intelligenceChangeFeedEmpty;

  /// API picker search hint
  ///
  /// In en, this message translates to:
  /// **'Search APIs…'**
  String get pickerSearchHint;

  /// Selected count in API picker
  ///
  /// In en, this message translates to:
  /// **'{count} of 4 selected'**
  String pickerSelectedCount(int count);

  /// Confirm button in API picker
  ///
  /// In en, this message translates to:
  /// **'Compare {count}'**
  String pickerDone(int count);

  /// Picker empty state when nothing saved
  ///
  /// In en, this message translates to:
  /// **'No saved APIs yet. Search to pick APIs to compare.'**
  String get pickerNoSavedApis;

  /// Change feed event type label
  ///
  /// In en, this message translates to:
  /// **'TRUST SCORE'**
  String get changeTypeTrustScore;

  /// Change feed event type label
  ///
  /// In en, this message translates to:
  /// **'PRICING'**
  String get changeTypePricing;

  /// Change feed event type label
  ///
  /// In en, this message translates to:
  /// **'HEALTH'**
  String get changeTypeHealth;

  /// Change feed event type label
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get changeTypeUpdate;

  /// Compare table row label
  ///
  /// In en, this message translates to:
  /// **'OpenAPI spec'**
  String get compareOpenApi;

  /// Onboarding step title
  ///
  /// In en, this message translates to:
  /// **'SEARCH ANYTHING'**
  String get onboardingSearchFabTitle;

  /// Onboarding step description
  ///
  /// In en, this message translates to:
  /// **'Tap the search button to find APIs across the whole registry.'**
  String get onboardingSearchFabDesc;

  /// Onboarding step title
  ///
  /// In en, this message translates to:
  /// **'NAVIGATION'**
  String get onboardingNavBarTitle;

  /// Onboarding step description
  ///
  /// In en, this message translates to:
  /// **'Switch between Home, Explore, Intelligence, Saved and You.'**
  String get onboardingNavBarDesc;

  /// Onboarding step title
  ///
  /// In en, this message translates to:
  /// **'KNOW AN API?'**
  String get onboardingSubmitApiTitle;

  /// Onboarding step description
  ///
  /// In en, this message translates to:
  /// **'Submit missing APIs and help the registry grow.'**
  String get onboardingSubmitApiDesc;

  /// Onboarding step title
  ///
  /// In en, this message translates to:
  /// **'COMPARE APIS'**
  String get onboardingCompareTitle;

  /// Onboarding step description
  ///
  /// In en, this message translates to:
  /// **'Pick up to 4 APIs and compare trust, pricing and health side by side.'**
  String get onboardingCompareDesc;

  /// Onboarding step title
  ///
  /// In en, this message translates to:
  /// **'YOUR ACTIVITY'**
  String get onboardingStatsTitle;

  /// Onboarding step description
  ///
  /// In en, this message translates to:
  /// **'Keep track of your bookmarked APIs and projects at a glance.'**
  String get onboardingStatsDesc;

  /// Onboarding step title
  ///
  /// In en, this message translates to:
  /// **'YOUR PROJECTS'**
  String get onboardingProjectsTitle;

  /// Onboarding step description
  ///
  /// In en, this message translates to:
  /// **'Group APIs into projects to compare and share them with your team.'**
  String get onboardingProjectsDesc;

  /// Onboarding step title
  ///
  /// In en, this message translates to:
  /// **'API OVERVIEW'**
  String get onboardingApiMetaTitle;

  /// Onboarding step description
  ///
  /// In en, this message translates to:
  /// **'Everything about this API: description, category, pricing, auth type and live health.'**
  String get onboardingApiMetaDesc;

  /// Onboarding step title
  ///
  /// In en, this message translates to:
  /// **'SAVE TO PROJECT'**
  String get onboardingSaveProjectTitle;

  /// Onboarding step description
  ///
  /// In en, this message translates to:
  /// **'Add this API to one of your projects, or create a new one.'**
  String get onboardingSaveProjectDesc;

  /// Onboarding step title
  ///
  /// In en, this message translates to:
  /// **'BOOKMARK IT'**
  String get onboardingBookmarkTitle;

  /// Onboarding step description
  ///
  /// In en, this message translates to:
  /// **'Save the API to your bookmarks for quick access anytime.'**
  String get onboardingBookmarkDesc;

  /// Replay onboarding tour entry
  ///
  /// In en, this message translates to:
  /// **'Replay intro'**
  String get settingsReplayIntro;

  /// Skip onboarding button
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get actionSkip;

  /// Previous onboarding step button
  ///
  /// In en, this message translates to:
  /// **'PREVIOUS'**
  String get actionPrevious;

  /// Next onboarding step button
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get actionNext;

  /// Submit-API encouragement nudge
  ///
  /// In en, this message translates to:
  /// **'KNOW AN API WE\'RE MISSING?'**
  String get nudgeSubmitApiTitle;

  /// Submit-API encouragement nudge
  ///
  /// In en, this message translates to:
  /// **'You\'ve explored 5 APIs. Help the registry grow by submitting one you love.'**
  String get nudgeSubmitApiMessage;

  /// Trust score with grade in compare table header
  ///
  /// In en, this message translates to:
  /// **'{score} · Grade {grade}'**
  String compareTrustScoreValue(int score, String grade);

  /// Compare table row label
  ///
  /// In en, this message translates to:
  /// **'Response time'**
  String get compareResponseTime;

  /// Compare table row label
  ///
  /// In en, this message translates to:
  /// **'Uptime (30d)'**
  String get compareUptime30d;

  /// Compare table row label
  ///
  /// In en, this message translates to:
  /// **'Rate limit'**
  String get compareRateLimit;

  /// Compare table row label
  ///
  /// In en, this message translates to:
  /// **'SDKs'**
  String get compareSdks;

  /// Error when fewer than two APIs selected
  ///
  /// In en, this message translates to:
  /// **'Select at least two APIs to compare'**
  String get compareSelectAtLeastTwo;

  /// Intelligence feature
  ///
  /// In en, this message translates to:
  /// **'Agent readiness scoring'**
  String get intelligenceAgentReadiness;

  /// Intelligence feature
  ///
  /// In en, this message translates to:
  /// **'Evidence-backed recommendations'**
  String get intelligenceEvidenceBacked;

  /// Intelligence feature
  ///
  /// In en, this message translates to:
  /// **'MCP tool discovery'**
  String get intelligenceMcpToolDiscovery;

  /// Intelligence highlight
  ///
  /// In en, this message translates to:
  /// **'Side-by-side API comparison'**
  String get intelligenceSideBySideComparison;

  /// Intelligence highlight
  ///
  /// In en, this message translates to:
  /// **'Contextual trust and agent scores'**
  String get intelligenceContextualScores;

  /// Intelligence highlight
  ///
  /// In en, this message translates to:
  /// **'Evidence-backed recommendations'**
  String get intelligenceEvidenceBackedRecommendations;

  /// Intelligence highlight
  ///
  /// In en, this message translates to:
  /// **'MCP server and tool discovery'**
  String get intelligenceMcpServerToolDiscovery;

  /// Intelligence highlight
  ///
  /// In en, this message translates to:
  /// **'Natural-language requirement matching'**
  String get intelligenceNaturalLanguageMatching;

  /// Intelligence subtitle
  ///
  /// In en, this message translates to:
  /// **'AI-powered API decisions, coming soon.'**
  String get intelligenceAiPoweredDecisions;

  /// Projects settings item
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get settingsProjects;

  /// Saved APIs settings item
  ///
  /// In en, this message translates to:
  /// **'Saved APIs'**
  String get settingsSavedApis;

  /// Submit API settings item
  ///
  /// In en, this message translates to:
  /// **'Submit an API'**
  String get settingsSubmitAnApi;

  /// App settings item
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get settingsAppSettings;

  /// Account settings item
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// Contact settings item
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get settingsContact;

  /// Privacy policy item
  ///
  /// In en, this message translates to:
  /// **'Privacy and policy'**
  String get settingsPrivacyAndPolicy;

  /// About app item
  ///
  /// In en, this message translates to:
  /// **'About app and developer'**
  String get settingsAboutAppAndDeveloper;

  /// Notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Export favorites action
  ///
  /// In en, this message translates to:
  /// **'Export favorites'**
  String get settingsExportFavorites;

  /// Clear local data action
  ///
  /// In en, this message translates to:
  /// **'Clear local data'**
  String get settingsClearLocalData;

  /// Clear data subtitle
  ///
  /// In en, this message translates to:
  /// **'Remove local cache, settings, tokens, and saved state.'**
  String get settingsClearLocalDataSubtitle;

  /// Saved stat label
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get settingsSavedStat;

  /// Projects stat label
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get settingsProjectsStat;

  /// Project APIs stat label
  ///
  /// In en, this message translates to:
  /// **'Project APIs'**
  String get settingsProjectApisStat;

  /// Profile saved label
  ///
  /// In en, this message translates to:
  /// **'You saved'**
  String get settingsProfileSaved;

  /// Profile have label
  ///
  /// In en, this message translates to:
  /// **'You have'**
  String get settingsProfileHave;

  /// Member duration
  ///
  /// In en, this message translates to:
  /// **'Member for {days} days'**
  String settingsProfileMemberFor(int days);

  /// Member since date
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String settingsProfileSince(String date);

  /// Last used date
  ///
  /// In en, this message translates to:
  /// **'Used {date}'**
  String settingsProfileUsed(String date);

  /// Website label
  ///
  /// In en, this message translates to:
  /// **'WEBSITE'**
  String get settingsWebsite;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get settingsEmail;

  /// Email info label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmailLabel;

  /// Account type label
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get settingsAccountType;

  /// Anonymous account type
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get settingsAnonymous;

  /// Registered account type
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get settingsRegistered;

  /// Guest badge
  ///
  /// In en, this message translates to:
  /// **'GUEST'**
  String get settingsGuest;

  /// Registered badge
  ///
  /// In en, this message translates to:
  /// **'REGISTERED'**
  String get settingsRegisteredBadge;

  /// Link with email option
  ///
  /// In en, this message translates to:
  /// **'Link with Email & Password'**
  String get settingsLinkWithEmail;

  /// Create account subtitle
  ///
  /// In en, this message translates to:
  /// **'Create a permanent account'**
  String get settingsCreatePermanentAccount;

  /// Link account description
  ///
  /// In en, this message translates to:
  /// **'Save your favorites and notes by linking to an account'**
  String get settingsLinkAccountDescription;

  /// Link account create description
  ///
  /// In en, this message translates to:
  /// **'Create a permanent account to save your data'**
  String get settingsLinkAccountCreateDescription;

  /// Privacy policy title
  ///
  /// In en, this message translates to:
  /// **'PRIVACY POLICY'**
  String get settingsPrivacyPolicy;

  /// Something went wrong title
  ///
  /// In en, this message translates to:
  /// **'SOMETHING WENT WRONG'**
  String get settingsSomethingWentWrong;

  /// Contact page title
  ///
  /// In en, this message translates to:
  /// **'CONTACT'**
  String get settingsContactTitle;

  /// Appearance theme section label
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Initial tab setting label
  ///
  /// In en, this message translates to:
  /// **'Initial open tab'**
  String get settingsInitialTab;

  /// Notification updating status
  ///
  /// In en, this message translates to:
  /// **'Updating notification status.'**
  String get settingsNotificationUpdating;

  /// Notifications enabled status
  ///
  /// In en, this message translates to:
  /// **'Enabled. Push token is registered.'**
  String get settingsNotificationEnabled;

  /// Notifications disabled status
  ///
  /// In en, this message translates to:
  /// **'Disabled. Push token is revoked.'**
  String get settingsNotificationDisabled;

  /// No description provided for @notificationSavedApiHealth.
  ///
  /// In en, this message translates to:
  /// **'Saved API health'**
  String get notificationSavedApiHealth;

  /// No description provided for @notificationSavedApiHealthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts when an API you saved goes down or recovers.'**
  String get notificationSavedApiHealthSubtitle;

  /// No description provided for @notificationNewMatchingApis.
  ///
  /// In en, this message translates to:
  /// **'Matching APIs'**
  String get notificationNewMatchingApis;

  /// No description provided for @notificationNewMatchingApisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New APIs matching categories you follow.'**
  String get notificationNewMatchingApisSubtitle;

  /// No description provided for @notificationWeeklyDigest.
  ///
  /// In en, this message translates to:
  /// **'Weekly digest and reminders'**
  String get notificationWeeklyDigest;

  /// No description provided for @notificationWeeklyDigestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly discoveries and community reminders.'**
  String get notificationWeeklyDigestSubtitle;

  /// No description provided for @notificationLifecycleUpdates.
  ///
  /// In en, this message translates to:
  /// **'Submission and report updates'**
  String get notificationLifecycleUpdates;

  /// No description provided for @notificationLifecycleUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Results for APIs you submit or report.'**
  String get notificationLifecycleUpdatesSubtitle;

  /// No description provided for @notificationPricingChanges.
  ///
  /// In en, this message translates to:
  /// **'Pricing changes'**
  String get notificationPricingChanges;

  /// No description provided for @notificationPricingChangesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts when pricing changes for saved APIs.'**
  String get notificationPricingChangesSubtitle;

  /// No description provided for @notificationTrustAlerts.
  ///
  /// In en, this message translates to:
  /// **'Trust alerts'**
  String get notificationTrustAlerts;

  /// No description provided for @notificationTrustAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warnings when trust scores drop for saved APIs.'**
  String get notificationTrustAlertsSubtitle;

  /// Export favorites subtitle
  ///
  /// In en, this message translates to:
  /// **'Export a list of your favorite APIs (name, description, link).'**
  String get settingsExportFavoritesSubtitle;

  /// Clear local data confirmation message
  ///
  /// In en, this message translates to:
  /// **'This will clear local app data and return {appName} to a fresh start.'**
  String dialogClearLocalDataConfirmMessage(String appName);

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Initial tab home option
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get initialTabHome;

  /// Initial tab explore option
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get initialTabExplore;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'API is unavailable'**
  String get reportApiUnavailable;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Link is broken'**
  String get reportLinkBroken;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Pricing is incorrect'**
  String get reportPricingIncorrect;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Authentication is incorrect'**
  String get reportAuthenticationIncorrect;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Description is incorrect'**
  String get reportDescriptionIncorrect;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'API is discontinued'**
  String get reportApiDiscontinued;

  /// Privacy policy URL label
  ///
  /// In en, this message translates to:
  /// **'Privacy policy URL'**
  String get privacyPolicyUrl;

  /// Onboarding get started button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// Onboarding guest button
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get onboardingContinueAsGuest;

  /// Onboarding next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Onboarding skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Onboarding subtitle text
  ///
  /// In en, this message translates to:
  /// **'Find the right API. Give your agents the right tools.'**
  String get onboardingSubtitle;

  /// Onboarding discover step title
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get onboardingDiscoverTitle;

  /// Onboarding discover step description
  ///
  /// In en, this message translates to:
  /// **'Browse a trusted catalog of 1,400+ APIs organized by category.'**
  String get onboardingDiscoverText;

  /// Onboarding evaluate step title
  ///
  /// In en, this message translates to:
  /// **'Evaluate'**
  String get onboardingEvaluateTitle;

  /// Onboarding evaluate step description
  ///
  /// In en, this message translates to:
  /// **'Check health, auth, pricing, and docs before you build.'**
  String get onboardingEvaluateText;

  /// Onboarding connect step title
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get onboardingConnectTitle;

  /// Onboarding connect step description
  ///
  /// In en, this message translates to:
  /// **'Bookmark APIs and organize them into projects for your next build.'**
  String get onboardingConnectText;

  /// Onboarding explore APIs button
  ///
  /// In en, this message translates to:
  /// **'Explore APIs'**
  String get onboardingExploreApis;

  /// Singular API label
  ///
  /// In en, this message translates to:
  /// **'API'**
  String get miscApi;

  /// Plural APIs label
  ///
  /// In en, this message translates to:
  /// **'APIs'**
  String get miscApis;

  /// Singular Project label
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get miscProject;

  /// Plural Projects label
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get miscProjects;

  /// Member duration
  ///
  /// In en, this message translates to:
  /// **'Member for {days} days'**
  String miscMemberForDays(int days);

  /// Unknown pricing label
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get miscUnknownPricing;

  /// Free pricing label
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get miscFree;

  /// Freemium pricing label
  ///
  /// In en, this message translates to:
  /// **'FREEMIUM'**
  String get miscFreemium;

  /// Paid pricing label
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get miscPaid;

  /// API link copied message
  ///
  /// In en, this message translates to:
  /// **'API link copied'**
  String get miscApiLinkCopied;

  /// Powered by label
  ///
  /// In en, this message translates to:
  /// **'Powered by Reqistry'**
  String get miscPoweredByReqistry;

  /// Edit name tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get tooltipEditName;

  /// Submit API button in home app bar
  ///
  /// In en, this message translates to:
  /// **'KNOW AN API?'**
  String get actionKnowAnApi;

  /// Title field validation error
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get formTitleRequired;

  /// Generic field validation error
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get formFieldRequired;

  /// Name too short validation error
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get formNameTooShort;

  /// Invalid URL validation error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid http(s) URL'**
  String get formInvalidUrl;

  /// Empty projects message in all projects view
  ///
  /// In en, this message translates to:
  /// **'Create a project, then add APIs you discover to keep them organized.'**
  String get emptyCreateProjectMessage;

  /// Platform health section header
  ///
  /// In en, this message translates to:
  /// **'PLATFORM-OBSERVED HEALTH'**
  String get apiDetailPlatformObservedHealth;

  /// Base URL section label
  ///
  /// In en, this message translates to:
  /// **'BASE URL'**
  String get apiDetailBaseUrl;

  /// Copy base URL tooltip
  ///
  /// In en, this message translates to:
  /// **'Copy BASE URL'**
  String get apiDetailCopyBaseUrl;

  /// Feature supported label
  ///
  /// In en, this message translates to:
  /// **'Supported'**
  String get apiDetailSupported;

  /// Feature not supported label
  ///
  /// In en, this message translates to:
  /// **'Not supported'**
  String get apiDetailNotSupported;

  /// Unknown value label
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get apiDetailUnknownValue;

  /// API type label in quick facts
  ///
  /// In en, this message translates to:
  /// **'API type'**
  String get apiDetailApiType;

  /// Response format label in quick facts
  ///
  /// In en, this message translates to:
  /// **'Response format'**
  String get apiDetailResponseFormat;

  /// Credit card required label
  ///
  /// In en, this message translates to:
  /// **'Credit card required'**
  String get apiDetailCreditCardRequired;

  /// Commercial use label
  ///
  /// In en, this message translates to:
  /// **'Commercial use'**
  String get apiDetailCommercialUse;

  /// OpenAPI available label
  ///
  /// In en, this message translates to:
  /// **'OpenAPI available'**
  String get apiDetailOpenApiAvailable;

  /// Yes label
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get apiDetailYes;

  /// No label
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get apiDetailNo;

  /// Report issue notice banner text
  ///
  /// In en, this message translates to:
  /// **'Reports are sent to Reqistry for review.'**
  String get formReportNoticeBanner;

  /// Report reason: other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportOther;

  /// Guest account type value
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get settingsGuestAccountType;

  /// Email account type value
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmailAccountType;

  /// Member since date prefix
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String settingsMemberSincePrefix(String date);

  /// Last used date prefix
  ///
  /// In en, this message translates to:
  /// **'Used {date}'**
  String settingsLastUsedPrefix(String date);

  /// Loading bookmarks message
  ///
  /// In en, this message translates to:
  /// **'Loading bookmarks'**
  String get stateLoadingBookmarks;

  /// Empty bookmarks message
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark icon on any API in the Discover tab to save it here.'**
  String get stateBookmarksEmptyMessage;

  /// Rename project tooltip
  ///
  /// In en, this message translates to:
  /// **'Rename project'**
  String get tooltipRenameProject;

  /// Delete project tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete project'**
  String get tooltipDeleteProject;

  /// No APIs in project message
  ///
  /// In en, this message translates to:
  /// **'Browse the Discover tab and add the APIs you want to keep here.'**
  String get stateNoApisInProjectMessage;

  /// Browse APIs button
  ///
  /// In en, this message translates to:
  /// **'Browse APIs'**
  String get actionBrowseApis;

  /// Saved APIs count in project header
  ///
  /// In en, this message translates to:
  /// **'{count} saved APIs'**
  String projectSavedApisCount(int count);

  /// Category fallback title
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get stateCategory;

  /// Loading category APIs message
  ///
  /// In en, this message translates to:
  /// **'Loading category APIs'**
  String get stateLoadingCategoryApis;

  /// Category load error
  ///
  /// In en, this message translates to:
  /// **'Could not load category'**
  String get stateCouldNotLoadCategory;

  /// No APIs available empty state
  ///
  /// In en, this message translates to:
  /// **'No APIs available'**
  String get stateNoApisAvailable;

  /// Category empty message
  ///
  /// In en, this message translates to:
  /// **'This category is empty right now. Try another category in the Discover tab.'**
  String get stateCategoryEmptyMessage;

  /// Not available label
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get miscNA;

  /// Email app opened message
  ///
  /// In en, this message translates to:
  /// **'Email app opened'**
  String get snackbarEmailAppOpened;

  /// Website opened message
  ///
  /// In en, this message translates to:
  /// **'Website opened'**
  String get snackbarWebsiteOpened;

  /// Just now time label
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// Minutes ago time label
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeMinutesAgo(int count);

  /// Hours ago time label
  ///
  /// In en, this message translates to:
  /// **'{count} hr ago'**
  String timeHoursAgo(int count);

  /// Days ago time label
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String timeDaysAgo(int count);

  /// API reference link label
  ///
  /// In en, this message translates to:
  /// **'API reference'**
  String get apiDetailApiReference;

  /// SDKs label in quick facts
  ///
  /// In en, this message translates to:
  /// **'SDKs'**
  String get apiDetailSdks;

  /// Rate limit label in quick facts
  ///
  /// In en, this message translates to:
  /// **'Rate limit'**
  String get apiDetailRateLimit;

  /// API logo semantics label
  ///
  /// In en, this message translates to:
  /// **'{name} logo'**
  String semanticsApiLogo(String name);

  /// Bad certificate error message
  ///
  /// In en, this message translates to:
  /// **'The connection could not be verified securely.'**
  String get errorBadCertificate;

  /// Too many requests error message
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get errorTooManyRequests;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'The server is having trouble. Please try again later.'**
  String get errorServerError;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorSomethingWentWrong;

  /// Discover catalog loading message
  ///
  /// In en, this message translates to:
  /// **'The Discover catalog is loading. Pull to refresh and try again.'**
  String get discoverCatalogLoadingMessage;

  /// Privacy page no internet error
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get privacyNoInternetConnection;

  /// Privacy content load failure
  ///
  /// In en, this message translates to:
  /// **'Failed to load privacy content'**
  String get privacyFailedToLoadContent;

  /// Unexpected error with details
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String unexpectedErrorOccurred(String error);

  /// API data not found error
  ///
  /// In en, this message translates to:
  /// **'API data not found'**
  String get errorApiDataNotFound;

  /// Project data not found error
  ///
  /// In en, this message translates to:
  /// **'Project data not found'**
  String get errorProjectDataNotFound;

  /// Local data cleared message
  ///
  /// In en, this message translates to:
  /// **'{appName} will start fresh.'**
  String snackbarLocalDataClearedMessage(String appName);

  /// Startup updated discover message
  ///
  /// In en, this message translates to:
  /// **'{appName} will open on Discover.'**
  String snackbarStartupUpdatedDiscoverMessage(String appName);

  /// Startup updated home message
  ///
  /// In en, this message translates to:
  /// **'{appName} will open on Home.'**
  String snackbarStartupUpdatedHomeMessage(String appName);

  /// API could not be loaded error
  ///
  /// In en, this message translates to:
  /// **'This API could not be loaded.'**
  String get apiDetailCouldNotBeLoaded;

  /// Fresh info unavailable error
  ///
  /// In en, this message translates to:
  /// **'Fresh API information is temporarily unavailable.'**
  String get apiDetailFreshInfoUnavailable;

  /// Similar APIs unavailable error
  ///
  /// In en, this message translates to:
  /// **'Similar APIs are unavailable.'**
  String get apiDetailSimilarApisUnavailable;

  /// Health loaded success message
  ///
  /// In en, this message translates to:
  /// **'Latest platform health result loaded.'**
  String get apiDetailHealthLoaded;

  /// Health refresh failure
  ///
  /// In en, this message translates to:
  /// **'Health could not be refreshed.'**
  String get apiDetailHealthRefreshFailed;

  /// Invalid navigation argument error
  ///
  /// In en, this message translates to:
  /// **'Invalid navigation argument: {type}'**
  String categoryApisInvalidArgument(String type);

  /// Unexpected category error
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get categoryApisUnexpectedError;

  /// Submit API tip card message
  ///
  /// In en, this message translates to:
  /// **'Submit an API for review. Provide the API name and URL.'**
  String get submitApiTipMessage;

  /// No reviewed description fallback
  ///
  /// In en, this message translates to:
  /// **'No reviewed description is available.'**
  String get apiDetailNoDescription;

  /// Automated backend check method label
  ///
  /// In en, this message translates to:
  /// **'Automated backend check'**
  String get apiDetailAutomatedBackendCheck;

  /// Not verified source label
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get apiDetailNotVerified;

  /// Automated check source label
  ///
  /// In en, this message translates to:
  /// **'Automated check'**
  String get apiDetailAutomatedCheck;

  /// Imported source label
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get apiDetailImported;

  /// No authentication label
  ///
  /// In en, this message translates to:
  /// **'No authentication'**
  String get apiDetailNoAuthentication;

  /// Basic authentication label
  ///
  /// In en, this message translates to:
  /// **'Basic authentication'**
  String get apiDetailBasicAuthentication;

  /// Free pricing label
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get apiDetailFree;

  /// Free tier pricing label
  ///
  /// In en, this message translates to:
  /// **'Free tier'**
  String get apiDetailFreeTier;

  /// Paid pricing label
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get apiDetailPaid;

  /// Provider verification source
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get apiDetailSourceProvider;

  /// Registry review verification source
  ///
  /// In en, this message translates to:
  /// **'Reqistry review'**
  String get apiDetailSourceRegistryReview;

  /// Community report verification source
  ///
  /// In en, this message translates to:
  /// **'Community report'**
  String get apiDetailSourceCommunityReport;

  /// Paid access warning
  ///
  /// In en, this message translates to:
  /// **'Paid access reported'**
  String get apiDetailWarningPaidAccess;

  /// No docs warning
  ///
  /// In en, this message translates to:
  /// **'Documentation URL is not available'**
  String get apiDetailWarningNoDocs;

  /// CORS not verified warning
  ///
  /// In en, this message translates to:
  /// **'CORS support is not verified'**
  String get apiDetailWarningCorsNotVerified;

  /// No health result warning
  ///
  /// In en, this message translates to:
  /// **'No recent platform health result is available'**
  String get apiDetailWarningNoHealthResult;

  /// Auth required warning
  ///
  /// In en, this message translates to:
  /// **'{authType} required'**
  String apiDetailWarningAuthRequired(String authType);

  /// Search category fallback
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get apiDetailSearchFallback;

  /// Platform health semantics label
  ///
  /// In en, this message translates to:
  /// **'Platform-observed health.'**
  String get apiDetailPlatformObservedHealthLabel;

  /// Empty response error title
  ///
  /// In en, this message translates to:
  /// **'Empty response'**
  String get errorEmptyResponse;

  /// Empty response error message
  ///
  /// In en, this message translates to:
  /// **'Server returned empty data'**
  String get errorServerReturnedEmptyData;

  /// Parse error title
  ///
  /// In en, this message translates to:
  /// **'Parse error'**
  String get errorParseError;

  /// Generic parse error message
  ///
  /// In en, this message translates to:
  /// **'Failed to process data'**
  String get errorFailedToProcessData;

  /// Invalid input error title
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get errorInvalidInput;

  /// Category ID empty error
  ///
  /// In en, this message translates to:
  /// **'Category ID cannot be empty'**
  String get errorCategoryIdEmpty;

  /// API name empty error
  ///
  /// In en, this message translates to:
  /// **'API name cannot be empty'**
  String get errorApiNameEmpty;

  /// API link empty error
  ///
  /// In en, this message translates to:
  /// **'API link cannot be empty'**
  String get errorApiLinkEmpty;

  /// Invalid data error title
  ///
  /// In en, this message translates to:
  /// **'Invalid Data'**
  String get errorInvalidData;

  /// Invalid API response error
  ///
  /// In en, this message translates to:
  /// **'The API response data is invalid'**
  String get errorApiResponseInvalid;

  /// Connection timeout error title
  ///
  /// In en, this message translates to:
  /// **'Connection timeout'**
  String get errorConnectionTimeout;

  /// Check internet connection message
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get errorCheckInternetConnection;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Intelligence collections section
  ///
  /// In en, this message translates to:
  /// **'CURATED COLLECTIONS'**
  String get intelligenceCollections;

  /// Intelligence collections subtitle
  ///
  /// In en, this message translates to:
  /// **'Task-fit starters. Pick a job, compare the shortlist.'**
  String get intelligenceCollectionsSubtitle;

  /// Intelligence hero title
  ///
  /// In en, this message translates to:
  /// **'DECIDE WITH EVIDENCE.'**
  String get intelligenceHeroTitle;

  /// Intelligence hero subtitle
  ///
  /// In en, this message translates to:
  /// **'Compare APIs side by side, backed by live trust evidence.'**
  String get intelligenceHeroSubtitle;

  /// Recent comparisons label
  ///
  /// In en, this message translates to:
  /// **'RECENT'**
  String get intelligenceRecent;

  /// API count in a collection
  ///
  /// In en, this message translates to:
  /// **'{count} APIs'**
  String collectionApisCount(Object count);

  /// Compare table trust row label
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get compareTrust;

  /// Compare verdict title
  ///
  /// In en, this message translates to:
  /// **'TOP PICK'**
  String get compareTopPick;

  /// Best value badge
  ///
  /// In en, this message translates to:
  /// **'BEST'**
  String get compareBest;

  /// Verdict fastest bullet
  ///
  /// In en, this message translates to:
  /// **'Fastest response: {name} at {ms} ms'**
  String compareVerdictFastest(Object ms, Object name);

  /// Verdict uptime bullet
  ///
  /// In en, this message translates to:
  /// **'Best uptime: {name} at {uptime}'**
  String compareVerdictUptime(Object name, Object uptime);

  /// Verdict fastest tie bullet
  ///
  /// In en, this message translates to:
  /// **'Also the fastest option'**
  String get compareVerdictAlsoFastest;

  /// Shared comparison header
  ///
  /// In en, this message translates to:
  /// **'API comparison via Reqistry'**
  String get compareShareHeader;

  /// Trust evidence sheet title
  ///
  /// In en, this message translates to:
  /// **'TRUST EVIDENCE'**
  String get trustEvidenceTitle;

  /// Trust score verification date
  ///
  /// In en, this message translates to:
  /// **'Verified {date}'**
  String trustEvidenceVerifiedOn(Object date);

  /// Live trust score note
  ///
  /// In en, this message translates to:
  /// **'Live score, fresh from this check'**
  String get trustEvidenceLiveScore;

  /// Average trust stat label
  ///
  /// In en, this message translates to:
  /// **'AVG TRUST'**
  String get statsAvgTrust;

  /// Down APIs stat label
  ///
  /// In en, this message translates to:
  /// **'DOWN NOW'**
  String get statsDownNow;

  /// Trending categories section
  ///
  /// In en, this message translates to:
  /// **'TRENDING'**
  String get sectionTrendingCategories;

  /// Contact form title
  ///
  /// In en, this message translates to:
  /// **'SEND A MESSAGE'**
  String get contactFormTitle;

  /// Contact form subtitle
  ///
  /// In en, this message translates to:
  /// **'Questions, feedback or broken data. The team reads everything.'**
  String get contactFormSubtitle;

  /// Contact subject field label
  ///
  /// In en, this message translates to:
  /// **'SUBJECT (OPTIONAL)'**
  String get formSubject;

  /// Contact message field label
  ///
  /// In en, this message translates to:
  /// **'MESSAGE'**
  String get formMessage;

  /// Invalid email error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get formInvalidEmail;

  /// Contact sent title
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get snackbarContactSentTitle;

  /// Contact sent fallback message
  ///
  /// In en, this message translates to:
  /// **'Your message has been sent.'**
  String get snackbarContactSentMessage;

  /// Contact failed message
  ///
  /// In en, this message translates to:
  /// **'Unable to send right now. Please try again.'**
  String get snackbarContactFailedMessage;

  /// Notification feed title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifFeedTitle;

  /// Clear notifications tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get notifFeedClearTooltip;

  /// Empty notifications title
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notifFeedEmptyTitle;

  /// Empty notifications message
  ///
  /// In en, this message translates to:
  /// **'Health, price, and trust alerts for your saved APIs will appear here.'**
  String get notifFeedEmptyMessage;

  /// Clear notifications confirm title
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications?'**
  String get notifFeedClearTitle;

  /// Clear notifications confirm message
  ///
  /// In en, this message translates to:
  /// **'This removes your local notification history. This cannot be undone.'**
  String get notifFeedClearMessage;

  /// Submission history title
  ///
  /// In en, this message translates to:
  /// **'My submissions'**
  String get submissionsTitle;

  /// Empty submissions title
  ///
  /// In en, this message translates to:
  /// **'No submissions yet'**
  String get submissionsEmptyTitle;

  /// Empty submissions message
  ///
  /// In en, this message translates to:
  /// **'APIs you submit for review will appear here with their review status.'**
  String get submissionsEmptyMessage;

  /// Open approved API action
  ///
  /// In en, this message translates to:
  /// **'Open API'**
  String get submissionsOpenApi;

  /// Submission date label
  ///
  /// In en, this message translates to:
  /// **'Submitted {date}'**
  String submissionsSubmittedOn(String date);

  /// Review date label
  ///
  /// In en, this message translates to:
  /// **'Reviewed {date}'**
  String submissionsReviewedOn(String date);

  /// Rejection reason label
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String submissionsRejectionReason(String reason);

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get submissionStatusPending;

  /// Approved status
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get submissionStatusApproved;

  /// Rejected status
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get submissionStatusRejected;

  /// Duplicate status
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get submissionStatusDuplicate;

  /// Spam status
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get submissionStatusSpam;

  /// My submissions settings entry
  ///
  /// In en, this message translates to:
  /// **'My submissions'**
  String get settingsMySubmissions;

  /// Undo action button
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// Done action button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// Watchlists title
  ///
  /// In en, this message translates to:
  /// **'Watchlists'**
  String get watchTitle;

  /// Empty watchlists title
  ///
  /// In en, this message translates to:
  /// **'No watches yet'**
  String get watchEmptyTitle;

  /// Empty watchlists message
  ///
  /// In en, this message translates to:
  /// **'Watch a keyword to get push alerts on new, price or trust changes.'**
  String get watchEmptyMessage;

  /// Create keyword watch action
  ///
  /// In en, this message translates to:
  /// **'Watch this search'**
  String get watchAction;

  /// Watch added message
  ///
  /// In en, this message translates to:
  /// **'Watch added'**
  String get watchAdded;

  /// Watchlist limit message
  ///
  /// In en, this message translates to:
  /// **'Watchlist limit reached'**
  String get watchLimitReached;

  /// Agent keys title
  ///
  /// In en, this message translates to:
  /// **'Agent API keys'**
  String get agentKeysTitle;

  /// Empty agent keys message
  ///
  /// In en, this message translates to:
  /// **'No keys yet. Create one so your agents can query Reqistry.'**
  String get agentKeysEmpty;

  /// Create key action
  ///
  /// In en, this message translates to:
  /// **'Create key'**
  String get agentKeyCreate;

  /// Key name hint
  ///
  /// In en, this message translates to:
  /// **'Key name (optional)'**
  String get agentKeyNameHint;

  /// Key once warning
  ///
  /// In en, this message translates to:
  /// **'Copy now — the full key shows only once.'**
  String get agentKeyOnceWarning;

  /// Key copied message
  ///
  /// In en, this message translates to:
  /// **'Key copied'**
  String get agentKeyCopied;

  /// Key usage label
  ///
  /// In en, this message translates to:
  /// **'{used} calls today'**
  String agentKeyUsageToday(int used);

  /// Revoke confirm title
  ///
  /// In en, this message translates to:
  /// **'Revoke this key?'**
  String get agentKeyRevokeTitle;

  /// Revoke confirm message
  ///
  /// In en, this message translates to:
  /// **'Agents using it stop working immediately.'**
  String get agentKeyRevokeMessage;

  /// Ship report title
  ///
  /// In en, this message translates to:
  /// **'Ship-check report'**
  String get shipReportTitle;

  /// Ship verdict
  ///
  /// In en, this message translates to:
  /// **'Safe to ship'**
  String get shipVerdictShip;

  /// Caution verdict
  ///
  /// In en, this message translates to:
  /// **'Ship with caution'**
  String get shipVerdictCaution;

  /// Avoid verdict
  ///
  /// In en, this message translates to:
  /// **'Do not ship'**
  String get shipVerdictAvoid;

  /// Monitor toggle title
  ///
  /// In en, this message translates to:
  /// **'Monitor stack'**
  String get monitorTitle;

  /// Monitor toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Daily health digest for this project'**
  String get monitorSubtitle;

  /// Stack history title
  ///
  /// In en, this message translates to:
  /// **'Stack history'**
  String get stackHistoryTitle;

  /// Empty stack history
  ///
  /// In en, this message translates to:
  /// **'Snapshots appear after the first daily digest.'**
  String get stackHistoryEmpty;

  /// Down count ticker
  ///
  /// In en, this message translates to:
  /// **'DOWN'**
  String get stackHistoryDown;

  /// Trust ticker
  ///
  /// In en, this message translates to:
  /// **'TRUST'**
  String get stackHistoryTrust;

  /// Notification deleted message
  ///
  /// In en, this message translates to:
  /// **'Notification deleted.'**
  String get notifFeedRemovedMessage;

  /// Ship-check row title
  ///
  /// In en, this message translates to:
  /// **'Production safety check'**
  String get shipCheckRowTitle;

  /// Ship-check row body
  ///
  /// In en, this message translates to:
  /// **'Trust, health, docs and auth signals for this API.'**
  String get shipCheckRowBody;

  /// Disclosure chip on native ad cards
  ///
  /// In en, this message translates to:
  /// **'Ad'**
  String get adBadgeLabel;

  /// UMP privacy options entry
  ///
  /// In en, this message translates to:
  /// **'Privacy choices'**
  String get settingsPrivacyChoices;

  /// Privacy options subtitle
  ///
  /// In en, this message translates to:
  /// **'Control personalized ads'**
  String get settingsPrivacyChoicesSubtitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
