import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/offer.dart';
import '../models/request_media.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../services/notification_service.dart';
import '../services/offer_service.dart';
import '../theme/app_theme.dart';
import '../utils/currency.dart';
import '../widgets/app_toast.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/glass.dart';
import '../widgets/presentation.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

AppLocalizations get _l10n => LocaleService.l10n;

String _roleDisplayLabel(String role) {
  switch (role) {
    case 'sales_officer':
      return _l10n.roleSalesOfficer;
    case 'factory_officer':
      return _l10n.roleTileFactory;
    case 'wood_factory_officer':
      return _l10n.roleWoodFactory;
    case 'company_officer':
      return _l10n.roleInstallationOfficer;
    case 'responsible_officer':
      return _l10n.roleResponsibleOfficer;
    default:
      return role;
  }
}

String _statusDisplayLabel(String status, {String? assignedRole}) {
  switch (status) {
    case 'pending_factory':
      return assignedRole == 'wood_factory_officer'
          ? _l10n.statusPendingWoodFactory
          : _l10n.statusPendingTileFactory;
    case 'pending_installation':
      return _l10n.statusPendingInstallation;
    case 'pending_resubmission':
      return _l10n.statusPendingResubmission;
    case 'in_progress':
      return _l10n.statusInProgress;
    case 'approved':
      return _l10n.statusApproved;
    case 'rejected':
      return _l10n.statusRejected;
    case 'completed':
      return _l10n.statusCompleted;
    case 'cancelled':
      return _l10n.statusCancelled;
    case 'submitted':
      return _l10n.statusSubmitted;
    case 'under_review':
      return _l10n.statusUnderReview;
    default:
      return status;
  }
}

String _rejectedByLabel(Offer offer) {
  final name = (offer.rejectedByName ?? '').trim();
  final role = (offer.rejectedByRole ?? '').trim();
  if (name.isEmpty && role.isEmpty) {
    return '';
  }
  final parts = <String>[
    if (name.isNotEmpty) name,
    if (role.isNotEmpty) _roleDisplayLabel(role),
  ];
  return parts.join(' • ');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Offer> _offers = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedOfferFilter = 'all';
  int _selectedTab = 0;
  String _profileName = 'User';
  String _profileRole = 'sales_officer';
  String _profileEmail = '';
  String _profileImageUrl = '';
  String _currentUserId = '';
  bool _isUploadingProfileImage = false;

  /// Id of the offer whose workflow action (accept/approve/reject/cancel/edit)
  /// is currently in flight. Drives the per-card loading overlay and blocks
  /// re-entrant taps so actions never run twice or look frozen.
  String? _processingOfferId;
  DateTime _selectedCalendarDay = DateTime.now();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadOffers();
    _initNotifications();
    pendingOfferIdNotifier.addListener(_onPendingOfferNotification);
    LocaleService.locale.addListener(_onLocaleChanged);
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      state,
    ) {
      if (state.session == null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initNotifications() async {
    await NotificationService.setup();
    await NotificationService.refreshToken();
  }

  void _onPendingOfferNotification() {
    final offerId = pendingOfferIdNotifier.value;
    if (offerId == null || !mounted) {
      return;
    }
    pendingOfferIdNotifier.value = null;
    Offer? offer;
    for (final o in _offers) {
      if (o.id == offerId) {
        offer = o;
        break;
      }
    }
    if (offer == null) {
      _loadOffers().then((_) {
        for (final o in _offers) {
          if (o.id == offerId) {
            _openOfferDetail(o);
            break;
          }
        }
      });
    } else {
      _openOfferDetail(offer);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _authSubscription?.cancel();
    LocaleService.locale.removeListener(_onLocaleChanged);
    pendingOfferIdNotifier.removeListener(_onPendingOfferNotification);
    super.dispose();
  }

  static const List<String> _bottomFilters = [
    'all',
    'pending_factory',
    'pending_installation',
    'approved',
    'rejected',
    'completed',
  ];

  String _tabTitle(int index) {
    switch (index) {
      case 0:
        return _l10n.tabOrders;
      case 1:
        return _l10n.tabCalendar;
      default:
        return _l10n.tabAccount;
    }
  }

  bool get _isSalesRole => _profileRole == 'sales_officer';
  bool get _isFactoryRole => _profileRole == 'factory_officer';
  bool get _isWoodFactoryRole => _profileRole == 'wood_factory_officer';
  bool get _isInstallerRole => _profileRole == 'company_officer';
  bool get _isResponsibleRole => _profileRole == 'responsible_officer';

  /// Whether the order has already been accepted by a factory or an
  /// installation worker. Editing such an order requires admin approval.
  bool _isOfferAccepted(Offer offer) =>
      offer.acceptedAt != null ||
      offer.status == 'approved' ||
      offer.status == 'completed';

  /// The order creator (sales officer / requester) or the responsible officer.
  bool _canEditOffer(Offer offer) {
    if (_isResponsibleRole) return true;
    if (_currentUserId.isEmpty) return _isSalesRole;
    return _isSalesRole ||
        offer.requesterId == _currentUserId ||
        offer.salesOfficerId == _currentUserId;
  }

  String _roleLabel(String role) => _roleDisplayLabel(role);

  bool _isFactoryStageRole(String? role) =>
      role == 'factory_officer' || role == 'wood_factory_officer';

  /// The user can review a factory-stage offer when they are responsible or
  /// when their own role matches the offer's assigned factory role.
  bool _isFactoryReviewer({
    required String? stageRole,
    required String status,
  }) {
    final isFactoryPending = status == 'pending_factory';
    final isFactoryStage = _isFactoryStageRole(stageRole);
    if (!(isFactoryStage || isFactoryPending)) {
      return false;
    }
    if (_isResponsibleRole) {
      return true;
    }
    return _profileRole == stageRole;
  }

  String _requestTypeLabel(String value) {
    switch (value) {
      case 'both':
        return _l10n.requestTypeBoth;
      case 'installation':
        return _l10n.requestTypeInstallation;
      default:
        return _l10n.requestTypeFabrication;
    }
  }

  String _categoryLabel(String value) {
    const map = {
      'vanity_top': 'VANITY TOP',
      'kitchen_top': 'KITCHEN TOP',
      'staircase': 'STAIRCASE',
      'threshold': 'TRESHOLD',
      'skirting': 'SKIRTING',
      'tiles_cutting': 'TILES CUTTING',
      'tables': 'TABLES',
      'kitchen_cabinet': 'KITCHEN CABINET',
      'vanity': 'VANITY',
      'wardrobe': 'WARDROBE',
      'doors': 'DOORS',
      'tv_unit': 'TV UNIT',
    };
    return map[value] ?? value;
  }

  String _filterLabel(String filter) {
    switch (filter) {
      case 'all':
        return _l10n.filterAll;
      case 'pending_factory':
        return _l10n.filterFactory;
      case 'pending_installation':
        return _l10n.filterInstallation;
      case 'approved':
        return _l10n.filterApproved;
      case 'rejected':
        return _l10n.filterRejected;
      case 'completed':
        return _l10n.filterCompleted;
      default:
        return filter;
    }
  }

  IconData _filterIcon(String filter) {
    switch (filter) {
      case 'all':
        return Icons.assignment_outlined;
      case 'pending_factory':
        return Icons.factory_outlined;
      case 'pending_installation':
        return Icons.build_outlined;
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.verified_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  List<Offer> get _filteredOffers {
    final byStatus = _selectedOfferFilter == 'all'
        ? _offers
        : _offers
              .where((offer) => offer.status == _selectedOfferFilter)
              .toList();
    return _applySearchQuery(byStatus);
  }

  List<Offer> _applySearchQuery(List<Offer> offers) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return offers;
    }
    return offers.where((offer) {
      final haystack = [
        offer.referenceNumber,
        offer.requestTitle,
        offer.customerName,
        offer.customerPhone,
        offer.sellerName,
        offer.material,
        offer.category,
        offer.tileCode,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  String get _emptyMessage {
    if (_searchQuery.trim().isNotEmpty) {
      return _l10n.noSearchResults;
    }
    return _selectedOfferFilter == 'all'
        ? _l10n.noOrdersYet
        : _l10n.noOrdersInCategory;
  }

  bool _isOverdue(Offer offer) {
    final handover = offer.handoverDate;
    if (handover == null) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(handover.year, handover.month, handover.day);
    return deadline.isBefore(today);
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }
    final local = value.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '-';
    }
    final local = value.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  // ─────────────────────────────── Data loading ───────────────────────────────

  Future<void> _loadOffers() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
      return;
    }

    try {
      final appUserId = await AuthService.getCurrentAppUserId();
      final profileRows = await Supabase.instance.client
          .from('users')
          .select('full_name, role, email, profile_image_url')
          .eq('auth_id', currentUser.id)
          .limit(1);

      var profileName = currentUser.email?.split('@').first ?? 'User';
      var profileRole = 'sales_officer';
      var profileEmail = currentUser.email ?? '';
      var profileImageUrl = '';

      if (profileRows.isNotEmpty) {
        final profile = profileRows.first;
        final dbName = (profile['full_name'] as String?)?.trim();
        final dbRole = (profile['role'] as String?)?.trim();
        final dbEmail = (profile['email'] as String?)?.trim();
        final dbProfileImageUrl = (profile['profile_image_url'] as String?)
            ?.trim();

        if (dbName != null && dbName.isNotEmpty) {
          profileName = dbName;
        }
        if (dbRole != null && dbRole.isNotEmpty) {
          profileRole = dbRole;
        }
        if (dbEmail != null && dbEmail.isNotEmpty) {
          profileEmail = dbEmail;
        }
        if (dbProfileImageUrl != null && dbProfileImageUrl.isNotEmpty) {
          profileImageUrl = dbProfileImageUrl;
        }
      }

      final data = await OfferService.fetchOffersForUser(
        appUserId,
        profileRole,
      );

      setState(() {
        _offers = data.map(Offer.fromJson).toList();
        _profileName = profileName;
        _profileRole = profileRole;
        _profileEmail = profileEmail;
        _profileImageUrl = profileImageUrl;
        _currentUserId = appUserId;
        _isLoading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.signOutFailed(error.toString()),
        type: AppToastType.error,
      );
    }
  }

  void _setOfferFilter(String filter) {
    setState(() {
      _selectedOfferFilter = filter;
    });
  }

  Future<void> _openCreateOffer() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateOfferScreen(sellerName: _profileName),
      ),
    );
    if (!mounted) return;
    _loadOffers();
  }

  void _openOrderHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderHistoryScreen(
          offers: List.of(_offers),
          generatedBy: _profileName,
        ),
      ),
    );
  }

  Future<void> _openEditOffer(Offer offer) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CreateOfferScreen(sellerName: _profileName, editOffer: offer),
      ),
    );
    if (!mounted) return;
    _loadOffers();
  }

  /// Lets the order creator request an edit for an already-accepted order.
  /// The edit is applied only after the responsible officer approves.
  Future<void> _requestOfferEdit(Offer offer) async {
    if (_processingOfferId != null) return;
    final reasonController = TextEditingController();
    String? reasonError;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(_l10n.editRequestTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _l10n.editRequestExplanation,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: _l10n.editReasonLabel,
                      hintText: _l10n.editReasonHint,
                      prefixIcon: const Icon(Icons.edit_outlined),
                      errorText: reasonError,
                    ),
                    minLines: 2,
                    maxLines: 4,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(_l10n.cancelLabel),
                ),
                FilledButton(
                  onPressed: () {
                    if (reasonController.text.trim().isEmpty) {
                      setDialogState(
                        () => reasonError = _l10n.editReasonRequired,
                      );
                      return;
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: Text(_l10n.sendRequest),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      return;
    }

    setState(() => _processingOfferId = offer.id);
    try {
      final requestorId = await AuthService.getCurrentAppUserId();
      await OfferService.requestOfferEdit(
        offerId: offer.id,
        requestedBy: requestorId,
        reason: reasonController.text.trim(),
      );
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.editRequestSent,
        type: AppToastType.success,
      );
      await _loadOffers();
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.editRequestFailed(error.toString()),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _processingOfferId = null);
    }
  }

  /// Responsible officer approves / rejects a pending edit request.
  Future<void> _resolveEditRequest(
    Offer offer, {
    required bool approved,
  }) async {
    if (_processingOfferId != null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final reason = offer.editRequestReason?.trim() ?? '';
        return AlertDialog(
          title: Text(
            approved ? _l10n.approveEditTitle : _l10n.rejectEditTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reason.isNotEmpty) ...[
                Text(
                  _l10n.editRequestReasonLabel,
                  style: const TextStyle(fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                approved
                    ? _l10n.approveEditConfirm
                    : _l10n.rejectEditConfirm,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_l10n.cancelLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                approved ? _l10n.approveEditAction : _l10n.rejectOrderAction,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _processingOfferId = offer.id);
    try {
      await OfferService.resolveOfferEditRequest(
        offerId: offer.id,
        approved: approved,
      );
      if (!mounted) return;
      AppToast.show(
        context,
        approved
            ? _l10n.editApprovedMsg
            : _l10n.editRejectedMsg,
        type: AppToastType.success,
      );
      await _loadOffers();
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.operationFailed(error.toString()),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _processingOfferId = null);
    }
  }

  // ─────────────────────────────── Workflow actions ───────────────────────────────

  /// Shows the rejection dialog and applies the rejection.
  /// Returns true when the offer was actually rejected.
  Future<bool> _showRejectDialog(Offer offer) async {
    final reasonController = TextEditingController();
    String? reasonError;
    var rejectType = 0; // 0 = delivery timing insufficient, 1 = other
    var suggestedDate = offer.handoverDate ?? DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isTiming = rejectType == 0;
            return AlertDialog(
              icon: const Icon(
                Icons.cancel_outlined,
                color: AppColors.danger,
                size: 40,
              ),
              title: Text(_l10n.rejectReasonTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: rejectType,
                      decoration: InputDecoration(
                        labelText: _l10n.reasonTypeLabel,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 0,
                          child: Text(_l10n.timingInsufficient),
                        ),
                        DropdownMenuItem(value: 1, child: Text(_l10n.otherReason)),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          rejectType = value;
                          reasonError = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (isTiming) ...[
                      Text(
                        _l10n.chooseDeliveryDate,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: suggestedDate,
                            firstDate: DateTime(DateTime.now().year - 1),
                            lastDate: DateTime(DateTime.now().year + 5),
                            helpText: _l10n.datePickerHelp,
                          );
                          if (picked != null) {
                            setDialogState(() {
                              suggestedDate = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.event_outlined),
                        label: Text(_formatDate(suggestedDate)),
                      ),
                    ] else ...[
                      TextField(
                        controller: reasonController,
                        decoration: InputDecoration(
                          labelText: _l10n.reasonLabel,
                          hintText: _l10n.reasonHint,
                          prefixIcon: const Icon(Icons.edit_outlined),
                          errorText: reasonError,
                        ),
                        minLines: 2,
                        maxLines: 4,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(_l10n.cancelLabel),
                ),
                FilledButton(
                  onPressed: () {
                    if (!isTiming && reasonController.text.trim().isEmpty) {
                      setDialogState(
                        () => reasonError = _l10n.rejectReasonRequired,
                      );
                      return;
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: Text(_l10n.rejectButton),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      return false;
    }
    if (_processingOfferId != null) return false;

    final rejectionReason = rejectType == 0
        ? _l10n.rejectTimingMessage(_formatDate(suggestedDate))
        : reasonController.text.trim();

    setState(() => _processingOfferId = offer.id);
    try {
      final reviewerId = await AuthService.getCurrentAppUserId();

      await OfferService.rejectOffer(
        offerId: offer.id,
        reviewerUserId: reviewerId,
        rejectionReason: rejectionReason,
      );

      if (!mounted) return false;
      AppToast.show(
        context,
        _l10n.orderRejected,
        type: AppToastType.success,
      );
      await _loadOffers();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      AppToast.show(
        context,
        _l10n.rejectFailed(error.toString()),
        type: AppToastType.error,
      );
      return false;
    } finally {
      if (mounted) setState(() => _processingOfferId = null);
    }
  }

  Future<void> _acceptOffer(Offer offer) async {
    if (_processingOfferId != null) return;
    setState(() => _processingOfferId = offer.id);
    try {
      final stageRole = _stageRoleForReview(offer);
      final reviewerId = await AuthService.getCurrentAppUserId();
      await OfferService.acceptOffer(
        offerId: offer.id,
        reviewerUserId: reviewerId,
        reviewerRole: _profileRole,
        currentAssignedRole: stageRole,
      );
      if (!mounted) return;
      AppToast.show(context, _l10n.orderAccepted, type: AppToastType.success);
      await _loadOffers();
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.acceptFailed(error.toString()),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _processingOfferId = null);
    }
  }

  Future<void> _approveOffer(
    Offer offer, {
    bool sendToInstallation = true,
  }) async {
    if (_processingOfferId != null) return;
    setState(() => _processingOfferId = offer.id);
    try {
      final stageRole = _stageRoleForReview(offer);
      final reviewerId = await AuthService.getCurrentAppUserId();
      await OfferService.approveOffer(
        offerId: offer.id,
        reviewerUserId: reviewerId,
        reviewerRole: _profileRole,
        currentAssignedRole: stageRole,
        sendToInstallation: sendToInstallation,
      );
      if (!mounted) return;

      final isFactoryDecision = _isFactoryStageRole(stageRole);

      final message = isFactoryDecision
          ? (sendToInstallation
                ? _l10n.sentToInstallation
                : _l10n.finishedFromFactory)
          : _l10n.orderFinished;

      AppToast.show(context, message, type: AppToastType.success);
      await _loadOffers();
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.acceptFailed(error.toString()),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _processingOfferId = null);
    }
  }

  String? _stageRoleForReview(Offer offer) {
    if (offer.assignedRole != null && offer.assignedRole!.trim().isNotEmpty) {
      return offer.assignedRole;
    }

    if (offer.status == 'pending_factory') {
      return 'factory_officer';
    }

    if (offer.status == 'pending_installation') {
      return 'company_officer';
    }

    return null;
  }

  Future<void> _cancelOffer(Offer offer) async {
    if (_processingOfferId != null) return;
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_l10n.cancelOrderTitle),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(
              labelText: _l10n.cancelReasonLabel,
              hintText: _l10n.cancelReasonHint,
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
            minLines: 2,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_l10n.backLabel),
            ),
            FilledButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: Text(_l10n.confirmCancellation),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    setState(() => _processingOfferId = offer.id);
    try {
      await OfferService.cancelOffer(
        offerId: offer.id,
        cancellationReason: reasonController.text.trim(),
      );

      if (!mounted) return;
      AppToast.show(context, _l10n.orderCancelled, type: AppToastType.success);
      await _loadOffers();
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.operationFailed(error.toString()),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _processingOfferId = null);
    }
  }

  Future<void> _uploadProfileImage() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );

    if (pickedFile == null) {
      return;
    }

    setState(() {
      _isUploadingProfileImage = true;
    });

    try {
      final bytes = await pickedFile.readAsBytes();
      final extension = _fileExtensionFromName(pickedFile.name);
      final objectPath =
          '${currentUser.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final storage = Supabase.instance.client.storage.from('user-avatars');
      await storage.uploadBinary(
        objectPath,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: _contentTypeForExtension(extension),
        ),
      );

      final publicUrl = storage.getPublicUrl(objectPath);

      await Supabase.instance.client
          .from('users')
          .update({'profile_image_url': publicUrl})
          .eq('auth_id', currentUser.id);

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'profile_image_url': publicUrl}),
      );

      if (!mounted) return;

      setState(() {
        _profileImageUrl = publicUrl;
      });

      AppToast.show(
        context,
        _l10n.profilePhotoUpdated,
        type: AppToastType.success,
      );
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.photoUploadFailed(error.toString()),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingProfileImage = false;
        });
      }
    }
  }

  // ─────────────────────────────── PDF report ───────────────────────────────

  String _statusLabelForReport(String status, {String? assignedRole}) {
    switch (status) {
      case 'pending_factory':
        return assignedRole == 'wood_factory_officer'
            ? 'Pending Wood Factory'
            : 'Pending Tile Factory';
      case 'pending_installation':
        return 'Pending Installation';
      case 'pending_resubmission':
        return 'Pending Resubmission';
      case 'in_progress':
        return 'In Progress';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'submitted':
        return 'Submitted';
      case 'under_review':
        return 'Under Review';
      default:
        return status;
    }
  }

  pw.Widget _buildDefaultReportHeader({
    required DateTime reportCreatedAt,
    required String generatedBy,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.blue300, width: 1.2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'MTA APP',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Text(
                'Request Completion Report',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.blue700),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated: ${_formatDateTime(reportCreatedAt)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Generated by: ${generatedBy.isEmpty ? '-' : generatedBy}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _requestTypeLabelForReport(String value) {
    switch (value) {
      case 'both':
        return 'Fabrication & Installation';
      case 'installation':
        return 'Installation';
      default:
        return 'Fabrication';
    }
  }

  String _stageLabelForReport(String stage) {
    switch (stage) {
      case 'tile':
        return 'Tile';
      case 'factory':
        return 'Factory';
      case 'installation':
        return 'Installation';
      case 'completion':
        return 'Completion';
      default:
        return stage;
    }
  }

  pw.TableRow _reportRow(String label, String value) {
    final normalizedValue = value.trim().isEmpty ? '-' : value.trim();
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(7),
          color: PdfColors.grey200,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(7),
          child: pw.Text(
            normalizedValue,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  Future<void> _printCompletedOfferReport(Offer offer) async {
    if (!_isResponsibleRole) {
      AppToast.show(
        context,
        _l10n.onlyAdminCanPrint,
        type: AppToastType.warning,
      );
      return;
    }

    if (offer.status != 'completed') {
      AppToast.show(
        context,
        _l10n.onlyCompletedCanPrint,
        type: AppToastType.warning,
      );
      return;
    }

    try {
      final mediaRows = await OfferService.fetchRequestMedia(offer.id);
      final media = mediaRows.map(RequestMedia.fromJson).toList();
      final safeReference = offer.referenceNumber.trim().isEmpty
          ? offer.id
          : offer.referenceNumber.trim();
      final reportCreatedAt = DateTime.now();

      final logoImage = await imageFromAssetBundle('assets/mta_logo.png');
      final document = pw.Document();

      document.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 60),
            buildBackground: (context) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Center(
                  child: pw.Opacity(
                    opacity: 0.08,
                    child: pw.Image(logoImage, width: 400),
                  ),
                ),
              );
            },
          ),
          header: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerLeft,
              margin: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Image(logoImage, width: 140),
            );
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.center,
              margin: const pw.EdgeInsets.only(top: 20),
              padding: const pw.EdgeInsets.only(top: 10),
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.blue900, width: 1.5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'Whatsapp: +971 58 873 1441, Tel. +971 6 528 0095, Tel No. +971 4 529 8277',
                    style: pw.TextStyle(fontSize: 8.5, color: PdfColors.blue900, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Head Office 508, Fairmont Office Towers, Trade Center 1, Sheikh Zayed Rd. Dubai, P.O. 57077',
                    style: pw.TextStyle(fontSize: 8.5, color: PdfColors.blue900, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Sharjah Office, King Faisal Road, Behind Maza Signal, Website: mta-investment.com, Email: info@mtainvestment.com',
                    style: pw.TextStyle(fontSize: 8.5, color: PdfColors.blue900, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            );
          },
          build: (context) {
            final mediaRowsForTable = media.isEmpty
                ? [_reportRow('Stage Evidence', 'No stage media uploaded.')]
                : media
                      .map(
                        (item) => _reportRow(
                          _stageLabelForReport(item.stage),
                          '${item.note.isEmpty ? 'No note' : item.note}\nUploaded: ${_formatDateTime(item.createdAt)}',
                        ),
                      )
                      .toList();

            return [
              _buildDefaultReportHeader(
                reportCreatedAt: reportCreatedAt,
                generatedBy: _profileName,
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Request Details',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.6,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.2),
                  1: const pw.FlexColumnWidth(3.8),
                },
                children: [
                  _reportRow('Reference Number', safeReference),
                  _reportRow('Request Title', offer.requestTitle),
                  _reportRow(
                    'Request Type',
                    _requestTypeLabelForReport(offer.requestType),
                  ),
                  _reportRow('Category', _categoryLabel(offer.category)),
                  _reportRow('Status', _statusLabelForReport(offer.status, assignedRole: offer.assignedRole)),
                  _reportRow('Seller Name', offer.sellerName),
                  _reportRow('Customer Name', offer.customerName),
                  _reportRow('Customer Phone', offer.customerPhone),
                  _reportRow('Handover Date', _formatDate(offer.handoverDate)),
                  _reportRow('Created At', _formatDateTime(offer.createdAt)),
                  _reportRow('Completed At', _formatDateTime(offer.approvedAt)),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Material & Cost',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.6,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.2),
                  1: const pw.FlexColumnWidth(3.8),
                },
                children: [
                  _reportRow('Material', offer.material),
                  _reportRow('Quantity', '${offer.quantity}'),
                  if (offer.totalPrice > 0)
                    _reportRow('Total Price', formatAEDLatin(offer.totalPrice)),
                  _reportRow('Tile Code', offer.tileCode),
                  _reportRow('Description', offer.description),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Stage Evidence',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.6,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.2),
                  1: const pw.FlexColumnWidth(3.8),
                },
                children: mediaRowsForTable,
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Responsible Officer Signature: ____________________',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Date: ${_formatDate(reportCreatedAt)}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (_) async => document.save(),
        name: 'completed_request_$safeReference.pdf',
      );

      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.reportReady,
        type: AppToastType.success,
      );
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.reportFailed(error.toString()),
        type: AppToastType.error,
      );
    }
  }

  Future<void> _uploadRequestMedia(Offer offer, String stage) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      return;
    }

    final uploaderId = await AuthService.getCurrentAppUserId();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(_l10n.takePhoto),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(_l10n.chooseFromGallery),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );

    if (pickedFile == null) {
      return;
    }

    try {
      final bytes = await pickedFile.readAsBytes();
      final extension = _fileExtensionFromName(pickedFile.name);
      final objectPath =
          '${currentUser.id}/${offer.id}/${stage}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final storage = Supabase.instance.client.storage.from('request-media');
      await storage.uploadBinary(
        objectPath,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: _contentTypeForExtension(extension),
        ),
      );

      final publicUrl = storage.getPublicUrl(objectPath);
      await OfferService.addRequestMedia(
        offerId: offer.id,
        uploadedBy: uploaderId,
        stage: stage,
        imageUrl: publicUrl,
      );

      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.stageImageUploaded,
        type: AppToastType.success,
      );
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.stageUploadFailed(error.toString()),
        type: AppToastType.error,
      );
    }
  }

  String _fileExtensionFromName(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == fileName.length - 1) {
      return 'jpg';
    }

    final extension = fileName.substring(dotIndex + 1).toLowerCase();
    const allowedExtensions = {
      'jpg',
      'jpeg',
      'png',
      'webp',
      'gif',
      'heic',
      'heif',
    };
    return allowedExtensions.contains(extension) ? extension : 'jpg';
  }

  String _contentTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  String _resolveRequestMediaUrl(String rawPathOrUrl) {
    final value = rawPathOrUrl.trim();
    if (value.isEmpty) {
      return value;
    }

    final isRemoteUrl =
        value.startsWith('http://') || value.startsWith('https://');
    if (isRemoteUrl) {
      return value;
    }

    return Supabase.instance.client.storage
        .from('request-media')
        .getPublicUrl(value);
  }

  // ─────────────────────────────── Profile widgets ───────────────────────────────

  String _profileInitials() {
    final name = _profileName.trim();
    if (name.isEmpty) {
      return 'U';
    }

    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  Widget _buildProfileAvatarContent() {
    if (_profileImageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _profileImageUrl,
          width: 68,
          height: 68,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return Text(
              _profileInitials(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );
    }

    return Text(
      _profileInitials(),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfileAvatar({double size = 64}) {
    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: Colors.white,
            child: SizedBox(
              width: size,
              height: size,
              child: _buildProfileAvatarContent(),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _isUploadingProfileImage
                    ? null
                    : () => _uploadProfileImage(),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: _isUploadingProfileImage
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.38 : 0.28,
            ),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              color: AppColors.primary,
              child: Row(
                children: [
                  _buildProfileAvatar(size: 78),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _profileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _roleLabel(_profileRole),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (_profileEmail.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            _profileEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -34,
              right: -34,
              width: 132,
              height: 132,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -44,
              left: -24,
              width: 116,
              height: 116,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStatsRow() {
    final completed = _offers
        .where((offer) => offer.status == 'completed')
        .length;
    final active = _offers
        .where(
          (offer) =>
              offer.status != 'completed' &&
              offer.status != 'rejected' &&
              offer.status != 'cancelled',
        )
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildAccountStat(
            '${_offers.length}',
            _l10n.historyFilterAll,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildAccountStat('$active', _l10n.statusInProgress),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildAccountStat('$completed', _l10n.statusCompleted),
        ),
      ],
    );
  }

  Widget _buildAccountStat(String value, String label) {
    final theme = Theme.of(context);
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final theme = Theme.of(context);
    final hasActions = _isSalesRole || _isResponsibleRole;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 16),
        _buildAccountStatsRow(),
        const SizedBox(height: 22),
        Text(
          _l10n.settingsTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              if (hasActions)
                _buildMenuTile(
                  icon: Icons.add_circle_outline,
                  title: _l10n.createNewOrder,
                  onTap: _openCreateOffer,
                ),
              if (hasActions) const Divider(height: 1, indent: 68),
              if (hasActions)
                _buildMenuTile(
                  icon: Icons.receipt_long_outlined,
                  title: _l10n.ordersHistory,
                  onTap: _openOrderHistory,
                ),
              if (hasActions) const Divider(height: 1, indent: 68),
              _buildMenuTile(
                icon: Icons.photo_camera_outlined,
                title: _l10n.changeProfilePhoto,
                onTap: _isUploadingProfileImage ? null : _uploadProfileImage,
              ),
              const Divider(height: 1, indent: 68),
              _buildMenuTile(
                icon: Icons.language_outlined,
                title: _l10n.languageLabel,
                onTap: _showLanguagePicker,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: _buildMenuTile(
            icon: Icons.logout_outlined,
            title: _l10n.signOut,
            iconColor: AppColors.danger,
            titleColor: AppColors.danger,
            onTap: _signOut,
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: Text(
            _l10n.appVersion,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _l10n.developedBy,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final current = LocaleService.current;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Text(
                  _l10n.languageLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _buildLanguageOption(
                context: sheetContext,
                label: _l10n.languageArabic,
                selected: current.languageCode == 'ar',
                onTap: () => _pickLanguage(sheetContext, const Locale('ar')),
              ),
              _buildLanguageOption(
                context: sheetContext,
                label: _l10n.languageEnglish,
                selected: current.languageCode == 'en',
                onTap: () => _pickLanguage(sheetContext, const Locale('en')),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickLanguage(
    BuildContext sheetContext,
    Locale locale,
  ) async {
    Navigator.of(sheetContext).pop();
    await LocaleService.setLocale(locale);
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(
        Icons.translate_rounded,
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    final theme = Theme.of(context);
    final resolvedIconColor = iconColor ?? theme.colorScheme.primary;
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      horizontalTitleGap: 14,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: resolvedIconColor.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 21, color: resolvedIconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: titleColor ?? theme.colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: onTap == null
          ? null
          : Icon(
              Icons.chevron_left_rounded,
              textDirection: TextDirection.ltr,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
      onTap: onTap,
    );
  }

  // ─────────────────────────────── Calendar ───────────────────────────────

  List<Offer> _offersForSelectedDay() {
    final selectedDay = DateTime(
      _selectedCalendarDay.year,
      _selectedCalendarDay.month,
      _selectedCalendarDay.day,
    );

    return _offers.where((offer) {
      final localCreated = offer.createdAt.toLocal();
      final offerDay = DateTime(
        localCreated.year,
        localCreated.month,
        localCreated.day,
      );
      return offerDay == selectedDay;
    }).toList();
  }

  Future<void> _pickCalendarDay() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedCalendarDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedCalendarDay = pickedDate;
    });
  }

  Widget _buildCalendarSection() {
    final theme = Theme.of(context);
    final dayOffers = _offersForSelectedDay();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: 22,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _l10n.selectedDateLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_selectedCalendarDay.year}-${_selectedCalendarDay.month.toString().padLeft(2, '0')}-${_selectedCalendarDay.day.toString().padLeft(2, '0')}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _pickCalendarDay,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(_l10n.chooseDateBtn),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _l10n.ordersToday(dayOffers.length),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: dayOffers.isEmpty
              ? _buildEmptyState(_l10n.noOrdersOnDate)
              : _buildOfferList(dayOffers),
        ),
      ],
    );
  }

  // ─────────────────────────────── Orders tab widgets ───────────────────────────────

  Widget _buildSearchField() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: _l10n.searchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: _l10n.clearSearch,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.55),
        ),
      ),
    );
  }

  Widget _buildStatsStrip() {
    if (_offers.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.factory_outlined,
            label: _l10n.statFactory,
            count: _offers.where((o) => o.status == 'pending_factory').length,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            icon: Icons.build_outlined,
            label: _l10n.statInstallation,
            count: _offers
                .where((o) => o.status == 'pending_installation')
                .length,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            icon: Icons.verified_outlined,
            label: _l10n.statCompleted,
            count: _offers.where((o) => o.status == 'completed').length,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            icon: Icons.check_circle_outline,
            label: _l10n.statApproved,
            count: _offers.where((o) => o.status == 'approved').length,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            icon: Icons.cancel_outlined,
            label: _l10n.statRejected,
            count: _offers.where((o) => o.status == 'rejected').length,
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? AppColors.surfaceContainerDark.withValues(alpha: 0.85)
              : scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _bottomFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _bottomFilters[index];
          final isSelected = _selectedOfferFilter == filter;
          return ChoiceChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Icon(
              _filterIcon(filter),
              size: 15,
              color: isSelected
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: Text(_filterLabel(filter)),
            labelStyle: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            onSelected: (_) => _setOfferFilter(filter),
          );
        },
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }
    final offers = _filteredOffers;
    return Column(
      children: [
        _buildStatsStrip(),
        _buildSearchField(),
        _buildFilterChips(),
        const SizedBox(height: 4),
        Expanded(
          child: offers.isEmpty
              ? _buildEmptyState(_emptyMessage)
              : _buildOfferList(offers),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return EmptyState(
      icon: Icons.cloud_off_outlined,
      title: _l10n.loadFailed,
      message: message,
      action: OutlinedButton.icon(
        onPressed: _loadOffers,
        icon: const Icon(Icons.refresh),
        label: Text(_l10n.retry),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: message,
      message: _l10n.noItemsToShow,
    );
  }

  // ─────────────────────────────── Offer card & list ───────────────────────────────

  Widget _buildStatusBadge(String status, {String? assignedRole}) {
    final fg = StatusColors.foreground(status);
    final bg = StatusColors.background(status);
    return StatusBadge(
      label: _statusDisplayLabel(status, assignedRole: assignedRole),
      foreground: fg,
      background: bg,
    );
  }

  IconData _categoryIcon(String value) {
    switch (value) {
      case 'vanity_top':
      case 'kitchen_top':
        return Icons.countertops_outlined;
      case 'staircase':
        return Icons.stairs_outlined;
      case 'threshold':
        return Icons.meeting_room_outlined;
      case 'skirting':
        return Icons.layers_outlined;
      case 'tiles_cutting':
        return Icons.grid_view_outlined;
      case 'tables':
        return Icons.table_restaurant_outlined;
      case 'kitchen_cabinet':
        return Icons.kitchen_outlined;
      case 'vanity':
        return Icons.wash_outlined;
      case 'wardrobe':
        return Icons.checkroom_outlined;
      case 'doors':
        return Icons.door_sliding_outlined;
      case 'tv_unit':
        return Icons.tv_outlined;
      default:
        return Icons.widgets_outlined;
    }
  }

  Widget _buildMetaLine(IconData icon, String text, {Color? color}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color ?? scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color ?? scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoticeBox({
    required Color bg,
    required Color fg,
    required IconData icon,
    required String title,
    required List<String> lines,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          for (final line in lines) ...[
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 21),
              child: Text(
                line,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOfferCard(Offer offer) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resolvedTileImageUrl =
        offer.tileImageUrl == null || offer.tileImageUrl!.trim().isEmpty
        ? ''
        : _resolveRequestMediaUrl(offer.tileImageUrl!);
    final overdue = _isOverdue(offer);
    final rejectionReason = offer.rejectionReason ?? '';
    final rejectedByLabel = _rejectedByLabel(offer);
    final cancellationReason = offer.cancellationReason ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openOfferDetail(offer),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _categoryIcon(offer.category),
                      size: 22,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.requestTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          offer.salesNumber.isEmpty
                              ? '#${offer.referenceNumber} • ${_requestTypeLabel(offer.requestType)}'
                              : '#${offer.referenceNumber} • ${offer.salesNumber} • ${_requestTypeLabel(offer.requestType)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(offer.status, assignedRole: offer.assignedRole),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetaLine(
                      Icons.person_outline,
                      offer.customerName,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetaLine(
                      Icons.category_outlined,
                      _categoryLabel(offer.category),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMetaLine(
                      Icons.build_outlined,
                      '${offer.material} • ${offer.quantity}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetaLine(
                      Icons.phone_outlined,
                      offer.customerPhone.isEmpty
                          ? _l10n.withoutPhone
                          : offer.customerPhone,
                    ),
                  ),
                ],
              ),
              if (offer.handoverDate != null) ...[
                const SizedBox(height: 8),
                _buildMetaLine(
                  Icons.event_outlined,
                  _l10n.deliveryLine(_formatDate(offer.handoverDate)),
                  color: overdue ? AppColors.danger : null,
                ),
              ],
              if (resolvedTileImageUrl.isNotEmpty) ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _showFullScreenImage(resolvedTileImageUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      resolvedTileImageUrl,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
              if (rejectionReason.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildNoticeBox(
                  bg: isDark ? AppColors.dangerBgDark : AppColors.dangerBg,
                  fg: AppColors.danger,
                  icon: Icons.cancel_outlined,
                  title: _l10n.rejectionReasonLine(rejectionReason),
                  lines: [
                    if (offer.rejectedAt != null)
                      _l10n.rejectionDateLine(
                        _formatDateTime(offer.rejectedAt),
                      ),
                    if (offer.status == 'rejected' &&
                        rejectedByLabel.isNotEmpty)
                      _l10n.rejectedByName(rejectedByLabel),
                  ],
                ),
              ],
              if (cancellationReason.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildNoticeBox(
                  bg: isDark ? AppColors.dangerBgDark : AppColors.dangerBg,
                  fg: AppColors.danger,
                  icon: Icons.cancel_outlined,
                  title: _l10n.cancellationReasonLine(cancellationReason),
                  lines: const [],
                ),
              ],
              if (offer.editRequestedBy != null) ...[
                const SizedBox(height: 8),
                _buildNoticeBox(
                  bg: isDark ? AppColors.warningBgDark : AppColors.warningBg,
                  fg: AppColors.warning,
                  icon: Icons.hourglass_top,
                  title: _l10n.editPendingApprovalCard,
                  lines: const [],
                ),
              ],
              if (offer.editApproved) ...[
                const SizedBox(height: 8),
                _buildNoticeBox(
                  bg: isDark ? AppColors.successBgDark : AppColors.successBg,
                  fg: AppColors.success,
                  icon: Icons.check_circle_outline,
                  title: _l10n.editApprovedCard,
                  lines: const [],
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(offer.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (offer.totalPrice > 0)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _l10n.totalLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatAED(offer.totalPrice),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openOfferDetail(Offer offer) {
    final canSwipe = _canReviewOffer(offer) && offer.status != 'approved';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _OfferDetailScreen(
          offer: offer,
          actions: _buildOfferActions(offer, useSwipeReview: canSwipe),
          canSwipeReview: canSwipe,
          onSwipeAccept: canSwipe
              ? () => _handleDetailSwipeAction(offer, isAccept: true)
              : null,
          onSwipeReject: canSwipe
              ? () => _handleDetailSwipeAction(offer, isAccept: false)
              : null,
          canUploadFactoryMedia: _canUploadFactoryMedia(offer),
          canUploadInstallationMedia: _canUploadInstallationMedia(offer),
          onUploadMedia: (stage) => _uploadRequestMedia(offer, stage),
          onPrintReport: _canPrintOfferReport(offer)
              ? () => _printCompletedOfferReport(offer)
              : null,
        ),
      ),
    );
  }

  bool _canUploadFactoryMedia(Offer offer) {
    return (_isFactoryRole || _isWoodFactoryRole || _isResponsibleRole) &&
        (offer.status == 'pending_factory' ||
            offer.status == 'approved' ||
            offer.status == 'pending_installation' ||
            offer.status == 'completed');
  }

  bool _canUploadInstallationMedia(Offer offer) {
    return (_isInstallerRole || _isResponsibleRole) &&
        (offer.status == 'pending_installation' ||
            offer.status == 'approved' ||
            offer.status == 'completed');
  }

  bool _canPrintOfferReport(Offer offer) {
    return _isResponsibleRole && offer.status == 'completed';
  }

  /// Runs accept/reject triggered by a swipe from inside the detail screen and
  /// pops the screen once the action completes so the refreshed list is shown.
  Future<void> _handleDetailSwipeAction(
    Offer offer, {
    required bool isAccept,
  }) async {
    try {
      final succeeded = isAccept
          ? await _confirmAndAcceptOffer(offer)
          : await _showRejectDialog(offer);
      if (!succeeded) return;
      if (!mounted) return;
      Navigator.of(context).pop();
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        isAccept
            ? _l10n.acceptFailed(error.toString())
            : _l10n.rejectFailed(error.toString()),
        type: AppToastType.error,
      );
    }
  }

  Future<bool> _confirmAndAcceptOffer(Offer offer) async {
    final confirmed = await _confirmApproveDialog(offer);
    if (confirmed != true) {
      return false;
    }
    await _runAcceptAction(offer);
    return true;
  }

  Widget _buildOfferList(List<Offer> offers) {
    return RefreshIndicator(
      onRefresh: _loadOffers,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 110),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          Widget card = _buildOfferCard(offer);

          // While a workflow action runs on this offer, cover the card with a
          // scrim + spinner so the UI feels responsive instead of frozen, and
          // block further taps on it.
          if (_processingOfferId == offer.id) {
            final scheme = Theme.of(context).colorScheme;
            card = ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  card,
                  Positioned.fill(
                    child: ColoredBox(
                      color: scheme.surface.withValues(alpha: 0.55),
                      child: AbsorbPointer(
                        child: Center(
                          child: SizedBox(
                            width: 34,
                            height: 34,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!_canReviewOffer(offer)) {
            return card;
          }
          return Dismissible(
            key: ValueKey('offer-${offer.id}'),
            direction: DismissDirection.horizontal,
            confirmDismiss: (direction) => _handleOfferSwipe(offer, direction),
            background: _buildSwipeBackground(
              alignment: Alignment.centerRight,
              icon: Icons.close_rounded,
              label: _l10n.rejectShort,
              color: AppColors.danger,
            ),
            secondaryBackground: _buildSwipeBackground(
              alignment: Alignment.centerLeft,
              icon: Icons.task_alt_rounded,
              label: _l10n.acceptShort,
              color: AppColors.success,
            ),
            child: card,
          );
        },
      ),
    );
  }

  // ─────────────────────────────── Swipe to review ───────────────────────────────

  /// Whether the current user can accept/reject this offer by swiping the card.
  bool _canReviewOffer(Offer offer) {
    if (offer.status == 'rejected' ||
        offer.status == 'cancelled' ||
        offer.status == 'completed') {
      return false;
    }
    final stageRole = _stageRoleForReview(offer);
    final isInstallationStage = stageRole == 'company_officer';
    final isInstallationPending = offer.status == 'pending_installation';
    final isFactoryReviewer = _isFactoryReviewer(
      stageRole: stageRole,
      status: offer.status,
    );
    final isInstallationReviewer =
        (_isInstallerRole || _isResponsibleRole) &&
        (isInstallationStage || isInstallationPending);
    return isFactoryReviewer || isInstallationReviewer;
  }

  Future<bool> _handleOfferSwipe(
    Offer offer,
    DismissDirection direction,
  ) async {
    // In RTL: endToStart = physical swipe right (accept), startToEnd =
    // physical swipe left (reject) — like Tinder/global apps.
    final isAccept = direction == DismissDirection.endToStart;

    if (isAccept) {
      final confirmed = await _confirmApproveDialog(offer);
      if (confirmed != true) {
        return false;
      }
      await _runAcceptAction(offer);
    } else {
      await _showRejectDialog(offer);
    }

    // Keep the card in the tree; the list refreshes after the action.
    return false;
  }

  /// Mirrors the primary accept button: accepts pending orders and advances
  /// already-accepted ones to the next stage.
  Future<void> _runAcceptAction(Offer offer) async {
    final stageRole = _stageRoleForReview(offer);
    final isFactoryStage = _isFactoryStageRole(stageRole);
    final isFactoryPending = offer.status == 'pending_factory';
    final isFactoryAccepted = offer.status == 'approved' && isFactoryStage;
    final isInstallationPending = offer.status == 'pending_installation';
    final isInstallationAccepted =
        offer.status == 'approved' && !isFactoryStage;

    if (isFactoryPending) {
      await _acceptOffer(offer);
    } else if (isFactoryAccepted) {
      if (offer.requestType == 'both') {
        await _approveOffer(offer, sendToInstallation: true);
      } else {
        await _approveOffer(offer, sendToInstallation: false);
      }
    } else if (isInstallationPending) {
      await _acceptOffer(offer);
    } else if (isInstallationAccepted) {
      await _approveOffer(offer);
    }
  }

  Future<bool?> _confirmApproveDialog(Offer offer) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          icon: Icon(
            Icons.task_alt_rounded,
            color: AppColors.success,
            size: 40,
          ),
          title: Text(_l10n.acceptOrderQuestion),
          content: Text(
            _l10n.acceptOrderDetail(offer.referenceNumber),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_l10n.cancelLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_l10n.acceptOrder),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────── Offer actions bar ───────────────────────────────

  Widget _buildOfferActions(Offer offer, {bool useSwipeReview = false}) {
    final stageRole = _stageRoleForReview(offer);
    final isFactoryStage = _isFactoryStageRole(stageRole);
    final isInstallationStage = stageRole == 'company_officer';
    final isFactoryPending = offer.status == 'pending_factory';
    final isInstallationPending = offer.status == 'pending_installation';
    final isFactoryReviewer = _isFactoryReviewer(
      stageRole: stageRole,
      status: offer.status,
    );
    final isInstallationReviewer =
        (_isInstallerRole || _isResponsibleRole) &&
        (isInstallationStage || isInstallationPending);
    final canReview = isFactoryReviewer || isInstallationReviewer;
    final isTerminalStatus =
        offer.status == 'rejected' ||
        offer.status == 'cancelled' ||
        offer.status == 'completed';
    final canResubmit = _isSalesRole && offer.needsResubmission;
    final canCancel =
        (_isSalesRole || _isResponsibleRole) &&
        offer.status != 'cancelled' &&
        offer.status != 'completed';

    final canEdit = _canEditOffer(offer);
    final isLockedEdit = _isOfferAccepted(offer) || offer.status == 'cancelled';
    final hasPendingEditRequest = offer.editRequestedBy != null;
    final isAdminReviewingRequest = _isResponsibleRole && hasPendingEditRequest;
    final canRequestEdit = canEdit &&
        isLockedEdit &&
        !_isResponsibleRole &&
        !offer.editApproved &&
        !hasPendingEditRequest;
    final canEditDirectly = canEdit &&
        !canResubmit &&
        (!isLockedEdit || _isResponsibleRole || offer.editApproved);

    final primaryActions = <Widget>[];
    if (canResubmit) {
      primaryActions.add(
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _openEditOffer(offer),
            icon: const Icon(Icons.restart_alt, size: 18),
            label: Text(
              _l10n.editAndResubmit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    } else if (!useSwipeReview && isFactoryReviewer && !isTerminalStatus) {
      final isFactoryAccepted = offer.status == 'approved' && isFactoryStage;
      if (isFactoryPending) {
        primaryActions.add(
          Expanded(
            flex: 3,
            child: FilledButton.icon(
              onPressed: () => _acceptOffer(offer),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: Text(
                _l10n.acceptOrder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
        if (offer.requestType != 'both') {
          primaryActions.add(const SizedBox(width: 8));
          primaryActions.add(
            Expanded(
              flex: 2,
              child: FilledButton.tonalIcon(
                onPressed: () =>
                    _approveOffer(offer, sendToInstallation: false),
                icon: const Icon(Icons.task_alt_outlined, size: 18),
                label: Text(
                  _l10n.finishOrder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }
      } else if (isFactoryAccepted) {
        final isCombined = offer.requestType == 'both';
        primaryActions.add(
          Expanded(
            child: FilledButton.icon(
              onPressed: isCombined
                  ? () => _approveOffer(offer, sendToInstallation: true)
                  : () => _approveOffer(offer, sendToInstallation: false),
              icon: Icon(
                isCombined ? Icons.forward_outlined : Icons.task_alt_outlined,
                size: 18,
              ),
              label: Text(
                isCombined ? _l10n.sendToInstallation : _l10n.finishOrder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }
    } else if (!useSwipeReview && isInstallationReviewer && !isTerminalStatus) {
      final isInstallationAccepted =
          offer.status == 'approved' && isInstallationStage;
      if (isInstallationPending) {
        primaryActions.add(
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _acceptOffer(offer),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: Text(
                _l10n.acceptOrder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      } else if (isInstallationAccepted) {
        primaryActions.add(
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _approveOffer(offer),
              icon: const Icon(Icons.task_alt_outlined, size: 18),
              label: Text(
                _l10n.finishOrder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }
    }

    final iconActions = <Widget>[];
    if (!useSwipeReview &&
        canReview &&
        !isTerminalStatus &&
        offer.status != 'approved') {
      iconActions.add(
        IconButton.filledTonal(
          tooltip: _l10n.rejectTooltip,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.dangerBg,
            foregroundColor: AppColors.danger,
          ),
          onPressed: () => _showRejectDialog(offer),
          icon: const Icon(Icons.close),
        ),
      );
    }
    if (canCancel && isAdminReviewingRequest) {
      iconActions.add(
        IconButton.filledTonal(
          tooltip: _l10n.cancelOrderTooltip,
          onPressed: () => _cancelOffer(offer),
          icon: const Icon(Icons.cancel_outlined),
        ),
      );
    }

    final editActions = <Widget>[];
    if (isAdminReviewingRequest) {
      editActions.add(
        Expanded(
          flex: 3,
          child: FilledButton.icon(
            onPressed: () => _resolveEditRequest(offer, approved: true),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text(
              _l10n.approveEditAction,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
      editActions.add(const SizedBox(width: 8));
      editActions.add(
        Expanded(
          flex: 2,
          child: FilledButton.tonalIcon(
            onPressed: () => _resolveEditRequest(offer, approved: false),
            icon: const Icon(Icons.close, size: 18),
            label: Text(
              _l10n.rejectShort,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    } else if (canRequestEdit) {
      editActions.add(
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => _requestOfferEdit(offer),
            icon: const Icon(Icons.edit_note_outlined, size: 18),
            label: Text(
              _l10n.requestEditBtn,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    } else if (canEditDirectly) {
      editActions.add(
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => _openEditOffer(offer),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(
              _l10n.editOrderBtn,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    } else if (canEdit && hasPendingEditRequest && !_isResponsibleRole) {
      editActions.add(
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_top,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _l10n.editPendingApprovalCard,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (canCancel && !isAdminReviewingRequest) {
      final cancelButton = Expanded(
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _cancelOffer(offer),
          icon: const Icon(Icons.cancel_outlined, size: 18),
          label: Text(
            _l10n.cancelOrderTooltip,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
      if (editActions.isNotEmpty) {
        editActions.add(const SizedBox(width: 8));
      }
      editActions.add(cancelButton);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.65),
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (editActions.isNotEmpty) ...[
                Row(
                  children: editActions,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: primaryActions.isEmpty
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  ...primaryActions,
                  if (primaryActions.isNotEmpty && iconActions.isNotEmpty)
                    const SizedBox(width: 8),
                  ...iconActions,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────── Root scaffold ───────────────────────────────

  Widget _buildAppBarTitle() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_tabTitle(_selectedTab)),
        if (_selectedTab == 0)
          Text(
            _filterLabel(_selectedOfferFilter),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCreate = _isSalesRole || _isResponsibleRole;

    return Scaffold(
      extendBody: true,
      appBar: Glass(
        child: AppBar(
          backgroundColor: Colors.transparent,
          title: _buildAppBarTitle(),
          actions: [
            // ── Refresh ─────────────────────────────────────────────────────
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadOffers,
              tooltip: _l10n.refresh,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackground()),
          switch (_selectedTab) {
            0 => _buildOrdersTab(),
            1 => _buildCalendarSection(),
            _ => _buildProfileTab(),
          },
        ],
      ),
      floatingActionButton: canCreate && _selectedTab == 0
          ? _CreateOrderFab(
              semanticLabel: _l10n.createNewOrder,
              onPressed: _openCreateOffer,
              primaryColor: theme.colorScheme.primary,
            )
          : null,
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: _selectedTab,
        onTabSelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        ordersLabel: _l10n.tabOrders,
        calendarLabel: _l10n.tabCalendar,
        accountLabel: _l10n.tabAccount,
        ordersBadgeCount: _offers.where((o) => _canReviewOffer(o)).isNotEmpty
            ? _offers.where((o) => _canReviewOffer(o)).length
            : null,
      ),
    );
  }
}




// ─────────────────────────────────────────────────────────────────────────────
// Circular floating Create-Order button (+ only)
// ─────────────────────────────────────────────────────────────────────────────

class _CreateOrderFab extends StatefulWidget {
  const _CreateOrderFab({
    required this.semanticLabel,
    required this.onPressed,
    required this.primaryColor,
  });

  final String semanticLabel;
  final VoidCallback onPressed;
  final Color primaryColor;

  @override
  State<_CreateOrderFab> createState() => _CreateOrderFabState();
}

class _CreateOrderFabState extends State<_CreateOrderFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _down(_) => _ctrl.forward();
  void _up(_) {
    _ctrl.reverse();
    HapticFeedback.mediumImpact();
    widget.onPressed();
  }

  void _cancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scale,
      builder: (ctx, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: Tooltip(
        message: widget.semanticLabel,
        child: GestureDetector(
          onTapDown: _down,
          onTapUp: _up,
          onTapCancel: _cancel,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.primaryColor,
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withValues(alpha: 0.40),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Swipe to review (call-style accept/reject)
// ─────────────────────────────────────────────────────────────────────────────

class _SwipeReviewBar extends StatefulWidget {
  const _SwipeReviewBar({
    this.hintLabel = '',
    this.acceptLabel = '',
    this.rejectLabel = '',
    this.onSwipeAccept,
    this.onSwipeReject,
  });

  final String hintLabel;
  final String acceptLabel;
  final String rejectLabel;
  final Future<void> Function()? onSwipeAccept;
  final Future<void> Function()? onSwipeReject;

  @override
  State<_SwipeReviewBar> createState() => _SwipeReviewBarState();
}

class _SwipeReviewBarState extends State<_SwipeReviewBar> {
  double _maxDrag = 150;
  static const double _thresholdFactor = 0.45;

  double _dx = 0;
  bool _dragging = false;
  bool _processing = false;

  double get _progress => (_dx / _maxDrag).clamp(-1.0, 1.0).toDouble();

  void _onHorizontalDragStart(_) {
    if (_processing) return;
    setState(() => _dragging = true);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_processing) return;
    setState(() {
      _dx = (_dx + details.delta.dx).clamp(-_maxDrag, _maxDrag).toDouble();
    });
  }

  Future<void> _onHorizontalDragEnd(DragEndDetails details) async {
    if (_processing) return;
    final velocity = details.primaryVelocity ?? 0;
    final threshold = _maxDrag * _thresholdFactor;
    final accept = _dx > threshold || (velocity > 300 && _dx > 0);
    final reject = _dx < -threshold || (velocity < -300 && _dx < 0);

    if (!accept && !reject) {
      setState(() {
        _dragging = false;
        _dx = 0;
      });
      return;
    }

    setState(() {
      _dragging = false;
      _processing = true;
    });

    if (accept) {
      await widget.onSwipeAccept?.call();
    } else {
      await widget.onSwipeReject?.call();
    }

    if (!mounted) return;
    setState(() {
      _processing = false;
      _dx = 0;
    });
  }

  void _onHorizontalDragCancel() {
    if (!mounted || _processing) return;
    setState(() {
      _dragging = false;
      _dx = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _progress;
    final isPositive = _dx >= 0;
    final actionColor = isPositive ? AppColors.success : AppColors.danger;
    final overlayAlpha = (progress.abs() * 0.30).clamp(0.0, 1.0);
    final showIdleHint = !_dragging && !_processing && _dx == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIdleHint && widget.hintLabel.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.hintLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        _buildSwipeBar(
          theme,
          actionColor,
          overlayAlpha,
        ),
      ],
    );
  }

  Widget _buildSwipeBar(
    ThemeData theme,
    Color actionColor,
    double overlayAlpha,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxDrag = ((constraints.maxWidth / 2) - 34).clamp(40.0, 1000.0);
        final isNeutral = _dx == 0;
        final isPositive = _dx >= 0;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          onHorizontalDragCancel: _onHorizontalDragCancel,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: actionColor.withValues(alpha: overlayAlpha + 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 70),
                    color: actionColor.withValues(alpha: overlayAlpha),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: AppColors.danger,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.rejectLabel,
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 18),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.acceptLabel,
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(_dx, 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 70),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isNeutral
                            ? theme.colorScheme.primary
                            : actionColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isNeutral
                            ? Icons.swipe
                            : isPositive
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Offer detail screen
// ─────────────────────────────────────────────────────────────────────────────

class _OfferDetailScreen extends StatefulWidget {
  const _OfferDetailScreen({
    required this.offer,
    required this.actions,
    this.canSwipeReview = false,
    this.onSwipeAccept,
    this.onSwipeReject,
    this.canUploadFactoryMedia = false,
    this.canUploadInstallationMedia = false,
    this.onUploadMedia,
    this.onPrintReport,
  });

  final Offer offer;
  final Widget actions;
  final bool canSwipeReview;
  final Future<void> Function()? onSwipeAccept;
  final Future<void> Function()? onSwipeReject;
  final bool canUploadFactoryMedia;
  final bool canUploadInstallationMedia;
  final Future<void> Function(String stage)? onUploadMedia;
  final Future<void> Function()? onPrintReport;

  @override
  State<_OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<_OfferDetailScreen> {
  Offer get offer => widget.offer;

  List<RequestMedia> _media = [];
  bool _loadingMedia = true;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    try {
      final data = await OfferService.fetchRequestMedia(offer.id);
      if (!mounted) return;
      setState(() {
        _media = data.map(RequestMedia.fromJson).toList();
        _loadingMedia = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _media = [];
        _loadingMedia = false;
      });
    }
  }

  Future<void> _handleUploadMedia(String stage) async {
    final upload = widget.onUploadMedia;
    if (upload == null) return;
    await upload(stage);
    await _loadMedia();
  }

  String _stageDisplayLabel(String stage) {
    return stage == 'installation'
        ? _l10n.stageInstallation
        : _l10n.stageFabrication;
  }

  String _resolveMediaUrl(String rawPathOrUrl) {
    final value = rawPathOrUrl.trim();
    if (value.isEmpty) {
      return value;
    }
    final isRemoteUrl =
        value.startsWith('http://') || value.startsWith('https://');
    if (isRemoteUrl) {
      return value;
    }
    return Supabase.instance.client.storage
        .from('request-media')
        .getPublicUrl(value);
  }

  Widget _buildStageMediaSection() {
    final theme = Theme.of(context);
    final canUpload =
        widget.canUploadFactoryMedia || widget.canUploadInstallationMedia;
    return _InfoSectionCard(
      icon: Icons.photo_library_outlined,
      title: _l10n.stageMediaTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canUpload) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.canUploadFactoryMedia)
                  OutlinedButton.icon(
                    onPressed: () => _handleUploadMedia('factory'),
                    icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                    label: Text(_l10n.uploadFactoryImage),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (widget.canUploadInstallationMedia)
                  OutlinedButton.icon(
                    onPressed: () => _handleUploadMedia('installation'),
                    icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                    label: Text(_l10n.uploadInstallationImage),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (_loadingMedia)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            )
          else if (_media.isEmpty)
            Text(
              _l10n.noImagesYet,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in _media) _buildMediaThumb(item),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMediaThumb(RequestMedia item) {
    final theme = Theme.of(context);
    final url = _resolveMediaUrl(item.imageUrl);
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, url),
      child: SizedBox(
        width: 108,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 108,
                height: 92,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Image.network(
                  url,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _stageDisplayLabel(item.stage),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLocalDate(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatLocalDateTime(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '${_formatLocalDate(value)} $h:$min';
  }

  String _resolveTileImageUrl(String? rawPathOrUrl) {
    final value = (rawPathOrUrl ?? '').trim();
    if (value.isEmpty) {
      return value;
    }

    final isRemoteUrl =
        value.startsWith('http://') || value.startsWith('https://');
    if (isRemoteUrl) {
      return value;
    }

    return Supabase.instance.client.storage
        .from('request-media')
        .getPublicUrl(value);
  }

  String _pdfFileNameFromUrl(String url) {
    if (url.trim().isEmpty) {
      return _l10n.attachedFile;
    }
    final segments = url.split('/').where((s) => s.isNotEmpty).toList();
    return segments.isEmpty ? _l10n.attachedFile : segments.last;
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      AppToast.show(context, _l10n.invalidLink, type: AppToastType.error);
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        AppToast.show(context, _l10n.cannotOpenLink, type: AppToastType.error);
      }
    } on Object catch (_) {
      if (context.mounted) {
        AppToast.show(context, _l10n.cannotOpenLink, type: AppToastType.error);
      }
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _requestTypeLabel(String value) {
    switch (value) {
      case 'both':
        return _l10n.requestTypeBoth;
      case 'installation':
        return _l10n.requestTypeInstallation;
      default:
        return _l10n.requestTypeFabrication;
    }
  }

  String _categoryLabel(String value) {
    const map = {
      'vanity_top': 'VANITY TOP',
      'kitchen_top': 'KITCHEN TOP',
      'staircase': 'STAIRCASE',
      'threshold': 'TRESHOLD',
      'skirting': 'SKIRTING',
      'tiles_cutting': 'TILES CUTTING',
      'tables': 'TABLES',
      'kitchen_cabinet': 'KITCHEN CABINET',
      'vanity': 'VANITY',
      'wardrobe': 'WARDROBE',
      'doors': 'DOORS',
      'tv_unit': 'TV UNIT',
    };
    return map[value] ?? value;
  }

  Widget _buildStatusBadge(String status, {String? assignedRole}) {
    final fg = StatusColors.foreground(status);
    final bg = StatusColors.background(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _statusDisplayLabel(status, assignedRole: assignedRole),
            style: TextStyle(
              color: fg,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final display = value.trim().isEmpty ? '-' : value.trim();
    final valueWidget = Text(
      display,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: valueColor ?? theme.colorScheme.onSurface,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: onTap != null
                ? InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(6),
                    child: valueWidget,
                  )
                : valueWidget,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedTileImageUrl = _resolveTileImageUrl(offer.tileImageUrl);
    final rejectionReason = offer.rejectionReason ?? '';
    final rejectedByLabel = _rejectedByLabel(offer);
    final cancellationReason = offer.cancellationReason ?? '';
    final canSwipe = widget.canSwipeReview &&
        widget.onSwipeAccept != null &&
        widget.onSwipeReject != null;

    return Scaffold(
      extendBody: true,
      appBar: Glass(
        child: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(_l10n.orderDetailsTitle),
          actions: [
            if (widget.onPrintReport != null)
              IconButton(
                tooltip: _l10n.printReportTooltip,
                onPressed: () => widget.onPrintReport!(),
                icon: const Icon(Icons.print_outlined),
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackground()),
          ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, canSwipe ? 240 : 150),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              offer.requestTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                  _buildStatusBadge(offer.status, assignedRole: offer.assignedRole),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 6),
                      _detailRow(
                        context,
                        icon: Icons.tag_outlined,
                        label: _l10n.refLabel,
                        value: offer.referenceNumber,
                      ),
                      if (offer.salesNumber.isNotEmpty)
                        _detailRow(
                          context,
                          icon: Icons.sell_outlined,
                          label: _l10n.salesNumberLabel,
                          value: offer.salesNumber,
                        ),
                      _detailRow(
                        context,
                        icon: Icons.category_outlined,
                        label: _l10n.categoryLabelDetail,
                        value: _categoryLabel(offer.category),
                      ),
                      _detailRow(
                        context,
                        icon: Icons.swap_vert_outlined,
                        label: _l10n.typeLabelDetail,
                        value: _requestTypeLabel(offer.requestType),
                      ),
                      _detailRow(
                        context,
                        icon: Icons.event_outlined,
                        label: _l10n.deliveryLabelDetail,
                        value: _formatLocalDate(offer.handoverDate),
                      ),
                      _detailRow(
                        context,
                        icon: Icons.schedule_outlined,
                        label: _l10n.createdLabelDetail,
                        value: _formatLocalDate(offer.createdAt),
                      ),
                      _detailRow(
                        context,
                        icon: Icons.check_circle_outline,
                        label: _l10n.completedLabelDetail,
                        value: _formatLocalDate(offer.approvedAt),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _InfoSectionCard(
                icon: Icons.people_outline,
                title: _l10n.customerAndSellerTitle,
                child: Column(
                  children: [
                    _detailRow(
                      context,
                      icon: Icons.person_outline,
                      label: _l10n.customerLabel,
                      value: offer.customerName,
                    ),
                    _detailRow(
                      context,
                      icon: Icons.phone_outlined,
                      label: _l10n.phoneLabel,
                      value: offer.customerPhone,
                    ),
                    if ((offer.customerAddress ?? '').trim().isNotEmpty)
                      _detailRow(
                        context,
                        icon: Icons.location_on_outlined,
                        label: _l10n.addressLabel,
                        value: offer.customerAddress!,
                      ),
                    if ((offer.customerAddressUrl ?? '').trim().isNotEmpty)
                      _detailRow(
                        context,
                        icon: Icons.map_outlined,
                        label: _l10n.mapLabel,
                        value: offer.customerAddressUrl!.replaceAll(
                          RegExp(r'^https?://'),
                          '',
                        ),
                        valueColor: theme.colorScheme.primary,
                        onTap: () =>
                            _launchUrl(context, offer.customerAddressUrl!),
                      ),
                    _detailRow(
                      context,
                      icon: Icons.storefront_outlined,
                      label: _l10n.sellerLabel,
                      value: offer.sellerName,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _InfoSectionCard(
                icon: Icons.inventory_2_outlined,
                title: _l10n.materialAndCostTitle,
                child: Column(
                  children: [
                    _detailRow(
                      context,
                      icon: Icons.build_outlined,
                      label: _l10n.materialLabel,
                      value: offer.material,
                    ),
                    _detailRow(
                      context,
                      icon: Icons.numbers_outlined,
                      label: _l10n.quantityLabel,
                      value: '${offer.quantity}',
                    ),
                    if ((offer.pdfUrl ?? '').trim().isNotEmpty)
                      _detailRow(
                        context,
                        icon: Icons.picture_as_pdf_outlined,
                        label: _l10n.pdfLabel,
                        value: _pdfFileNameFromUrl(offer.pdfUrl!),
                        valueColor: theme.colorScheme.primary,
                        onTap: () => _launchUrl(context, offer.pdfUrl!),
                      ),
                    if (offer.tileCode.isNotEmpty)
                      _detailRow(
                        context,
                        icon: Icons.qr_code_outlined,
                        label: _l10n.tileCodeLabel,
                        value: offer.tileCode,
                      ),
                    if (resolvedTileImageUrl.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        _l10n.materialImageLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () =>
                            _showFullScreenImage(context, resolvedTileImageUrl),
                        borderRadius: BorderRadius.circular(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 110,
                            width: double.infinity,
                            child: Image.network(
                              resolvedTileImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.zoom_in_outlined,
                            size: 13,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _l10n.tapToZoom,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildStageMediaSection(),
              if (offer.description.isNotEmpty) ...[
                const SizedBox(height: 14),
                _InfoSectionCard(
                  icon: Icons.notes_outlined,
                  title: _l10n.descriptionTitle,
                  child: Text(offer.description),
                ),
              ],
              if (offer.status == 'rejected' ||
                  rejectionReason.isNotEmpty) ...[
                const SizedBox(height: 14),
                _InfoSectionCard(
                  icon: Icons.cancel_outlined,
                  title: _l10n.rejectReasonTitleDetail,
                  iconColor: AppColors.danger,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (rejectedByLabel.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.person_off_outlined,
                              size: 16,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _l10n.rejectedByLine(rejectedByLabel),
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        rejectionReason.isEmpty
                            ? _l10n.noReason
                            : rejectionReason,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                      if (offer.rejectedAt != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_outlined,
                              size: 16,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _l10n.rejectionDateLine(
                                _formatLocalDateTime(offer.rejectedAt),
                              ),
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (cancellationReason.isNotEmpty) ...[
                const SizedBox(height: 14),
                _InfoSectionCard(
                  icon: Icons.cancel_outlined,
                  title: _l10n.cancellationTitleDetail,
                  iconColor: AppColors.danger,
                  child: Text(
                    cancellationReason,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              ],
              if (offer.editRequestedBy != null) ...[
                const SizedBox(height: 14),
                _InfoSectionCard(
                  icon: Icons.hourglass_top,
                  title: _l10n.editPendingTitle,
                  iconColor: AppColors.warning,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((offer.editRequestReason ?? '').trim().isNotEmpty)
                        Text(
                          _l10n.editReasonLine(offer.editRequestReason!),
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        _l10n.editPendingBody,
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
              if (offer.editApproved) ...[
                const SizedBox(height: 14),
                _InfoSectionCard(
                icon: Icons.check_circle_outline,
                title: _l10n.editApprovedTitle,
                iconColor: AppColors.success,
                child: Text(
                  _l10n.editApprovedBody,
                  style: const TextStyle(color: AppColors.success),
                ),
              ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Glass(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canSwipe)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _SwipeReviewBar(
                  hintLabel: offer.status == 'approved'
                      ? (offer.requestType == 'both'
                          ? _l10n.swipeHintSendInstallation
                          : _l10n.swipeHintFinish)
                      : _l10n.swipeHintAcceptReject,
                  acceptLabel: offer.status == 'approved'
                      ? (offer.requestType == 'both'
                          ? _l10n.sendToInstallation
                          : _l10n.finishOrder)
                      : _l10n.acceptOrder,
                  rejectLabel: _l10n.rejectShort,
                  onSwipeAccept: widget.onSwipeAccept,
                  onSwipeReject: widget.onSwipeReject,
                ),
              ),
            widget.actions,
          ],
        ),
      ),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (iconColor ?? theme.colorScheme.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Create / edit offer screen
// ─────────────────────────────────────────────────────────────────────────────

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({
    super.key,
    required this.sellerName,
    this.editOffer,
  });

  final String sellerName;
  final Offer? editOffer;

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final _referenceNumberController = TextEditingController();
  final _salesNumberController = TextEditingController();
  final _tileCodeController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerAddressUrlController = TextEditingController();
  final _requestTitleController = TextEditingController();
  final _materialController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellerNameController = TextEditingController();

  String _requestType = 'fabrication';
  String _category = OfferService.requestCategories.first;
  DateTime? _handoverDate;
  bool _isSubmitting = false;
  String _tileImageUrl = '';
  String _pdfUrl = '';
  String _pdfFileName = '';
  bool _referenceLoading = true;

  bool get _isEditMode => widget.editOffer != null;

  /// True when the order was already accepted and this edit is being applied
  /// after the responsible officer approved an edit request (or the responsible
  /// officer is editing directly). The order must be reopened for re-review.
  bool get _isPostAcceptanceEdit {
    final offer = widget.editOffer;
    if (offer == null) return false;
    return offer.acceptedAt != null ||
        offer.status == 'approved' ||
        offer.status == 'completed';
  }

  @override
  void initState() {
    super.initState();
    _sellerNameController.text = widget.sellerName;
    _fillEditData();
    if (!_isEditMode) {
      _loadReferenceNumber();
    }
  }

  Future<void> _loadReferenceNumber() async {
    try {
      final reference = await OfferService.fetchCurrentReferenceNumber();
      if (!mounted) return;
      setState(() {
        _referenceNumberController.text = reference;
        _referenceLoading = false;
      });
    } on Object catch (_) {
      if (!mounted) return;
      setState(() {
        _referenceNumberController.text = _generateFallbackReferenceNumber();
        _referenceLoading = false;
      });
    }
  }

  String _generateFallbackReferenceNumber() {
    final now = DateTime.now();
    final stamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return 'REQ-$stamp';
  }

  void _fillEditData() {
    final offer = widget.editOffer;
    if (offer == null) {
      return;
    }

    _referenceNumberController.text = offer.referenceNumber;
    _salesNumberController.text = offer.salesNumber;
    _requestType = offer.requestType;
    _tileCodeController.text = offer.tileCode;
    _tileImageUrl = offer.tileImageUrl ?? '';
    _category = OfferService.requestCategories.contains(offer.category)
        ? offer.category
        : OfferService.requestCategories.first;
    _customerNameController.text = offer.customerName;
    _customerPhoneController.text = offer.customerPhone;
    _customerAddressController.text = offer.customerAddress ?? '';
    _customerAddressUrlController.text = offer.customerAddressUrl ?? '';
    _requestTitleController.text = offer.requestTitle;
    _handoverDate = offer.handoverDate;
    _materialController.text = offer.material;
    _quantityController.text = offer.quantity.toString();
    _descriptionController.text = offer.description;
    _pdfUrl = offer.pdfUrl ?? '';
    _pdfFileName = _fileNameFromUrl(_pdfUrl);
  }

  String _fileNameFromUrl(String url) {
    if (url.trim().isEmpty) {
      return '';
    }
    final segments = url.split('/').where((s) => s.isNotEmpty).toList();
    return segments.isEmpty ? url : segments.last;
  }

  @override
  void dispose() {
    _referenceNumberController.dispose();
    _salesNumberController.dispose();
    _tileCodeController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _customerAddressUrlController.dispose();
    _requestTitleController.dispose();
    _materialController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _sellerNameController.dispose();
    super.dispose();
  }

  Future<void> _pickHandoverDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _handoverDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _handoverDate = pickedDate;
    });
  }

  Future<void> _pickTileImage() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );

    if (pickedFile == null) {
      return;
    }

    try {
      final bytes = await pickedFile.readAsBytes();
      final ext = pickedFile.name.contains('.')
          ? pickedFile.name.split('.').last.toLowerCase()
          : 'jpg';
      final safeExt = ['jpg', 'jpeg', 'png', 'webp'].contains(ext)
          ? ext
          : 'jpg';
      final objectPath =
          '${currentUser.id}/tile_${DateTime.now().millisecondsSinceEpoch}.$safeExt';
      final storage = Supabase.instance.client.storage.from('request-media');
      await storage.uploadBinary(
        objectPath,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: safeExt == 'png' ? 'image/png' : 'image/jpeg',
        ),
      );
      final publicUrl = storage.getPublicUrl(objectPath);

      if (!mounted) return;
      setState(() {
        _tileImageUrl = publicUrl;
      });
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.tileImageUploadFailed(error.toString()),
        type: AppToastType.error,
      );
    }
  }

  Future<void> _pickPdfFile() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      return;
    }

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      return;
    }

    try {
      final objectPath =
          '${currentUser.id}/docs/offer_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final storage = Supabase.instance.client.storage.from('request-media');
      await storage.uploadBinary(
        objectPath,
        bytes,
        fileOptions: FileOptions(upsert: true, contentType: 'application/pdf'),
      );
      final publicUrl = storage.getPublicUrl(objectPath);

      if (!mounted) return;
      setState(() {
        _pdfUrl = publicUrl;
        _pdfFileName = file.name;
      });
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.pdfUploadFailed(error.toString()),
        type: AppToastType.error,
      );
    }
  }

  Future<void> _submitOffer() async {
    final reference = _referenceNumberController.text.trim();
    final salesNumber = _salesNumberController.text.trim();
    final customerName = _customerNameController.text.trim();
    final customerPhone = _customerPhoneController.text.trim();
    final requestTitle = _requestTitleController.text.trim();
    final material = _materialController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    if (reference.isEmpty) {
      AppToast.show(context, _l10n.refRequired, type: AppToastType.error);
      return;
    }

    if (salesNumber.isEmpty) {
      AppToast.show(
        context,
        _l10n.salesNumberRequired,
        type: AppToastType.error,
      );
      return;
    }

    if (customerName.isEmpty) {
      AppToast.show(
        context,
        _l10n.customerNameRequired,
        type: AppToastType.error,
      );
      return;
    }

    if (customerPhone.isEmpty) {
      AppToast.show(
        context,
        _l10n.customerPhoneRequired,
        type: AppToastType.error,
      );
      return;
    }

    if (requestTitle.isEmpty) {
      AppToast.show(
        context,
        _l10n.orderTitleRequired,
        type: AppToastType.error,
      );
      return;
    }

    if (material.isEmpty || quantity <= 0) {
      AppToast.show(
        context,
        _l10n.materialQuantityInvalid,
        type: AppToastType.error,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final appUserId = await AuthService.getCurrentAppUserId();

      if (_isEditMode) {
        await OfferService.updateOfferDraft(
          offerId: widget.editOffer!.id,
          requestType: _requestType,
          category: _category,
          salesNumber: salesNumber,
          customerName: customerName,
          customerPhone: customerPhone,
          customerAddress: _customerAddressController.text.trim(),
          customerAddressUrl: _customerAddressUrlController.text.trim(),
          pdfUrl: _pdfUrl,
          requestTitle: requestTitle,
          material: material,
          quantity: quantity,
          handoverDate: _handoverDate,
          tileCode: _tileCodeController.text.trim(),
          tileImageUrl: _tileImageUrl,
          description: _descriptionController.text.trim(),
        );

        if (_isPostAcceptanceEdit) {
          await OfferService.reopenOfferForEdit(
            offerId: widget.editOffer!.id,
            requestType: _requestType,
            category: _category,
          );
        } else {
          await OfferService.resubmitOffer(
            offerId: widget.editOffer!.id,
            requestType: _requestType,
            category: _category,
            rejectedByRole: widget.editOffer!.assignedRole,
          );
        }
      } else {
        var finalReference = reference;
        try {
          final reserved = await OfferService.fetchNextReferenceNumber();
          finalReference = reserved;
        } on Object {
          // Reservation failed — fall back to the displayed number.
        }
        await OfferService.createOffer(
          salesOfficerId: appUserId,
          sellerName: widget.sellerName,
          referenceNumber: finalReference,
          salesNumber: salesNumber,
          requestType: _requestType,
          category: _category,
          customerName: customerName,
          customerPhone: customerPhone,
          customerAddress: _customerAddressController.text.trim(),
          customerAddressUrl: _customerAddressUrlController.text.trim(),
          pdfUrl: _pdfUrl,
          requestTitle: requestTitle,
          material: material,
          quantity: quantity,
          handoverDate: _handoverDate,
          tileCode: _tileCodeController.text.trim(),
          tileImageUrl: _tileImageUrl,
          description: _descriptionController.text.trim(),
        );
      }

      if (!mounted) return;
      AppToast.show(
        context,
        _isEditMode
            ? (_isPostAcceptanceEdit
                ? _l10n.editResubmittedForReview
                : _l10n.editResubmitted)
            : _l10n.orderAdded,
        type: AppToastType.success,
      );
      Navigator.of(context).pop();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      AppToast.show(
        context,
        _l10n.saveFailed(error.toString()),
        type: AppToastType.error,
      );
    }
  }

  String _normalizeCategoryForDisplay(String value) {
    switch (value) {
      case 'vanity_top':
        return 'VANITY TOP';
      case 'kitchen_top':
        return 'KITCHEN TOP';
      case 'staircase':
        return 'STAIRCASE';
      case 'threshold':
        return 'TRESHOLD';
      case 'skirting':
        return 'SKIRTING';
      case 'tiles_cutting':
        return 'TILES CUTTING';
      case 'tables':
        return 'TABLES';
      case 'kitchen_cabinet':
        return 'KITCHEN CABINET';
      case 'vanity':
        return 'VANITY';
      case 'wardrobe':
        return 'WARDROBE';
      case 'doors':
        return 'DOORS';
      case 'tv_unit':
        return 'TV UNIT';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      appBar: Glass(
        child: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            _isEditMode
                ? (_isPostAcceptanceEdit
                    ? _l10n.editOrderAfterApproval
                    : _l10n.editOrderTitle)
                : _l10n.newOrderTitle,
          ),
          centerTitle: true,
          actions: [
            IconButton(
tooltip: _l10n.cancelOrderTooltip,
              onPressed: _isSubmitting
                  ? null
                  : () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackground()),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
            children: [
              _InfoSectionCard(
                icon: Icons.receipt_long_outlined,
                title: _l10n.refNumberSection,
                child: Column(
                  children: [
                    TextField(
                      controller: _referenceNumberController,
                      decoration: InputDecoration(
                        labelText: _l10n.serialNumberLabel,
                        hintText: _referenceLoading
                            ? _l10n.generatingSerial
                            : null,
                        prefixIcon: const Icon(Icons.numbers_outlined),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _salesNumberController,
                      decoration: InputDecoration(
                        labelText: _l10n.salesNumberLabel,
                        prefixIcon: const Icon(
                          Icons.sell_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _l10n.requestTypeSection,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          selected: _requestType == 'fabrication',
                          avatar: const Icon(Icons.handyman_outlined, size: 16),
                          label: Text(_l10n.fabricationChip),
                          onSelected: (_) {
                            setState(() => _requestType = 'fabrication');
                          },
                        ),
                        ChoiceChip(
                          selected: _requestType == 'installation',
                          avatar: const Icon(
                            Icons.home_work_outlined,
                            size: 16,
                          ),
                          label: Text(_l10n.installationChip),
                          onSelected: (_) {
                            setState(() => _requestType = 'installation');
                          },
                        ),
                        ChoiceChip(
                          selected: _requestType == 'both',
                          avatar: const Icon(
                            Icons.all_inclusive_outlined,
                            size: 16,
                          ),
                          label: Text(_l10n.requestTypeBoth),
                          onSelected: (_) {
                            setState(() => _requestType = 'both');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _InfoSectionCard(
                icon: Icons.people_outline,
                title: _l10n.customerSection,
                child: Column(
                  children: [
                    TextField(
                      controller: _sellerNameController,
                      decoration: InputDecoration(
                        labelText: _l10n.sellerField,
                        prefixIcon: const Icon(Icons.storefront_outlined),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customerNameController,
                      decoration: InputDecoration(
                        labelText: _l10n.customerNameField,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customerPhoneController,
                      decoration: InputDecoration(
                        labelText: _l10n.customerPhoneField,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customerAddressController,
                      decoration: InputDecoration(
                        labelText: _l10n.customerAddressField,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customerAddressUrlController,
                      decoration: InputDecoration(
                        labelText: _l10n.addressUrlField,
                        prefixIcon: const Icon(Icons.link_outlined),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _InfoSectionCard(
                icon: Icons.inventory_2_outlined,
                title: _l10n.detailsSection,
                child: Column(
                  children: [
                    TextField(
                      controller: _requestTitleController,
                      decoration: InputDecoration(
                        labelText: _l10n.orderTitleField,
                        prefixIcon: const Icon(Icons.title_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: InputDecoration(
                        labelText: _l10n.categoryField,
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      items: OfferService.requestCategories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                _normalizeCategoryForDisplay(category),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _category = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _materialController,
                      decoration: InputDecoration(
                        labelText: _l10n.materialField,
                        prefixIcon: const Icon(Icons.build_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: _l10n.quantityField,
                        prefixIcon: const Icon(Icons.numbers_outlined),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _pickHandoverDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: _l10n.deliveryDateField,
                          prefixIcon: const Icon(Icons.event_outlined),
                        ),
                        child: Text(
                          _handoverDate == null
                              ? _l10n.notSpecified
                              : '${_handoverDate!.year}-${_handoverDate!.month.toString().padLeft(2, '0')}-${_handoverDate!.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tileCodeController,
                      decoration: InputDecoration(
                        labelText: _l10n.tileCodeField,
                        prefixIcon: const Icon(Icons.qr_code_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _tileImageUrl.isEmpty
                                ? _l10n.tileImageNone
                                : _l10n.tileImageUploaded,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickTileImage,
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            size: 18,
                          ),
                          label: Text(_l10n.chooseImageBtn),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _pdfFileName.isEmpty
                                ? _l10n.pdfNone
                                : _l10n.pdfName(_pdfFileName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        if (_pdfFileName.isNotEmpty)
                          IconButton(
                            tooltip: _l10n.removeFileTooltip,
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              setState(() {
                                _pdfUrl = '';
                                _pdfFileName = '';
                              });
                            },
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        OutlinedButton.icon(
                          onPressed: _pickPdfFile,
                          icon: const Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 18,
                          ),
                          label: Text(
                            _pdfFileName.isEmpty
                                ? _l10n.choosePdfBtn
                                : _l10n.changePdfBtn,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: _l10n.descriptionField,
                        prefixIcon: const Icon(Icons.notes_outlined),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Glass(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _submitOffer,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 20),
              label: Text(
                _isSubmitting
                    ? _l10n.submitting
                    : (_isEditMode
                        ? _l10n.saveAndResubmit
                        : _l10n.submitOrderBtn),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
