import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  static Future<AuthResponse> signInWithEmail(String email, String password) {
    return _client.auth
        .signInWithPassword(email: email, password: password)
        .then((response) async {
          if (response.session != null) {
            await ensureUserProfile();
          }
          return response;
        });
  }

  static Future<AuthResponse> signUpWithEmail(
    String email,
    String password, {
    String? fullName,
    String? role,
  }) {
    final normalizedName = fullName?.trim();
    final normalizedRole = role?.trim();

    return _client.auth
        .signUp(
          email: email,
          password: password,
          data: {
            if (normalizedName != null && normalizedName.isNotEmpty)
              'full_name': normalizedName,
            if (normalizedRole != null && normalizedRole.isNotEmpty)
              'role': normalizedRole,
          },
        )
        .then((response) async {
          if (response.session != null) {
            await ensureUserProfile(fullName: fullName, role: role);
          }
          return response;
        });
  }

  static Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) {
    return _client.auth
        .verifyOTP(
          type: OtpType.signup,
          email: email,
          token: token,
        )
        .then((response) async {
          if (response.session != null) {
            await ensureUserProfile();
          }
          return response;
        });
  }

  static Future<void> resendSignupOTP(String email) {
    return _client.auth.resend(type: OtpType.signup, email: email.trim());
  }

  static Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(email.trim());
  }

  static Future<void> ensureUserProfile({
    String? fullName,
    String? role,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    final existingRows = await _client
        .from('users')
        .select('full_name, role')
        .eq('auth_id', user.id)
        .limit(1);

    String? existingFullName;
    String? existingRole;
    final rowExists = existingRows.isNotEmpty;
    if (rowExists) {
      existingFullName = (existingRows.first['full_name'] as String?)?.trim();
      existingRole = (existingRows.first['role'] as String?)?.trim();
    }

    final payload = <String, dynamic>{'auth_id': user.id, 'email': user.email};

    final metadataImageUrl = user.userMetadata?['profile_image_url'];
    if (metadataImageUrl is String && metadataImageUrl.trim().isNotEmpty) {
      payload['profile_image_url'] = metadataImageUrl.trim();
    }

    final normalizedName = fullName?.trim();
    final resolvedName = _resolveProfileName(
      user: user,
      providedFullName: normalizedName,
      existingFullName: existingFullName,
    );

    // Include full_name on inserts (or explicit updates) to satisfy NOT NULL databases.
    if (!rowExists || (normalizedName != null && normalizedName.isNotEmpty)) {
      payload['full_name'] = resolvedName;
    }

    final resolvedRole = _resolveProfileRole(
      user: user,
      providedRole: role,
      existingRole: existingRole,
    );
    payload['role'] = resolvedRole;

    await _client.from('users').upsert(payload, onConflict: 'auth_id');
  }

  static String _resolveProfileName({
    required User user,
    String? providedFullName,
    String? existingFullName,
  }) {
    final fromInput = providedFullName?.trim();
    if (fromInput != null && fromInput.isNotEmpty) {
      return fromInput;
    }

    final fromExisting = existingFullName?.trim();
    if (fromExisting != null && fromExisting.isNotEmpty) {
      return fromExisting;
    }

    final metadata = user.userMetadata;
    final metadataName = metadata?['full_name'];
    if (metadataName is String && metadataName.trim().isNotEmpty) {
      return metadataName.trim();
    }

    final email = user.email?.trim() ?? '';
    if (email.contains('@')) {
      final prefix = email.split('@').first.trim();
      if (prefix.isNotEmpty) {
        return prefix;
      }
    }

    return 'User';
  }

  static String _resolveProfileRole({
    required User user,
    String? providedRole,
    String? existingRole,
  }) {
    final fromInput = _normalizeRole(providedRole);
    if (fromInput != null) {
      return fromInput;
    }

    final fromExisting = _normalizeRole(existingRole);
    if (fromExisting != null) {
      return fromExisting;
    }

    final metadataRole = user.userMetadata?['role'];
    if (metadataRole is String) {
      final fromMetadata = _normalizeRole(metadataRole);
      if (fromMetadata != null) {
        return fromMetadata;
      }
    }

    return 'sales_officer';
  }

  static String? _normalizeRole(String? role) {
    final value = role?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    const allowedRoles = {
      'sales_officer',
      'factory_officer',
      'wood_factory_officer',
      'company_officer',
      'responsible_officer',
    };

    return allowedRoles.contains(value) ? value : null;
  }

  static Future<String> getCurrentAppUserId() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    await ensureUserProfile();

    final row = await _client
        .from('users')
        .select('id')
        .eq('auth_id', user.id)
        .single();

    return row['id'] as String;
  }

  static Future<void> signOut() {
    return NotificationService.clearToken().then((_) {
      return _client.auth.signOut();
    });
  }
}
