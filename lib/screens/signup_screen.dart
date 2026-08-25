import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';
import '../widgets/auth_inputs.dart';
import '../widgets/glass.dart';
import 'home_screen.dart';
import 'otp_verification_screen.dart';

AppLocalizations get _l10n => LocaleService.l10n;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _step1FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  int _currentStep = 0;
  String _selectedRole = 'sales_officer';
  bool _isLoading = false;
  bool _acceptedPolicies = false;

  String _passwordInput = '';
  String _confirmInput = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      if (mounted && _passwordInput != _passwordController.text) {
        setState(() {
          _passwordInput = _passwordController.text;
        });
      }
    });
    _confirmController.addListener(() {
      if (mounted && _confirmInput != _confirmController.text) {
        setState(() {
          _confirmInput = _confirmController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  List<
    ({String value, String label, String description, IconData icon, Color color})
  >
  get _roles => [
    (
      value: 'sales_officer',
      label: _l10n.roleSalesOfficer,
      description: _l10n.roleSalesDescription,
      icon: Icons.person_pin_outlined,
      color: const Color(0xFF15579E),
    ),
    (
      value: 'factory_officer',
      label: _l10n.roleTileFactory,
      description: _l10n.roleTileFactoryDescription,
      icon: Icons.grid_view_rounded,
      color: const Color(0xFF0EA5E9),
    ),
    (
      value: 'wood_factory_officer',
      label: _l10n.roleWoodFactory,
      description: _l10n.roleWoodFactoryDescription,
      icon: Icons.chair_outlined,
      color: const Color(0xFFD97706),
    ),
    (
      value: 'company_officer',
      label: _l10n.roleInstallationOfficer,
      description: _l10n.roleInstallationDescription,
      icon: Icons.handyman_outlined,
      color: const Color(0xFF39AE50),
    ),
    (
      value: 'responsible_officer',
      label: _l10n.roleResponsibleOfficer,
      description: _l10n.roleResponsibleDescription,
      icon: Icons.admin_panel_settings_outlined,
      color: const Color(0xFF8B5CF6),
    ),
  ];

  Future<void> _showExistingAccountDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_l10n.accountExistsTitle),
          content: Text(_l10n.accountExistsBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_l10n.closeLabel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(_l10n.goToLogin),
            ),
          ],
        );
      },
    );
  }

  String _mapAuthError(Object error) {
    if (error is AuthApiException) {
      final code = error.code ?? '';
      if (code == 'user_already_exists') {
        return _l10n.emailAlreadyExists;
      }
      if (code == 'email_not_confirmed') {
        return _l10n.emailNotConfirmed;
      }
      if (code == 'over_email_send_rate_limit') {
        return _l10n.emailRateLimit;
      }
      if (error.message.isNotEmpty) {
        return error.message;
      }
    }
    return error.toString();
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep == 0) {
      if (!_step1FormKey.currentState!.validate()) {
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_selectedRole.isEmpty) {
        AppToast.show(
          context,
          _l10n.selectRoleFirst,
          type: AppToastType.warning,
        );
        return;
      }
      setState(() => _currentStep = 2);
    }
  }

  void _prevStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
    if (!_step3FormKey.currentState!.validate()) {
      return;
    }

    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      AppToast.show(context, _l10n.nameRequired, type: AppToastType.error);
      return;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppToast.show(
        context,
        _l10n.emailInvalidMsg,
        type: AppToastType.error,
      );
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      AppToast.show(
        context,
        _l10n.passwordsMismatch,
        type: AppToastType.error,
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      AppToast.show(
        context,
        _l10n.passwordTooShort,
        type: AppToastType.error,
      );
      return;
    }

    if (!_acceptedPolicies) {
      AppToast.show(
        context,
        _l10n.policiesRequired,
        type: AppToastType.warning,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.signUpWithEmail(
        email,
        _passwordController.text,
        fullName: fullName,
        role: _selectedRole,
      );

      if (response.session != null) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        return;
      }

      // Email confirmation required - navigate to OTP screen
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            email: email,
            fullName: fullName,
            role: _selectedRole,
            password: _passwordController.text,
          ),
        ),
      );
    } on Object catch (error) {
      final mappedError = _mapAuthError(error);
      if (!mounted) return;
      AppToast.show(context, mappedError, type: AppToastType.error);

      if (error is AuthApiException &&
          (error.code ?? '') == 'user_already_exists') {
        await _showExistingAccountDialog();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showTermsModal() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131B26) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(
                            alpha: isDark ? 0.22 : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.article_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _l10n.termsTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TermsArticle(
                        number: '1',
                        title: _l10n.termsSectionOne,
                        body: _l10n.termsBodyOne,
                      ),
                      _TermsArticle(
                        number: '2',
                        title: _l10n.termsSectionTwo,
                        body: _l10n.termsBodyTwo,
                      ),
                      _TermsArticle(
                        number: '3',
                        title: _l10n.termsSectionThree,
                        body: _l10n.termsBodyThree,
                      ),
                      _TermsArticle(
                        number: '4',
                        title: _l10n.termsSectionFour,
                        body: _l10n.termsBodyFour,
                      ),
                      _TermsArticle(
                        number: '5',
                        title: _l10n.termsSectionFive,
                        body: _l10n.termsBodyFive,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryGradientButton(
                onPressed: () {
                  setState(() => _acceptedPolicies = true);
                  Navigator.of(context).pop();
                },
                label: Text(
                  _l10n.agreeCheckbox,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                  ),
                ),
                height: 50,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      _l10n.stepPersonalInfo,
      _l10n.stepRole,
      _l10n.stepSecurity,
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Column(
      children: [
        Row(
          children: List.generate(3, (index) {
            final isDone = _currentStep > index;
            final isCurrent = _currentStep == index;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDone || isCurrent
                            ? primary
                            : (isDark
                                ? const Color(0xFF263342)
                                : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                  if (index < 2) const SizedBox(width: 8),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _l10n.stepOf(_currentStep + 1, 3),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            Text(
              steps[_currentStep],
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthField(
            controller: _fullNameController,
            label: _l10n.nameLabel,
            hint: _l10n.nameHint,
            icon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            showClearButton: true,
            required: true,
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) {
                return _l10n.nameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthField(
            controller: _emailController,
            label: _l10n.emailLabel,
            hint: 'name@example.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            showClearButton: true,
            required: true,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty || !email.contains('@')) {
                return _l10n.emailInvalidMsg;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2RoleCard({
    required String value,
    required String label,
    required String description,
    required IconData icon,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedRole == value;

    return Semantics(
      selected: isSelected,
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => setState(() => _selectedRole = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? accentColor.withValues(alpha: 0.16)
                    : accentColor.withValues(alpha: 0.08))
                : (isDark
                    ? const Color(0xFF161E28)
                    : Colors.white),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              width: isSelected ? 2.0 : 1.1,
              color: isSelected
                  ? accentColor
                  : (isDark
                      ? const Color(0xFF263342)
                      : const Color(0xFFE2E8F0)),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.12 : 0.02,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withValues(alpha: 0.22)
                          : accentColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? accentColor
                            : (isDark
                                ? const Color(0xFF3B4858)
                                : const Color(0xFFCBD5E1)),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _roles
          .map(
            (role) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildStep2RoleCard(
                value: role.value,
                label: role.label,
                description: role.description,
                icon: role.icon,
                accentColor: role.color,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStep3() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMatching = _passwordInput.isNotEmpty &&
        _confirmInput.isNotEmpty &&
        _passwordInput == _confirmInput;
    final hasMismatch = _passwordInput.isNotEmpty &&
        _confirmInput.isNotEmpty &&
        _passwordInput != _confirmInput;

    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthField(
            controller: _passwordController,
            label: _l10n.passwordLabel,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: true,
            isPassword: true,
            toggleTooltip: _l10n.showHideTooltip,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
            required: true,
            validator: (value) {
              if (value == null || value.length < 6) {
                return _l10n.passwordTooShort;
              }
              return null;
            },
          ),
          PasswordStrengthMeter(password: _passwordInput),
          const SizedBox(height: 14),
          AuthField(
            controller: _confirmController,
            label: _l10n.confirmPasswordLabel,
            hint: '••••••••',
            icon: Icons.verified_user_outlined,
            obscure: true,
            isPassword: true,
            toggleTooltip: _l10n.showHideTooltip,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            required: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return _l10n.passwordsMismatch;
              }
              return null;
            },
          ),
          if (isMatching || hasMismatch) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  isMatching
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  size: 15,
                  color: isMatching
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 6),
                Text(
                  isMatching
                      ? _l10n.passwordMatch
                      : _l10n.passwordMismatchHint,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isMatching
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Terms & Policies Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF161E28)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF263342)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.privacy_tip_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _l10n.termsTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _showTermsModal,
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        size: 15,
                      ),
                      label: Text(
                        _l10n.viewTermsButton,
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () {
                    setState(() {
                      _acceptedPolicies = !_acceptedPolicies;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _acceptedPolicies,
                            onChanged: (val) {
                              setState(() {
                                _acceptedPolicies = val ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _l10n.agreeCheckbox,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _l10n.signupTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _prevStep,
        ),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 16),
            child: AuthLanguageButton(),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStepIndicator(),
                      const SizedBox(height: 20),
                      GlassContainer(
                        padding: const EdgeInsets.all(22),
                        borderRadius: 28,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: KeyedSubtree(
                            key: ValueKey<int>(_currentStep),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_currentStep == 0) _buildStep1(),
                                if (_currentStep == 1) _buildStep2(),
                                if (_currentStep == 2) _buildStep3(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Action buttons
                      Row(
                        children: [
                          if (_currentStep > 0) ...[
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : _prevStep,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _l10n.prevStep,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            flex: 2,
                            child: PrimaryGradientButton(
                              onPressed: _isLoading
                                  ? null
                                  : (_currentStep == 2 ? _signUp : _nextStep),
                              loading: _isLoading,
                              icon: Icon(
                                _currentStep == 2
                                    ? Icons.person_add_alt_1_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                              label: Text(
                                _currentStep == 2
                                    ? _l10n.createAccountButton
                                    : _l10n.nextStep,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Already have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _l10n.alreadyHaveAccount,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 13.5,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Text(
                              _l10n.loginTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
}

class _TermsArticle extends StatelessWidget {
  const _TermsArticle({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}