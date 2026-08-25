import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/locale_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_inputs.dart';
import '../widgets/glass.dart';

AppLocalizations get _l10n => LocaleService.l10n;

enum _OnboardingSceneType {
  materials,
  production,
  documentation,
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.sceneType,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.featureA,
    required this.featureB,
  });

  final _OnboardingSceneType sceneType;
  final Color accent;
  final String title;
  final String subtitle;
  final String featureA;
  final String featureB;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _totalSlides = 3;

  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_OnboardingItem> _slides() {
    return [
      _OnboardingItem(
        sceneType: _OnboardingSceneType.materials,
        accent: AppColors.primary,
        title: _l10n.onboardingSlide1Title,
        subtitle: _l10n.onboardingSlide1Subtitle,
        featureA: _l10n.onboardingF1a,
        featureB: _l10n.onboardingF1b,
      ),
      _OnboardingItem(
        sceneType: _OnboardingSceneType.production,
        accent: AppColors.teal,
        title: _l10n.onboardingSlide2Title,
        subtitle: _l10n.onboardingSlide2Subtitle,
        featureA: _l10n.onboardingF2a,
        featureB: _l10n.onboardingF2b,
      ),
      _OnboardingItem(
        sceneType: _OnboardingSceneType.documentation,
        accent: const Color(0xFFD97706),
        title: _l10n.onboardingSlide3Title,
        subtitle: _l10n.onboardingSlide3Subtitle,
        featureA: _l10n.onboardingF3a,
        featureB: _l10n.onboardingF3b,
      ),
    ];
  }

  void _goNext() {
    if (_current >= _totalSlides - 1) {
      widget.onFinished();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isDark = theme.brightness == Brightness.dark;
    final slides = _slides();
    final currentSlide = slides[_current];

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackground()),
          SafeArea(
            child: Column(
              children: [
                // Top Header: Logo + Language Switcher + Skip
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorsAlpha(scheme.surface, isDark ? 0.6 : 0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorsAlpha(
                              Colors.white,
                              isDark ? 0.08 : 0.6,
                            ),
                          ),
                        ),
                        child: Image.asset(
                          'assets/mta_logo.png',
                          width: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Spacer(),
                      const AuthLanguageButton(),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: widget.onFinished,
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.onSurfaceVariant,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(44, 38),
                        ),
                        child: Text(
                          _l10n.onboardingSkip,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    reverse: isRtl,
                    itemCount: _totalSlides,
                    onPageChanged: (index) {
                      setState(() => _current = index);
                    },
                    itemBuilder: (context, index) {
                      return _SlidePage(
                        key: ValueKey(index),
                        slide: slides[index],
                      );
                    },
                  ),
                ),
                // Footer Navigation: Dots Indicator + Next / Get Started Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _DotsIndicator(
                        count: _totalSlides,
                        current: _current,
                        activeColor: currentSlide.accent,
                      ),
                      const SizedBox(height: 20),
                      PrimaryGradientButton(
                        onPressed: _goNext,
                        height: 54,
                        icon: Icon(
                          _current >= _totalSlides - 1
                              ? Icons.check_rounded
                              : (isRtl
                                  ? Icons.arrow_back_rounded
                                  : Icons.arrow_forward_rounded),
                          size: 21,
                          color: Colors.white,
                        ),
                        label: Text(
                          _current >= _totalSlides - 1
                              ? _l10n.onboardingGetStarted
                              : _l10n.onboardingNext,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color colorsAlpha(Color c, double a) => c.withValues(alpha: a);
}

/// A single onboarding slide with custom building materials graphics.
class _SlidePage extends StatelessWidget {
  const _SlidePage({super.key, required this.slide});

  final _OnboardingItem slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 480),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BuildingMaterialGraphic(
                sceneType: slide.sceneType,
                accent: slide.accent,
              ),
              const SizedBox(height: 24),
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FeaturePill(text: slide.featureA, accent: slide.accent),
                  _FeaturePill(text: slide.featureB, accent: slide.accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Master artwork container resolving the dedicated building materials scene.
class _BuildingMaterialGraphic extends StatelessWidget {
  const _BuildingMaterialGraphic({
    required this.sceneType,
    required this.accent,
  });

  final _OnboardingSceneType sceneType;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    switch (sceneType) {
      case _OnboardingSceneType.materials:
        return _MaterialsSourcingScene(accent: accent);
      case _OnboardingSceneType.production:
        return _FactoryProductionScene(accent: accent);
      case _OnboardingSceneType.documentation:
        return _HandoverInspectionScene(accent: accent);
    }
  }
}

/// Scene 1: Marble, Ceramic Tiles & Wood Fabrication Artwork.
class _MaterialsSourcingScene extends StatelessWidget {
  const _MaterialsSourcingScene({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 320,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background ambient blueprint aura
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: isDark ? 0.25 : 0.14),
                  accent.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          // Isometric blueprint base grid
          Positioned(
            bottom: 20,
            child: Container(
              width: 240,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: accent.withValues(alpha: isDark ? 0.25 : 0.20),
                  width: 1.2,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accent.withValues(alpha: isDark ? 0.08 : 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main 3D Marble Slab Tile Representation
          Positioned(
            top: 28,
            child: Container(
              width: 190,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFFFFFFFF), const Color(0xFFF1F5F9)],
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: isDark ? 0.35 : 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Marble Veins pattern representation
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MarbleVeinPainter(
                        color: accent.withValues(alpha: isDark ? 0.25 : 0.18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.square_foot_rounded,
                                    size: 13,
                                    color: accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '60 × 120 cm',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 12,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Marble & Porcelain Slab',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating Material Card: Italian Carrara
          Positioned(
            left: 6,
            top: 20,
            child: _BadgePill(
              icon: Icons.grid_view_rounded,
              label: 'رخام وبلاط فاخر',
              color: const Color(0xFF0284C7),
              isDark: isDark,
            ),
          ),
          // Floating Material Card: Oak Woodwork
          Positioned(
            right: 6,
            top: 65,
            child: _BadgePill(
              icon: Icons.chair_outlined,
              label: 'تفصيل خشب طبيعي',
              color: const Color(0xFFD97706),
              isDark: isDark,
            ),
          ),
          // Bottom Order Card Chip
          Positioned(
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A222E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'طلب توريد وتفصيل معتمد #104',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '120 م²',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scene 2: Factory Cutting Lines & On-Site Installation Artwork.
class _FactoryProductionScene extends StatelessWidget {
  const _FactoryProductionScene({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 320,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ambient Glow
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: isDark ? 0.22 : 0.14),
                  accent.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          // Central Factory Hub Card
          Positioned(
            top: 24,
            child: Container(
              width: 230,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131E2A) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFE2E8F0),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: isDark ? 0.30 : 0.15),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.factory_outlined,
                          size: 20,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'خط إنتاج المصنع',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'قص دقيق ومطابقة للمواصفات',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white60
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '95%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.95,
                      minHeight: 5,
                      backgroundColor: accent.withValues(alpha: 0.15),
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating Installation Team Badge
          Positioned(
            bottom: 44,
            left: 12,
            child: _BadgePill(
              icon: Icons.handyman_rounded,
              label: 'فريق التركيب الميداني',
              color: const Color(0xFF10B981),
              isDark: isDark,
            ),
          ),
          // Floating CNC / Precision Cut Badge
          Positioned(
            top: 6,
            right: 8,
            child: _BadgePill(
              icon: Icons.precision_manufacturing_outlined,
              label: 'قص CNC ليزري',
              color: const Color(0xFF0284C7),
              isDark: isDark,
            ),
          ),
          // Live Workflow Pipeline Step Bar
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  const Text('تم القص', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  const Text('➔', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  const Text('الجودة', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  const Text('➔', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(width: 6),
                  Icon(Icons.bolt, size: 14, color: accent),
                  const SizedBox(width: 4),
                  Text(
                    'التركيب',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scene 3: Photo Verification, Handover Inspection & Certified PDF Reports.
class _HandoverInspectionScene extends StatelessWidget {
  const _HandoverInspectionScene({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 320,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background Glow
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: isDark ? 0.25 : 0.15),
                  accent.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          // Main Document Container
          Positioned(
            top: 20,
            child: Container(
              width: 230,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1F2B) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFE2E8F0),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: isDark ? 0.32 : 0.16),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.verified_outlined,
                              size: 18,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تقرير تسليم معتمد',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'مطابق ✓',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stage Photo Evidence Preview Box
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF111722) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.camera_alt_outlined, size: 18, color: accent),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'صورة توثيق موقع التركيب',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF334155),
                                ),
                              ),
                              const Text(
                                'تم الرفع والمطابقة بنجاح',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating Signature Badge
          Positioned(
            left: 4,
            top: 20,
            child: _BadgePill(
              icon: Icons.draw_outlined,
              label: 'توقيع المسؤول العام',
              color: const Color(0xFF8B5CF6),
              isDark: isDark,
            ),
          ),
          // Floating Instant PDF Export Badge
          Positioned(
            right: 4,
            bottom: 40,
            child: _BadgePill(
              icon: Icons.picture_as_pdf_outlined,
              label: 'تصدير تقرير PDF',
              color: const Color(0xFFEF4444),
              isDark: isDark,
            ),
          ),
          // Bottom Alert Instant notification
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131E2A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    size: 15,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'إشعار فوري لجميع الأطراف المعنية',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating glass badge pill with icon and title.
class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E28) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.22 : 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the marble veins on the ceramic/marble slab.
class _MarbleVeinPainter extends CustomPainter {
  _MarbleVeinPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(size.width * 0.15, size.height * 0.95)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.70,
        size.width * 0.40,
        size.height * 0.45,
        size.width * 0.75,
        size.height * 0.10,
      );

    final path2 = Path()
      ..moveTo(size.width * 0.45, size.height * 0.55)
      ..cubicTo(
        size.width * 0.60,
        size.height * 0.65,
        size.width * 0.70,
        size.height * 0.50,
        size.width * 0.90,
        size.height * 0.40,
      );

    canvas.drawPath(path1, paint);
    canvas.drawPath(
      path2,
      paint..strokeWidth = 0.8..color = color.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant _MarbleVeinPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Little tinted check pill describing a slide feature.
class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated pill dots that highlight the active slide.
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
  });

  final int count;
  final int current;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: 0.25,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final active = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}