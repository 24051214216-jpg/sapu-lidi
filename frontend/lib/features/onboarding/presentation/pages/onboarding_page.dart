import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

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
  static const Duration _slideDuration = Duration(seconds: 5);

  final PageController _pageController = PageController();

  Timer? _autoSlideTimer;

  int _activeDot = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Transparansi Iuran, Surat Cepat & Siaga Keamanan',
      description: 'Pantau kas terbuka RT, pinjam inventaris gotong royong, '
          'hingga panggil pos satpam siaga darurat langsung dari genggaman.',
    ),
    _OnboardingSlide(
      title: 'Kelola Iuran Warga & Catatan Kas Real-Time',
      description: 'Cek laporan pemasukan, pengeluaran sampah & ronda bulanan '
          'dengan bukti transfer digital yang dapat diunduh transparan.',
    ),
    _OnboardingSlide(
      title: 'Pinjam Sarana RT & Tombol Tanggap SOS',
      description: 'Pinjam tenda, kursi, mesin rumput secara gratis serta '
          'tombol darurat 1-klik terhubung langsung ke pos ronda & warga.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  // AUTO SLIDE

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();

    _autoSlideTimer = Timer.periodic(_slideDuration, (timer) {
      if (!mounted || !_pageController.hasClients) return;

      final nextPage = (_activeDot + 1) % _slides.length;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
  }

  // PAGE CHANGED

  void _onPageChanged(int index) {
    if (!mounted) return;

    setState(() {
      _activeDot = index;
    });
  }

  // NAVIGASI MANUAL

  void _goToPage(int index) {
    if (!_pageController.hasClients) return;

    _stopAutoSlide();

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );

    _startAutoSlide();
  }

  // PESAN

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _handleStart() {
    if (widget.onStart != null) {
      widget.onStart!();
    } else {
      _showMessage('Halaman login akan segera tersedia.');
    }
  }

  void _handleLogin() {
    if (widget.onLogin != null) {
      widget.onLogin!();
    } else {
      _showMessage('Halaman login akan segera tersedia.');
    }
  }

  void _handleSkip() {
    _stopAutoSlide();

    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      _showMessage('Onboarding selesai. Silakan lanjut ke login.');
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 740;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -64,
              right: -64,
              child: _glow(
                210,
                AppColors.secondaryFixed.withValues(alpha: 0.40),
              ),
            ),
            Positioned(
              top: size.height * 0.34,
              left: -82,
              child: _glow(
                190,
                AppColors.primaryFixed.withValues(alpha: 0.30),
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    _header(),
                    SizedBox(height: compact ? 8 : 12),
                    _hero(size, compact),
                    SizedBox(height: compact ? 14 : 18),
                    _tagline(),
                    const SizedBox(height: 12),
                    _slideContent(),
                    const SizedBox(height: 16),
                    _pagination(),
                    const SizedBox(height: 16),
                    _startButton(),
                    const SizedBox(height: 16),
                    _loginPrompt(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BACKGROUND GLOW

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // HEADER LOGO DAN TOMBOL LEWATI

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(40),
            boxShadow: _softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cleaning_services,
                  size: 17,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SapuLidi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'SUPERAPP RT',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: _handleSkip,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.onSurfaceVariant,
            backgroundColor: Colors.white.withValues(alpha: 0.88),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 7,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const StadiumBorder(),
          ),
          child: Text(
            'Lewati',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // GAMBAR UTAMA ONBOARDING
  // Gambar tetap, tidak ikut berganti ketika slide berubah.

  Widget _hero(Size size, bool compact) {
    final heroHeight =
        (size.height * (compact ? 0.39 : 0.43)).clamp(260.0, 390.0).toDouble();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SizedBox(
          height: heroHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFE9E0),
                        AppColors.surfaceContainerLow,
                        AppColors.surfaceContainerLowest,
                      ],
                    ),
                  ),
                ),

                // BACKGROUND ARCH PEACH

                Positioned(
                  left: 30,
                  right: 30,
                  top: 20,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed.withValues(
                        alpha: 0.78,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.elliptical(180, 210),
                      ),
                    ),
                  ),
                ),

                // KARAKTER 3D PENGURUS RT

                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Image.asset(
                      'assets/images/onboarding_character.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 60,
                            color: AppColors.outline,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // BADGE GUYUB RUKUN

                Positioned(
                  top: 14,
                  right: 12,
                  child: _floatingBadge(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '100% Guyub Rukun',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BADGE TRANSPARANSI KAS

                Positioned(
                  bottom: 16,
                  left: 12,
                  child: _floatingBadge(
                    radius: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 27,
                          height: 27,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.verified_user,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transparansi',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                color: AppColors.outline,
                              ),
                            ),
                            Text(
                              'Kas RT Terbuka',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // FLOATING BADGE

  Widget _floatingBadge({
    required Widget child,
    double radius = 30,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: _softShadow,
      ),
      child: child,
    );
  }

  // TAGLINE

  Widget _tagline() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.handshake,
            size: 14,
            color: AppColors.onPrimaryFixed,
          ),
          const SizedBox(width: 5),
          Text(
            'Sahabat Rukun Tetangga & Warga',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimaryFixed,
            ),
          ),
        ],
      ),
    );
  }

  // AUTO-SLIDE TULISAN DI BAWAH GAMBAR

  Widget _slideContent() {
    return SizedBox(
      height: 158,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _slides.length,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final slide = _slides[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: Column(
                key: ValueKey(index),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 21,
                      height: 1.28,
                      letterSpacing: -0.6,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    slide.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      height: 1.55,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // PAGINATION DOTS

  Widget _pagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        final active = index == _activeDot;

        return GestureDetector(
          onTap: () => _goToPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 25 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: active ? AppColors.primaryContainer : AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(20),
              boxShadow: active ? _softShadow : null,
            ),
          ),
        );
      }),
    );
  }

  // TOMBOL MULAI SEKARANG

  Widget _startButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _handleStart,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: const StadiumBorder(),
        ),
        child: Row(
          children: [
            Text(
              'Mulai Sekarang',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
              ),
            ),
            const Spacer(),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LINK LOGIN

  Widget _loginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun warga? ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: AppColors.outline,
          ),
        ),
        GestureDetector(
          onTap: _handleLogin,
          child: Text(
            'Masuk',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // SHADOW

  List<BoxShadow> get _softShadow => [
        BoxShadow(
          color: const Color(0xFF172A20).withValues(alpha: 0.10),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}

// MODEL SLIDE ONBOARDING

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
