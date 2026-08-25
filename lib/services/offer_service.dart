import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';

class OfferService {
  static final SupabaseClient _client = Supabase.instance.client;

  static const List<String> requestCategories = [
    // Tile factory (مصنع البلاط)
    'vanity_top',
    'kitchen_top',
    'staircase',
    'threshold',
    'skirting',
    'tiles_cutting',
    'tables',
    // Wood factory (مصنع الخشب)
    'kitchen_cabinet',
    'vanity',
    'wardrobe',
    'doors',
    'tv_unit',
  ];

  static const List<String> requestTypes = [
    'fabrication',
    'installation',
    'both',
  ];

  /// Categories that are fabricated at the tile factory (مصنع البلاط).
  /// Everything else goes to the wood factory (مصنع الخشب).
  static const List<String> tileFactoryCategories = [
    'vanity_top',
    'kitchen_top',
    'staircase',
    'threshold',
    'skirting',
    'tiles_cutting',
    'tables',
  ];

  static String factoryRoleForCategory(String category) {
    return tileFactoryCategories.contains(category)
        ? 'factory_officer'
        : 'wood_factory_officer';
  }

  static Future<String> fetchNextReferenceNumber() async {
    final result = await _client.rpc('next_reference_number');
    return result as String;
  }

  static Future<String> fetchCurrentReferenceNumber() async {
    final result = await _client.rpc('current_reference_number');
    return result as String;
  }

  static Future<List<Map<String, dynamic>>> fetchOffersForUser(
    String userId,
    String role,
  ) async {
    if (role == 'responsible_officer') {
      final data = await _client
          .from('offers')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data as List<dynamic>);
    }

    if (role == 'factory_officer') {
      final data = await _client
          .from('offers')
          .select()
          .or(
            'assigned_role.eq.factory_officer,assigned_to.eq.$userId,last_reviewer_id.eq.$userId',
          )
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data as List<dynamic>);
    }

    if (role == 'company_officer') {
      final data = await _client
          .from('offers')
          .select()
          .or(
            'assigned_role.eq.company_officer,assigned_to.eq.$userId,last_reviewer_id.eq.$userId',
          )
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data as List<dynamic>);
    }

    if (role == 'wood_factory_officer') {
      final data = await _client
          .from('offers')
          .select()
          .or(
            'assigned_role.eq.wood_factory_officer,assigned_to.eq.$userId,last_reviewer_id.eq.$userId',
          )
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data as List<dynamic>);
    }

    final data = await _client
        .from('offers')
        .select()
        .or('sales_officer_id.eq.$userId,requester_id.eq.$userId')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data as List<dynamic>);
  }

  static Future<void> createOffer({
    required String salesOfficerId,
    required String sellerName,
    required String referenceNumber,
    required String salesNumber,
    required String requestType,
    required String category,
    required String customerName,
    required String customerPhone,
    String? customerAddress,
    String? customerAddressUrl,
    String? pdfUrl,
    required String requestTitle,
    required String material,
    required int quantity,
    DateTime? handoverDate,
    String tileCode = '',
    String tileImageUrl = '',
    String description = '',
  }) async {
    final normalizedType = requestTypes.contains(requestType)
        ? requestType
        : 'fabrication';
    final normalizedCategory = requestCategories.contains(category)
        ? category
        : requestCategories.first;

    final assignedRole = normalizedType == 'installation'
        ? 'company_officer'
        : factoryRoleForCategory(normalizedCategory);
    final initialStatus = normalizedType == 'installation'
        ? 'pending_installation'
        : 'pending_factory';

    final inserted = await _client.from('offers').insert({
      'sales_officer_id': salesOfficerId,
      'requester_id': salesOfficerId,
      'reference_number': referenceNumber,
      'sales_number': salesNumber,
      'request_type': normalizedType,
      'tile_code': tileCode,
      'tile_image_url': tileImageUrl.isEmpty ? null : tileImageUrl,
      'category': normalizedCategory,
      'seller_name': sellerName,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress?.trim().isEmpty ?? true
          ? null
          : customerAddress!.trim(),
      'customer_address_url': customerAddressUrl?.trim().isEmpty ?? true
          ? null
          : customerAddressUrl!.trim(),
      'pdf_url': pdfUrl?.trim().isEmpty ?? true ? null : pdfUrl!.trim(),
      'request_title': requestTitle,

      'assigned_role': assignedRole,
      'material': material,
      'quantity': quantity,
      'unit': '',
      'unit_price': 0,
      'description': description,
      'status': initialStatus,
      'needs_resubmission': false,
    }).select('id').single();

    final offerId = inserted['id'] as String;
    NotificationService.notifyOfferEvent(offerId, 'new').ignore();
  }

  static Future<void> updateOfferDraft({
    required String offerId,
    required String requestType,
    required String category,
    required String customerName,
    required String customerPhone,
    String? customerAddress,
    String? customerAddressUrl,
    String? pdfUrl,
    required String requestTitle,
    required String material,
    required int quantity,
    DateTime? handoverDate,
    String tileCode = '',
    String tileImageUrl = '',
    String description = '',
    String salesNumber = '',
  }) async {
    final normalizedType = requestTypes.contains(requestType)
        ? requestType
        : 'fabrication';
    final normalizedCategory = requestCategories.contains(category)
        ? category
        : requestCategories.first;

    await _client
        .from('offers')
        .update({
          'request_type': normalizedType,
          'category': normalizedCategory,
          'sales_number': salesNumber,
          'customer_name': customerName,
          'customer_phone': customerPhone,
          'customer_address': customerAddress?.trim().isEmpty ?? true
              ? null
              : customerAddress!.trim(),
          'customer_address_url': customerAddressUrl?.trim().isEmpty ?? true
              ? null
              : customerAddressUrl!.trim(),
          'pdf_url': pdfUrl?.trim().isEmpty ?? true ? null : pdfUrl!.trim(),
          'request_title': requestTitle,
          'material': material,
          'quantity': quantity,
          'unit': '',
          'unit_price': 0,
          'handover_date': handoverDate?.toIso8601String(),
          'tile_code': tileCode,
          'tile_image_url': tileImageUrl.isEmpty ? null : tileImageUrl,
          'description': description,
          // Preserve the stage that rejected the request (assigned_role) so
          // the resubmission returns to the same stage instead of restarting.
          'needs_resubmission': false,
          'edit_requested_by': null,
          'edit_request_reason': null,
          'edit_requested_at': null,
          'edit_approved': false,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId);
  }

  /// Creator / responsible officer asks to edit an order that has already been
  /// accepted. The edit is applied only after the responsible officer approves.
  static Future<void> requestOfferEdit({
    required String offerId,
    required String requestedBy,
    required String reason,
  }) async {
    await _client
        .from('offers')
        .update({
          'edit_requested_by': requestedBy,
          'edit_request_reason': reason,
          'edit_requested_at': DateTime.now().toUtc().toIso8601String(),
          'edit_approved': false,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId);

    NotificationService.notifyOfferEvent(offerId, 'edit_requested').ignore();
  }

  /// Approves or rejects a pending edit request for an accepted order.
  /// When approved, the order is unlocked for editing by the requestor.
  static Future<void> resolveOfferEditRequest({
    required String offerId,
    required bool approved,
  }) async {
    await _client
        .from('offers')
        .update({
          'edit_requested_by': null,
          'edit_request_reason': null,
          'edit_requested_at': null,
          'edit_approved': approved,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId);

    NotificationService.notifyOfferEvent(
      offerId,
      approved ? 'edit_approved' : 'edit_rejected',
    ).ignore();
  }

  /// Applies a post-acceptance edit: clears the edit-approval state and routes
  /// the order back to the appropriate pending stage so the factories or
  /// installation workers review the updated details again.
  static Future<void> reopenOfferForEdit({
    required String offerId,
    required String requestType,
    required String category,
  }) async {
    final normalizedType = requestTypes.contains(requestType)
        ? requestType
        : 'fabrication';
    final normalizedCategory = requestCategories.contains(category)
        ? category
        : requestCategories.first;
    final assignedRole = normalizedType == 'installation'
        ? 'company_officer'
        : factoryRoleForCategory(normalizedCategory);
    final nextStatus = normalizedType == 'installation'
        ? 'pending_installation'
        : 'pending_factory';

    await _client
        .from('offers')
        .update({
          'status': nextStatus,
          'assigned_role': assignedRole,
          'edit_requested_by': null,
          'edit_request_reason': null,
          'edit_requested_at': null,
          'edit_approved': false,
          'needs_resubmission': false,
          'rejection_reason': null,
          'rejected_by_name': null,
          'rejected_by_role': null,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId);

    NotificationService.notifyOfferEvent(offerId, 'reopened').ignore();
  }

  static Future<void> updateOfferStatus({
    required String offerId,
    required String status,
    String? factoryComment,
    String? rejectionReason,
  }) async {
    await _client
        .from('offers')
        .update({
          'status': status,
          'factory_comment': factoryComment,
          'rejection_reason': rejectionReason,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId);
  }

  static Future<void> acceptOffer({
    required String offerId,
    required String reviewerUserId,
    String? reviewerRole,
    String? currentAssignedRole,
    String? note,
  }) async {
    final effectiveRole = reviewerRole == 'responsible_officer'
        ? (currentAssignedRole ?? reviewerRole)
        : reviewerRole;

    await _client
        .from('offers')
        .update({
          'status': 'approved',
          // Keep the stage role so the responsible officer can tell which
          // stage accepted the order (factory vs installation).
          'assigned_to': reviewerUserId,
          'last_reviewer_id': reviewerUserId,
          'reviewed_by': reviewerUserId,
          'factory_comment': note,
          'rejection_reason': null,
          'needs_resubmission': false,
          'accepted_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId);

    if (effectiveRole == null) {
      return;
    }
    await _logHistory(offerId, reviewerUserId, effectiveRole, 'approved', note);
    NotificationService.notifyOfferEvent(offerId, 'approved').ignore();
  }

  static Future<void> _logHistory(
    String offerId,
    String performedBy,
    String role,
    String toStatus,
    String? note,
  ) async {
    try {
      await _client.from('offer_history').insert({
        'offer_id': offerId,
        'performed_by': performedBy,
        'from_status': null,
        'to_status': toStatus,
        'role': role,
        'note': note,
      });
    } on Object {
      // History logging is best-effort.
    }
  }

  static Future<void> approveOffer({
    required String offerId,
    required String reviewerUserId,
    required String reviewerRole,
    String? currentAssignedRole,
    bool sendToInstallation = true,
    String? note,
  }) async {
    final effectiveRole = reviewerRole == 'responsible_officer'
        ? (currentAssignedRole ?? reviewerRole)
        : reviewerRole;

    late final String nextStatus;
    String? nextRole;
    final nextAssignee = reviewerUserId;

    if (effectiveRole == 'factory_officer' ||
        effectiveRole == 'wood_factory_officer') {
      if (sendToInstallation) {
        nextStatus = 'pending_installation';
        nextRole = 'company_officer';
      } else {
        nextStatus = 'completed';
        nextRole = null;
      }
    } else {
      nextStatus = 'completed';
      nextRole = null;
    }

    await _client
        .from('offers')
        .update({
          'status': nextStatus,
          'assigned_role': nextRole,
          // Keep the reviewer linked to the row so current RLS checks allow
          // transitions that hand over or complete the request.
          'assigned_to': nextAssignee,
          'last_reviewer_id': reviewerUserId,
          'reviewed_by': reviewerUserId,
          'factory_comment': note,
          'rejection_reason': null,
          if (nextStatus == 'completed')
            'approved_at': DateTime.now().toUtc().toIso8601String(),
          'needs_resubmission': false,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId);

    NotificationService.notifyOfferEvent(
      offerId,
      nextStatus == 'pending_installation' ? 'pending_installation' : 'completed',
    ).ignore();
  }

  static Future<void> rejectOffer({
    required String offerId,
    required String reviewerUserId,
    required String rejectionReason,
  }) async {
    String? rejecterName;
    String? rejecterRole;
    try {
      final profile = await _client
          .from('users')
          .select('full_name, role')
          .eq('id', reviewerUserId)
          .single();
      rejecterName = profile['full_name'] as String?;
      rejecterRole = profile['role'] as String?;
    } on Object {
      // Best-effort: the rejection still goes through without profile info.
    }

    await _client
        .from('offers')
        .update({
          'status': 'rejected',
          'rejection_reason': rejectionReason,
          'rejected_by_name': rejecterName,
          'rejected_by_role': rejecterRole,
          // Link the reviewer to the row so the current RLS "with check"
          // (assigned_to = u.id) allows moving the status to 'rejected'.
          'assigned_to': reviewerUserId,
          'last_reviewer_id': reviewerUserId,
          'reviewed_by': reviewerUserId,
          'needs_resubmission': true,
          'rejected_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId);

    NotificationService.notifyOfferEvent(
      offerId,
      'rejected',
      extra: {'rejection_reason': rejectionReason},
    ).ignore();
  }

  static Future<void> resubmitOffer({
    required String offerId,
    required String requestType,
    required String category,
    String? rejectedByRole,
  }) async {
    // Return the request to the same stage that rejected it so the flow
    // does not restart from the beginning. When the rejecting stage was a
    // factory, keep that factory unless the category changed, in which case
    // the request is re-routed to the factory for the new category.
    late final String nextStatus;
    late final String nextRole;
    if (rejectedByRole == 'company_officer') {
      nextStatus = 'pending_installation';
      nextRole = 'company_officer';
    } else {
      final targetRole = factoryRoleForCategory(category);
      final rejectedByFactory = rejectedByRole == 'factory_officer' ||
          rejectedByRole == 'wood_factory_officer';
      if (rejectedByFactory && rejectedByRole == targetRole) {
        nextRole = rejectedByRole!;
      } else {
        nextRole = targetRole;
      }
      nextStatus = 'pending_factory';
    }

    await _client
        .from('offers')
        .update({
          'status': nextStatus,
          'assigned_role': nextRole,
          'needs_resubmission': false,
          'rejection_reason': null,
          'rejected_by_name': null,
          'rejected_by_role': null,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId);

    NotificationService.notifyOfferEvent(offerId, 'resubmitted').ignore();
  }

  static Future<void> cancelOffer({
    required String offerId,
    required String cancellationReason,
  }) async {
    await _client
        .from('offers')
        .update({
          'status': 'cancelled',
          'cancellation_reason': cancellationReason,
          'cancelled_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId);

    NotificationService.notifyOfferEvent(offerId, 'cancelled').ignore();
  }

  static Future<List<Map<String, dynamic>>> fetchRequestMedia(
    String offerId,
  ) async {
    final data = await _client
        .from('request_media')
        .select()
        .eq('offer_id', offerId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data as List<dynamic>);
  }

  static Future<void> addRequestMedia({
    required String offerId,
    required String uploadedBy,
    required String stage,
    required String imageUrl,
    String note = '',
  }) async {
    await _client.from('request_media').insert({
      'offer_id': offerId,
      'uploaded_by': uploadedBy,
      'stage': stage,
      'image_url': imageUrl,
      'note': note,
    });
  }
}
