import 'dart:ui';

import 'package:flutter/material.dart';

/// Soft colorful blurred blobs that sit behind translucent surfaces so the
/// frosted glass has something to refract (the iOS 26 "Liquid Glass" trick).
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  left: -110,
                  width: 330,
                  height: 330,
                  child: _Blob(
                    color: scheme.primary.withValues(
                      alpha: isDark ? 0.16 : 0.12,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -170,
                  right: -120,
                  width: 390,
                  height: 390,
                  child: _Blob(
                    color: const Color(
                      0xFF39AE50,
                    ).withValues(alpha: isDark ? 0.12 : 0.10),
                  ),
                ),
                Positioned(
                  top: 290,
                  right: -130,
                  width: 250,
                  height: 250,
                  child: _Blob(
                    color: scheme.primary.withValues(
                      alpha: isDark ? 0.08 : 0.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ?child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

/// Wraps a widget with a frosted-glass backdrop blur. Use it around a single
/// surface (AppBar, NavigationBar, bottom action bar) so content scrolling
/// underneath gets the Liquid Glass look.
class Glass extends StatelessWidget implements PreferredSizeWidget {
  const Glass({super.key, required this.child, this.blur = 14});

  final Widget child;
  final double blur;

  @override
  Size get preferredSize => child is PreferredSizeWidget
      ? (child as PreferredSizeWidget).preferredSize
      : Size.zero;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}

/// A complete frosted "Liquid Glass" surface: backdrop blur + translucent
/// fill + hairline highlight + soft shadow.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.padding,
    this.margin,
    this.blur = 18,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = theme.colorScheme.surface.withValues(
      alpha: isDark ? 0.70 : 0.72,
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ),
        ),
      ),
    );
  }
}
