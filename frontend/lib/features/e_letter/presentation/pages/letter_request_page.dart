import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LetterRequestPage extends StatefulWidget {
  const LetterRequestPage({
    super.key,
    required this.user,
  });

  final Map<String, dynamic> user;

  @override
  State<LetterRequestPage> createState() => _LetterRequestPageState();
}

class _LetterRequestPageState extends State<LetterRequestPage> {
  static const Color _primary = Color(0xFF006130);
  static const Color _primaryContainer = Color(0xFF107C41);
  static const Color _background = Color(0xFFFAF8FF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceLow = Color(0xFFF2F3FF);
  static const Color _surfaceHigh = Color(0xFFE2E7FF);
  static const Color _ink = Color(0xFF17251C);
  static const Color _muted = Color(0xFF718078);
  static const Color _tertiary = Color(0xFF005988);

  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  late final TextEditingController _phoneController;

  int? _selectedType;
  bool _submitting = false;

  static final List<_LetterType> _types = [
    _LetterType(
      title: 'Surat Pengantar RT',
      description: 'Pengantar administrasi dan keperluan warga',
      icon: Icons.description_outlined,
    ),
    _LetterType(
      title: 'Surat Keterangan Domisili',
      description: 'Bukti tempat tinggal sementara / buka rekening bank',
      icon: Icons.home_work_outlined,
    ),
    _LetterType(
      title: 'Pengantar Nikah (Model N1-N4)',
      description: 'Pengurusan pendaftaran pernikahan di KUA / Catatan Sipil',
      icon: Icons.favorite_outline_rounded,
    ),
    _LetterType(
      title: 'Keterangan Usaha (SKU)',
      description: 'Pengajuan KUR UMKM, izin usaha mikro, perbankan',
      icon: Icons.storefront_outlined,
    ),
    _LetterType(
      title: 'Pindah Domisili / Keterangan Kematian',
      description: 'Penerbitan surat jalan pindah KK atau akta lelayu',
      icon: Icons.transfer_within_a_station,
    ),
  ];

  static final List<_LetterRecord> _records = [];

  String get _name {
    final value = widget.user['nama']?.toString().trim();
    return value == null || value.isEmpty ? 'Warga SapuLidi' : value;
  }

  String get _phone {
    final value = widget.user['noHp']?.toString().trim();
    return value == null || value.isEmpty ? '' : value;
  }

  String get _address {
    final block = widget.user['blokRumah']?.toString().trim() ?? '';
    final number = widget.user['noRumah']?.toString().trim() ?? '';

    final parts = <String>[
      if (block.isNotEmpty && block != '-') 'Blok $block',
      if (number.isNotEmpty && number != '-') 'No. $number',
    ];

    return parts.isEmpty ? 'Alamat domisili belum tersedia' : parts.join(' • ');
  }

  String get _initial => _name.isEmpty ? 'W' : _name[0].toUpperCase();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: _phone);
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  TextStyle get _heading => GoogleFonts.plusJakartaSans(
        color: _ink,
        fontWeight: FontWeight.w800,
      );

  TextStyle get _body => GoogleFonts.inter(
        color: _muted,
        fontSize: 12,
      );

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontSize: 12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Bantuan Pengajuan E-Surat', style: _heading),
        content: Text(
          'Pilih kategori surat yang dibutuhkan, tuliskan tujuan pengajuan '
          'minimal 10 karakter, lalu pastikan nomor WhatsApp aktif. '
          'Pengajuan simulasi akan tercatat pada riwayat selama aplikasi '
          'masih berjalan.',
          style: _body.copyWith(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_selectedType == null) {
      _showMessage('Pilih kategori surat terlebih dahulu.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final now = DateTime.now();
    final record = _LetterRecord(
      id: 'ES-${now.millisecondsSinceEpoch}',
      applicant: _name,
      category: _types[_selectedType!].title,
      purpose: _purposeController.text.trim(),
      phone: _phoneController.text.trim(),
      date: now,
      status: 'Menunggu Verifikasi RT',
    );

    _records.insert(0, record);

    setState(() => _submitting = false);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: Color(0xFFE3F8E9),
              child: Icon(
                Icons.check_circle_rounded,
                color: _primary,
                size: 43,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pengajuan Berhasil',
              style: _heading.copyWith(fontSize: 19),
            ),
            const SizedBox(height: 9),
            Text(
              'Simulasi pengajuan surat berhasil dibuat. '
              'Pengajuan tercatat dengan nomor ${record.id}. '
              'Data belum dikirim ke server.',
              textAlign: TextAlign.center,
              style: _body.copyWith(height: 1.6),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: Text(
          'Form Pengajuan E Surat',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Riwayat Pengajuan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LetterHistoryPage(records: _records),
                ),
              );
            },
            icon: const Icon(Icons.history_rounded, color: _muted),
          ),
          IconButton(
            tooltip: 'Bantuan',
            onPressed: _showHelp,
            icon: const Icon(Icons.help_outline_rounded, color: _muted),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgress(),
                        const SizedBox(height: 18),
                        _buildApplicantCard(),
                        const SizedBox(height: 24),
                        _buildCategorySection(),
                        const SizedBox(height: 24),
                        _buildFormFields(),
                        const SizedBox(height: 22),
                        _buildInformationCard(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'LANGKAH 1 DARI 2',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _primary,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: _surfaceHigh,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Estimasi: 2 Menit',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _muted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const LinearProgressIndicator(
            value: 0.5,
            minHeight: 7,
            backgroundColor: _surfaceHigh,
            valueColor: AlwaysStoppedAnimation<Color>(_primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Data Permohonan Surat',
          style: _heading.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          'Surat Pengantar RT / Surat Keterangan Warga Mandiri',
          style: _body.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildApplicantCard() {
    final status = widget.user['status']?.toString() ?? 'Aktif';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: _primary,
                size: 20,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'DATA PEMOHON TERVERIFIKASI',
                  style: GoogleFonts.inter(
                    color: _primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8F9DF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF005228),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE8FFF0),
                child: Text(
                  _initial,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _heading.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Identitas mengikuti data akun terdaftar',
                      style: _body.copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        _smallTag('Warga Terdaftar', _tertiary),
                        _smallTag('Data Akun', _muted),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surfaceLow,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  // PERBAIKAN: Mengganti Icons.home_pin_rounded menjadi Icons.location_on_rounded
                  Icons.location_on_rounded,
                  color: _primary,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ALAMAT DOMISILI TERDAFTAR',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _address,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: _ink,
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

  Widget _smallTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Pilih Kategori Surat',
                style: _heading.copyWith(fontSize: 16),
              ),
            ),
            Text(
              'WAJIB DIPILIH',
              style: GoogleFonts.inter(
                color: _primary,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Pilih jenis surat sesuai kebutuhan administrasi kamu.',
          style: _body.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 12),
        ...List.generate(_types.length, (index) {
          final type = _types[index];
          final selected = _selectedType == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Material(
              color: selected ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                onTap: () => setState(() => _selectedType = index),
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: selected ? _primary : const Color(0xFFE5EAE7),
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: selected ? _primary : _surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          type.icon,
                          color: selected ? Colors.white : _muted,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.title,
                              style: GoogleFonts.inter(
                                color: _ink,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type.description,
                              style: GoogleFonts.inter(
                                color: _muted,
                                fontSize: 9,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 23,
                        height: 23,
                        decoration: BoxDecoration(
                          color: selected ? _primary : _surfaceHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: selected ? Colors.white : Colors.transparent,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Keperluan / Alasan Pengajuan',
                style: _heading.copyWith(fontSize: 13),
              ),
            ),
            Text(
              'Min. 10 Karakter',
              style: GoogleFonts.inter(fontSize: 9, color: _muted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _purposeController,
          minLines: 3,
          maxLines: 5,
          style: GoogleFonts.inter(fontSize: 12, color: _ink),
          decoration: InputDecoration(
            hintText:
                'Contoh: Untuk persyaratan administrasi seleksi rekrutmen...',
            hintStyle: GoogleFonts.inter(
              fontSize: 11,
              color: _muted,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xFFE5EAE7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _primary),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().length < 10) {
              return 'Keperluan minimal 10 karakter.';
            }
            return null;
          },
        ),
        const SizedBox(height: 19),
        Row(
          children: [
            Expanded(
              child: Text(
                'No. WhatsApp Aktif (Notifikasi Status)',
                style: _heading.copyWith(fontSize: 12),
              ),
            ),
            const Icon(Icons.chat_rounded, size: 14, color: _primary),
            const SizedBox(width: 3),
            Text(
              'Update Otomatis',
              style: GoogleFonts.inter(
                fontSize: 8,
                color: _primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.phone_iphone_rounded,
              color: _primary,
            ),
            hintText: '+62 8xx-xxxx-xxxx',
            hintStyle: GoogleFonts.inter(fontSize: 11),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xFFE5EAE7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _primary),
            ),
          ),
          validator: (value) {
            final phone = value?.trim() ?? '';
            if (phone.isEmpty || phone.length < 9) {
              return 'Masukkan nomor WhatsApp yang valid.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEEFF).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Color(0xFFCDE8FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_rounded,
              color: _tertiary,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verifikasi Cepat & Tanda Tangan Digital',
                  style: GoogleFonts.inter(
                    color: _tertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Proses verifikasi tanda tangan digital Pak RT '
                  'biasanya memerlukan waktu 1x24 jam kerja. '
                  'Surat resmi nantinya dapat diterbitkan dengan '
                  'QR Code untuk validasi instansi tujuan. '
                  'Informasi ini merupakan gambaran alur layanan, '
                  'belum terhubung dengan proses penerbitan server.',
                  style: GoogleFonts.inter(
                    color: _muted,
                    fontSize: 10,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 49,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryContainer,
                    disabledBackgroundColor: _primary.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Memproses Pengajuan...',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ajukan Surat Pengantar',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 9),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 19,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    color: _primary,
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Data Anda dilindungi dan digunakan untuk pengajuan surat',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LetterHistoryPage extends StatelessWidget {
  const LetterHistoryPage({
    super.key,
    required this.records,
  });

  final List<_LetterRecord> records;

  static const Color _green = Color(0xFF107C41);
  static const Color _ink = Color(0xFF17251C);
  static const Color _muted = Color(0xFF718078);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Riwayat Pengajuan E-Surat',
          style: GoogleFonts.plusJakartaSans(
            color: _ink,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: records.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 48,
                      color: _green,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Belum Ada Pengajuan',
                      style: GoogleFonts.plusJakartaSans(
                        color: _ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pengajuan surat yang kamu buat akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: _muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final record = records[index];

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LetterDetailPage(record: record),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Container(
                            width: 43,
                            height: 43,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8FFF0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: _green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.category,
                                  style: GoogleFonts.inter(
                                    color: _ink,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  record.id,
                                  style: GoogleFonts.inter(
                                    color: _muted,
                                    fontSize: 9,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  record.status,
                                  style: GoogleFonts.inter(
                                    color: _green,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: _muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class LetterDetailPage extends StatelessWidget {
  const LetterDetailPage({
    super.key,
    required this.record,
  });

  final _LetterRecord record;

  static const Color _green = Color(0xFF107C41);
  static const Color _ink = Color(0xFF17251C);
  static const Color _muted = Color(0xFF718078);

  @override
  Widget build(BuildContext context) {
    final date = '${record.date.day.toString().padLeft(2, '0')}/'
        '${record.date.month.toString().padLeft(2, '0')}/'
        '${record.date.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Detail Pengajuan',
          style: GoogleFonts.plusJakartaSans(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(17),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.description_rounded,
                  size: 36,
                  color: _green,
                ),
                const SizedBox(height: 14),
                Text(
                  record.category,
                  style: GoogleFonts.plusJakartaSans(
                    color: _ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  record.id,
                  style: GoogleFonts.inter(
                    color: _muted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FFF0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    record.status,
                    style: GoogleFonts.inter(
                      color: _green,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Divider(height: 28),
                _detailRow('Nama Pemohon', record.applicant),
                _detailRow('Tanggal Pengajuan', date),
                _detailRow('WhatsApp', record.phone),
                _detailRow('Keperluan', record.purpose),
              ],
            ),
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahapan Pengajuan',
                  style: GoogleFonts.plusJakartaSans(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 18),
                _timelineItem(
                  'Pengajuan Dibuat',
                  'Data pengajuan berhasil dicatat secara lokal.',
                  true,
                  false,
                ),
                _timelineItem(
                  'Verifikasi RT',
                  'Menunggu pemeriksaan pengurus RT.',
                  false,
                  false,
                ),
                _timelineItem(
                  'Tanda Tangan Digital',
                  'Menunggu proses verifikasi dan penerbitan.',
                  false,
                  true,
                ),
                const SizedBox(height: 10),
                Text(
                  'Ini merupakan simulasi status. Belum ada proses '
                  'verifikasi atau penerbitan surat melalui server.',
                  style: GoogleFonts.inter(
                    color: _muted,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: _muted,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: _ink,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(
    String title,
    String description,
    bool active,
    bool last,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: active ? _green : const Color(0xFFE8EEE9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    active ? Icons.check_rounded : Icons.more_horiz_rounded,
                    color: active ? Colors.white : _muted,
                    size: 13,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE0E9E2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: _ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      color: _muted,
                      fontSize: 9,
                      height: 1.4,
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

class _LetterType {
  const _LetterType({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class _LetterRecord {
  const _LetterRecord({
    required this.id,
    required this.applicant,
    required this.category,
    required this.purpose,
    required this.phone,
    required this.date,
    required this.status,
  });

  final String id;
  final String applicant;
  final String category;
  final String purpose;
  final String phone;
  final DateTime date;
  final String status;
}
