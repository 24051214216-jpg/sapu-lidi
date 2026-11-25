import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    required this.resetToken,
  });

  final String resetToken;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  static const Color _green = Color(0xFF006130);
  static const Color _text = Color(0xFF131B2E);
  static const Color _muted = Color(0xFF667085);
  static const Color _surface = Color(0xFFFAF8FF);

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final AuthRemoteDataSource _authRemoteDataSource;

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    _authRemoteDataSource = AuthRemoteDataSource(
      DioClient.create(),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password baru wajib diisi';
    }

    if (password.length < 8) {
      return 'Password minimal 8 karakter';
    }

    if (password.length > 72) {
      return 'Password maksimal 72 karakter';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }

    if (value != _passwordController.text) {
      return 'Konfirmasi password tidak sama';
    }

    return null;
  }

  Future<void> _submitNewPassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authRemoteDataSource.resetPassword(
        resetToken: widget.resetToken,
        newPassword: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showError(error);
    }
  }

  void _showError(Object error) {
    String message = 'Password gagal diperbarui. Silakan coba kembali.';

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _finish() {
    Navigator.pop(context, true);
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
              const SizedBox(height: 35),
              _buildIllustration(),
              const SizedBox(height: 25),
              Text(
                _isSuccess ? 'Password Berhasil Diubah' : 'Buat Password Baru',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isSuccess
                    ? 'Password akun Anda sudah berhasil diperbarui. Silakan masuk kembali menggunakan password baru.'
                    : 'Buat password baru yang kuat dan mudah Anda ingat untuk menjaga keamanan akun SapuLidi.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.7,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 28),
              _isSuccess ? _buildSuccessCard() : _buildPasswordForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _isLoading ? null : () => Navigator.pop(context),
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_rounded,
                color: _text,
                size: 21,
              ),
            ),
          ),
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
          Icon(
            _isSuccess ? Icons.verified_user_rounded : Icons.lock_reset_rounded,
            size: 88,
            color: _green,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
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
            _buildFieldLabel('Password Baru'),
            const SizedBox(height: 9),
            _buildPasswordField(
              controller: _passwordController,
              hint: 'Masukkan password baru',
              obscureText: _obscurePassword,
              onToggle: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: _validatePassword,
            ),
            const SizedBox(height: 18),
            _buildFieldLabel('Konfirmasi Password Baru'),
            const SizedBox(height: 9),
            _buildPasswordField(
              controller: _confirmPasswordController,
              hint: 'Ulangi password baru',
              obscureText: _obscureConfirmPassword,
              onToggle: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: _validateConfirmPassword,
            ),
            const SizedBox(height: 14),
            _buildInfoBox(),
            const SizedBox(height: 22),
            AppPrimaryButton(
              label: 'Simpan Password Baru',
              icon: Icons.lock_reset_rounded,
              isLoading: _isLoading,
              onPressed: _submitNewPassword,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: _text,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: _text,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 12,
          color: const Color(0xFF98A2B3),
        ),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: _muted,
          size: 19,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _muted,
            size: 19,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
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
              'Password harus terdiri dari minimal 8 karakter dan maksimal 72 karakter.',
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

  Widget _buildSuccessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: _green,
            size: 65,
          ),
          const SizedBox(height: 18),
          Text(
            'Password berhasil diperbarui!',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Gunakan password baru Anda untuk masuk kembali ke aplikasi SapuLidi.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.6,
              color: _muted,
            ),
          ),
          const SizedBox(height: 22),
          AppPrimaryButton(
            label: 'Kembali ke Login',
            icon: Icons.login_rounded,
            onPressed: _finish,
          ),
        ],
      ),
    );
  }
}
