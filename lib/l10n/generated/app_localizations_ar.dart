// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'MTA';

  @override
  String get appVersion => 'MTA • الإصدار 1.0.0';

  @override
  String get developedBy => 'تم تطوير التطبيق بواسطة Yasen Shamali';

  @override
  String get brandTagline => 'منصة إدارة طلبات التصنيع والتركيب';

  @override
  String get toastSuccess => 'تمت العملية بنجاح';

  @override
  String get toastError => 'حدث خطأ';

  @override
  String get toastWarning => 'تنبيه';

  @override
  String get toastInfo => 'ملاحظة';

  @override
  String get roleSalesOfficer => 'رجل مبيعات';

  @override
  String get roleTileFactory => 'مصنع البلاط';

  @override
  String get roleWoodFactory => 'مصنع الخشب';

  @override
  String get roleInstallationOfficer => 'مسؤول التركيب';

  @override
  String get roleResponsibleOfficer => 'المسؤول العام';

  @override
  String get roleSalesDescription => 'إنشاء وتعديل الطلبات';

  @override
  String get roleTileFactoryDescription => 'مراجعة طلبات مصنع البلاط';

  @override
  String get roleWoodFactoryDescription => 'مراجعة طلبات مصنع الخشب';

  @override
  String get roleInstallationDescription => 'مراجعة طلبات التركيب';

  @override
  String get roleResponsibleDescription => 'إشراف وتقارير';

  @override
  String get statusPendingTileFactory => 'بانتظار مصنع البلاط';

  @override
  String get statusPendingWoodFactory => 'بانتظار مصنع الخشب';

  @override
  String get statusPendingInstallation => 'بانتظار التركيب';

  @override
  String get statusPendingResubmission => 'بانتظار إعادة الإرسال';

  @override
  String get statusInProgress => 'قيد التنفيذ';

  @override
  String get statusApproved => 'مقبول';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get statusSubmitted => 'مرسل';

  @override
  String get statusUnderReview => 'قيد المراجعة';

  @override
  String get filterAll => 'كل الطلبات';

  @override
  String get filterFactory => 'طلبات المصنع';

  @override
  String get filterInstallation => 'طلبات التركيب';

  @override
  String get filterApproved => 'المقبولة';

  @override
  String get filterRejected => 'المرفوضة';

  @override
  String get filterCompleted => 'المكتملة';

  @override
  String get historyFilterAll => 'الكل';

  @override
  String get historyFilterPendingFactory => 'بانتظار المصنع';

  @override
  String get historyFilterPendingInstallation => 'بانتظار التركيب';

  @override
  String get historyFilterApproved => 'مقبول';

  @override
  String get historyFilterInProgress => 'قيد التنفيذ';

  @override
  String get historyFilterCompleted => 'مكتمل';

  @override
  String get historyFilterRejected => 'مرفوض';

  @override
  String get historyFilterCancelled => 'ملغي';

  @override
  String get requestTypeFabrication => 'تفصيل';

  @override
  String get requestTypeInstallation => 'تركيب';

  @override
  String get requestTypeBoth => 'تفصيل وتركيب';

  @override
  String get stageFabrication => 'التصنيع';

  @override
  String get stageInstallation => 'التركيب';

  @override
  String get tabOrders => 'الطلبات';

  @override
  String get tabCalendar => 'التقويم';

  @override
  String get tabAccount => 'حسابي';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get createNewOrder => 'إنشاء طلب جديد';

  @override
  String get ordersHistory => 'سجل الطلبات';

  @override
  String get ordersHistorySubtitle => 'سجل كامل للطلبات مع تقرير للطباعة';

  @override
  String get changeProfilePhoto => 'تغيير الصورة الشخصية';

  @override
  String get uploading => 'جارٍ الرفع...';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String signOutFailed(String error) {
    return 'تعذر تسجيل الخروج: $error';
  }

  @override
  String get profilePhotoUpdated => 'تم تحديث الصورة الشخصية بنجاح.';

  @override
  String photoUploadFailed(String error) {
    return 'تعذر رفع الصورة: $error';
  }

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String get searchHint => 'بحث بالرقم، الاسم، الهاتف، المادة...';

  @override
  String get clearSearch => 'مسح';

  @override
  String get statFactory => 'المصنع';

  @override
  String get statInstallation => 'التركيب';

  @override
  String get statCompleted => 'مكتمل';

  @override
  String get statApproved => 'مقبول';

  @override
  String get statRejected => 'مرفوض';

  @override
  String get noSearchResults => 'لا توجد نتائج مطابقة للبحث';

  @override
  String get noOrdersYet => 'لا توجد طلبات بعد';

  @override
  String get noOrdersInCategory => 'لا توجد طلبات في هذه الفئة';

  @override
  String get loadFailed => 'تعذر تحميل البيانات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noItemsToShow => 'لا توجد عناصر لعرضها حاليًا';

  @override
  String get refresh => 'تحديث';

  @override
  String get editRequestTitle => 'طلب تعديل الطلب';

  @override
  String get editRequestExplanation =>
      'تم قبول الطلب من إحدى المراحل، لذلك يجب موافقة الإدارة على التعديل. اكتب سبب التعديل.';

  @override
  String get editReasonLabel => 'سبب التعديل';

  @override
  String get editReasonHint => 'مثال: تعديل الكمية أو بيانات العميل';

  @override
  String get cancelLabel => 'إلغاء';

  @override
  String get sendRequest => 'إرسال الطلب';

  @override
  String get editReasonRequired => 'يرجى كتابة سبب التعديل';

  @override
  String get editRequestSent => 'تم إرسال طلب التعديل بانتظار موافقة الإدارة.';

  @override
  String editRequestFailed(String error) {
    return 'تعذر إرسال طلب التعديل: $error';
  }

  @override
  String get approveEditTitle => 'اعتماد التعديل';

  @override
  String get rejectEditTitle => 'رفض طلب التعديل';

  @override
  String get editRequestReasonLabel => 'سبب طلب التعديل:';

  @override
  String get approveEditConfirm =>
      'ستصبح بيانات الطلب قابلة للتعديل. هل تريد المتابعة؟';

  @override
  String get rejectEditConfirm => 'لن يتم تعديل الطلب. هل تريد المتابعة؟';

  @override
  String get approveEditAction => 'اعتماد';

  @override
  String get rejectOrderAction => 'رفض الطلب';

  @override
  String get editApprovedMsg => 'تم اعتماد التعديل، أصبح الطلب قابلاً للتعديل.';

  @override
  String get editRejectedMsg => 'تم رفض طلب التعديل.';

  @override
  String operationFailed(String error) {
    return 'تعذر تنفيذ العملية: $error';
  }

  @override
  String get rejectReasonTitle => 'سبب الرفض';

  @override
  String get reasonTypeLabel => 'نوع السبب';

  @override
  String get timingInsufficient => 'توقيت التسليم غير كافي';

  @override
  String get otherReason => 'أخرى';

  @override
  String get chooseDeliveryDate => 'اختر التاريخ المناسب للتسليم:';

  @override
  String get datePickerHelp => 'اختر التاريخ المناسب للتسليم';

  @override
  String get reasonLabel => 'السبب';

  @override
  String get reasonHint => 'اكتب سبب الرفض';

  @override
  String get rejectButton => 'رفض الطلب';

  @override
  String get rejectReasonRequired => 'يرجى كتابة سبب الرفض';

  @override
  String rejectTimingMessage(String date) {
    return 'توقيت التسليم غير كافي، التاريخ المناسب: $date';
  }

  @override
  String get orderRejected => 'تم رفض الطلب وإرجاعه للمرسل.';

  @override
  String rejectFailed(String error) {
    return 'تعذر رفض الطلب: $error';
  }

  @override
  String get orderAccepted => 'تم قبول الطلب.';

  @override
  String acceptFailed(String error) {
    return 'تعذر قبول الطلب: $error';
  }

  @override
  String get sentToInstallation => 'تم إرسال الطلب إلى عامل التركيب.';

  @override
  String get finishedFromFactory => 'تم إنهاء الطلب من المصنع.';

  @override
  String get orderFinished => 'تم إنهاء الطلب.';

  @override
  String get cancelOrderTitle => 'إلغاء الطلب';

  @override
  String get cancelReasonLabel => 'سبب الإلغاء';

  @override
  String get cancelReasonHint => 'اكتب سبب الإلغاء';

  @override
  String get backLabel => 'تراجع';

  @override
  String get confirmCancellation => 'تأكيد الإلغاء';

  @override
  String get orderCancelled => 'تم إلغاء الطلب.';

  @override
  String get onlyAdminCanPrint => 'فقط المسؤول يمكنه طباعة التقارير.';

  @override
  String get onlyCompletedCanPrint => 'يمكن طباعة تقارير الطلبات المكتملة فقط.';

  @override
  String get reportReady => 'تم تجهيز التقرير للطباعة بنجاح.';

  @override
  String reportFailed(String error) {
    return 'تعذر إنشاء التقرير: $error';
  }

  @override
  String get printReportTooltip => 'طباعة التقرير';

  @override
  String get stageImageUploaded => 'تم رفع صورة المرحلة بنجاح.';

  @override
  String stageUploadFailed(String error) {
    return 'تعذر رفع صورة المرحلة: $error';
  }

  @override
  String get uploadFactoryImage => 'رفع صورة التصنيع';

  @override
  String get uploadInstallationImage => 'رفع صورة التركيب';

  @override
  String get noImagesYet => 'لا توجد صور مرفوعة بعد.';

  @override
  String get stageMediaTitle => 'صور التصنيع والتركيب';

  @override
  String get orderDetailsTitle => 'تفاصيل الطلب';

  @override
  String get refLabel => 'المرجع';

  @override
  String get categoryLabelDetail => 'الفئة';

  @override
  String get typeLabelDetail => 'النوع';

  @override
  String get deliveryLabelDetail => 'التسليم';

  @override
  String get createdLabelDetail => 'الإنشاء';

  @override
  String get completedLabelDetail => 'الإكمال';

  @override
  String get customerAndSellerTitle => 'العميل والبائع';

  @override
  String get customerLabel => 'العميل';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get mapLabel => 'الخريطة';

  @override
  String get sellerLabel => 'البائع';

  @override
  String get materialAndCostTitle => 'المواد والتكلفة';

  @override
  String get materialLabel => 'المادة';

  @override
  String get quantityLabel => 'الكمية';

  @override
  String get pdfLabel => 'ملف PDF';

  @override
  String get tileCodeLabel => 'كود البلاطة';

  @override
  String get materialImageLabel => 'صورة المادة';

  @override
  String get tapToZoom => 'اضغط لتكبير الصورة';

  @override
  String get descriptionTitle => 'الوصف';

  @override
  String get rejectReasonTitleDetail => 'سبب الرفض';

  @override
  String rejectedByLine(String name) {
    return 'قام برفض الطلب: $name';
  }

  @override
  String get noReason => 'بدون سبب';

  @override
  String rejectionDateLine(String date) {
    return 'تاريخ الرفض: $date';
  }

  @override
  String get cancellationTitleDetail => 'سبب الإلغاء';

  @override
  String get editPendingTitle => 'طلب تعديل بانتظار الموافقة';

  @override
  String editReasonLine(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get editPendingBody => 'بانتظار موافقة حساب المسؤول على التعديل.';

  @override
  String get editApprovedTitle => 'اعتماد التعديل';

  @override
  String get editApprovedBody =>
      'تمت الموافقة على التعديل، أصبح الطلب قابلاً للتعديل.';

  @override
  String get attachedFile => 'ملف مرفق';

  @override
  String get invalidLink => 'رابط غير صالح.';

  @override
  String get cannotOpenLink => 'تعذر فتح الرابط.';

  @override
  String get swipeHintAcceptReject => 'اسحب يميناً للقبول أو يساراً للرفض';

  @override
  String get swipeHintSendInstallation => 'اسحب يميناً لإرسال الطلب للتركيب';

  @override
  String get swipeHintFinish => 'اسحب يميناً لإنهاء الطلب';

  @override
  String get sendToInstallation => 'إرسال للتركيب';

  @override
  String get finishOrder => 'إنهاء الطلب';

  @override
  String get acceptShort => 'قبول';

  @override
  String get rejectShort => 'رفض';

  @override
  String get withoutPhone => 'بدون هاتف';

  @override
  String deliveryLine(String date) {
    return 'التسليم: $date';
  }

  @override
  String rejectionReasonLine(String reason) {
    return 'سبب الرفض: $reason';
  }

  @override
  String rejectedByName(String name) {
    return 'قام برفض الطلب: $name';
  }

  @override
  String cancellationReasonLine(String reason) {
    return 'سبب الإلغاء: $reason';
  }

  @override
  String get editPendingApprovalCard => 'طلب تعديل بانتظار موافقة الإدارة';

  @override
  String get editApprovedCard => 'تمت الموافقة على طلب التعديل';

  @override
  String get totalLabel => 'الإجمالي';

  @override
  String get editAndResubmit => 'تعديل وإعادة الإرسال';

  @override
  String get acceptOrder => 'قبول الطلب';

  @override
  String get rejectTooltip => 'رفض الطلب';

  @override
  String get cancelTooltip => 'إلغاء الطلب';

  @override
  String get requestEditBtn => 'طلب تعديل الطلب';

  @override
  String get editOrderBtn => 'تعديل الطلب';

  @override
  String get editPendingApprovalShort => 'طلب التعديل بانتظار موافقة الإدارة';

  @override
  String get acceptOrderQuestion => 'قبول الطلب؟';

  @override
  String acceptOrderDetail(String ref) {
    return 'سيتم قبول الطلب #$ref ومتابعته للمرحلة التالية.';
  }

  @override
  String get selectedDateLabel => 'التاريخ المحدد';

  @override
  String get chooseDateBtn => 'اختيار';

  @override
  String ordersToday(int count) {
    return 'طلبات هذا اليوم ($count)';
  }

  @override
  String get noOrdersOnDate => 'لا توجد طلبات في هذا التاريخ';

  @override
  String get editOrderAfterApproval => 'تعديل الطلب (بعد الموافقة)';

  @override
  String get editOrderTitle => 'تعديل الطلب';

  @override
  String get newOrderTitle => 'طلب جديد';

  @override
  String get cancelOrderTooltip => 'إلغاء الطلب';

  @override
  String get refNumberSection => 'رقم الطلب';

  @override
  String get serialNumberLabel => 'الرقم التسلسلي';

  @override
  String get generatingSerial => 'جارٍ توليد الرقم التسلسلي...';

  @override
  String get salesNumberLabel => 'رقم المبيعات';

  @override
  String get salesNumberRequired => 'رقم المبيعات مطلوب.';

  @override
  String get requestTypeSection => 'نوع الطلب';

  @override
  String get fabricationChip => 'تفصيل';

  @override
  String get installationChip => 'تركيب';

  @override
  String get customerSection => 'العميل';

  @override
  String get sellerField => 'البائع';

  @override
  String get customerNameField => 'اسم العميل';

  @override
  String get customerPhoneField => 'رقم العميل';

  @override
  String get customerAddressField => 'عنوان العميل';

  @override
  String get addressUrlField => 'رابط العنوان (خريطة)';

  @override
  String get detailsSection => 'التفاصيل والمواد';

  @override
  String get orderTitleField => 'عنوان الطلب';

  @override
  String get categoryField => 'الفئة';

  @override
  String get materialField => 'المادة';

  @override
  String get quantityField => 'الكمية';

  @override
  String get deliveryDateField => 'تاريخ التسليم';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get tileCodeField => 'كود البلاطة (اختياري)';

  @override
  String get tileImageNone => 'صورة البلاطة: لا يوجد';

  @override
  String get tileImageUploaded => 'صورة البلاطة: تم الرفع ✓';

  @override
  String get chooseImageBtn => 'اختيار صورة';

  @override
  String get pdfNone => 'ملف PDF: لا يوجد';

  @override
  String pdfName(String name) {
    return 'ملف PDF: $name';
  }

  @override
  String get removeFileTooltip => 'إزالة الملف';

  @override
  String get choosePdfBtn => 'اختيار ملف PDF';

  @override
  String get changePdfBtn => 'تغيير الملف';

  @override
  String get descriptionField => 'الوصف (اختياري)';

  @override
  String get submitting => 'جارٍ الإرسال...';

  @override
  String get saveAndResubmit => 'حفظ وإعادة الإرسال';

  @override
  String get submitOrderBtn => 'إرسال الطلب';

  @override
  String get refRequired => 'رقم الطلب مطلوب.';

  @override
  String get customerNameRequired => 'اسم العميل مطلوب.';

  @override
  String get customerPhoneRequired => 'رقم العميل مطلوب.';

  @override
  String get orderTitleRequired => 'عنوان الطلب مطلوب.';

  @override
  String get materialQuantityInvalid =>
      'يرجى تعبئة بيانات المادة والكمية بشكل صحيح.';

  @override
  String tileImageUploadFailed(String error) {
    return 'تعذر رفع صورة البلاطة: $error';
  }

  @override
  String pdfUploadFailed(String error) {
    return 'تعذر رفع ملف PDF: $error';
  }

  @override
  String get editResubmittedForReview =>
      'تم تعديل الطلب وإعادة إرساله للمراجعة.';

  @override
  String get editResubmitted => 'تم تعديل الطلب وإعادة إرساله بنجاح.';

  @override
  String get orderAdded => 'تم إضافة الطلب بنجاح.';

  @override
  String saveFailed(String error) {
    return 'تعذر حفظ الطلب: $error';
  }

  @override
  String get historyTitle => 'سجل الطلبات';

  @override
  String get downloadTooltip => 'تنزيل تقرير الطلبات';

  @override
  String get historySearchHint => 'بحث بالرقم، العنوان، العميل، المادة...';

  @override
  String get clearSearchTooltip => 'مسح البحث';

  @override
  String get historyEmptyTitle => 'لا توجد طلبات مطابقة';

  @override
  String get historyEmptyMessage => 'جرّب تغيير الفلتر أو كلمة البحث.';

  @override
  String get noOrdersForReport =>
      'لا توجد طلبات ضمن الفلتر الحالي لإنشاء تقرير.';

  @override
  String get singleReportReady => 'تم تجهيز تقرير الطلب للطباعة.';

  @override
  String get listReportReady => 'تم تجهيز تقرير الطلبات للطباعة.';

  @override
  String get openMapLink => 'فتح رابط العنوان على الخريطة';

  @override
  String get printOrderReport => 'طباعة تقرير هذا الطلب';

  @override
  String get timelineCreated => 'تم إنشاء الطلب';

  @override
  String get timelineAccepted => 'قبول الطلب';

  @override
  String get timelineCompleted => 'إنجاز الطلب';

  @override
  String get timelineRejected => 'رفض الطلب';

  @override
  String get timelineCancelled => 'إلغاء الطلب';

  @override
  String reasonColon(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get detailSeller => 'البائع';

  @override
  String get detailCustomer => 'العميل';

  @override
  String get detailPhone => 'الهاتف';

  @override
  String get detailAddress => 'العنوان';

  @override
  String get detailMaterial => 'المادة';

  @override
  String get detailQuantity => 'الكمية';

  @override
  String get detailTileCode => 'رمز البلاطة';

  @override
  String get detailDescription => 'الوصف';

  @override
  String get detailHandover => 'موعد التسليم';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginWelcomeBack => 'أهلاً بعودتك! أدخل بياناتك للمتابعة';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'user@example.com';

  @override
  String get emailInvalid => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get loginLoading => 'جارٍ تسجيل الدخول...';

  @override
  String get loginNoAccount => 'ليس لديك حساب؟';

  @override
  String get createAccountLink => 'إنشاء حساب جديد';

  @override
  String get loginInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String loginFailed(String error) {
    return 'تعذر تسجيل الدخول: $error';
  }

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get resetPasswordTitle => 'استعادة كلمة المرور';

  @override
  String get resetPasswordDesc =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.';

  @override
  String get sendResetLink => 'إرسال رابط الاستعادة';

  @override
  String get resetLinkSent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.';

  @override
  String get passwordStrengthWeak => 'ضعيفة';

  @override
  String get passwordStrengthFair => 'مقبولة';

  @override
  String get passwordStrengthGood => 'جيدة';

  @override
  String get passwordStrengthStrong => 'قوية جداً';

  @override
  String get passwordReqLength => '6 أحرف على الأقل';

  @override
  String get passwordReqNumber => 'تحتوي على رقم أو رمز';

  @override
  String get passwordMatch => 'كلمتا المرور متطابقتان';

  @override
  String get passwordMismatchHint => 'كلمتا المرور غير متطابقتين';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get stepPersonalInfo => 'البيانات الأساسية';

  @override
  String get stepRole => 'الدور الوظيفي';

  @override
  String get stepSecurity => 'الأمان والشروط';

  @override
  String stepOf(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get nextStep => 'المتابعة';

  @override
  String get prevStep => 'السابق';

  @override
  String get selectRoleFirst => 'يرجى اختيار الدور في المنظومة للمتابعة.';

  @override
  String get signupTitle => 'إنشاء حساب جديد';

  @override
  String get accountExistsTitle => 'الحساب موجود بالفعل';

  @override
  String get accountExistsBody =>
      'هذا البريد الإلكتروني مسجل مسبقًا. يمكنك تسجيل الدخول مباشرة.';

  @override
  String get closeLabel => 'إغلاق';

  @override
  String get goToLogin => 'الانتقال لتسجيل الدخول';

  @override
  String get emailAlreadyExists =>
      'هذا البريد الإلكتروني مستخدم بالفعل. سجّل الدخول بدل إنشاء حساب جديد.';

  @override
  String get emailNotConfirmed =>
      'يرجى تأكيد البريد الإلكتروني قبل تسجيل الدخول.';

  @override
  String get emailRateLimit =>
      'تم تجاوز حد إرسال الرسائل. حاول مجددًا بعد قليل.';

  @override
  String get nameRequired => 'يرجى إدخال الاسم.';

  @override
  String get emailInvalidMsg => 'يرجى إدخال بريد إلكتروني صالح.';

  @override
  String get passwordsMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get passwordTooShort => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.';

  @override
  String get policiesRequired =>
      'يجب الموافقة على الشروط وسياسة الخصوصية قبل إنشاء الحساب.';

  @override
  String get accountCreated =>
      'تم إنشاء الحساب بنجاح. يمكنك الآن تسجيل الدخول.';

  @override
  String get otpTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get otpSubtitle => 'أرسلنا رمزًا من 6 أرقام إلى بريدك الإلكتروني';

  @override
  String get otpCodeLabel => 'أدخل الرمز';

  @override
  String get otpCodeHint => '000000';

  @override
  String get otpVerifyButton => 'تحقق';

  @override
  String get otpResendLabel => 'لم تستلم الرمز؟';

  @override
  String get otpResendButton => 'إعادة الإرسال';

  @override
  String get otpInvalidCode => 'رمز غير صحيح أو منتهي الصلاحية. حاول مرة أخرى.';

  @override
  String get otpCodeExpired => 'انتهت صلاحية هذا الرمز. يرجى طلب رمز جديد.';

  @override
  String get otpCodeIncomplete => 'يرجى إدخال الرمز كاملًا (6 أرقام).';

  @override
  String get otpCodeSent => 'تم إرسال رمز جديد إلى بريدك الإلكتروني.';

  @override
  String get termsTitle => 'الشروط والسياسات';

  @override
  String get termsSectionOne => '1. شروط الاستخدام';

  @override
  String get termsBodyOne =>
      'يجب على المستخدم استخدام التطبيق بشكل قانوني ومسؤول، وعدم نشر محتوى مخالف أو مسيء أو مضلل.';

  @override
  String get termsSectionTwo => '2. سياسة الخصوصية';

  @override
  String get termsBodyTwo =>
      'سيتم جمع بيانات الحساب مثل رقم الهاتف وكلمة المرور لتشغيل التطبيق وتوفير الخدمات فقط، مع الالتزام بحماية المعلومات.';

  @override
  String get termsSectionThree => '3. الموافقة على معالجة البيانات';

  @override
  String get termsBodyThree =>
      'أنت توافق على استخدام بياناتك لتسجيل الدخول، إدارة العروض، وإرسال الإشعارات المهمة المتعلقة بحسابك أو الطلبات.';

  @override
  String get termsSectionFour => '4. مسؤولية الحساب';

  @override
  String get termsBodyFour =>
      'أنت مسؤول عن سرية بيانات الدخول الخاصة بك وعن أي نشاط يتم عبر حسابك.';

  @override
  String get termsSectionFive => '5. الإشعارات والتواصل';

  @override
  String get termsBodyFive =>
      'قد نرسل لك إشعارات تتعلق بحسابك أو بحالة العروض والعمليات داخل التطبيق.';

  @override
  String get personalDataSection => 'البيانات الشخصية';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get nameHint => 'مثال: أحمد محمد';

  @override
  String get roleInSystem => 'الدور في المنظومة';

  @override
  String get passwordSection => 'كلمة المرور';

  @override
  String get showHideTooltip => 'إظهار / إخفاء';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get termsReviewNote =>
      'يرجى مراجعة الشروط والسياسات قبل الإكمال. يجب الموافقة عليها لإنشاء الحساب.';

  @override
  String get viewTermsButton => 'عرض الشروط والسياسات';

  @override
  String get agreeCheckbox =>
      'أوافق على شروط الاستخدام وسياسة الخصوصية ومعالجة البيانات.';

  @override
  String get createAccountButton => 'إنشاء الحساب';

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
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingSlide1Title => 'منصة توريد وتصنيع مواد البناء';

  @override
  String get onboardingSlide1Subtitle =>
      'إدارة متكاملة لطلبات تفصيل الرخام، البلاط، وأعمال الخشب والمواد الإنشائية بكل دقة وسرعة.';

  @override
  String get onboardingF1a => 'تفصيل الرخام والبلاط والخشب';

  @override
  String get onboardingF1b => 'إدارة الكميات والمواصفات';

  @override
  String get onboardingSlide2Title => 'متابعة دقيقة للمصانع والتركيب';

  @override
  String get onboardingSlide2Subtitle =>
      'ربط فوري بين ورش الإنتاج ومسؤولي التركيب الميداني لمتابعة حالة كل طلب خطوة بخطوة.';

  @override
  String get onboardingF2a => 'خطوط إنتاج المصانع';

  @override
  String get onboardingF2b => 'التركيب الميداني المباشر';

  @override
  String get onboardingSlide3Title => 'توثيق مرحلي وتقارير تسليم معتمدة';

  @override
  String get onboardingSlide3Subtitle =>
      'توثيق بالصور لكل مرحلة تصنيع وتركيب، مع إشعارات فورية واعتماد تقارير تسليم رسمية.';

  @override
  String get onboardingF3a => 'توثيق مصوّر للمراحل';

  @override
  String get onboardingF3b => 'تقارير PDF معتمدة';
}
