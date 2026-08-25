import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/locale_service.dart';
import '../theme/app_theme.dart';
import 'presentation.dart';

AppLocalizations get _l10n => LocaleService.l10n;

/// A premium auth text field: outer label, animated focus ring with soft glow,
/// prefix icon with accent tint, clear button, and password visibility toggle.
class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.isPassword = false,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.validator,
    this.required = false,
    this.toggleTooltip,
    this.showClearButton = false,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool isPassword;
  final TextInputAction textInputAction;
  final List<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool required;
  final String? toggleTooltip;
  final bool showClearButton;
  final bool autofocus;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final FocusNode _focusNode = FocusNode();
  late bool _obscure;
  bool _hasText = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
    _hasText = widget.controller.text.isNotEmpty;
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onTextChanged() {
    final has = widget.controller.text.isNotEmpty;
    if (_hasText != has && mounted) {
      setState(() {
        _hasText = has;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final focused = _focusNode.hasFocus;
    final hasError = _errorText != null && _errorText!.isNotEmpty;

    // Premium modern color palette for backgrounds
    final fill = isDark
        ? (focused ? const Color(0xFF1A232F) : const Color(0xFF121922))
        : (focused ? Colors.white : const Color(0xFFF8FAFC));

    // Dynamic borders with slightly thicker width on focus
    final borderColor = hasError
        ? scheme.error.withValues(alpha: 0.7)
        : (focused
            ? scheme.primary
            : (isDark ? const Color(0xFF2A3645) : const Color(0xFFE2E8F0)));

    final iconColor = hasError
        ? scheme.error
        : (focused
            ? scheme.primary
            : (isDark ? const Color(0xFF7A8A9E) : const Color(0xFF94A3B8)));

    // Subtle background for the prefix icon when focused
    final iconBgColor = hasError 
        ? scheme.error.withValues(alpha: 0.1)
        : (focused 
            ? scheme.primary.withValues(alpha: isDark ? 0.15 : 0.08)
            : Colors.transparent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(label: widget.label, required: widget.required),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCirc,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: focused ? 1.8 : 1.2,
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: (hasError ? scheme.error : scheme.primary).withValues(
                        alpha: isDark ? 0.2 : 0.12,
                      ),
                      blurRadius: 16,
                      spreadRadius: -2,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Semantics(
            container: true,
            label: widget.label,
            textField: true,
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              obscureText: _obscure,
              textInputAction: widget.textInputAction,
              autofillHints: widget.autofillHints,
              textAlignVertical: TextAlignVertical.center,
              validator: (value) {
                final result = widget.validator?.call(value);
                if (_errorText != result) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _errorText = result);
                  });
                }
                return result;
              },
              onFieldSubmitted: widget.onSubmitted,
              onChanged: (val) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
                widget.onChanged?.call(val);
              },
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface,
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
                letterSpacing: widget.isPassword ? 1.5 : 0.2,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                hintText: widget.hint,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 54,
                  minHeight: 56,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCirc,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: iconColor,
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 50,
                  minHeight: 56,
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        tooltip: widget.toggleTooltip ?? '',
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 50,
                          minHeight: 56,
                        ),
                        onPressed: () {
                          setState(() => _obscure = !_obscure);
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) => FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(scale: animation, child: child),
                          ),
                          child: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            key: ValueKey(_obscure),
                            size: 20,
                            color: iconColor.withValues(alpha: 0.8),
                          ),
                        ),
                      )
                    : (widget.showClearButton && _hasText
                        ? IconButton(
                            tooltip: _l10n.clearSearch,
                            splashRadius: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 50,
                              minHeight: 56,
                            ),
                            onPressed: () {
                              widget.controller.clear();
                              widget.onChanged?.call('');
                            },
                            icon: Icon(
                              Icons.cancel_rounded,
                              size: 18,
                              color: isDark
                                  ? const Color(0xFF7A8A9E)
                                  : const Color(0xFF94A3B8),
                            ),
                          )
                        : const SizedBox(width: 16)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                errorStyle: const TextStyle(fontSize: 0, height: 0),
                contentPadding: const EdgeInsetsDirectional.only(
                  start: 4,
                  end: 16,
                  top: 18,
                  bottom: 18,
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: scheme.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      color: scheme.error,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}


/// Dynamic real-time Password Strength Meter widget.
/// Renders 4 segmented bars, animated label (Weak -> Fair -> Good -> Strong),
/// and checklist requirements.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({
    super.key,
    required this.password,
  });

  final String password;

  int _calculateStrength() {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 9) score++;
    if (RegExp(r'[0-9]').hasMatch(password) ||
        RegExp(r'[!@#\$&*~_=+^%<>/.,:;?|~-]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    return score.clamp(0, 4);
  }

  Color _strengthColor(int score, BuildContext context) {
    switch (score) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFF3B82F6);
      case 4:
        return const Color(0xFF10B981);
      default:
        return Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);
    }
  }

  String _strengthLabel(int score) {
    switch (score) {
      case 1:
        return _l10n.passwordStrengthWeak;
      case 2:
        return _l10n.passwordStrengthFair;
      case 3:
        return _l10n.passwordStrengthGood;
      case 4:
        return _l10n.passwordStrengthStrong;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final score = _calculateStrength();
    final color = _strengthColor(score, context);
    final label = _strengthLabel(score);

    final hasMinLength = password.length >= 6;
    final hasNumberOrSymbol = RegExp(r'[0-9!@#\$&*~_=+^%<>/.,:;?|~-]')
        .hasMatch(password);

    if (password.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(4, (index) {
                final filled = index < score;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    height: 4.5,
                    margin: EdgeInsetsDirectional.only(
                      end: index < 3 ? 5 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: filled
                          ? color
                          : (isDark
                              ? const Color(0xFF263342)
                              : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: filled && score >= 2
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.35),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  label,
                  key: ValueKey<String>(label),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _RequirementPill(
                satisfied: hasMinLength,
                text: _l10n.passwordReqLength,
              ),
              _RequirementPill(
                satisfied: hasNumberOrSymbol,
                text: _l10n.passwordReqNumber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequirementPill extends StatelessWidget {
  const _RequirementPill({required this.satisfied, required this.text});

  final bool satisfied;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = satisfied
        ? const Color(0xFF10B981)
        : (isDark ? const Color(0xFF8C98A9) : const Color(0xFF94A3B8));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: satisfied
                ? const Color(0xFF10B981).withValues(alpha: 0.16)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: satisfied ? 1.2 : 1,
            ),
          ),
          child: Center(
            child: Icon(
              satisfied ? Icons.check : Icons.circle,
              size: satisfied ? 10 : 4,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: satisfied ? FontWeight.w600 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// A high-end Segmented Pill Switcher to switch between Login and Sign Up tabs.
class AuthSegmentedControl extends StatelessWidget {
  const AuthSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E28) : const Color(0xFFEBF0F7),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? const Color(0xFF243040) : const Color(0xFFDDE5F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentTab(
              title: _l10n.loginTitle,
              icon: Icons.login_rounded,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
              scheme: scheme,
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _SegmentTab(
              title: _l10n.signupTitle,
              icon: Icons.person_add_outlined,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
              scheme: scheme,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.scheme,
    required this.isDark,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? scheme.primary : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: (selected && isDark
                            ? scheme.primary
                            : Colors.black)
                        .withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: selected
                      ? (isDark ? Colors.white : scheme.primary)
                      : (isDark
                          ? const Color(0xFF8C98A9)
                          : const Color(0xFF64748B)),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected
                          ? (isDark ? Colors.white : scheme.primary)
                          : (isDark
                              ? const Color(0xFF8C98A9)
                              : const Color(0xFF64748B)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fully-drawn gradient primary button with micro-bounce touch animation,
/// subtle glowing shadow, and animated loading state.
class PrimaryGradientButton extends StatefulWidget {
  const PrimaryGradientButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.loading = false,
    this.height = 54,
  });

  final VoidCallback? onPressed;
  final Widget label;
  final Widget? icon;
  final bool loading;
  final double height;

  @override
  State<PrimaryGradientButton> createState() => _PrimaryGradientButtonState();
}

class _PrimaryGradientButtonState extends State<PrimaryGradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final enabled = widget.onPressed != null && !widget.loading;

    final base = scheme.primary;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(base, isDark ? Colors.white : Colors.black, 0.08)!,
        Color.lerp(base, isDark ? Colors.white : Colors.black, 0.22)!,
      ],
    );

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutQuad,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: enabled ? 1 : 0.55,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: base.withValues(
                          alpha: isDark ? 0.42 : 0.28,
                        ),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? widget.onPressed : null,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Center(
                  child: widget.loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              widget.icon!,
                              const SizedBox(width: 10),
                            ],
                            DefaultTextStyle(
                              style: theme.textTheme.labelLarge!.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                              child: widget.label,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating Language Switcher button (AR / EN) with frosted glass styling.
class AuthLanguageButton extends StatelessWidget {
  const AuthLanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = LocaleService.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          LocaleService.setLocale(
            isArabic ? const Locale('en') : const Locale('ar'),
          );
        },
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                isArabic ? 'English' : 'العربية',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}