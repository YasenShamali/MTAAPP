import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/offer.dart';
import '../services/locale_service.dart';
import '../theme/app_theme.dart';
import '../utils/currency.dart';
import '../widgets/app_toast.dart';
import '../widgets/presentation.dart';

AppLocalizations get _l10n => LocaleService.l10n;

String _roleLabelForReport(String role) {
  switch (role) {
    case 'sales_officer':
      return 'Sales Officer';
    case 'factory_officer':
      return 'Tile Factory';
    case 'wood_factory_officer':
      return 'Wood Factory';
    case 'company_officer':
      return 'Installation Officer';
    case 'responsible_officer':
      return 'Responsible Officer';
    default:
      return role;
  }
}

String _rejectedByForReport(Offer offer) {
  final name = (offer.rejectedByName ?? '').trim();
  final role = (offer.rejectedByRole ?? '').trim();
  if (name.isEmpty && role.isEmpty) {
    return '';
  }
  final parts = <String>[
    if (name.isNotEmpty) name,
    if (role.isNotEmpty) _roleLabelForReport(role),
  ];
  return parts.join(' • ');
}

/// Full activity log of all requests with an optional printable PDF report.
/// Available to sales officers and the responsible officer.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({
    super.key,
    required this.offers,
    required this.generatedBy,
  });

  final List<Offer> offers;
  final String generatedBy;

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  static const List<String> _filters = [
    'all',
    'pending_factory',
    'pending_installation',
    'approved',
    'in_progress',
    'completed',
    'rejected',
    'cancelled',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';
  bool _busy = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Offer> get _filteredOffers {
    final query = _searchController.text.trim().toLowerCase();
    return widget.offers.where((offer) {
      final matchesStatus =
          _statusFilter == 'all' || offer.status == _statusFilter;
      if (!matchesStatus) return false;
      if (query.isEmpty) return true;

      final haystack = [
        offer.referenceNumber,
        offer.requestTitle,
        offer.customerName,
        offer.customerPhone,
        offer.sellerName,
        offer.material,
        offer.tileCode,
        offer.description,
        _statusLabel(offer.status),
        _requestTypeLabel(offer.requestType),
        _categoryLabel(offer.category),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Future<void> _printReport() async {
    await _printReportFor(_filteredOffers, single: false);
  }

  Future<void> _printSingleOffer(Offer offer) async {
    await _printReportFor([offer], single: true);
  }

  Future<void> _printReportFor(
    List<Offer> offers, {
    required bool single,
  }) async {
    if (offers.isEmpty) {
      AppToast.show(
        context,
        _l10n.noOrdersForReport,
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final logoImage = await imageFromAssetBundle('assets/mta_logo.png');
      final reportCreatedAt = DateTime.now();

      for (final offer in offers) {
        final document = pw.Document();

        document.addPage(
          pw.MultiPage(
            pageTheme: pw.PageTheme(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 60),
              buildBackground: (ctx) {
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
              final safeReference = offer.referenceNumber.trim().isEmpty
                  ? offer.id
                  : offer.referenceNumber.trim();

              return [
                _buildDefaultReportHeader(
                  reportCreatedAt: reportCreatedAt,
                  generatedBy: widget.generatedBy,
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
                    if (offer.customerAddress?.trim().isNotEmpty ?? false)
                      _reportRow('Customer Address', offer.customerAddress!),
                    if (offer.customerAddressUrl?.trim().isNotEmpty ?? false)
                      _reportRow('Address Map Link', offer.customerAddressUrl!),
                    _reportRow('Handover Date', _formatDate(offer.handoverDate)),
                    _reportRow('Created At', _formatDateTime(offer.createdAt)),
                    if (offer.acceptedAt != null)
                      _reportRow('Accepted At', _formatDateTime(offer.acceptedAt)),
                    if (offer.status == 'completed')
                      _reportRow('Completed At', _formatDateTime(offer.approvedAt)),
                    if (offer.status == 'rejected') ...[
                      _reportRow('Rejected At', _formatDateTime(offer.rejectedAt)),
                      if (_rejectedByForReport(offer).isNotEmpty)
                        _reportRow('Rejected By', _rejectedByForReport(offer)),
                      if (offer.rejectionReason?.trim().isNotEmpty ?? false)
                        _reportRow('Rejection Reason', offer.rejectionReason!),
                    ],
                    if (offer.status == 'cancelled') ...[
                      _reportRow('Cancelled At', _formatDateTime(offer.cancelledAt)),
                      if (offer.cancellationReason?.trim().isNotEmpty ?? false)
                        _reportRow('Cancellation Reason', offer.cancellationReason!),
                    ],
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
                    if (offer.tileCode.trim().isNotEmpty)
                      _reportRow('Tile Code', offer.tileCode),
                    if (offer.description.trim().isNotEmpty)
                      _reportRow('Description', offer.description),
                  ],
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

        final safeName = reportCreatedAt
            .toIso8601String()
            .replaceAll(':', '-')
            .split('.')
            .first;
        await Printing.layoutPdf(
          onLayout: (_) async => document.save(),
          name: single
              ? 'order_report_$safeName.pdf'
              : 'orders_history_$safeName.pdf',
        );
      }

      if (!mounted) return;
      AppToast.show(
        context,
        single ? _l10n.singleReportReady : _l10n.listReportReady,
        type: AppToastType.success,
      );
    } on Object catch (error) {
      if (!mounted) return;
      AppToast.show(
        context,
        _l10n.reportFailed(error.toString()),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
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
                'Requests History Report',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offers = _filteredOffers;

    return Scaffold(
      appBar: AppBar(
        title: Text(_l10n.historyTitle),
        actions: [
          IconButton(
            tooltip: _l10n.downloadTooltip,
            icon: const Icon(Icons.download_outlined),
            onPressed: _busy ? null : _printReport,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: _l10n.historySearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: _l10n.clearSearchTooltip,
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final count = widget.offers
                          .where((o) =>
                              filter == 'all' || o.status == filter)
                          .length;
                      return ChoiceChip(
                        label: Text(
                          '${_filterLabel(filter)} ($count)',
                        ),
                        selected: _statusFilter == filter,
                        onSelected: (_) =>
                            setState(() => _statusFilter = filter),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: offers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: offers.length,
                          itemBuilder: (context, index) => _HistoryCard(
                            offer: offers[index],
                            onPrint: () => _printSingleOffer(offers[index]),
                          ),
                        ),
                ),
              ],
            ),
          ),
          if (_busy)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.primary
                    .withValues(alpha: 0.15),
              ),
            ),
          if (_busy)
            const ModalBarrier(
              dismissible: false,
              color: Colors.black26,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: _l10n.historyEmptyTitle,
      message: _l10n.historyEmptyMessage,
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.offer, this.onPrint});

  final Offer offer;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColors = _statusBgColor(offer.status);

    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  backgroundColors.withValues(alpha: 0.30),
                  backgroundColors.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
                begin: Alignment.topRight,
                end: Alignment.topLeft,
              ),
            ),
            child: Row(
              children: [
                _StatusBadge(status: offer.status),
                const Spacer(),
                Text(
                  '#${offer.referenceNumber.trim().isEmpty ? offer.id : offer.referenceNumber.trim()}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.requestTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_requestTypeLabel(offer.requestType)} • ${_categoryLabel(offer.category)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (offer.totalPrice > 0)
                      Text(
                        formatAED(offer.totalPrice),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TimelineStep(
                  icon: Icons.schedule,
                  color: AppColors.primary,
                  title: _l10n.timelineCreated,
                  timestamp: _formatDateTime(offer.createdAt),
                ),
                if (offer.acceptedAt != null)
                  _TimelineStep(
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                    title: _l10n.timelineAccepted,
                    timestamp: _formatDateTime(offer.acceptedAt),
                  ),
                if (offer.status == 'completed')
                  _TimelineStep(
                    icon: Icons.flag_outlined,
                    color: AppColors.success,
                    title: _l10n.timelineCompleted,
                    timestamp: _formatDateTime(offer.approvedAt),
                  ),
                if (offer.status == 'rejected') ...[
                  _TimelineStep(
                    icon: Icons.cancel_outlined,
                    color: AppColors.danger,
                    title: _l10n.timelineRejected,
                    timestamp: _formatDateTime(offer.rejectedAt),
                  ),
                  if (offer.rejectionReason?.trim().isNotEmpty ?? false)
                    _NoteLine(
                      color: AppColors.danger,
                      text: _l10n.reasonColon(offer.rejectionReason!.trim()),
                    ),
                ],
                if (offer.status == 'cancelled') ...[
                  _TimelineStep(
                    icon: Icons.remove_circle_outline,
                    color: AppColors.textSecondary,
                    title: _l10n.timelineCancelled,
                    timestamp: _formatDateTime(offer.cancelledAt),
                  ),
                  if (offer.cancellationReason?.trim().isNotEmpty ?? false)
                    _NoteLine(
                      color: AppColors.textSecondary,
                      text: _l10n.reasonColon(offer.cancellationReason!.trim()),
                    ),
                ],
              ],
            ),
          ),
          const Divider(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(_l10n.detailSeller, offer.sellerName),
                _DetailRow(_l10n.detailCustomer, offer.customerName),
                _DetailRow(_l10n.detailPhone, offer.customerPhone),
                if (offer.customerAddress?.trim().isNotEmpty ?? false)
                  _DetailRow(_l10n.detailAddress, offer.customerAddress!.trim()),
                if (offer.customerAddressUrl?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: () => _launchMap(context, offer.customerAddressUrl!),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: Text(_l10n.openMapLink),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
                const Divider(height: 18),
                _DetailRow(_l10n.detailMaterial, offer.material),
                _DetailRow(_l10n.detailQuantity, '${offer.quantity}'),
                if (offer.tileCode.trim().isNotEmpty)
                  _DetailRow(_l10n.detailTileCode, offer.tileCode.trim()),
                if (offer.description.trim().isNotEmpty)
                  _DetailRow(_l10n.detailDescription, offer.description.trim()),
                _DetailRow(
                  _l10n.detailHandover,
                  _formatDate(offer.handoverDate),
                ),
                if (onPrint != null) ...[
                  const Divider(height: 18),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: OutlinedButton.icon(
                      onPressed: onPrint,
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: Text(_l10n.printOrderReport),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchMap(BuildContext context, String url) async {
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
    } on Object {
      if (context.mounted) {
        AppToast.show(context, _l10n.cannotOpenLink, type: AppToastType.error);
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: _statusLabel(status),
      foreground: _statusColor(status),
      background: _statusBgColor(status),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.icon,
    required this.color,
    required this.title,
    required this.timestamp,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            timestamp,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteLine extends StatelessWidget {
  const _NoteLine({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 28, bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Shared helpers ─────────────────────────────

String _filterLabel(String filter) {
  switch (filter) {
    case 'all':
      return _l10n.historyFilterAll;
    case 'pending_factory':
      return _l10n.historyFilterPendingFactory;
    case 'pending_installation':
      return _l10n.historyFilterPendingInstallation;
    case 'approved':
      return _l10n.historyFilterApproved;
    case 'in_progress':
      return _l10n.historyFilterInProgress;
    case 'completed':
      return _l10n.historyFilterCompleted;
    case 'rejected':
      return _l10n.historyFilterRejected;
    case 'cancelled':
      return _l10n.historyFilterCancelled;
    default:
      return filter;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'pending_factory':
      return _l10n.statusPendingTileFactory;
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

Color _statusColor(String status) {
  switch (status) {
    case 'approved':
      return AppColors.success;
    case 'completed':
      return AppColors.success;
    case 'rejected':
      return AppColors.danger;
    case 'cancelled':
      return AppColors.textSecondary;
    case 'in_progress':
      return AppColors.primary;
    default:
      return AppColors.warning;
  }
}

Color _statusBgColor(String status) {
  switch (status) {
    case 'approved':
    case 'completed':
      return AppColors.successBg;
    case 'rejected':
      return AppColors.dangerBg;
    case 'cancelled':
      return AppColors.infoBg;
    case 'in_progress':
      return AppColors.infoBg;
    default:
      return AppColors.warningBg;
  }
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

String _formatDate(DateTime? value) {
  if (value == null) return '-';
  final local = value.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _formatDateTime(DateTime? value) {
  if (value == null) return '-';
  final local = value.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final h = local.hour.toString().padLeft(2, '0');
  final min = local.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $h:$min';
}