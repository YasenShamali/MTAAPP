import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore_for_file: unused_element

/// A world-class Floating Glass Island Navigation Dock — 3 balanced tabs.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.ordersBadgeCount,
    required this.ordersLabel,
    required this.calendarLabel,
    required this.accountLabel,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final int? ordersBadgeCount;
  final String ordersLabel;
  final String calendarLabel;
  final String accountLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        bottomInset > 0 ? bottomInset + 4 : 16,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF131B26).withValues(alpha: 0.84)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.11)
                    : const Color(0xFFE2E8F0).withValues(alpha: 0.95),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.38 : 0.08,
                  ),
                  blurRadius: 28,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: scheme.primary.withValues(
                    alpha: isDark ? 0.08 : 0.04,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Tab 0: Orders
                Expanded(
                  child: _NavTabButton(
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long_rounded,
                    label: ordersLabel,
                    selected: selectedIndex == 0,
                    badgeCount: ordersBadgeCount,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTabSelected(0);
                    },
                  ),
                ),
                // Vertical divider
                _Divider(isDark: isDark),
                // Tab 1: Calendar
                Expanded(
                  child: _NavTabButton(
                    icon: Icons.calendar_month_outlined,
                    selectedIcon: Icons.calendar_month_rounded,
                    label: calendarLabel,
                    selected: selectedIndex == 1,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTabSelected(1);
                    },
                  ),
                ),
                // Vertical divider
                _Divider(isDark: isDark),
                // Tab 2: Account
                Expanded(
                  child: _NavTabButton(
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    label: accountLabel,
                    selected: selectedIndex == 2,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTabSelected(2);
                    },
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

/// Subtle divider between nav tabs.
class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : Colors.black.withValues(alpha: 0.06),
    );
  }
}

/// Sleek nav tab item: animated pill highlight + micro-bounce icon.
class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = scheme.primary;
    final inactiveColor = isDark
        ? const Color(0xFF8C98A9)
        : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      splashColor: activeColor.withValues(alpha: 0.10),
      highlightColor: Colors.transparent,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected
                ? activeColor.withValues(alpha: isDark ? 0.16 : 0.09)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 230),
                    curve: Curves.easeOutBack,
                    scale: selected ? 1.10 : 1.0,
                    child: Icon(
                      selected ? selectedIcon : icon,
                      size: 22,
                      color: selected ? activeColor : inactiveColor,
                    ),
                  ),
                  if (badgeCount != null && badgeCount! > 0)
                    Positioned(
                      top: -5,
                      right: -9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF131B26)
                                : Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          badgeCount! > 99 ? '99+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 230),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? activeColor : inactiveColor,
                  fontFamily: theme.textTheme.labelMedium?.fontFamily,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
