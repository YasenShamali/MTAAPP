import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';
import '../widgets/auth_inputs.dart';
import '../widgets/glass.dart';
import 'home_screen.dart';

AppLocalizations get _l10n => LocaleService.l10n;

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.fullName,
    required this.role,
    required this.password,
  });

  final String email;
  final String fullName;
  final String role;
  final String password;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _codeLength = 6;

  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_codeLength, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _requestFocus(0);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _requestFocus(int index) {
    if (index >= 0 && index < _codeLength) {
      _focusNodes[index].requestFocus();
    }
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < _codeLength - 1) {
      _requestFocus(index + 1);
    } else if (value.isEmpty && index > 0) {
      _requestFocus(index - 1);
    }

    final fullCode = _controllers.map((c) => c.text).join();
    if (fullCode.length == _codeLength) {
      _verifyCode(fullCode);
    }
  }

  Future<void> _verifyCode(String code) async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final response = await AuthService.verifyOTP(
        email: widget.email,
        token: code,
      );

      if (!mounted) return;

      if (response.session != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        _showError(_l10n.otpInvalidCode);
        _clearCode();
      }
    } on AuthApiException catch (error) {
      if (!mounted) return;
      final isExpired = (error.code ?? '') == 'otp_expired';
      _showError(isExpired ? _l10n.otpCodeExpired : _l10n.otpInvalidCode);
      _clearCode();
    } on Object catch (_) {
      if (!mounted) return;
      _showError(_l10n.otpInvalidCode);
      _clearCode();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearCode() {
    for (final c in _controllers) {
      c.clear();
    }
    _requestFocus(0);
  }

  void _showError(String message) {
    AppToast.show(context, message, type: AppToastType.error);
  }

  Future<void> _resendCode() async {
    if (_isResending) return;
    setState(() => _isResending = true);

    try {
      await AuthService.resendSignupOTP(widget.email);
      if (!mounted) return;
      _clearCode();
      _startResendCooldown();
      AppToast.show(
        context,
        _l10n.otpCodeSent,
        type: AppToastType.success,
      );
    } on Object catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _startResendCooldown() {
    const cooldownSeconds = 60;
    _resendCooldown = cooldownSeconds;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCooldown--);
      return _resendCooldown > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _BrandHeader(),
                      const SizedBox(height: 28),
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _l10n.otpTitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _l10n.otpSubtitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.email,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(height: 28),
                            _buildCodeFields(),
                            const SizedBox(height: 24),
                            PrimaryGradientButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      final code = _controllers.map((c) => c.text).join();
                                      if (code.length == 6) {
                                        _verifyCode(code);
                                      } else {
                                        _showError(_l10n.otpCodeIncomplete);
                                      }
                                    },
                              loading: _isLoading,
                              icon: const Icon(
                                Icons.verified_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                              label: Text(
                                _isLoading ? _l10n.loginLoading : _l10n.otpVerifyButton,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildResendSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeFields() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_codeLength, (index) {
        return Container(
          width: 48,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '○',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              filled: true,
              fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: scheme.primary, width: 2),
              ),
            ),
            onChanged: (v) => _onCodeChanged(v, index),
          ),
        );
      }),
    );
  }

  Widget _buildResendSection() {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _l10n.otpResendLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _resendCooldown > 0 || _isResending ? null : _resendCode,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: _resendCooldown > 0
              ? Text(
                  '${_l10n.otpResendButton} (${_resendCooldown}s)',
                  style: TextStyle(
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                )
              : _isResending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _l10n.otpResendButton,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
        ),
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth * 0.62).clamp(150.0, 250.0);
            return Image.asset(
              'assets/mta_logo.png',
              width: width,
              fit: BoxFit.contain,
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          _l10n.brandTagline,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}