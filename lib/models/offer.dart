class Offer {
  final String id;
  final String salesOfficerId;
  final String? requesterId;
  final String? factoryOfficerId;
  final String material;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final String status;
  final String? factoryComment;
  final String? rejectionReason;
  final String description;
  final String referenceNumber;
  final String salesNumber;
  final String requestType;
  final String tileCode;
  final String? tileImageUrl;
  final String category;
  final String sellerName;
  final String customerName;
  final String customerPhone;
  final String? customerAddress;
  final String? customerAddressUrl;
  final String? pdfUrl;
  final String requestTitle;
  final DateTime? handoverDate;
  final String? assignedRole;
  final String? assignedTo;
  final String? reviewedBy;
  final String? lastReviewerId;
  final bool needsResubmission;
  final DateTime? approvedAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final String? rejectedByName;
  final String? rejectedByRole;
  final String? editRequestedBy;
  final String? editRequestReason;
  final DateTime? editRequestedAt;
  final bool editApproved;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Offer({
    required this.id,
    required this.salesOfficerId,
    this.requesterId,
    this.factoryOfficerId,
    required this.material,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    this.factoryComment,
    this.rejectionReason,
    required this.description,
    required this.referenceNumber,
    required this.salesNumber,
    required this.requestType,
    required this.tileCode,
    this.tileImageUrl,
    required this.category,
    required this.sellerName,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress,
    this.customerAddressUrl,
    this.pdfUrl,
    required this.requestTitle,
    this.handoverDate,
    this.assignedRole,
    this.assignedTo,
    this.reviewedBy,
    this.lastReviewerId,
    required this.needsResubmission,
    this.approvedAt,
    this.acceptedAt,
    this.rejectedAt,
    this.rejectedByName,
    this.rejectedByRole,
    this.editRequestedBy,
    this.editRequestReason,
    this.editRequestedAt,
    this.editApproved = false,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String key) {
      final value = json[key] as String?;
      if (value == null || value.isEmpty) {
        return null;
      }
      return DateTime.tryParse(value);
    }

    return Offer(
      id: json['id'] as String,
      salesOfficerId: json['sales_officer_id'] as String,
      requesterId: json['requester_id'] as String?,
      factoryOfficerId: json['factory_officer_id'] as String?,
      material: json['material'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'] as String,
      factoryComment: json['factory_comment'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      description: json['description'] as String? ?? '',
      referenceNumber: json['reference_number'] as String? ?? '',
      salesNumber: json['sales_number'] as String? ?? '',
      requestType: json['request_type'] as String? ?? 'fabrication',
      tileCode: json['tile_code'] as String? ?? '',
      tileImageUrl: json['tile_image_url'] as String?,
      category: json['category'] as String? ?? 'kitchen',
      sellerName: json['seller_name'] as String? ?? 'User',
      customerName: json['customer_name'] as String? ?? 'Customer',
      customerPhone: json['customer_phone'] as String? ?? '',
      customerAddress: json['customer_address'] as String?,
      customerAddressUrl: json['customer_address_url'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      requestTitle:
          json['request_title'] as String? ??
          (json['material'] as String? ?? ''),
      handoverDate: parseDate('handover_date'),
      assignedRole: json['assigned_role'] as String?,
      assignedTo: json['assigned_to'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      lastReviewerId: json['last_reviewer_id'] as String?,
      needsResubmission: json['needs_resubmission'] as bool? ?? false,
      approvedAt: parseDate('approved_at'),
      acceptedAt: parseDate('accepted_at'),
      rejectedAt: parseDate('rejected_at'),
      rejectedByName: json['rejected_by_name'] as String?,
      rejectedByRole: json['rejected_by_role'] as String?,
      editRequestedBy: json['edit_requested_by'] as String?,
      editRequestReason: json['edit_request_reason'] as String?,
      editRequestedAt: parseDate('edit_requested_at'),
      editApproved: json['edit_approved'] as bool? ?? false,
      cancelledAt: parseDate('cancelled_at'),
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
