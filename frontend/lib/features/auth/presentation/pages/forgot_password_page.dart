import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const Color _green = Color(0xFF006130);
  static const Color _text = Color(0xFF131B2E);
  static const Color _muted = Color(0xFF667085);
  static const Color _surface = Color(0xFFFAF8FF);

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  late final AuthRemoteDataSource _authRemoteDataSource;

  bool _isLoading = false;
  bool _otpSent = false;

  int _expiresIn = 300;

  @override
  void initState() {
    super.initState();

    _authRemoteDataSource = AuthRemoteDataSource(
      DioClient.create(),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _normalizePhone(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    if (digits.startsWith('62')) {
      return '+$digits';
    }

    return '+62$digits';
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

  String? _validateOtp(String? value) {
    final otp = value?.trim() ?? '';

    if (otp.isEmpty) {
      return 'Kode OTP wajib diisi';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'Kode OTP harus terdiri dari 6 angka';
    }

    return null;
  }

  Future<void> _requestResetOtp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final noHp = _normalizePhone(_phoneController.text);

      final expiresIn = await _authRemoteDataSource.requestPasswordResetOtp(
        noHp: noHp,
      );

      if (!mounted) return;

      setState(() {
        _expiresIn = expiresIn;
        _otpSent = true;
        _isLoading = false;
      });

      _showMessage(
        'Jika nomor terdaftar, kode OTP akan dikirim melalui WhatsApp.',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showError(error);
    }
  }

  Future<void> _resendOtp() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final noHp = _normalizePhone(_phoneController.text);

      final expiresIn = await _authRemoteDataSource.requestPasswordResetOtp(
        noHp: noHp,
      );

      if (!mounted) return;

      setState(() {
        _expiresIn = expiresIn;
        _otpController.clear();
        _isLoading = false;
      });

      _showMessage('Permintaan OTP berhasil diproses.');
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showError(error);
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final noHp = _normalizePhone(_phoneController.text);

      final resetToken = await _authRemoteDataSource.verifyPasswordResetOtp(
        noHp: noHp,
        otp: _otpController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(
            resetToken: resetToken,
          ),
        ),
      );

      if (!mounted) return;

      if (result == true) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showError(error);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showError(Object error) {
    String message = 'Terjadi kesalahan. Silakan coba kembali.';

    if (error is DioException) {
      final responseData = error.response?.data;

      if (responseData is Map) {
        message = responseData['message']?.toString() ?? message;
      } else if (error.message != null) {
        message = error.message!;
      }
    } else {
      message = error.toString().replaceFirst('Exception: ', '');
    }

    _showMessage(message);
  }

  void _backToLogin() {
    Navigator.pop(context);
  }

  void _showContactMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Silakan hubungi Ketua RT atau pengurus untuk mendapatkan bantuan.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildIllustration(),
              const SizedBox(height: 25),
              Text(
                'Atur Ulang Password',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _otpSent
                    ? 'Masukkan kode OTP 6 digit yang dikirimkan ke WhatsApp Anda untuk melanjutkan pengaturan ulang password.'
                    : 'Jangan khawatir! Masukkan nomor HP yang terdaftar. Kami akan membantu Anda mengatur ulang kata sandi.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.7,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 28),
              _buildResetForm(),
              const SizedBox(height: 22),
              _buildHelpCard(),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: _backToLogin,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 17,
                ),
                label: const Text('Kembali ke halaman Login'),
                style: TextButton.styleFrom(
                  foregroundColor: _green,
                  textStyle: GoogleFonts.inter(
                    fontSize: 12,
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

  Widget _buildHeader() {
    return Row(
      children: [
        _roundIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: _backToLogin,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _green,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const CircleAvatar(
          radius: 21,
          backgroundColor: Color(0xFFE2E7FD),
          child: Icon(
            Icons.person_rounded,
            color: _green,
          ),
        ),
      ],
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

  Widget _buildIllustration() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7ED),
        borderRadius: BorderRadius.circular(90),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 125,
            height: 125,
            decoration: BoxDecoration(
              color: const Color(0xFFD4F1DB),
              borderRadius: BorderRadius.circular(36),
            ),
          ),
          const Icon(
            Icons.lock_reset_rounded,
            size: 88,
            color: _green,
          ),
          Positioned(
            right: 20,
            top: 25,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                size: 21,
                color: _green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.06),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Nomor HP Terdaftar',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _text,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7ED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'WhatsApp Aktif',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildPhoneField(),
            if (_otpSent) ...[
              const SizedBox(height: 22),
              Text(
                'Kode Verifikasi OTP',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 10),
              _buildOtpField(),
              const SizedBox(height: 10),
              Text(
                'Kode OTP berlaku sekitar ${(_expiresIn / 60).ceil()} menit.',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: _muted,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading ? null : _resendOtp,
                  child: Text(
                    'Kirim Ulang OTP',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _green,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 14),
              _buildInfoBox(),
            ],
            const SizedBox(height: 22),
            AppPrimaryButton(
              label: _otpSent ? 'Verifikasi OTP' : 'Kirim Kode OTP',
              icon: _otpSent ? Icons.verified_rounded : Icons.send_rounded,
              isLoading: _isLoading,
              onPressed: _otpSent ? _verifyOtp : _requestResetOtp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBECABD)),
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
            color: const Color(0xFFBECABD),
          ),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              enabled: !_otpSent && !_isLoading,
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
                suffixIcon: IconButton(
                  tooltip: 'Hapus nomor',
                  onPressed:
                      _otpSent || _isLoading ? null : _phoneController.clear,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: _muted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      validator: _validateOtp,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      style: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 12,
        color: _green,
      ),
      decoration: InputDecoration(
        hintText: '000000',
        counterText: '',
        hintStyle: GoogleFonts.inter(
          fontSize: 18,
          letterSpacing: 8,
          color: const Color(0xFFBECABD),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBECABD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBECABD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _green, width: 1.5),
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
            color: _green,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kode OTP untuk mengatur ulang password akan dikirim melalui WhatsApp. Masukkan kode tersebut untuk melanjutkan.',
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

  Widget _buildHelpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E5F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.support_agent_rounded,
                color: _green,
                size: 23,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Butuh Bantuan?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Nomor HP tidak aktif atau mengalami kendala? Hubungi Ketua RT atau pengurus untuk mendapatkan bantuan.',
            style: GoogleFonts.inter(
              fontSize: 11,
              height: 1.6,
              color: _muted,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _showContactMessage,
            icon: const Icon(Icons.chat_rounded, size: 17),
            label: const Text('Chat Pengurus RT'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _green,
              side: const BorderSide(color: _green),
              textStyle: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
