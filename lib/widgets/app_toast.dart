import 'dart:async';

import 'package:flutter/material.dart';

import '../services/locale_service.dart';
import '../theme/app_theme.dart';

/// Type of in-app popup notification.
enum AppToastType { success, error, info, warning }

/// Lightweight animated popup messages shown on top of the app (like iOS
/// notification banners). Replaces SnackBars and inline error banners.
class AppToast {
  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    String message, {
    String? title,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    _current?.remove();
    _current = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _AppToast(
          message: message,
          title: title ?? _defaultTitle(type),
          type: type,
          onDismiss: () {
            entry.remove();
            if (identical(_current, entry)) {
              _current = null;
            }
          },
        );
      },
    );
    _current = entry;
    overlay.insert(entry);

    Timer(duration, () {
      if (identical(_current, entry)) {
        entry.remove();
        _current = null;
      }
    });
  }

  static String _defaultTitle(AppToastType type) {
    final l10n = LocaleService.l10n;
    switch (type) {
      case AppToastType.success:
        return l10n.toastSuccess;
      case AppToastType.error:
        return l10n.toastError;
      case AppToastType.warning:
        return l10n.toastWarning;
      case AppToastType.info:
        return l10n.toastInfo;
    }
  }
}

class _AppToast extends StatefulWidget {
  const _AppToast({
    required this.message,
    required this.title,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final String title;
  final AppToastType type;
  final VoidCallback onDismiss;

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
      reverseDuration: const Duration(milliseconds: 280),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInCubic,
    );
    _slide = Tween(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(curve);
    _fade = Tween(begin: 0.0, end: 1.0).animate(curve);
    _scale = Tween(begin: 0.85, end: 1.0).animate(curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }

  (IconData, Color) get _visuals {
    switch (widget.type) {
      case AppToastType.success:
        return (Icons.check_circle_rounded, const Color(0xFF1F9D57));
      case AppToastType.error:
        return (Icons.error_rounded, AppColors.danger);
      case AppToastType.warning:
        return (Icons.warning_amber_rounded, const Color(0xFFB25E00));
      case AppToastType.info:
        return (Icons.info_rounded, AppColors.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final (icon, color) = _visuals;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF1C1C1E) : Colors.white)
                          .withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withValues(alpha: 0.35),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _dismiss,
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
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
