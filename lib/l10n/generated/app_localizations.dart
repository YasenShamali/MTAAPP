import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MTA'**
  String get appName;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'MTA · Version 1.0.0'**
  String get appVersion;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'App developed by Yasen Shamali'**
  String get developedBy;

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'Fabrication & Installation Orders Management Platform'**
  String get brandTagline;

  /// No description provided for @toastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully'**
  String get toastSuccess;

  /// No description provided for @toastError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get toastError;

  /// No description provided for @toastWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get toastWarning;

  /// No description provided for @toastInfo.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get toastInfo;

  /// No description provided for @roleSalesOfficer.
  ///
  /// In en, this message translates to:
  /// **'Sales Officer'**
  String get roleSalesOfficer;

  /// No description provided for @roleTileFactory.
  ///
  /// In en, this message translates to:
  /// **'Tile Factory'**
  String get roleTileFactory;

  /// No description provided for @roleWoodFactory.
  ///
  /// In en, this message translates to:
  /// **'Wood Factory'**
  String get roleWoodFactory;

  /// No description provided for @roleInstallationOfficer.
  ///
  /// In en, this message translates to:
  /// **'Installation Officer'**
  String get roleInstallationOfficer;

  /// No description provided for @roleResponsibleOfficer.
  ///
  /// In en, this message translates to:
  /// **'Responsible Officer'**
  String get roleResponsibleOfficer;

  /// No description provided for @roleSalesDescription.
  ///
  /// In en, this message translates to:
  /// **'Create and edit orders'**
  String get roleSalesDescription;

  /// No description provided for @roleTileFactoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Review tile factory orders'**
  String get roleTileFactoryDescription;

  /// No description provided for @roleWoodFactoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Review wood factory orders'**
  String get roleWoodFactoryDescription;

  /// No description provided for @roleInstallationDescription.
  ///
  /// In en, this message translates to:
  /// **'Review installation orders'**
  String get roleInstallationDescription;

  /// No description provided for @roleResponsibleDescription.
  ///
  /// In en, this message translates to:
  /// **'Supervision and reports'**
  String get roleResponsibleDescription;

  /// No description provided for @statusPendingTileFactory.
  ///
  /// In en, this message translates to:
  /// **'Pending Tile Factory'**
  String get statusPendingTileFactory;

  /// No description provided for @statusPendingWoodFactory.
  ///
  /// In en, this message translates to:
  /// **'Pending Wood Factory'**
  String get statusPendingWoodFactory;

  /// No description provided for @statusPendingInstallation.
  ///
  /// In en, this message translates to:
  /// **'Pending Installation'**
  String get statusPendingInstallation;

  /// No description provided for @statusPendingResubmission.
  ///
  /// In en, this message translates to:
  /// **'Pending Resubmission'**
  String get statusPendingResubmission;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get statusUnderReview;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All orders'**
  String get filterAll;

  /// No description provided for @filterFactory.
  ///
  /// In en, this message translates to:
  /// **'Factory orders'**
  String get filterFactory;

  /// No description provided for @filterInstallation.
  ///
  /// In en, this message translates to:
  /// **'Installation orders'**
  String get filterInstallation;

  /// No description provided for @filterApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get filterApproved;

  /// No description provided for @filterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get filterRejected;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @historyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyFilterAll;

  /// No description provided for @historyFilterPendingFactory.
  ///
  /// In en, this message translates to:
  /// **'Pending factory'**
  String get historyFilterPendingFactory;

  /// No description provided for @historyFilterPendingInstallation.
  ///
  /// In en, this message translates to:
  /// **'Pending installation'**
  String get historyFilterPendingInstallation;

  /// No description provided for @historyFilterApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get historyFilterApproved;

  /// No description provided for @historyFilterInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get historyFilterInProgress;

  /// No description provided for @historyFilterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get historyFilterCompleted;

  /// No description provided for @historyFilterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get historyFilterRejected;

  /// No description provided for @historyFilterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get historyFilterCancelled;

  /// No description provided for @requestTypeFabrication.
  ///
  /// In en, this message translates to:
  /// **'Fabrication'**
  String get requestTypeFabrication;

  /// No description provided for @requestTypeInstallation.
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get requestTypeInstallation;

  /// No description provided for @requestTypeBoth.
  ///
  /// In en, this message translates to:
  /// **'Fabrication & Installation'**
  String get requestTypeBoth;

  /// No description provided for @stageFabrication.
  ///
  /// In en, this message translates to:
  /// **'Fabrication'**
  String get stageFabrication;

  /// No description provided for @stageInstallation.
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get stageInstallation;

  /// No description provided for @tabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get tabOrders;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @tabAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tabAccount;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @createNewOrder.
  ///
  /// In en, this message translates to:
  /// **'Create new order'**
  String get createNewOrder;

  /// No description provided for @ordersHistory.
  ///
  /// In en, this message translates to:
  /// **'Orders History'**
  String get ordersHistory;

  /// No description provided for @ordersHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Full order history with printable report'**
  String get ordersHistorySubtitle;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign out: {error}'**
  String signOutFailed(String error);

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated successfully.'**
  String get profilePhotoUpdated;

  /// No description provided for @photoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload photo: {error}'**
  String photoUploadFailed(String error);

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by number, name, phone, material...'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearSearch;

  /// No description provided for @statFactory.
  ///
  /// In en, this message translates to:
  /// **'Factory'**
  String get statFactory;

  /// No description provided for @statInstallation.
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get statInstallation;

  /// No description provided for @statCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statCompleted;

  /// No description provided for @statApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statApproved;

  /// No description provided for @statRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statRejected;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results match your search'**
  String get noSearchResults;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @noOrdersInCategory.
  ///
  /// In en, this message translates to:
  /// **'No orders in this category'**
  String get noOrdersInCategory;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get loadFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noItemsToShow.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show right now'**
  String get noItemsToShow;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @editRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request order edit'**
  String get editRequestTitle;

  /// No description provided for @editRequestExplanation.
  ///
  /// In en, this message translates to:
  /// **'The order was accepted at one of the stages, so management approval is required for the edit. Write the reason.'**
  String get editRequestExplanation;

  /// No description provided for @editReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit reason'**
  String get editReasonLabel;

  /// No description provided for @editReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Change quantity or customer details'**
  String get editReasonHint;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @editReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please write a reason for the edit'**
  String get editReasonRequired;

  /// No description provided for @editRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Edit request sent, awaiting management approval.'**
  String get editRequestSent;

  /// No description provided for @editRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send edit request: {error}'**
  String editRequestFailed(String error);

  /// No description provided for @approveEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve edit'**
  String get approveEditTitle;

  /// No description provided for @rejectEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject edit request'**
  String get rejectEditTitle;

  /// No description provided for @editRequestReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit request reason:'**
  String get editRequestReasonLabel;

  /// No description provided for @approveEditConfirm.
  ///
  /// In en, this message translates to:
  /// **'The order data will become editable. Do you want to continue?'**
  String get approveEditConfirm;

  /// No description provided for @rejectEditConfirm.
  ///
  /// In en, this message translates to:
  /// **'The order will not be edited. Do you want to continue?'**
  String get rejectEditConfirm;

  /// No description provided for @approveEditAction.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveEditAction;

  /// No description provided for @rejectOrderAction.
  ///
  /// In en, this message translates to:
  /// **'Reject order'**
  String get rejectOrderAction;

  /// No description provided for @editApprovedMsg.
  ///
  /// In en, this message translates to:
  /// **'Edit approved, the order is now editable.'**
  String get editApprovedMsg;

  /// No description provided for @editRejectedMsg.
  ///
  /// In en, this message translates to:
  /// **'Edit request rejected.'**
  String get editRejectedMsg;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete the operation: {error}'**
  String operationFailed(String error);

  /// No description provided for @rejectReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get rejectReasonTitle;

  /// No description provided for @reasonTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason type'**
  String get reasonTypeLabel;

  /// No description provided for @timingInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Delivery timing is insufficient'**
  String get timingInsufficient;

  /// No description provided for @otherReason.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherReason;

  /// No description provided for @chooseDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Choose the appropriate delivery date:'**
  String get chooseDeliveryDate;

  /// No description provided for @datePickerHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose the appropriate delivery date'**
  String get datePickerHelp;

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reasonLabel;

  /// No description provided for @reasonHint.
  ///
  /// In en, this message translates to:
  /// **'Write the rejection reason'**
  String get reasonHint;

  /// No description provided for @rejectButton.
  ///
  /// In en, this message translates to:
  /// **'Reject order'**
  String get rejectButton;

  /// No description provided for @rejectReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please write a rejection reason'**
  String get rejectReasonRequired;

  /// No description provided for @rejectTimingMessage.
  ///
  /// In en, this message translates to:
  /// **'Delivery timing is insufficient, suitable date: {date}'**
  String rejectTimingMessage(String date);

  /// No description provided for @orderRejected.
  ///
  /// In en, this message translates to:
  /// **'Order rejected and returned to sender.'**
  String get orderRejected;

  /// No description provided for @rejectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject order: {error}'**
  String rejectFailed(String error);

  /// No description provided for @orderAccepted.
  ///
  /// In en, this message translates to:
  /// **'Order accepted.'**
  String get orderAccepted;

  /// No description provided for @acceptFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept order: {error}'**
  String acceptFailed(String error);

  /// No description provided for @sentToInstallation.
  ///
  /// In en, this message translates to:
  /// **'Order sent to installation worker.'**
  String get sentToInstallation;

  /// No description provided for @finishedFromFactory.
  ///
  /// In en, this message translates to:
  /// **'Order finished by factory.'**
  String get finishedFromFactory;

  /// No description provided for @orderFinished.
  ///
  /// In en, this message translates to:
  /// **'Order finished.'**
  String get orderFinished;

  /// No description provided for @cancelOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrderTitle;

  /// No description provided for @cancelReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get cancelReasonLabel;

  /// No description provided for @cancelReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Write the cancellation reason'**
  String get cancelReasonHint;

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// No description provided for @confirmCancellation.
  ///
  /// In en, this message translates to:
  /// **'Confirm cancellation'**
  String get confirmCancellation;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled.'**
  String get orderCancelled;

  /// No description provided for @onlyAdminCanPrint.
  ///
  /// In en, this message translates to:
  /// **'Only the responsible officer can print reports.'**
  String get onlyAdminCanPrint;

  /// No description provided for @onlyCompletedCanPrint.
  ///
  /// In en, this message translates to:
  /// **'Only completed orders can be printed.'**
  String get onlyCompletedCanPrint;

  /// No description provided for @reportReady.
  ///
  /// In en, this message translates to:
  /// **'Report ready for printing.'**
  String get reportReady;

  /// No description provided for @reportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate report: {error}'**
  String reportFailed(String error);

  /// No description provided for @printReportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Print report'**
  String get printReportTooltip;

  /// No description provided for @stageImageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Stage image uploaded successfully.'**
  String get stageImageUploaded;

  /// No description provided for @stageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload stage image: {error}'**
  String stageUploadFailed(String error);

  /// No description provided for @uploadFactoryImage.
  ///
  /// In en, this message translates to:
  /// **'Upload fabrication image'**
  String get uploadFactoryImage;

  /// No description provided for @uploadInstallationImage.
  ///
  /// In en, this message translates to:
  /// **'Upload installation image'**
  String get uploadInstallationImage;

  /// No description provided for @noImagesYet.
  ///
  /// In en, this message translates to:
  /// **'No images uploaded yet.'**
  String get noImagesYet;

  /// No description provided for @stageMediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Fabrication & Installation images'**
  String get stageMediaTitle;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetailsTitle;

  /// No description provided for @refLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get refLabel;

  /// No description provided for @categoryLabelDetail.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabelDetail;

  /// No description provided for @typeLabelDetail.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabelDetail;

  /// No description provided for @deliveryLabelDetail.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get deliveryLabelDetail;

  /// No description provided for @createdLabelDetail.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdLabelDetail;

  /// No description provided for @completedLabelDetail.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabelDetail;

  /// No description provided for @customerAndSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer & Seller'**
  String get customerAndSellerTitle;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @mapLabel.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapLabel;

  /// No description provided for @sellerLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerLabel;

  /// No description provided for @materialAndCostTitle.
  ///
  /// In en, this message translates to:
  /// **'Material & Cost'**
  String get materialAndCostTitle;

  /// No description provided for @materialLabel.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get materialLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @pdfLabel.
  ///
  /// In en, this message translates to:
  /// **'PDF file'**
  String get pdfLabel;

  /// No description provided for @tileCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Tile code'**
  String get tileCodeLabel;

  /// No description provided for @materialImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Material image'**
  String get materialImageLabel;

  /// No description provided for @tapToZoom.
  ///
  /// In en, this message translates to:
  /// **'Tap to zoom'**
  String get tapToZoom;

  /// No description provided for @descriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionTitle;

  /// No description provided for @rejectReasonTitleDetail.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get rejectReasonTitleDetail;

  /// No description provided for @rejectedByLine.
  ///
  /// In en, this message translates to:
  /// **'Rejected by: {name}'**
  String rejectedByLine(String name);

  /// No description provided for @noReason.
  ///
  /// In en, this message translates to:
  /// **'No reason'**
  String get noReason;

  /// No description provided for @rejectionDateLine.
  ///
  /// In en, this message translates to:
  /// **'Rejection date: {date}'**
  String rejectionDateLine(String date);

  /// No description provided for @cancellationTitleDetail.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get cancellationTitleDetail;

  /// No description provided for @editPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit request pending approval'**
  String get editPendingTitle;

  /// No description provided for @editReasonLine.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String editReasonLine(String reason);

  /// No description provided for @editPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval from the responsible officer account.'**
  String get editPendingBody;

  /// No description provided for @editApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit approved'**
  String get editApprovedTitle;

  /// No description provided for @editApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'The edit was approved; the order is now editable.'**
  String get editApprovedBody;

  /// No description provided for @attachedFile.
  ///
  /// In en, this message translates to:
  /// **'Attached file'**
  String get attachedFile;

  /// No description provided for @invalidLink.
  ///
  /// In en, this message translates to:
  /// **'Invalid link.'**
  String get invalidLink;

  /// No description provided for @cannotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get cannotOpenLink;

  /// No description provided for @swipeHintAcceptReject.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to accept or left to reject'**
  String get swipeHintAcceptReject;

  /// No description provided for @swipeHintSendInstallation.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to send the order for installation'**
  String get swipeHintSendInstallation;

  /// No description provided for @swipeHintFinish.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to finish the order'**
  String get swipeHintFinish;

  /// No description provided for @sendToInstallation.
  ///
  /// In en, this message translates to:
  /// **'Send to installation'**
  String get sendToInstallation;

  /// No description provided for @finishOrder.
  ///
  /// In en, this message translates to:
  /// **'Finish order'**
  String get finishOrder;

  /// No description provided for @acceptShort.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptShort;

  /// No description provided for @rejectShort.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectShort;

  /// No description provided for @withoutPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get withoutPhone;

  /// No description provided for @deliveryLine.
  ///
  /// In en, this message translates to:
  /// **'Delivery: {date}'**
  String deliveryLine(String date);

  /// No description provided for @rejectionReasonLine.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason: {reason}'**
  String rejectionReasonLine(String reason);

  /// No description provided for @rejectedByName.
  ///
  /// In en, this message translates to:
  /// **'Rejected by: {name}'**
  String rejectedByName(String name);

  /// No description provided for @cancellationReasonLine.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason: {reason}'**
  String cancellationReasonLine(String reason);

  /// No description provided for @editPendingApprovalCard.
  ///
  /// In en, this message translates to:
  /// **'Edit request awaiting management approval'**
  String get editPendingApprovalCard;

  /// No description provided for @editApprovedCard.
  ///
  /// In en, this message translates to:
  /// **'Edit request approved'**
  String get editApprovedCard;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @editAndResubmit.
  ///
  /// In en, this message translates to:
  /// **'Edit & resubmit'**
  String get editAndResubmit;

  /// No description provided for @acceptOrder.
  ///
  /// In en, this message translates to:
  /// **'Accept order'**
  String get acceptOrder;

  /// No description provided for @rejectTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reject order'**
  String get rejectTooltip;

  /// No description provided for @cancelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelTooltip;

  /// No description provided for @requestEditBtn.
  ///
  /// In en, this message translates to:
  /// **'Request order edit'**
  String get requestEditBtn;

  /// No description provided for @editOrderBtn.
  ///
  /// In en, this message translates to:
  /// **'Edit order'**
  String get editOrderBtn;

  /// No description provided for @editPendingApprovalShort.
  ///
  /// In en, this message translates to:
  /// **'Edit request awaiting management approval'**
  String get editPendingApprovalShort;

  /// No description provided for @acceptOrderQuestion.
  ///
  /// In en, this message translates to:
  /// **'Accept the order?'**
  String get acceptOrderQuestion;

  /// No description provided for @acceptOrderDetail.
  ///
  /// In en, this message translates to:
  /// **'Order #{ref} will be accepted and moved to the next stage.'**
  String acceptOrderDetail(String ref);

  /// No description provided for @selectedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected date'**
  String get selectedDateLabel;

  /// No description provided for @chooseDateBtn.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get chooseDateBtn;

  /// No description provided for @ordersToday.
  ///
  /// In en, this message translates to:
  /// **'Orders today ({count})'**
  String ordersToday(int count);

  /// No description provided for @noOrdersOnDate.
  ///
  /// In en, this message translates to:
  /// **'No orders on this date'**
  String get noOrdersOnDate;

  /// No description provided for @editOrderAfterApproval.
  ///
  /// In en, this message translates to:
  /// **'Edit order (after approval)'**
  String get editOrderAfterApproval;

  /// No description provided for @editOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit order'**
  String get editOrderTitle;

  /// No description provided for @newOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get newOrderTitle;

  /// No description provided for @cancelOrderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrderTooltip;

  /// No description provided for @refNumberSection.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get refNumberSection;

  /// No description provided for @serialNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Serial number'**
  String get serialNumberLabel;

  /// No description provided for @generatingSerial.
  ///
  /// In en, this message translates to:
  /// **'Generating serial number...'**
  String get generatingSerial;

  /// No description provided for @salesNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales Number'**
  String get salesNumberLabel;

  /// No description provided for @salesNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Sales number is required.'**
  String get salesNumberRequired;

  /// No description provided for @requestTypeSection.
  ///
  /// In en, this message translates to:
  /// **'Order type'**
  String get requestTypeSection;

  /// No description provided for @fabricationChip.
  ///
  /// In en, this message translates to:
  /// **'Fabrication'**
  String get fabricationChip;

  /// No description provided for @installationChip.
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get installationChip;

  /// No description provided for @customerSection.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerSection;

  /// No description provided for @sellerField.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerField;

  /// No description provided for @customerNameField.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get customerNameField;

  /// No description provided for @customerPhoneField.
  ///
  /// In en, this message translates to:
  /// **'Customer phone'**
  String get customerPhoneField;

  /// No description provided for @customerAddressField.
  ///
  /// In en, this message translates to:
  /// **'Customer address'**
  String get customerAddressField;

  /// No description provided for @addressUrlField.
  ///
  /// In en, this message translates to:
  /// **'Address link (map)'**
  String get addressUrlField;

  /// No description provided for @detailsSection.
  ///
  /// In en, this message translates to:
  /// **'Details & material'**
  String get detailsSection;

  /// No description provided for @orderTitleField.
  ///
  /// In en, this message translates to:
  /// **'Order title'**
  String get orderTitleField;

  /// No description provided for @categoryField.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryField;

  /// No description provided for @materialField.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get materialField;

  /// No description provided for @quantityField.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityField;

  /// No description provided for @deliveryDateField.
  ///
  /// In en, this message translates to:
  /// **'Delivery date'**
  String get deliveryDateField;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @tileCodeField.
  ///
  /// In en, this message translates to:
  /// **'Tile code (optional)'**
  String get tileCodeField;

  /// No description provided for @tileImageNone.
  ///
  /// In en, this message translates to:
  /// **'Tile image: none'**
  String get tileImageNone;

  /// No description provided for @tileImageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Tile image: uploaded'**
  String get tileImageUploaded;

  /// No description provided for @chooseImageBtn.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get chooseImageBtn;

  /// No description provided for @pdfNone.
  ///
  /// In en, this message translates to:
  /// **'PDF file: none'**
  String get pdfNone;

  /// No description provided for @pdfName.
  ///
  /// In en, this message translates to:
  /// **'PDF file: {name}'**
  String pdfName(String name);

  /// No description provided for @removeFileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove file'**
  String get removeFileTooltip;

  /// No description provided for @choosePdfBtn.
  ///
  /// In en, this message translates to:
  /// **'Choose PDF file'**
  String get choosePdfBtn;

  /// No description provided for @changePdfBtn.
  ///
  /// In en, this message translates to:
  /// **'Change file'**
  String get changePdfBtn;

  /// No description provided for @descriptionField.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionField;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @saveAndResubmit.
  ///
  /// In en, this message translates to:
  /// **'Save & resubmit'**
  String get saveAndResubmit;

  /// No description provided for @submitOrderBtn.
  ///
  /// In en, this message translates to:
  /// **'Submit order'**
  String get submitOrderBtn;

  /// No description provided for @refRequired.
  ///
  /// In en, this message translates to:
  /// **'Order number is required.'**
  String get refRequired;

  /// No description provided for @customerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Customer name is required.'**
  String get customerNameRequired;

  /// No description provided for @customerPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Customer phone is required.'**
  String get customerPhoneRequired;

  /// No description provided for @orderTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Order title is required.'**
  String get orderTitleRequired;

  /// No description provided for @materialQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the material and quantity correctly.'**
  String get materialQuantityInvalid;

  /// No description provided for @tileImageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload tile image: {error}'**
  String tileImageUploadFailed(String error);

  /// No description provided for @pdfUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload PDF file: {error}'**
  String pdfUploadFailed(String error);

  /// No description provided for @editResubmittedForReview.
  ///
  /// In en, this message translates to:
  /// **'Order edited and resubmitted for review.'**
  String get editResubmittedForReview;

  /// No description provided for @editResubmitted.
  ///
  /// In en, this message translates to:
  /// **'Order edited and resubmitted successfully.'**
  String get editResubmitted;

  /// No description provided for @orderAdded.
  ///
  /// In en, this message translates to:
  /// **'Order added successfully.'**
  String get orderAdded;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save order: {error}'**
  String saveFailed(String error);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders History'**
  String get historyTitle;

  /// No description provided for @downloadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Download orders report'**
  String get downloadTooltip;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by number, title, customer, material...'**
  String get historySearchHint;

  /// No description provided for @clearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchTooltip;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching orders'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try changing the filter or search keyword.'**
  String get historyEmptyMessage;

  /// No description provided for @noOrdersForReport.
  ///
  /// In en, this message translates to:
  /// **'No orders in the current filter to generate a report.'**
  String get noOrdersForReport;

  /// No description provided for @singleReportReady.
  ///
  /// In en, this message translates to:
  /// **'Order report ready for printing.'**
  String get singleReportReady;

  /// No description provided for @listReportReady.
  ///
  /// In en, this message translates to:
  /// **'Orders report ready for printing.'**
  String get listReportReady;

  /// No description provided for @openMapLink.
  ///
  /// In en, this message translates to:
  /// **'Open address link on map'**
  String get openMapLink;

  /// No description provided for @printOrderReport.
  ///
  /// In en, this message translates to:
  /// **'Print this order\'s report'**
  String get printOrderReport;

  /// No description provided for @timelineCreated.
  ///
  /// In en, this message translates to:
  /// **'Order created'**
  String get timelineCreated;

  /// No description provided for @timelineAccepted.
  ///
  /// In en, this message translates to:
  /// **'Order accepted'**
  String get timelineAccepted;

  /// No description provided for @timelineCompleted.
  ///
  /// In en, this message translates to:
  /// **'Order completed'**
  String get timelineCompleted;

  /// No description provided for @timelineRejected.
  ///
  /// In en, this message translates to:
  /// **'Order rejected'**
  String get timelineRejected;

  /// No description provided for @timelineCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get timelineCancelled;

  /// No description provided for @reasonColon.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String reasonColon(String reason);

  /// No description provided for @detailSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get detailSeller;

  /// No description provided for @detailCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get detailCustomer;

  /// No description provided for @detailPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get detailPhone;

  /// No description provided for @detailAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get detailAddress;

  /// No description provided for @detailMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get detailMaterial;

  /// No description provided for @detailQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get detailQuantity;

  /// No description provided for @detailTileCode.
  ///
  /// In en, this message translates to:
  /// **'Tile code'**
  String get detailTileCode;

  /// No description provided for @detailDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get detailDescription;

  /// No description provided for @detailHandover.
  ///
  /// In en, this message translates to:
  /// **'Delivery date'**
  String get detailHandover;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Enter your details to continue.'**
  String get loginWelcomeBack;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'user@example.com'**
  String get emailHint;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @loginLoading.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get loginLoading;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get createAccountLink;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect.'**
  String get loginInvalidCredentials;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in: {error}'**
  String loginFailed(String error);

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordDesc;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link has been sent to your email.'**
  String get resetLinkSent;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passwordStrengthFair;

  /// No description provided for @passwordStrengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordStrengthGood;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Very Strong'**
  String get passwordStrengthStrong;

  /// No description provided for @passwordReqLength.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordReqLength;

  /// No description provided for @passwordReqNumber.
  ///
  /// In en, this message translates to:
  /// **'Contains numbers or symbols'**
  String get passwordReqNumber;

  /// No description provided for @passwordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get passwordMatch;

  /// No description provided for @passwordMismatchHint.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatchHint;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @stepPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get stepPersonalInfo;

  /// No description provided for @stepRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get stepRole;

  /// No description provided for @stepSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security & Terms'**
  String get stepSecurity;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get nextStep;

  /// No description provided for @prevStep.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get prevStep;

  /// No description provided for @selectRoleFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select your role to proceed.'**
  String get selectRoleFirst;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get signupTitle;

  /// No description provided for @accountExistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account already exists'**
  String get accountExistsTitle;

  /// No description provided for @accountExistsBody.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. You can sign in directly.'**
  String get accountExistsBody;

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goToLogin;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use. Sign in instead of creating a new account.'**
  String get emailAlreadyExists;

  /// No description provided for @emailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email before signing in.'**
  String get emailNotConfirmed;

  /// No description provided for @emailRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Email sending limit exceeded. Try again shortly.'**
  String get emailRateLimit;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get nameRequired;

  /// No description provided for @emailInvalidMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get emailInvalidMsg;

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsMismatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordTooShort;

  /// No description provided for @policiesRequired.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the terms and privacy policy before creating an account.'**
  String get policiesRequired;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. You can now sign in.'**
  String get accountCreated;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to your email'**
  String get otpSubtitle;

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get otpCodeLabel;

  /// No description provided for @otpCodeHint.
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get otpCodeHint;

  /// No description provided for @otpVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerifyButton;

  /// No description provided for @otpResendLabel.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otpResendLabel;

  /// No description provided for @otpResendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get otpResendButton;

  /// No description provided for @otpInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code. Please try again.'**
  String get otpInvalidCode;

  /// No description provided for @otpCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Please request a new one.'**
  String get otpCodeExpired;

  /// No description provided for @otpCodeIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Please enter the full 6-digit code.'**
  String get otpCodeIncomplete;

  /// No description provided for @otpCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent to your email.'**
  String get otpCodeSent;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Policies'**
  String get termsTitle;

  /// No description provided for @termsSectionOne.
  ///
  /// In en, this message translates to:
  /// **'1. Terms of Use'**
  String get termsSectionOne;

  /// No description provided for @termsBodyOne.
  ///
  /// In en, this message translates to:
  /// **'Users must use the app legally and responsibly, and must not post illegal, offensive, or misleading content.'**
  String get termsBodyOne;

  /// No description provided for @termsSectionTwo.
  ///
  /// In en, this message translates to:
  /// **'2. Privacy Policy'**
  String get termsSectionTwo;

  /// No description provided for @termsBodyTwo.
  ///
  /// In en, this message translates to:
  /// **'Account data such as phone number and password are collected only to run the app and provide services, with a commitment to protecting information.'**
  String get termsBodyTwo;

  /// No description provided for @termsSectionThree.
  ///
  /// In en, this message translates to:
  /// **'3. Consent to Data Processing'**
  String get termsSectionThree;

  /// No description provided for @termsBodyThree.
  ///
  /// In en, this message translates to:
  /// **'You agree to the use of your data for logging in, managing orders, and sending important notifications related to your account or orders.'**
  String get termsBodyThree;

  /// No description provided for @termsSectionFour.
  ///
  /// In en, this message translates to:
  /// **'4. Account Responsibility'**
  String get termsSectionFour;

  /// No description provided for @termsBodyFour.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for keeping your login credentials confidential and for any activity carried out through your account.'**
  String get termsBodyFour;

  /// No description provided for @termsSectionFive.
  ///
  /// In en, this message translates to:
  /// **'5. Notifications & Communication'**
  String get termsSectionFive;

  /// No description provided for @termsBodyFive.
  ///
  /// In en, this message translates to:
  /// **'We may send you notifications related to your account or the status of orders and operations within the app.'**
  String get termsBodyFive;

  /// No description provided for @personalDataSection.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get personalDataSection;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ahmed Mohammed'**
  String get nameHint;

  /// No description provided for @roleInSystem.
  ///
  /// In en, this message translates to:
  /// **'Role in the System'**
  String get roleInSystem;

  /// No description provided for @passwordSection.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordSection;

  /// No description provided for @showHideTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show / Hide'**
  String get showHideTooltip;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @termsReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Please review the terms and policies before continuing. You must agree to them to create an account.'**
  String get termsReviewNote;

  /// No description provided for @viewTermsButton.
  ///
  /// In en, this message translates to:
  /// **'View Terms & Policies'**
  String get viewTermsButton;

  /// No description provided for @agreeCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Use, Privacy Policy, and Data Processing.'**
  String get agreeCheckbox;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @reportOrdersSummary.
  ///
  /// In en, this message translates to:
  /// **'Orders Summary'**
  String get reportOrdersSummary;

  /// No description provided for @reportDetailedHistory.
  ///
  /// In en, this message translates to:
  /// **'Detailed History ({count, plural, =1{1 order} other{{count} orders}})'**
  String reportDetailedHistory(int count);

  /// No description provided for @reportRef.
  ///
  /// In en, this message translates to:
  /// **'Ref #'**
  String get reportRef;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reportTitle;

  /// No description provided for @reportType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get reportType;

  /// No description provided for @reportStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get reportStatus;

  /// No description provided for @reportCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get reportCreated;

  /// No description provided for @reportAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get reportAccepted;

  /// No description provided for @reportDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get reportDelivered;

  /// No description provided for @reportReferenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference Number'**
  String get reportReferenceNumber;

  /// No description provided for @reportRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Title'**
  String get reportRequestTitle;

  /// No description provided for @reportRequestType.
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get reportRequestType;

  /// No description provided for @reportCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get reportCategory;

  /// No description provided for @reportSellerName.
  ///
  /// In en, this message translates to:
  /// **'Seller Name'**
  String get reportSellerName;

  /// No description provided for @reportCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get reportCustomerName;

  /// No description provided for @reportCustomerPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer Phone'**
  String get reportCustomerPhone;

  /// No description provided for @reportCustomerAddress.
  ///
  /// In en, this message translates to:
  /// **'Customer Address'**
  String get reportCustomerAddress;

  /// No description provided for @reportAddressMapLink.
  ///
  /// In en, this message translates to:
  /// **'Address Map Link'**
  String get reportAddressMapLink;

  /// No description provided for @reportMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get reportMaterial;

  /// No description provided for @reportQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get reportQuantity;

  /// No description provided for @reportTotalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get reportTotalPrice;

  /// No description provided for @reportTileCode.
  ///
  /// In en, this message translates to:
  /// **'Tile Code'**
  String get reportTileCode;

  /// No description provided for @reportDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reportDescription;

  /// No description provided for @reportHandoverDate.
  ///
  /// In en, this message translates to:
  /// **'Handover Date'**
  String get reportHandoverDate;

  /// No description provided for @reportCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get reportCreatedAt;

  /// No description provided for @reportAcceptedAt.
  ///
  /// In en, this message translates to:
  /// **'Accepted At'**
  String get reportAcceptedAt;

  /// No description provided for @reportCompletedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed At'**
  String get reportCompletedAt;

  /// No description provided for @reportRejectedAt.
  ///
  /// In en, this message translates to:
  /// **'Rejected At'**
  String get reportRejectedAt;

  /// No description provided for @reportRejectedBy.
  ///
  /// In en, this message translates to:
  /// **'Rejected By'**
  String get reportRejectedBy;

  /// No description provided for @reportRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get reportRejectionReason;

  /// No description provided for @reportCancelledAt.
  ///
  /// In en, this message translates to:
  /// **'Cancelled At'**
  String get reportCancelledAt;

  /// No description provided for @reportCancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Reason'**
  String get reportCancellationReason;

  /// No description provided for @reportStageEvidence.
  ///
  /// In en, this message translates to:
  /// **'Stage Evidence'**
  String get reportStageEvidence;

  /// No description provided for @reportNoStageMedia.
  ///
  /// In en, this message translates to:
  /// **'No stage media uploaded.'**
  String get reportNoStageMedia;

  /// No description provided for @reportNoNote.
  ///
  /// In en, this message translates to:
  /// **'No note'**
  String get reportNoNote;

  /// No description provided for @reportUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded: {time}'**
  String reportUploaded(String time);

  /// No description provided for @reportSignature.
  ///
  /// In en, this message translates to:
  /// **'Responsible Officer Signature: ____________________'**
  String get reportSignature;

  /// No description provided for @reportDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String reportDate(String date);

  /// No description provided for @reportMtaApp.
  ///
  /// In en, this message translates to:
  /// **'MTA App'**
  String get reportMtaApp;

  /// No description provided for @reportRequestCompletion.
  ///
  /// In en, this message translates to:
  /// **'Request Completion Report'**
  String get reportRequestCompletion;

  /// No description provided for @reportRequestsHistory.
  ///
  /// In en, this message translates to:
  /// **'Requests History Report'**
  String get reportRequestsHistory;

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated: {time}'**
  String reportGenerated(String time);

  /// No description provided for @reportGeneratedBy.
  ///
  /// In en, this message translates to:
  /// **'Generated by: {name}'**
  String reportGeneratedBy(String name);

  /// No description provided for @reportRequestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get reportRequestDetails;

  /// No description provided for @reportMaterialCost.
  ///
  /// In en, this message translates to:
  /// **'Material & Cost'**
  String get reportMaterialCost;

  /// No description provided for @reportStatusPendingTileFactory.
  ///
  /// In en, this message translates to:
  /// **'Pending Tile Factory'**
  String get reportStatusPendingTileFactory;

  /// No description provided for @reportStatusPendingWoodFactory.
  ///
  /// In en, this message translates to:
  /// **'Pending Wood Factory'**
  String get reportStatusPendingWoodFactory;

  /// No description provided for @reportStatusPendingInstallation.
  ///
  /// In en, this message translates to:
  /// **'Pending Installation'**
  String get reportStatusPendingInstallation;

  /// No description provided for @reportStatusPendingResubmission.
  ///
  /// In en, this message translates to:
  /// **'Pending Resubmission'**
  String get reportStatusPendingResubmission;

  /// No description provided for @reportStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get reportStatusInProgress;

  /// No description provided for @reportStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get reportStatusApproved;

  /// No description provided for @reportStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get reportStatusRejected;

  /// No description provided for @reportStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get reportStatusCompleted;

  /// No description provided for @reportStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get reportStatusCancelled;

  /// No description provided for @reportStatusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get reportStatusSubmitted;

  /// No description provided for @reportStatusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get reportStatusUnderReview;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Building Materials & Fabrication'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive management for tile, marble, and woodwork custom fabrication orders with precision.'**
  String get onboardingSlide1Subtitle;

  /// No description provided for @onboardingF1a.
  ///
  /// In en, this message translates to:
  /// **'Tile, Marble & Woodwork'**
  String get onboardingF1a;

  /// No description provided for @onboardingF1b.
  ///
  /// In en, this message translates to:
  /// **'Specs & Quantity Tracking'**
  String get onboardingF1b;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Factory & Site Installation Tracking'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time connection between production workshops and site installation teams stage by stage.'**
  String get onboardingSlide2Subtitle;

  /// No description provided for @onboardingF2a.
  ///
  /// In en, this message translates to:
  /// **'Factory Production Lines'**
  String get onboardingF2a;

  /// No description provided for @onboardingF2b.
  ///
  /// In en, this message translates to:
  /// **'On-Site Installation Teams'**
  String get onboardingF2b;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Visual Evidence & Handover Reports'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Photo verification for every fabrication stage, instant notifications, and certified PDF reports.'**
  String get onboardingSlide3Subtitle;

  /// No description provided for @onboardingF3a.
  ///
  /// In en, this message translates to:
  /// **'Stage Photo Documentation'**
  String get onboardingF3a;

  /// No description provided for @onboardingF3b.
  ///
  /// In en, this message translates to:
  /// **'Certified PDF Handover Reports'**
  String get onboardingF3b;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
