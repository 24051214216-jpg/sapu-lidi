import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Color _green = Color(0xFF006130);
  static const Color _greenLight = Color(0xFFEAF7ED);
  static const Color _text = Color(0xFF131B2E);
  static const Color _muted = Color(0xFF667085);
  static const Color _outline = Color(0xFFBECABD);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final Dio _dio;
  late final AuthRemoteDataSource _authRemoteDataSource;
  final SecureStorage _secureStorage = SecureStorage();

  String? _selectedBlock;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreementAccepted = false;
  bool _isLoading = false;

  static const Map<String, String> _blocks = {
    'A': 'Gang 1',
    'B': 'Gang 2-3',
    'C': 'Taman',
    'D': 'Gerbang Timur',
  };

  @override
  void initState() {
    super.initState();
    _dio = DioClient.create();
    _authRemoteDataSource = AuthRemoteDataSource(_dio);
    _passwordController.addListener(_refreshPasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_refreshPasswordStrength);
    _nameController.dispose();
    _phoneController.dispose();
    _houseNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _refreshPasswordStrength() {
    if (!mounted) return;

    setState(() {});

    if (_confirmPasswordController.text.isNotEmpty) {
      _formKey.currentState?.validate();
    }
  }

  int get _passwordStrength {
    final password = _passwordController.text;

    if (password.isEmpty) return 0;

    var score = 0;

    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    if (score <= 2) return 1;
    if (score <= 3) return 2;

    return 3;
  }

  String get _passwordStrengthLabel {
    switch (_passwordStrength) {
      case 0:
        return 'Belum diisi';
      case 1:
        return 'Lemah';
      case 2:
        return 'Sedang';
      default:
        return 'Kuat';
    }
  }

  Color get _passwordStrengthColor {
    switch (_passwordStrength) {
      case 0:
        return const Color(0xFFD9DED9);
      case 1:
        return const Color(0xFFE05252);
      case 2:
        return const Color(0xFFEF9B27);
      default:
        return _green;
    }
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Nama lengkap wajib diisi';
    }

    if (name.length < 3) {
      return 'Nama minimal 3 karakter';
    }

    if (RegExp(r'[0-9]').hasMatch(name)) {
      return 'Nama tidak boleh mengandung angka';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final phone = (value ?? '').replaceAll(RegExp(r'\D'), '');

    if (phone.isEmpty) {
      return 'Nomor WhatsApp wajib diisi';
    }

    if (phone.startsWith('0')) {
      return 'Hilangkan angka 0 setelah kode +62';
    }

    if (phone.length < 9 || phone.length > 13) {
      return 'Nomor HP harus terdiri dari 9-13 digit';
    }

    return null;
  }

  String? _validateBlock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Silakan pilih blok rumah';
    }

    return null;
  }

  String? _validateHouseNumber(String? value) {
    final houseNumber = value?.trim() ?? '';

    if (houseNumber.isEmpty) {
      return 'Nomor rumah wajib diisi';
    }

    if (houseNumber.length > 15) {
      return 'Nomor rumah maksimal 15 karakter';
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ulangi password Anda';
    }

    if (value != _passwordController.text) {
      return 'Password tidak sama';
    }

    return null;
  }

  String _normalizePhoneNumber(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    if (digits.startsWith('62')) {
      digits = digits.substring(2);
    }

    return '+62$digits';
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

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    if (!_agreementAccepted) {
      _showMessage('Anda harus menyetujui syarat dan ketentuan.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final session = await _authRemoteDataSource.register(
        nama: _nameController.text.trim(),
        noHp: _normalizePhoneNumber(_phoneController.text),
        blokRumah: _selectedBlock!,
        noRumah: _houseNumberController.text.trim(),
        password: _passwordController.text,
      );

      final role = session.user['role']?.toString().toUpperCase();
      final status = session.user['status']?.toString().toUpperCase();

      if (role != 'WARGA' || status != 'AKTIF') {
        throw Exception(
          'Pendaftaran tersimpan, tetapi server tidak mengembalikan '
          'status akun AKTIF. Silakan hubungi administrator.',
        );
      }

      if (session.accessToken.isEmpty) {
        throw Exception(
          'Pendaftaran berhasil, tetapi access token tidak diterima.',
        );
      }

      await _secureStorage.saveAccessToken(session.accessToken);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: const BoxDecoration(
                    color: _greenLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: _green,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Pendaftaran Berhasil',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Akun warga Anda berhasil dibuat dan sudah AKTIF. '
                  'Sesi autentikasi juga telah disimpan dengan aman. '
                  'Anda tidak perlu menunggu persetujuan RT.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.6,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(
                      'Selesai',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } on DioException catch (error) {
      final responseData = error.response?.data;
      final message = responseData is Map
          ? responseData['message']?.toString()
          : null;

      _showMessage(
        message ?? 'Tidak dapat terhubung ke server. Periksa koneksi API.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 22),
              _buildHero(),
              const SizedBox(height: 22),
              _buildRegistrationForm(),
              const SizedBox(height: 20),
              _buildFooter(),
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
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Akun Warga',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              Text(
                'RT 05 / RW 08 Menteng Asri',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: _greenLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user_rounded,
                size: 13,
                color: _green,
              ),
              const SizedBox(width: 5),
              Text(
                'Data Warga',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _green,
                ),
              ),
            ],
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

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF084C27),
            Color(0xFF107C41),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              'SATU PINTU DIGITAL RT 05',
              style: GoogleFonts.inter(
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFB6FFC5),
              ),
            ),
          ),
          const SizedBox(height: 17),
          Text(
            'Gabung Ekosistem Warga',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lengkapi data diri Anda untuk menikmati layanan '
            'warga yang lebih mudah, cepat, dan transparan.',
            style: GoogleFonts.inter(
              fontSize: 11,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
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
            Text(
              'Informasi Pribadi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Pastikan data sesuai dengan identitas Anda.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _muted,
              ),
            ),
            const SizedBox(height: 22),
            _fieldLabel('Nama Lengkap'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Masukkan nama lengkap',
              icon: Icons.person_outline_rounded,
              validator: _validateName,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 17),
            _fieldLabel('Nomor WhatsApp Aktif'),
            const SizedBox(height: 8),
            _buildPhoneField(),
            const SizedBox(height: 17),
            _fieldLabel('Blok Rumah'),
            const SizedBox(height: 8),
            _buildBlockDropdown(),
            const SizedBox(height: 17),
            _fieldLabel('Nomor Rumah'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _houseNumberController,
              hint: 'Contoh: 12A',
              icon: Icons.home_outlined,
              validator: _validateHouseNumber,
            ),
            const SizedBox(height: 22),
            _buildSectionDivider(),
            const SizedBox(height: 20),
            _fieldLabel('Password Baru'),
            const SizedBox(height: 8),
            _buildPasswordField(),
            const SizedBox(height: 10),
            _buildPasswordStrength(),
            const SizedBox(height: 17),
            _fieldLabel('Ulangi Kata Sandi'),
            const SizedBox(height: 8),
            _buildConfirmPasswordField(),
            const SizedBox(height: 20),
            _buildAgreement(),
            const SizedBox(height: 22),
            AppPrimaryButton(
              label: 'Daftar Sekarang',
              icon: Icons.arrow_forward_rounded,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleRegister,
            ),
            const SizedBox(height: 16),
            _buildTrustNote(),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _text,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: _text,
      ),
      decoration: _inputDecoration(
        hint: hint,
        icon: icon,
      ),
    );
  }

  // Nomor WhatsApp: pesan validasi diletakkan di luar border input.
  Widget _buildPhoneField() {
    return FormField<String>(
      initialValue: _phoneController.text,
      validator: _validatePhone,
      builder: (fieldState) {
        final hasError = fieldState.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: hasError ? Colors.red : _outline,
                  width: hasError ? 1.2 : 1,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                    ),
                    child: Text(
                      '+62',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _text,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: _outline,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _text,
                      ),
                      onChanged: (value) {
                        fieldState.didChange(value);
                        if (fieldState.hasError) {
                          fieldState.validate();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: '812-3456-7890',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF98A2B3),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  fieldState.errorText!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBlockDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedBlock,
      isExpanded: true,
      validator: _validateBlock,
      hint: Text(
        'Pilih blok rumah',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: const Color(0xFF98A2B3),
        ),
      ),
      decoration: _inputDecoration(
        hint: 'Pilih blok rumah',
        icon: Icons.location_on_outlined,
      ),
      items: _blocks.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(
            'Blok ${entry.key} (${entry.value})',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _text,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedBlock = value);
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 12,
        color: const Color(0xFF98A2B3),
      ),
      prefixIcon: Icon(
        icon,
        size: 18,
        color: _muted,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 15,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _green,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: _validatePassword,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: _text,
      ),
      decoration: _inputDecoration(
        hint: 'Minimal 8 karakter',
        icon: Icons.lock_outline_rounded,
      ).copyWith(
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
            size: 18,
            color: _muted,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      validator: _validateConfirmPassword,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: _text,
      ),
      decoration: _inputDecoration(
        hint: 'Masukkan kembali password',
        icon: Icons.lock_reset_rounded,
      ).copyWith(
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 18,
            color: _muted,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrength() {
    final strength = _passwordStrength;
    final color = _passwordStrengthColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (index) {
            final active = strength > index;

            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(
                  right: index == 2 ? 0 : 5,
                ),
                decoration: BoxDecoration(
                  color: active ? color : const Color(0xFFE6EAE6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Kekuatan password',
              style: GoogleFonts.inter(
                fontSize: 9,
                color: _muted,
              ),
            ),
            const Spacer(),
            Text(
              _passwordStrengthLabel,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Color(0xFFE5EAE4)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'KEAMANAN AKUN',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: _muted,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0xFFE5EAE4)),
        ),
      ],
    );
  }

  Widget _buildAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreementAccepted,
            activeColor: _green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (value) {
              setState(() {
                _agreementAccepted = value ?? false;
              });
            },
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreementAccepted = !_agreementAccepted;
              });
            },
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 10,
                  height: 1.6,
                  color: _muted,
                ),
                children: const [
                  TextSpan(text: 'Saya menyetujui '),
                  TextSpan(
                    text: 'Syarat dan Ketentuan',
                    style: TextStyle(
                      color: _green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' serta '),
                  TextSpan(
                    text: 'Kebijakan Privasi',
                    style: TextStyle(
                      color: _green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' SapuLidi.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9EBDD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: _green,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Data pribadi Anda akan digunakan untuk keperluan '
              'administrasi warga dan dikelola oleh pengurus RT.',
              style: GoogleFonts.inter(
                fontSize: 10,
                height: 1.5,
                color: const Color(0xFF315C40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Sudah punya akun warga?',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: _muted,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Masuk di sini',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _green,
            ),
          ),
        ),
        Text(
          'SapuLidi • RT 05 / RW 08 Menteng Asri',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: _muted,
          ),
        ),
      ],
    );
  }
}
