import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_primary_button.dart';
import '../../../auth/presentation/pages/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    this.onStart,
    this.onLogin,
    this.onSkip,
  });

  final VoidCallback? onStart;
  final VoidCallback? onLogin;
  final VoidCallback? onSkip;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const Color _green = Color(0xFF006130);
  static const Color _surface = Color(0xFFFAF8FF);
  static const Color _text = Color(0xFF131B2E);
  static const Color _muted = Color(0xFF667085);

  final PageController _pageController = PageController();

  Timer? _timer;
  int _activePage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Selamat Datang di SapuLidi',
      description:
          'Solusi digital terpadu manajemen RT/RW. Cek iuran, pinjam inventaris gotong royong, dan urus administrasi warga lebih cepat & transparan.',
    ),
    _OnboardingSlide(
      title: 'Urus Administrasi Lebih Mudah',
      description:
          'Akses berbagai layanan administrasi lingkungan dalam satu aplikasi. Lebih praktis, cepat, dan terorganisir.',
    ),
    _OnboardingSlide(
      title: 'Wujudkan Lingkungan Guyub Rukun',
      description:
          'Bangun komunikasi dan kebersamaan antarwarga melalui ekosistem digital SapuLidi.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;

      final nextPage = (_activePage + 1) % _slides.length;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() => _activePage = index);
  }

  void _navigateToLogin(VoidCallback? callback) {
    _timer?.cancel();

    if (callback != null) {
      callback();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  void _handleStart() {
    _navigateToLogin(widget.onStart);
  }

  void _handleLogin() {
    _navigateToLogin(widget.onLogin);
  }

  void _handleSkip() {
    _navigateToLogin(widget.onSkip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundDecorations(),
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _buildHeroImage(),
                              const SizedBox(height: 24),
                              _buildTagline(),
                              const SizedBox(height: 20),
                              _buildSlideContent(),
                              const SizedBox(height: 20),
                              _buildPagination(),
                              const SizedBox(height: 24),
                              AppPrimaryButton(
                                label: 'Mulai Sekarang',
                                icon: Icons.arrow_forward_rounded,
                                height: 58,
                                borderRadius: 18,
                                onPressed: _handleStart,
                              ),
                              const SizedBox(height: 18),
                              _buildLoginLink(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFDBC8).withValues(
                    alpha: 0.32,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 250,
              left: -140,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF96F7AF).withValues(
                    alpha: 0.18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFE5EAE4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cleaning_services_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 9),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SapuLidi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _text,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'SUPERAPP RT',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: _green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _handleSkip,
            style: TextButton.styleFrom(
              foregroundColor: _muted,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            child: Text(
              'Lewati',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(220.0, 340.0);

        return SizedBox(
          width: width,
          height: width * 1.12,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 10,
                right: 10,
                top: 8,
                bottom: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE8D9),
                    borderRadius: BorderRadius.circular(150).copyWith(
                      bottomLeft: const Radius.circular(32),
                      bottomRight: const Radius.circular(32),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'assets/images/onboarding_character.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        alignment: Alignment.center,
                        color: const Color(0xFFFFE8D9),
                        child: const Icon(
                          Icons.people_alt_rounded,
                          size: 110,
                          color: _green,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 22,
                right: 0,
                child: _heroBadge(
                  icon: Icons.handshake_rounded,
                  title: '100% Guyub Rukun',
                  background: Colors.white,
                  foreground: _green,
                ),
              ),
              Positioned(
                bottom: 24,
                left: 0,
                child: _heroBadge(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Transparansi',
                  subtitle: 'Kas RT Terbuka',
                  background: _green,
                  foreground: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _heroBadge({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 18),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: foreground,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: foreground.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7ED),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.handshake_outlined,
            color: _green,
            size: 17,
          ),
          const SizedBox(width: 7),
          Text(
            'Sahabat Rukun Tetangga & Warga',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideContent() {
    return SizedBox(
      height: 130,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _slides.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final slide = _slides[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 23,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                      color: _text,
                    ),
                    children: _buildTitleSpans(slide.title),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    height: 1.7,
                    color: _muted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<InlineSpan> _buildTitleSpans(String title) {
    if (title == 'Selamat Datang di SapuLidi') {
      return [
        const TextSpan(text: 'Selamat Datang di '),
        const TextSpan(
          text: 'SapuLidi',
          style: TextStyle(color: _green),
        ),
      ];
    }

    return [TextSpan(text: title)];
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) {
          final isActive = index == _activePage;

          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 25 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive ? _green : const Color(0xFFD9E1D9),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            'Sudah punya akun warga? ',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: _muted,
            ),
          ),
          GestureDetector(
            onTap: _handleLogin,
            child: Text(
              'Masuk',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
