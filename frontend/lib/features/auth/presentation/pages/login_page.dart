import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import 'forgot_password_page.dart';
import 'otp_verification_page.dart';
import 'register_page.dart';

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

  late final Dio _dio;
  late final AuthRemoteDataSource _authDataSource;

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _dio = DioClient.create();
    _authDataSource = AuthRemoteDataSource(_dio);
  }

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

  String _normalizePhone(String value) {
    var phone = value.replaceAll(RegExp(r'\D'), '');

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    } else if (phone.startsWith('62')) {
      phone = phone.substring(2);
    }

    return '+62$phone';
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final phone = _normalizePhone(
        _phoneController.text,
      );

      final result = await _authDataSource.login(
        noHp: phone,
        password: _passwordController.text,
      );

      if (!mounted) return;

      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(
            challengeId: result['challengeId'] as String,
            phoneNumber: result['phoneMasked'] as String,
            expiresIn: int.tryParse(
                  result['expiresIn'].toString(),
                ) ??
                300,
          ),
        ),
      );

      if (!mounted) return;

      if (verified == true) {
        _showMessage(
          'Verifikasi berhasil. Sesi autentikasi telah disimpan.',
        );
      }
    } on DioException catch (error) {
      final responseData = error.response?.data;

      final message =
          responseData is Map ? responseData['message']?.toString() : null;

      _showMessage(
        message ?? 'Tidak dapat terhubung ke server.',
      );
    } catch (error) {
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordPage(),
      ),
    );
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );
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
        border: Border.all(
          color: const Color(0xFFE5EAE4),
        ),
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
          child: Icon(
            icon,
            color: _text,
            size: 21,
          ),
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
        borderRadius: BorderRadius.all(
          Radius.circular(28),
        ),
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
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleLogin,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  _isLoading ? 'Memproses...' : 'Masuk',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _green.withValues(
                    alpha: 0.6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
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
                    onTap: _openRegister,
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
          Container(
            width: 1,
            height: 25,
            color: _outline,
          ),
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
      style: GoogleFonts.inter(
        fontSize: 14,
        color: _text,
      ),
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
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
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
          borderSide: const BorderSide(
            color: _green,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
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
              setState(() {
                _rememberMe = value ?? false;
              });
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
          onTap: _openForgotPassword,
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

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F2),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFD9EBDD),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 19,
            color: _green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Keamanan akun dilindungi dengan verifikasi dua langkah. '
              'Setelah password benar, kode OTP akan dikirim ke nomor HP terdaftar.',
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
            'RT 04 / RW 07 • Kel. Sukamaju',
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
