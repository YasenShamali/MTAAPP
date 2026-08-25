// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MTA';

  @override
  String get appVersion => 'MTA · Version 1.0.0';

  @override
  String get developedBy => 'App developed by Yasen Shamali';

  @override
  String get brandTagline =>
      'Fabrication & Installation Orders Management Platform';

  @override
  String get toastSuccess => 'Operation completed successfully';

  @override
  String get toastError => 'An error occurred';

  @override
  String get toastWarning => 'Warning';

  @override
  String get toastInfo => 'Note';

  @override
  String get roleSalesOfficer => 'Sales Officer';

  @override
  String get roleTileFactory => 'Tile Factory';

  @override
  String get roleWoodFactory => 'Wood Factory';

  @override
  String get roleInstallationOfficer => 'Installation Officer';

  @override
  String get roleResponsibleOfficer => 'Responsible Officer';

  @override
  String get roleSalesDescription => 'Create and edit orders';

  @override
  String get roleTileFactoryDescription => 'Review tile factory orders';

  @override
  String get roleWoodFactoryDescription => 'Review wood factory orders';

  @override
  String get roleInstallationDescription => 'Review installation orders';

  @override
  String get roleResponsibleDescription => 'Supervision and reports';

  @override
  String get statusPendingTileFactory => 'Pending Tile Factory';

  @override
  String get statusPendingWoodFactory => 'Pending Wood Factory';

  @override
  String get statusPendingInstallation => 'Pending Installation';

  @override
  String get statusPendingResubmission => 'Pending Resubmission';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get statusUnderReview => 'Under Review';

  @override
  String get filterAll => 'All orders';

  @override
  String get filterFactory => 'Factory orders';

  @override
  String get filterInstallation => 'Installation orders';

  @override
  String get filterApproved => 'Approved';

  @override
  String get filterRejected => 'Rejected';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get historyFilterAll => 'All';

  @override
  String get historyFilterPendingFactory => 'Pending factory';

  @override
  String get historyFilterPendingInstallation => 'Pending installation';

  @override
  String get historyFilterApproved => 'Approved';

  @override
  String get historyFilterInProgress => 'In progress';

  @override
  String get historyFilterCompleted => 'Completed';

  @override
  String get historyFilterRejected => 'Rejected';

  @override
  String get historyFilterCancelled => 'Cancelled';

  @override
  String get requestTypeFabrication => 'Fabrication';

  @override
  String get requestTypeInstallation => 'Installation';

  @override
  String get requestTypeBoth => 'Fabrication & Installation';

  @override
  String get stageFabrication => 'Fabrication';

  @override
  String get stageInstallation => 'Installation';

  @override
  String get tabOrders => 'Orders';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabAccount => 'Account';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get createNewOrder => 'Create new order';

  @override
  String get ordersHistory => 'Orders History';

  @override
  String get ordersHistorySubtitle =>
      'Full order history with printable report';

  @override
  String get changeProfilePhoto => 'Change profile photo';

  @override
  String get uploading => 'Uploading...';

  @override
  String get signOut => 'Sign Out';

  @override
  String signOutFailed(String error) {
    return 'Failed to sign out: $error';
  }

  @override
  String get profilePhotoUpdated => 'Profile photo updated successfully.';

  @override
  String photoUploadFailed(String error) {
    return 'Failed to upload photo: $error';
  }

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get searchHint => 'Search by number, name, phone, material...';

  @override
  String get clearSearch => 'Clear';

  @override
  String get statFactory => 'Factory';

  @override
  String get statInstallation => 'Installation';

  @override
  String get statCompleted => 'Completed';

  @override
  String get statApproved => 'Approved';

  @override
  String get statRejected => 'Rejected';

  @override
  String get noSearchResults => 'No results match your search';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get noOrdersInCategory => 'No orders in this category';

  @override
  String get loadFailed => 'Failed to load data';

  @override
  String get retry => 'Retry';

  @override
  String get noItemsToShow => 'Nothing to show right now';

  @override
  String get refresh => 'Refresh';

  @override
  String get editRequestTitle => 'Request order edit';

  @override
  String get editRequestExplanation =>
      'The order was accepted at one of the stages, so management approval is required for the edit. Write the reason.';

  @override
  String get editReasonLabel => 'Edit reason';

  @override
  String get editReasonHint => 'e.g. Change quantity or customer details';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get sendRequest => 'Send request';

  @override
  String get editReasonRequired => 'Please write a reason for the edit';

  @override
  String get editRequestSent =>
      'Edit request sent, awaiting management approval.';

  @override
  String editRequestFailed(String error) {
    return 'Failed to send edit request: $error';
  }

  @override
  String get approveEditTitle => 'Approve edit';

  @override
  String get rejectEditTitle => 'Reject edit request';

  @override
  String get editRequestReasonLabel => 'Edit request reason:';

  @override
  String get approveEditConfirm =>
      'The order data will become editable. Do you want to continue?';

  @override
  String get rejectEditConfirm =>
      'The order will not be edited. Do you want to continue?';

  @override
  String get approveEditAction => 'Approve';

  @override
  String get rejectOrderAction => 'Reject order';

  @override
  String get editApprovedMsg => 'Edit approved, the order is now editable.';

  @override
  String get editRejectedMsg => 'Edit request rejected.';

  @override
  String operationFailed(String error) {
    return 'Failed to complete the operation: $error';
  }

  @override
  String get rejectReasonTitle => 'Rejection reason';

  @override
  String get reasonTypeLabel => 'Reason type';

  @override
  String get timingInsufficient => 'Delivery timing is insufficient';

  @override
  String get otherReason => 'Other';

  @override
  String get chooseDeliveryDate => 'Choose the appropriate delivery date:';

  @override
  String get datePickerHelp => 'Choose the appropriate delivery date';

  @override
  String get reasonLabel => 'Reason';

  @override
  String get reasonHint => 'Write the rejection reason';

  @override
  String get rejectButton => 'Reject order';

  @override
  String get rejectReasonRequired => 'Please write a rejection reason';

  @override
  String rejectTimingMessage(String date) {
    return 'Delivery timing is insufficient, suitable date: $date';
  }

  @override
  String get orderRejected => 'Order rejected and returned to sender.';

  @override
  String rejectFailed(String error) {
    return 'Failed to reject order: $error';
  }

  @override
  String get orderAccepted => 'Order accepted.';

  @override
  String acceptFailed(String error) {
    return 'Failed to accept order: $error';
  }

  @override
  String get sentToInstallation => 'Order sent to installation worker.';

  @override
  String get finishedFromFactory => 'Order finished by factory.';

  @override
  String get orderFinished => 'Order finished.';

  @override
  String get cancelOrderTitle => 'Cancel order';

  @override
  String get cancelReasonLabel => 'Cancellation reason';

  @override
  String get cancelReasonHint => 'Write the cancellation reason';

  @override
  String get backLabel => 'Back';

  @override
  String get confirmCancellation => 'Confirm cancellation';

  @override
  String get orderCancelled => 'Order cancelled.';

  @override
  String get onlyAdminCanPrint =>
      'Only the responsible officer can print reports.';

  @override
  String get onlyCompletedCanPrint => 'Only completed orders can be printed.';

  @override
  String get reportReady => 'Report ready for printing.';

  @override
  String reportFailed(String error) {
    return 'Failed to generate report: $error';
  }

  @override
  String get printReportTooltip => 'Print report';

  @override
  String get stageImageUploaded => 'Stage image uploaded successfully.';

  @override
  String stageUploadFailed(String error) {
    return 'Failed to upload stage image: $error';
  }

  @override
  String get uploadFactoryImage => 'Upload fabrication image';

  @override
  String get uploadInstallationImage => 'Upload installation image';

  @override
  String get noImagesYet => 'No images uploaded yet.';

  @override
  String get stageMediaTitle => 'Fabrication & Installation images';

  @override
  String get orderDetailsTitle => 'Order details';

  @override
  String get refLabel => 'Reference';

  @override
  String get categoryLabelDetail => 'Category';

  @override
  String get typeLabelDetail => 'Type';

  @override
  String get deliveryLabelDetail => 'Delivery';

  @override
  String get createdLabelDetail => 'Created';

  @override
  String get completedLabelDetail => 'Completed';

  @override
  String get customerAndSellerTitle => 'Customer & Seller';

  @override
  String get customerLabel => 'Customer';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get addressLabel => 'Address';

  @override
  String get mapLabel => 'Map';

  @override
  String get sellerLabel => 'Seller';

  @override
  String get materialAndCostTitle => 'Material & Cost';

  @override
  String get materialLabel => 'Material';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get pdfLabel => 'PDF file';

  @override
  String get tileCodeLabel => 'Tile code';

  @override
  String get materialImageLabel => 'Material image';

  @override
  String get tapToZoom => 'Tap to zoom';

  @override
  String get descriptionTitle => 'Description';

  @override
  String get rejectReasonTitleDetail => 'Rejection reason';

  @override
  String rejectedByLine(String name) {
    return 'Rejected by: $name';
  }

  @override
  String get noReason => 'No reason';

  @override
  String rejectionDateLine(String date) {
    return 'Rejection date: $date';
  }

  @override
  String get cancellationTitleDetail => 'Cancellation reason';

  @override
  String get editPendingTitle => 'Edit request pending approval';

  @override
  String editReasonLine(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get editPendingBody =>
      'Awaiting approval from the responsible officer account.';

  @override
  String get editApprovedTitle => 'Edit approved';

  @override
  String get editApprovedBody =>
      'The edit was approved; the order is now editable.';

  @override
  String get attachedFile => 'Attached file';

  @override
  String get invalidLink => 'Invalid link.';

  @override
  String get cannotOpenLink => 'Could not open the link.';

  @override
  String get swipeHintAcceptReject => 'Swipe right to accept or left to reject';

  @override
  String get swipeHintSendInstallation =>
      'Swipe right to send the order for installation';

  @override
  String get swipeHintFinish => 'Swipe right to finish the order';

  @override
  String get sendToInstallation => 'Send to installation';

  @override
  String get finishOrder => 'Finish order';

  @override
  String get acceptShort => 'Accept';

  @override
  String get rejectShort => 'Reject';

  @override
  String get withoutPhone => 'No phone';

  @override
  String deliveryLine(String date) {
    return 'Delivery: $date';
  }

  @override
  String rejectionReasonLine(String reason) {
    return 'Rejection reason: $reason';
  }

  @override
  String rejectedByName(String name) {
    return 'Rejected by: $name';
  }

  @override
  String cancellationReasonLine(String reason) {
    return 'Cancellation reason: $reason';
  }

  @override
  String get editPendingApprovalCard =>
      'Edit request awaiting management approval';

  @override
  String get editApprovedCard => 'Edit request approved';

  @override
  String get totalLabel => 'Total';

  @override
  String get editAndResubmit => 'Edit & resubmit';

  @override
  String get acceptOrder => 'Accept order';

  @override
  String get rejectTooltip => 'Reject order';

  @override
  String get cancelTooltip => 'Cancel order';

  @override
  String get requestEditBtn => 'Request order edit';

  @override
  String get editOrderBtn => 'Edit order';

  @override
  String get editPendingApprovalShort =>
      'Edit request awaiting management approval';

  @override
  String get acceptOrderQuestion => 'Accept the order?';

  @override
  String acceptOrderDetail(String ref) {
    return 'Order #$ref will be accepted and moved to the next stage.';
  }

  @override
  String get selectedDateLabel => 'Selected date';

  @override
  String get chooseDateBtn => 'Choose';

  @override
  String ordersToday(int count) {
    return 'Orders today ($count)';
  }

  @override
  String get noOrdersOnDate => 'No orders on this date';

  @override
  String get editOrderAfterApproval => 'Edit order (after approval)';

  @override
  String get editOrderTitle => 'Edit order';

  @override
  String get newOrderTitle => 'New order';

  @override
  String get cancelOrderTooltip => 'Cancel order';

  @override
  String get refNumberSection => 'Order number';

  @override
  String get serialNumberLabel => 'Serial number';

  @override
  String get generatingSerial => 'Generating serial number...';

  @override
  String get salesNumberLabel => 'Sales Number';

  @override
  String get salesNumberRequired => 'Sales number is required.';

  @override
  String get requestTypeSection => 'Order type';

  @override
  String get fabricationChip => 'Fabrication';

  @override
  String get installationChip => 'Installation';

  @override
  String get customerSection => 'Customer';

  @override
  String get sellerField => 'Seller';

  @override
  String get customerNameField => 'Customer name';

  @override
  String get customerPhoneField => 'Customer phone';

  @override
  String get customerAddressField => 'Customer address';

  @override
  String get addressUrlField => 'Address link (map)';

  @override
  String get detailsSection => 'Details & material';

  @override
  String get orderTitleField => 'Order title';

  @override
  String get categoryField => 'Category';

  @override
  String get materialField => 'Material';

  @override
  String get quantityField => 'Quantity';

  @override
  String get deliveryDateField => 'Delivery date';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get tileCodeField => 'Tile code (optional)';

  @override
  String get tileImageNone => 'Tile image: none';

  @override
  String get tileImageUploaded => 'Tile image: uploaded';

  @override
  String get chooseImageBtn => 'Choose image';

  @override
  String get pdfNone => 'PDF file: none';

  @override
  String pdfName(String name) {
    return 'PDF file: $name';
  }

  @override
  String get removeFileTooltip => 'Remove file';

  @override
  String get choosePdfBtn => 'Choose PDF file';

  @override
  String get changePdfBtn => 'Change file';

  @override
  String get descriptionField => 'Description (optional)';

  @override
  String get submitting => 'Submitting...';

  @override
  String get saveAndResubmit => 'Save & resubmit';

  @override
  String get submitOrderBtn => 'Submit order';

  @override
  String get refRequired => 'Order number is required.';

  @override
  String get customerNameRequired => 'Customer name is required.';

  @override
  String get customerPhoneRequired => 'Customer phone is required.';

  @override
  String get orderTitleRequired => 'Order title is required.';

  @override
  String get materialQuantityInvalid =>
      'Please fill in the material and quantity correctly.';

  @override
  String tileImageUploadFailed(String error) {
    return 'Failed to upload tile image: $error';
  }

  @override
  String pdfUploadFailed(String error) {
    return 'Failed to upload PDF file: $error';
  }

  @override
  String get editResubmittedForReview =>
      'Order edited and resubmitted for review.';

  @override
  String get editResubmitted => 'Order edited and resubmitted successfully.';

  @override
  String get orderAdded => 'Order added successfully.';

  @override
  String saveFailed(String error) {
    return 'Failed to save order: $error';
  }

  @override
  String get historyTitle => 'Orders History';

  @override
  String get downloadTooltip => 'Download orders report';

  @override
  String get historySearchHint =>
      'Search by number, title, customer, material...';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String get historyEmptyTitle => 'No matching orders';

  @override
  String get historyEmptyMessage =>
      'Try changing the filter or search keyword.';

  @override
  String get noOrdersForReport =>
      'No orders in the current filter to generate a report.';

  @override
  String get singleReportReady => 'Order report ready for printing.';

  @override
  String get listReportReady => 'Orders report ready for printing.';

  @override
  String get openMapLink => 'Open address link on map';

  @override
  String get printOrderReport => 'Print this order\'s report';

  @override
  String get timelineCreated => 'Order created';

  @override
  String get timelineAccepted => 'Order accepted';

  @override
  String get timelineCompleted => 'Order completed';

  @override
  String get timelineRejected => 'Order rejected';

  @override
  String get timelineCancelled => 'Order cancelled';

  @override
  String reasonColon(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get detailSeller => 'Seller';

  @override
  String get detailCustomer => 'Customer';

  @override
  String get detailPhone => 'Phone';

  @override
  String get detailAddress => 'Address';

  @override
  String get detailMaterial => 'Material';

  @override
  String get detailQuantity => 'Quantity';

  @override
  String get detailTileCode => 'Tile code';

  @override
  String get detailDescription => 'Description';

  @override
  String get detailHandover => 'Delivery date';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginWelcomeBack =>
      'Welcome back! Enter your details to continue.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'user@example.com';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get loginLoading => 'Signing in...';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get createAccountLink => 'Create new account';

  @override
  String get loginInvalidCredentials => 'The email or password is incorrect.';

  @override
  String loginFailed(String error) {
    return 'Failed to sign in: $error';
  }

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordDesc =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetLinkSent =>
      'Password reset link has been sent to your email.';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthFair => 'Fair';

  @override
  String get passwordStrengthGood => 'Good';

  @override
  String get passwordStrengthStrong => 'Very Strong';

  @override
  String get passwordReqLength => 'At least 6 characters';

  @override
  String get passwordReqNumber => 'Contains numbers or symbols';

  @override
  String get passwordMatch => 'Passwords match';

  @override
  String get passwordMismatchHint => 'Passwords do not match';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get stepPersonalInfo => 'Basic Info';

  @override
  String get stepRole => 'Role';

  @override
  String get stepSecurity => 'Security & Terms';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get nextStep => 'Continue';

  @override
  String get prevStep => 'Back';

  @override
  String get selectRoleFirst => 'Please select your role to proceed.';

  @override
  String get signupTitle => 'Create new account';

  @override
  String get accountExistsTitle => 'Account already exists';

  @override
  String get accountExistsBody =>
      'This email is already registered. You can sign in directly.';

  @override
  String get closeLabel => 'Close';

  @override
  String get goToLogin => 'Go to login';

  @override
  String get emailAlreadyExists =>
      'This email is already in use. Sign in instead of creating a new account.';

  @override
  String get emailNotConfirmed =>
      'Please confirm your email before signing in.';

  @override
  String get emailRateLimit =>
      'Email sending limit exceeded. Try again shortly.';

  @override
  String get nameRequired => 'Please enter your name.';

  @override
  String get emailInvalidMsg => 'Please enter a valid email address.';

  @override
  String get passwordsMismatch => 'Passwords do not match.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get policiesRequired =>
      'You must agree to the terms and privacy policy before creating an account.';

  @override
  String get accountCreated =>
      'Account created successfully. You can now sign in.';

  @override
  String get otpTitle => 'Verify your email';

  @override
  String get otpSubtitle => 'We sent a 6-digit code to your email';

  @override
  String get otpCodeLabel => 'Enter the code';

  @override
  String get otpCodeHint => '000000';

  @override
  String get otpVerifyButton => 'Verify';

  @override
  String get otpResendLabel => 'Didn\'t receive the code?';

  @override
  String get otpResendButton => 'Resend';

  @override
  String get otpInvalidCode => 'Invalid or expired code. Please try again.';

  @override
  String get otpCodeExpired =>
      'This code has expired. Please request a new one.';

  @override
  String get otpCodeIncomplete => 'Please enter the full 6-digit code.';

  @override
  String get otpCodeSent => 'A new code has been sent to your email.';

  @override
  String get termsTitle => 'Terms & Policies';

  @override
  String get termsSectionOne => '1. Terms of Use';

  @override
  String get termsBodyOne =>
      'Users must use the app legally and responsibly, and must not post illegal, offensive, or misleading content.';

  @override
  String get termsSectionTwo => '2. Privacy Policy';

  @override
  String get termsBodyTwo =>
      'Account data such as phone number and password are collected only to run the app and provide services, with a commitment to protecting information.';

  @override
  String get termsSectionThree => '3. Consent to Data Processing';

  @override
  String get termsBodyThree =>
      'You agree to the use of your data for logging in, managing orders, and sending important notifications related to your account or orders.';

  @override
  String get termsSectionFour => '4. Account Responsibility';

  @override
  String get termsBodyFour =>
      'You are responsible for keeping your login credentials confidential and for any activity carried out through your account.';

  @override
  String get termsSectionFive => '5. Notifications & Communication';

  @override
  String get termsBodyFive =>
      'We may send you notifications related to your account or the status of orders and operations within the app.';

  @override
  String get personalDataSection => 'Personal Data';

  @override
  String get nameLabel => 'Full Name';

  @override
  String get nameHint => 'e.g. Ahmed Mohammed';

  @override
  String get roleInSystem => 'Role in the System';

  @override
  String get passwordSection => 'Password';

  @override
  String get showHideTooltip => 'Show / Hide';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get termsReviewNote =>
      'Please review the terms and policies before continuing. You must agree to them to create an account.';

  @override
  String get viewTermsButton => 'View Terms & Policies';

  @override
  String get agreeCheckbox =>
      'I agree to the Terms of Use, Privacy Policy, and Data Processing.';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get reportOrdersSummary => 'Orders Summary';

  @override
  String reportDetailedHistory(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
    );
    return 'Detailed History ($_temp0)';
  }

  @override
  String get reportRef => 'Ref #';

  @override
  String get reportTitle => 'Title';

  @override
  String get reportType => 'Type';

  @override
  String get reportStatus => 'Status';

  @override
  String get reportCreated => 'Created';

  @override
  String get reportAccepted => 'Accepted';

  @override
  String get reportDelivered => 'Delivered';

  @override
  String get reportReferenceNumber => 'Reference Number';

  @override
  String get reportRequestTitle => 'Request Title';

  @override
  String get reportRequestType => 'Request Type';

  @override
  String get reportCategory => 'Category';

  @override
  String get reportSellerName => 'Seller Name';

  @override
  String get reportCustomerName => 'Customer Name';

  @override
  String get reportCustomerPhone => 'Customer Phone';

  @override
  String get reportCustomerAddress => 'Customer Address';

  @override
  String get reportAddressMapLink => 'Address Map Link';

  @override
  String get reportMaterial => 'Material';

  @override
  String get reportQuantity => 'Quantity';

  @override
  String get reportTotalPrice => 'Total Price';

  @override
  String get reportTileCode => 'Tile Code';

  @override
  String get reportDescription => 'Description';

  @override
  String get reportHandoverDate => 'Handover Date';

  @override
  String get reportCreatedAt => 'Created At';

  @override
  String get reportAcceptedAt => 'Accepted At';

  @override
  String get reportCompletedAt => 'Completed At';

  @override
  String get reportRejectedAt => 'Rejected At';

  @override
  String get reportRejectedBy => 'Rejected By';

  @override
  String get reportRejectionReason => 'Rejection Reason';

  @override
  String get reportCancelledAt => 'Cancelled At';

  @override
  String get reportCancellationReason => 'Cancellation Reason';

  @override
  String get reportStageEvidence => 'Stage Evidence';

  @override
  String get reportNoStageMedia => 'No stage media uploaded.';

  @override
  String get reportNoNote => 'No note';

  @override
  String reportUploaded(String time) {
    return 'Uploaded: $time';
  }

  @override
  String get reportSignature =>
      'Responsible Officer Signature: ____________________';

  @override
  String reportDate(String date) {
    return 'Date: $date';
  }

  @override
  String get reportMtaApp => 'MTA App';

  @override
  String get reportRequestCompletion => 'Request Completion Report';

  @override
  String get reportRequestsHistory => 'Requests History Report';

  @override
  String reportGenerated(String time) {
    return 'Generated: $time';
  }

  @override
  String reportGeneratedBy(String name) {
    return 'Generated by: $name';
  }

  @override
  String get reportRequestDetails => 'Request Details';

  @override
  String get reportMaterialCost => 'Material & Cost';

  @override
  String get reportStatusPendingTileFactory => 'Pending Tile Factory';

  @override
  String get reportStatusPendingWoodFactory => 'Pending Wood Factory';

  @override
  String get reportStatusPendingInstallation => 'Pending Installation';

  @override
  String get reportStatusPendingResubmission => 'Pending Resubmission';

  @override
  String get reportStatusInProgress => 'In Progress';

  @override
  String get reportStatusApproved => 'Approved';

  @override
  String get reportStatusRejected => 'Rejected';

  @override
  String get reportStatusCompleted => 'Completed';

  @override
  String get reportStatusCancelled => 'Cancelled';

  @override
  String get reportStatusSubmitted => 'Submitted';

  @override
  String get reportStatusUnderReview => 'Under Review';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingSlide1Title => 'Building Materials & Fabrication';

  @override
  String get onboardingSlide1Subtitle =>
      'Comprehensive management for tile, marble, and woodwork custom fabrication orders with precision.';

  @override
  String get onboardingF1a => 'Tile, Marble & Woodwork';

  @override
  String get onboardingF1b => 'Specs & Quantity Tracking';

  @override
  String get onboardingSlide2Title => 'Factory & Site Installation Tracking';

  @override
  String get onboardingSlide2Subtitle =>
      'Real-time connection between production workshops and site installation teams stage by stage.';

  @override
  String get onboardingF2a => 'Factory Production Lines';

  @override
  String get onboardingF2b => 'On-Site Installation Teams';

  @override
  String get onboardingSlide3Title => 'Visual Evidence & Handover Reports';

  @override
  String get onboardingSlide3Subtitle =>
      'Photo verification for every fabrication stage, instant notifications, and certified PDF reports.';

  @override
  String get onboardingF3a => 'Stage Photo Documentation';

  @override
  String get onboardingF3b => 'Certified PDF Handover Reports';
}
