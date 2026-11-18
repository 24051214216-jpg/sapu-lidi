import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.challengeId,
    required this.phoneNumber,
    this.expiresIn = 300,
  });

  final String challengeId;
  final String phoneNumber;
  final int expiresIn;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const Color _green = Color(0xFF006130);

  final _otpController = TextEditingController();

  late final Dio _dio;
  late final AuthRemoteDataSource _authDataSource;

  Timer? _timer;

  int _remainingSeconds = 300;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();

    _dio = DioClient.create();
    _authDataSource = AuthRemoteDataSource(_dio);

    _remainingSeconds = widget.expiresIn > 0 ? widget.expiresIn : 300;

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

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds <= 1) {
          timer.cancel();

          setState(() {
            _remainingSeconds = 0;
          });
        } else {
          setState(() {
            _remainingSeconds--;
          });
        }
      },
    );
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

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    final otp = _otpController.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      _showMessage('Masukkan kode OTP 6 digit.');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final session = await _authDataSource.verifyOtp(
        challengeId: widget.challengeId,
        otp: otp,
      );

      await SecureStorage().saveAccessToken(
        session.accessToken,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } on DioException catch (error) {
      final message = error.response?.data is Map
          ? error.response?.data['message']?.toString()
          : null;

      _showMessage(
        message ?? 'Tidak dapat menghubungi server.',
      );
    } catch (error) {
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);

    try {
      await _authDataSource.requestOtp(
        challengeId: widget.challengeId,
      );

      if (!mounted) return;

      setState(() {
        _remainingSeconds = 300;
      });

      _startTimer();

      _showMessage('Kode OTP berhasil dikirim ulang.');
    } on DioException catch (error) {
      final message = error.response?.data is Map
          ? error.response?.data['message']?.toString()
          : null;

      _showMessage(
        message ?? 'Gagal mengirim ulang kode OTP.',
      );
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');

    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        title: Text(
          'Verifikasi OTP',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7ED),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: _green,
                  size: 38,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                'Satu Langkah Lagi!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF131B2E),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Masukkan kode OTP 6 digit yang dikirimkan '
                'ke nomor HP kamu.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.6,
                  color: const Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.phoneNumber,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _green,
                ),
              ),
              const SizedBox(height: 35),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 12,
                  color: _green,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '------',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 24,
                    letterSpacing: 9,
                    color: const Color(0xFFBECABD),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFBECABD),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFBECABD),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: _green,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _remainingSeconds > 0
                    ? 'Kode berlaku selama $_formattedTime'
                    : 'Kode OTP telah kedaluwarsa.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed:
                    _remainingSeconds == 0 && !_isResending ? _resendOtp : null,
                child: _isResending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Kirim Ulang Kode OTP',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          color: _green,
                        ),
                      ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isVerifying
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          'Verifikasi Sekarang',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Kembali ke Login',
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
