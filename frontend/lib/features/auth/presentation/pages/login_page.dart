import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color _green = Color(0xFF006130);
  static const Color _surface = Color(0xFFFAF8FF);
  static const Color _text = Color(0xFF131B2E);
  static const Color _muted = Color(0xFF667085);
  static const Color _outline = Color(0xFFBECABD);

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Hubungkan dengan API autentikasi backend.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() => _isLoading = false);

    _showMessage(
      'Form login valid. Autentikasi backend belum dihubungkan.',
    );
  }

  void _openOtp(String method) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OtpVerificationSheet(
        phoneNumber: _phoneController.text.trim(),
        method: method,
      ),
    );
  }

  void _openPlaceholder(String pageName) {
    _showMessage('Halaman $pageName belum diimplementasikan.');
  }

  String? _validatePhone(String? value) {
    final phone = value?.replaceAll(RegExp(r'\D'), '') ?? '';

    if (phone.isEmpty) {
      return 'Nomor HP wajib diisi';
    }

    if (phone.length < 9 || phone.length > 13) {
      return 'Masukkan nomor HP yang valid';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildHero(),
              Transform.translate(
                offset: const Offset(0, -24),
                child: _buildLoginCard(),
              ),
              Transform.translate(
                offset: const Offset(0, -12),
                child: _buildFooter(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        children: [
          _roundIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.maybePop(context),
          ),
          const Spacer(),
          _brandPill(),
          const Spacer(),
          const CircleAvatar(
            radius: 21,
            backgroundColor: Color(0xFFE2E7FD),
            child: Icon(
              Icons.person_rounded,
              color: _green,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandPill() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE5EAE4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cleaning_services_rounded,
            color: _green,
            size: 17,
          ),
          const SizedBox(width: 6),
          Text(
            'SapuLidi',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: _green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: _text, size: 21),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF084C27),
            Color(0xFF0D6535),
            Color(0xFF107C41),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.cleaning_services_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'PORTAL WARGA DIGITAL',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: const Color(0xFFB6FFC5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Selamat Datang\nKembali!',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 27,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Silakan masuk ke akun warga RT Anda untuk mengakses layanan & iuran.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.07),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masuk ke Akun Anda',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Gunakan nomor HP yang sudah terdaftar.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _muted,
              ),
            ),
            const SizedBox(height: 24),
            _fieldLabel('Nomor HP'),
            const SizedBox(height: 8),
            _buildPhoneField(),
            const SizedBox(height: 18),
            _fieldLabel('Kata Sandi'),
            const SizedBox(height: 8),
            _buildPasswordField(),
            const SizedBox(height: 12),
            _buildFormOptions(),
            const SizedBox(height: 22),
            AppPrimaryButton(
              label: 'Masuk',
              icon: Icons.arrow_forward_rounded,
              isLoading: _isLoading,
              onPressed: _handleLogin,
            ),
            const SizedBox(height: 22),
            _buildDivider(),
            const SizedBox(height: 18),
            Text(
              'Pilih metode verifikasi alternatif',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _muted,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAlternativeCard(
                    icon: Icons.chat_rounded,
                    title: 'WhatsApp',
                    subtitle: '1-Klik',
                    color: const Color(0xFF20A85A),
                    onTap: () => _openOtp('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAlternativeCard(
                    icon: Icons.sms_rounded,
                    title: 'Kode OTP',
                    subtitle: '6 Digit',
                    color: const Color(0xFF2876D2),
                    onTap: () => _openOtp('SMS & Telegram'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoBox(),
            const SizedBox(height: 22),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'Belum punya akun warga? ',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _muted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openPlaceholder('Registrasi'),
                    child: Text(
                      'Daftar Sekarang',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _text,
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Text(
              '+62',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
          ),
          Container(width: 1, height: 25, color: _outline),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _text,
              ),
              decoration: InputDecoration(
                hintText: '812-3456-7890',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF98A2B3),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: _validatePassword,
      style: GoogleFonts.inter(fontSize: 14, color: _text),
      decoration: InputDecoration(
        hintText: 'Masukkan kata sandi',
        hintStyle: GoogleFonts.inter(
          fontSize: 13,
          color: const Color(0xFF98A2B3),
        ),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          size: 19,
          color: _muted,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 19,
            color: _muted,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _green, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFormOptions() {
    return Row(
      children: [
        SizedBox(
          height: 28,
          child: Checkbox(
            value: _rememberMe,
            activeColor: _green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (value) {
              setState(() => _rememberMe = value ?? false);
            },
          ),
        ),
        Text(
          'Ingat Saya',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: _muted,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _openPlaceholder('Lupa Password'),
          child: Text(
            'Lupa Password?',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5EAE4))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ATAU MASUK DENGAN',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: _muted,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5EAE4))),
      ],
    );
  }

  Widget _buildAlternativeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5EAE4)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 25),
              const SizedBox(width: 9),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F2),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFD9EBDD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: _green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Login Tanpa Sandi: Tautan verifikasi 1-klik atau 6 digit OTP akan dikirim langsung ke kontak nomor HP yang terdaftar di basis data RT.',
              style: GoogleFonts.inter(
                fontSize: 10,
                height: 1.6,
                color: const Color(0xFF315C40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: _green,
                size: 16,
              ),
              const SizedBox(width: 7),
              Text(
                'Dilindungi enkripsi data kependudukan RT/RW',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: _muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'RT 04 / RW 07  •  Kel. Sukamaju',
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
}

class _OtpVerificationSheet extends StatefulWidget {
  const _OtpVerificationSheet({
    required this.phoneNumber,
    required this.method,
  });

  final String phoneNumber;
  final String method;

  @override
  State<_OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<_OtpVerificationSheet> {
  static const Color _green = Color(0xFF006130);

  final _otpController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 45;
  bool _isVerifying = false;

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
    setState(() => _remainingSeconds = 45);

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
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan 6 digit kode OTP.'),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    // TODO: Verifikasi OTP melalui backend.
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() => _isVerifying = false);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Kode diterima. Verifikasi backend belum dihubungkan.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
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
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DED9),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7ED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: _green,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Verifikasi Kode OTP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF131B2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan 6 digit kode yang dikirim melalui ${widget.method} ke nomor:',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.6,
                  color: const Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+62 ${widget.phoneNumber}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _green,
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 12,
                  color: _green,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '------',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 23,
                    letterSpacing: 8,
                    color: const Color(0xFFBECABD),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7FAF7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFFBECABD),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFFBECABD),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: _green,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _remainingSeconds > 0
                    ? 'Kirim ulang kode dalam 00:${_remainingSeconds.toString().padLeft(2, '0')}'
                    : 'Belum menerima kode OTP?',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF667085),
                ),
              ),
              if (_remainingSeconds == 0)
                TextButton(
                  onPressed: _startTimer,
                  child: Text(
                    'Kirim Ulang Kode',
                    style: GoogleFonts.inter(
                      color: _green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              AppPrimaryButton(
                label: 'Verifikasi Sekarang',
                isLoading: _isVerifying,
                onPressed: _verifyOtp,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batalkan',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF667085),
                    fontWeight: FontWeight.w600,
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
