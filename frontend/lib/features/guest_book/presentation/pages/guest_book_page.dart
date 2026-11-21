import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class GuestBookPage extends StatefulWidget {
  const GuestBookPage({
    super.key,
    required this.user,
  });

  final Map<String, dynamic> user;

  @override
  State<GuestBookPage> createState() => _GuestBookPageState();
}

class _GuestBookPageState extends State<GuestBookPage> {
  static const Color _green = Color(0xFF107C41);
  static const Color _greenDark = Color(0xFF084C27);
  static const Color _mint = Color(0xFFE8FFF0);
  static const Color _border = Color(0xFFBDEFD2);
  static const Color _background = Color(0xFFF4FBF6);
  static const Color _text = Color(0xFF17251C);
  static const Color _muted = Color(0xFF718078);

  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _waController = TextEditingController();
  final _platController = TextEditingController();

  String _hubungan = 'Keluarga / Kerabat Kandung';
  DateTime _tanggalMulai = DateTime.now();
  DateTime _tanggalSelesai = DateTime.now().add(
    const Duration(days: 3),
  );

  bool _setuju = true;
  bool _showForm = true;
  bool _showSecurityNotice = true;
  bool _hasSubmitted = false;

  final List<Map<String, String>> _activeGuests = [
    {
      'nama': 'Dimas Kurniawan',
      'hubungan': 'Kerabat Kandung',
      'tuanRumah': 'Bambang Wijaya (B3/12)',
      'plat': 'B 4821 KDF',
      'periode': '17 Nov – 20 Nov 2024',
      'status': 'AKTIF MENGINAP (HARI KE-2)',
    },
    {
      'nama': 'Rizky Ramadhan',
      'hubungan': 'Teman / Kolega',
      'tuanRumah': 'Hendro Sukarno (A2/05)',
      'plat': 'D 1902 ABX',
      'periode': '18 Nov – 19 Nov 2024',
      'status': 'AKTIF MENGINAP (HARI KE-1)',
    },
  ];

  String get _namaWarga {
    final value = widget.user['nama']?.toString().trim();
    return value == null || value.isEmpty ? 'Warga SapuLidi' : value;
  }

  String get _alamatWarga {
    final blok = widget.user['blokRumah']?.toString() ?? '-';
    final nomor = widget.user['noRumah']?.toString() ?? '-';
    return 'Blok $blok No. $nomor';
  }

  int get _durasi {
    final start = DateTime(
      _tanggalMulai.year,
      _tanggalMulai.month,
      _tanggalMulai.day,
    );
    final end = DateTime(
      _tanggalSelesai.year,
      _tanggalSelesai.month,
      _tanggalSelesai.day,
    );

    final days = end.difference(start).inDays;
    return days > 0 ? days : 1;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateRange() {
    return '${_formatDate(_tanggalMulai)} – ${_formatDate(_tanggalSelesai)}';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _waController.dispose();
    _platController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initial = isStart ? _tanggalMulai : _tanggalSelesai;

    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isStart ? DateTime(2020) : _tanggalMulai,
      lastDate: DateTime(2100),
      helpText: isStart ? 'Pilih tanggal mulai' : 'Pilih rencana selesai',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      if (isStart) {
        _tanggalMulai = selected;

        if (!_tanggalSelesai.isAfter(selected)) {
          _tanggalSelesai = selected.add(const Duration(days: 1));
        }
      } else {
        _tanggalSelesai = selected;
      }

      _showSecurityNotice = _durasi > 2;
    });
  }

  void _showInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            _iconBox(Icons.gavel_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Peraturan Tamu Lingkungan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '• Tamu yang berkunjung lebih dari 1x24 jam wajib dilaporkan oleh tuan rumah kepada Pengurus RT.\n\n'
          '• Kendaraan tamu yang diparkir di tepi jalan umum perumahan harus mencantumkan nomor plat aktif.\n\n'
          '• Data identitas yang dicatat digunakan sebagai simulasi pendataan keamanan lingkungan pada tahap ini.',
          style: GoogleFonts.inter(
            fontSize: 12,
            height: 1.7,
            color: _muted,
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _green,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Saya Mengerti'),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: _mint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Icon(icon, color: _green, size: 20),
    );
  }

  void _openIdentityInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Foto KTP / Identitas',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Pemilihan dan pengunggahan foto identitas belum diaktifkan. '
          'Fitur ini akan dihubungkan pada tahap integrasi berikutnya.',
          style: GoogleFonts.inter(
            fontSize: 12,
            height: 1.6,
            color: _muted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_setuju) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamu harus menyetujui pernyataan tanggung jawab.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_tanggalSelesai.isAfter(_tanggalMulai)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal selesai harus setelah tanggal mulai.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _showConfirmation();
  }

  void _showConfirmation() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            22,
            12,
            22,
            22 + MediaQuery.of(sheetContext).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5DDD8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _iconBox(Icons.verified_user_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Konfirmasi Pelaporan Tamu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _text,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Periksa kembali data sebelum dicatat',
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
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9F8),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: const Color(0xFFE4EBE6)),
                  ),
                  child: Column(
                    children: [
                      _summaryRow('NAMA TAMU', _namaController.text.trim()),
                      _summaryRow('NIK KTP', _nikController.text.trim()),
                      _summaryRow('HUBUNGAN', _hubungan),
                      _summaryRow('DURASI', '$_durasi Hari Menginap'),
                      _summaryRow('PERIODE', _formatDateRange()),
                      _summaryRow(
                        'PLAT NOMOR',
                        _platController.text.trim().isEmpty
                            ? '-'
                            : _platController.text.trim().toUpperCase(),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8EF),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: _green,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ini merupakan simulasi pencatatan lokal. Belum ada pengiriman ke Pos Keamanan atau RT.',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                            color: _greenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 17),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _completeLocalSubmission();
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      'Konfirmasi & Catat Laporan',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: Text(
                      'Periksa Kembali',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _muted,
              ),
            ),
          ),
          const Text(':  ', style: TextStyle(color: _muted)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeLocalSubmission() {
    final ticket =
        'TAMU-RT05-${DateTime.now().millisecondsSinceEpoch % 9000 + 1000}';

    setState(() {
      _activeGuests.insert(0, {
        'nama': _namaController.text.trim(),
        'hubungan': _hubungan,
        'tuanRumah': '$_namaWarga (${_alamatWarga})',
        'plat': _platController.text.trim().isEmpty
            ? '-'
            : _platController.text.trim().toUpperCase(),
        'periode': _formatDateRange(),
        'status': 'SIMULASI LAPORAN BARU',
      });

      _hasSubmitted = true;
      _showForm = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Laporan simulasi berhasil dicatat. Tiket #$ticket',
        ),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 13),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0x40BDEFD2)),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: _mint,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                width: 39,
                height: 39,
                child: Icon(Icons.arrow_back_rounded, color: _green),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buku Tamu & Lapor Tamu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'LAYANAN WARGA RT',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: _green,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Informasi aturan',
            onPressed: _showInfoDialog,
            icon: const Icon(
              Icons.info_outline_rounded,
              color: _muted,
            ),
          ),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8EF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: _green,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_greenDark, _green, Color(0xFF0D6B38)],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.16),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  'ATURAN 1X24 JAM',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                '• Pos Siaga',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC8F5D5),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFFC8F5D5),
                size: 19,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Wajib Lapor Tamu Menginap',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Tamu yang menginap lebih dari 24 jam wajib didaftarkan demi keamanan lingkungan.',
            style: GoogleFonts.inter(
              fontSize: 10,
              height: 1.6,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE4F8EA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8E3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              label: 'Form Lapor Tamu',
              icon: Icons.edit_note_rounded,
              selected: _showForm,
              onTap: () => setState(() => _showForm = true),
            ),
          ),
          Expanded(
            child: _tabButton(
              label: 'Daftar Tamu Aktif',
              icon: Icons.groups_rounded,
              selected: !_showForm,
              count: _activeGuests.length,
              onTap: () => setState(() => _showForm = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    int? count,
  }) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: selected ? Border.all(color: _border) : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? _green : _muted,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? _green : _muted,
                  ),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplicantCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          _iconBox(Icons.home_rounded),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tuan Rumah / Pelapor',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_namaWarga • $_alamatWarga',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _mint,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: Text(
              'Warga Tetap',
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: _green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                size: 17,
                color: _green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: _text,
                  ),
                ),
              ),
              Text(
                '* Wajib Diisi',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: _muted,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 10,
        color: const Color(0xFFA0AAA4),
      ),
      prefixIcon: prefix,
      filled: true,
      fillColor: const Color(0xFFF7F9F8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE1E7E3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE1E7E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _green, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.4),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required: required),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _text,
          ),
          decoration: _inputDecoration(hint: hint).copyWith(
            helperText: helperText,
            helperStyle: GoogleFonts.inter(
              fontSize: 9,
              color: _muted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Hubungan / Kategori Tamu', required: true),
        DropdownButtonFormField<String>(
          value: _hubungan,
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: _muted,
          ),
          decoration: _inputDecoration(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _text,
          ),
          items: const [
            'Keluarga / Kerabat Kandung',
            'Teman / Rekan Kerja',
            'Pekerja / Tukang Bangunan',
            'Tamu Bisnis / Kedinasan',
            'Lainnya',
          ].map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _hubungan = value);
            }
          },
        ),
      ],
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE1E7E3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 14,
                    color: _green,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      _formatDate(date),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
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

  Widget _buildStayPeriod() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE1E7E3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Periode Menginap',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_durasi Hari',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _dateTile(
                label: 'Tanggal Mulai',
                date: _tanggalMulai,
                onTap: () => _selectDate(isStart: true),
              ),
              const SizedBox(width: 9),
              _dateTile(
                label: 'Rencana Selesai',
                date: _tanggalSelesai,
                onTap: () => _selectDate(isStart: false),
              ),
            ],
          ),
          if (_showSecurityNotice) ...[
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC9DDF8)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_alert_rounded,
                    size: 16,
                    color: Color(0xFF2463A5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Menginap lebih dari 2 hari: laporan perlu mendapat perhatian Pos Keamanan.',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF24527F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIdentityUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _fieldLabel('Foto KTP / Identitas Tamu'),
            ),
            const Icon(Icons.lock_outline_rounded, size: 12, color: _green),
            const SizedBox(width: 3),
            Text(
              'Privasi Data',
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: _green,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: _openIdentityInfo,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FBF4),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _border,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                _iconBox(Icons.description_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum ada foto identitas',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Fitur unggah akan tersedia pada tahap berikutnya',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Pilih',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsibilityCheckbox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _setuju = !_setuju),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _setuju ? const Color(0xFFE1E7E3) : Colors.red.shade300,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _setuju,
                    activeColor: _green,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (value) {
                      setState(() => _setuju = value ?? false);
                    },
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Saya menyatakan data tamu akurat dan bertanggung jawab penuh atas ketertiban lingkungan selama masa kunjungan.',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      height: 1.55,
                      fontWeight: FontWeight.w600,
                      color: _text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!_setuju)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              'Persetujuan wajib diberikan sebelum laporan dicatat.',
              style: GoogleFonts.inter(
                fontSize: 9,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildApplicantCard(),
          _sectionCard(
            title: 'Identitas & Keperluan Tamu',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  label: 'Nama Lengkap Tamu',
                  controller: _namaController,
                  hint: 'Masukkan nama lengkap sesuai identitas',
                  required: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama lengkap tamu wajib diisi.';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama minimal 3 karakter.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'NIK KTP Tamu',
                        controller: _nikController,
                        hint: '16 digit NIK',
                        required: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'NIK wajib diisi.';
                          }
                          if (value.trim().length != 16) {
                            return 'NIK harus 16 digit.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        label: 'No. WhatsApp',
                        controller: _waController,
                        hint: '08xxxxxxxxxx',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildRelationshipField(),
                const SizedBox(height: 16),
                _buildStayPeriod(),
                const SizedBox(height: 16),
                _buildIdentityUpload(),
                const SizedBox(height: 15),
                _buildTextField(
                  label: 'Plat Nomor Kendaraan Tamu (Opsional)',
                  controller: _platController,
                  hint: 'Contoh: B 1234 XYZ',
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(12),
                    UpperCaseTextFormatter(),
                  ],
                ),
                const SizedBox(height: 15),
                _buildResponsibilityCheckbox(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: _green,
                  size: 18,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Data pelaporan akan ditampilkan sebagai simulasi pencatatan pada perangkat ini.',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: _text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGuests() {
    if (_activeGuests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.groups_outlined,
              size: 38,
              color: _muted,
            ),
            const SizedBox(height: 10),
            Text(
              'Belum ada data tamu aktif',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final guest in _activeGuests) ...[
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: guest['status'] == 'SIMULASI LAPORAN BARU'
                                  ? const Color(0xFFFFF4DF)
                                  : const Color(0xFFEAF8EF),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color:
                                    guest['status'] == 'SIMULASI LAPORAN BARU'
                                        ? const Color(0xFFF0D9A9)
                                        : _border,
                              ),
                            ),
                            child: Text(
                              guest['status'] ?? 'AKTIF',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color:
                                    guest['status'] == 'SIMULASI LAPORAN BARU'
                                        ? const Color(0xFF96610D)
                                        : _green,
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            guest['nama'] ?? '-',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: _text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${guest['hubungan']} • ${guest['tuanRumah']}',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        guest['plat'] ?? '-',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: _text,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 11),
                  child: Divider(height: 1, color: Color(0xFFEDF0EE)),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        guest['periode'] ?? '-',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _muted,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.verified_rounded,
                      size: 13,
                      color: _green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      guest['status'] == 'SIMULASI LAPORAN BARU'
                          ? 'Simulasi lokal'
                          : 'Data contoh',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: _green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
        ],
      ],
    );
  }

  Widget _buildBottomAction() {
    if (!_showForm) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0x40BDEFD2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: _submitForm,
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.send_rounded, size: 17),
            label: Text(
              'Kirim Laporan ke Pos Keamanan & RT',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                children: [
                  _buildRuleBanner(),
                  const SizedBox(height: 15),
                  _buildTabs(),
                  const SizedBox(height: 15),
                  if (_showForm) _buildFormContent() else _buildActiveGuests(),
                  if (_hasSubmitted && !_showForm) ...[
                    const SizedBox(height: 5),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _showForm = true),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Buat Laporan Tamu Baru'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _green,
                        side: const BorderSide(color: _border),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
