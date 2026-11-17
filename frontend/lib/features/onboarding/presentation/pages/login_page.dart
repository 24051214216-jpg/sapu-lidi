import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color _primary = Color(0xFF006130);
  static const Color _surface = Color(0xFFFAF8FF);
  static const Color _onSurface = Color(0xFF131B2E);
  static const Color _onSurfaceVariant = Color(0xFF3F4940);
  static const Color _outline = Color(0xFFBECABD);

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _formattedPhone {
    final phone = _phoneController.text.trim();
    return phone.isEmpty ? '+62 812-3456-7890' : '+62 $phone';
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulasi proses login. Belum terhubung ke backend.
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() => _isLoading = false);

    _showMessage(
      'Tampilan login berhasil diuji. Autentikasi backend belum diaktifkan.',
    );
  }

  void _openOtpSheet({required bool useWhatsApp}) {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showMessage('Masukkan nomor HP terlebih dahulu.');
      return;
    }

    if (phone.length < 9) {
      _showMessage('Periksa kembali nomor HP yang kamu masukkan.');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OtpVerificationSheet(
        phoneNumber: _formattedPhone,
        useWhatsApp: useWhatsApp,
      ),
    );
  }

  void _openNextPage(String pageName) {
    _showMessage('Halaman $pageName akan dibuat pada tahap berikutnya.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: Column(
                      children: [
                        _buildHero(),
                        const SizedBox(height: 22),
                        _buildLoginCard(),
                        const SizedBox(height: 20),
                        _buildSecurityFooter(),
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

  Widget _buildHeader() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Phone Login',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFE8EDE8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 23,
                  height: 23,
                  decoration: const BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cleaning_services_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'SapuLidi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: const Color(0xFFE4EFE6),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: _primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF084C27),
            Color(0xFF0D6535),
            Color(0xFF107C41),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.cleaning_services_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              'PORTAL WARGA DIGITAL',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 17),
          Text(
            'Selamat Datang Kembali!',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 23,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Silakan masuk ke akun warga RT Anda untuk mengakses layanan & iuran.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 12,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173D28).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Nomor HP'),
            const SizedBox(height: 9),
            _buildPhoneField(),
            const SizedBox(height: 19),
            _buildFieldLabel('Kata Sandi'),
            const SizedBox(height: 9),
            _buildPasswordField(),
            const SizedBox(height: 12),
            _buildRememberAndForgot(),
            const SizedBox(height: 20),
            _buildLoginButton(),
            const SizedBox(height: 22),
            _buildDivider(),
            const SizedBox(height: 18),
            Text(
              'Masuk lebih cepat dengan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _buildAlternativeLogin(),
            const SizedBox(height: 16),
            _buildInfoCallout(),
            const SizedBox(height: 20),
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        color: _onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _onSurface,
      ),
      decoration: _inputDecoration(
        hint: '812-3456-7890',
        prefix: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin: const EdgeInsets.only(right: 10),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: Color(0xFFE2E8E2)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇮🇩', style: TextStyle(fontSize: 17)),
              const SizedBox(width: 7),
              Text(
                '+62',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                ),
              ),
            ],
          ),
        ),
        suffix: const Icon(
          Icons.phone_iphone_rounded,
          color: Color(0xFF778477),
          size: 20,
        ),
      ),
      validator: (value) {
        final phone = value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';

        if (phone.isEmpty) {
          return 'Nomor HP wajib diisi.';
        }

        if (phone.length < 9 || phone.length > 13) {
          return 'Masukkan nomor HP yang valid.';
        }

        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _onSurface,
      ),
      decoration: _inputDecoration(
        hint: 'Masukkan kata sandi',
        prefix: const Icon(
          Icons.lock_outline_rounded,
          color: Color(0xFF778477),
          size: 20,
        ),
        suffix: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF778477),
            size: 20,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Kata sandi wajib diisi.';
        }

        if (value.length < 8) {
          return 'Kata sandi minimal 8 karakter.';
        }

        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 12,
        color: const Color(0xFF9AA49A),
      ),
      prefixIcon: prefix,
      prefixIconConstraints: const BoxConstraints(
        minWidth: 0,
        minHeight: 0,
      ),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 16,
      ),
      filled: true,
      fillColor: const Color(0xFFFAFCFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE1E9E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE1E9E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _rememberMe,
            activeColor: _primary,
            side: const BorderSide(color: _outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (value) {
              setState(() {
                _rememberMe = value ?? false;
              });
            },
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'Ingat Saya',
            style: GoogleFonts.plusJakartaSans(
              color: _onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () => _openNextPage('Lupa Password'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Lupa Password?',
            style: GoogleFonts.plusJakartaSans(
              color: _primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: _isLoading ? null : _login,
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primary.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Masuk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Color(0xFFE6EBE6)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ATAU MASUK DENGAN',
            style: GoogleFonts.inter(
              color: const Color(0xFF849084),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0xFFE6EBE6)),
        ),
      ],
    );
  }

  Widget _buildAlternativeLogin() {
    return Row(
      children: [
        Expanded(
          child: _AlternativeLoginCard(
            icon: Icons.chat_rounded,
            iconColor: const Color(0xFF159B58),
            title: 'WhatsApp',
            subtitle: '1-Klik',
            description: 'Verifikasi Bot RT',
            onTap: () => _openOtpSheet(useWhatsApp: true),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _AlternativeLoginCard(
            icon: Icons.sms_outlined,
            iconColor: const Color(0xFF3277C8),
            title: 'Kode OTP',
            subtitle: '6 Digit',
            description: 'SMS & Telegram',
            onTap: () => _openOtpSheet(useWhatsApp: false),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCallout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F1),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFD9EBDD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: _primary,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  height: 1.6,
                  color: _onSurfaceVariant,
                ),
                children: const [
                  TextSpan(
                    text: 'Login Tanpa Sandi: ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text:
                        'Tautan verifikasi 1-klik atau 6 digit OTP akan dikirim langsung ke kontak nomor HP yang terdaftar di basis data RT.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            'Belum punya akun? ',
            style: GoogleFonts.plusJakartaSans(
              color: _onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () => _openNextPage('Registrasi Warga'),
            child: Text(
              'Daftar Sekarang',
              style: GoogleFonts.plusJakartaSans(
                color: _primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 16,
              color: _primary,
            ),
            const SizedBox(width: 7),
            Text(
              'Dilindungi enkripsi data kependudukan RT/RW',
              style: GoogleFonts.plusJakartaSans(
                color: _onSurfaceVariant,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerLabel('RT 04 / RW 07'),
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 9),
              decoration: const BoxDecoration(
                color: Color(0xFF9AA49A),
                shape: BoxShape.circle,
              ),
            ),
            _footerLabel('Kel. Sukamaju'),
          ],
        ),
      ],
    );
  }

  Widget _footerLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: const Color(0xFF849084),
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8EDE8)),
        ),
        child: Icon(
          icon,
          size: 20,
          color: const Color(0xFF26372A),
        ),
      ),
    );
  }
}

class _AlternativeLoginCard extends StatelessWidget {
  const _AlternativeLoginCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFDFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE1E9E1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF17251A),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                color: const Color(0xFF7B877C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpVerificationSheet extends StatefulWidget {
  const _OtpVerificationSheet({
    required this.phoneNumber,
    required this.useWhatsApp,
  });

  final String phoneNumber;
  final bool useWhatsApp;

  @override
  State<_OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<_OtpVerificationSheet> {
  final _otpController = TextEditingController();

  Timer? _timer;
  int _remainingSeconds = 45;
  bool _isVerifying = false;

  static const Color _primary = Color(0xFF006130);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 45;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds--);
      }
    });

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan 6 digit kode OTP.'),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    // Simulasi verifikasi OTP. Belum terhubung ke server.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() => _isVerifying = false);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Simulasi OTP selesai. Verifikasi asli belum diaktifkan.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final methodName = widget.useWhatsApp ? 'WhatsApp' : 'SMS / Telegram';

    final methodColor =
        widget.useWhatsApp ? const Color(0xFF159B58) : const Color(0xFF3277C8);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(23, 13, 23, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE4DC),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: 57,
                height: 57,
                decoration: BoxDecoration(
                  color: methodColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.useWhatsApp ? Icons.chat_rounded : Icons.sms_rounded,
                  color: methodColor,
                  size: 27,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Verifikasi Nomor HP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF131B2E),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Masukkan kode 6 digit untuk melanjutkan. '
                'Kode simulasi ditampilkan di bawah.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  height: 1.6,
                  color: const Color(0xFF667267),
                ),
              ),
              const SizedBox(height: 13),
              Text(
                widget.phoneNumber,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 19),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 23,
                  letterSpacing: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF131B2E),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFFB7C1B7),
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7FAF7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFDDE7DD),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFDDE7DD),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: _primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: const Color(0xFFF7DFC2),
                  ),
                ),
                child: Text(
                  'Kode demo: 482913',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF994700),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Verifikasi & Masuk',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _remainingSeconds > 0
                        ? 'Kirim ulang dalam $_remainingSeconds detik'
                        : 'Belum menerima kode?',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF778477),
                      fontSize: 10,
                    ),
                  ),
                  if (_remainingSeconds == 0)
                    TextButton(
                      onPressed: _startTimer,
                      child: Text(
                        'Kirim Ulang',
                        style: GoogleFonts.plusJakartaSans(
                          color: _primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Metode pengiriman kode: $methodName. '
                        'Pengiriman asli belum tersedia.',
                      ),
                    ),
                  );
                },
                child: Text(
                  'Ganti metode verifikasi',
                  style: GoogleFonts.plusJakartaSans(
                    color: _primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
