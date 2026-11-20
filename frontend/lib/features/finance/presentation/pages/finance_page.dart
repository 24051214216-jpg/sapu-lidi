import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({
    super.key,
    required this.user,
  });

  final Map<String, dynamic> user;

  static const Color _green = Color(0xFF006130);
  static const Color _greenLight = Color(0xFF107C41);
  static const Color _background = Color(0xFFFAF8FF);
  static const Color _text = Color(0xFF131B2E);
  static const Color _muted = Color(0xFF667085);
  static const Color _line = Color(0xFFE7EAF2);
  static const Color _softGreen = Color(0xFFE8F8ED);
  static const Color _softBlue = Color(0xFFEAF3FF);

  String _userValue(String key) {
    final value = user[key]?.toString().trim();

    if (value == null || value.isEmpty) {
      return '';
    }

    return value;
  }

  String get _residentName {
    return _userValue('nama').isEmpty ? 'Warga SapuLidi' : _userValue('nama');
  }

  String get _residentAddress {
    final parts = <String>[];

    final blok = _userValue('blokRumah');
    final rumah = _userValue('noRumah');
    final rt = _userValue('rt');
    final rw = _userValue('rw');

    if (blok.isNotEmpty) {
      parts.add('Blok $blok');
    }

    if (rumah.isNotEmpty) {
      parts.add('No. $rumah');
    }

    if (rt.isNotEmpty) {
      parts.add('RT $rt');
    }

    if (rw.isNotEmpty) {
      parts.add('RW $rw');
    }

    return parts.isEmpty ? 'Data alamat belum tersedia' : parts.join(' • ');
  }

  String get _communityLabel {
    final rt = _userValue('rt');
    final rw = _userValue('rw');

    if (rt.isEmpty && rw.isEmpty) {
      return 'GOTONG ROYONG WARGA';
    }

    final parts = <String>[];

    if (rt.isNotEmpty) {
      parts.add('RT $rt');
    }

    if (rw.isNotEmpty) {
      parts.add('RW $rw');
    }

    return 'GOTONG ROYONG ${parts.join(' / ')}';
  }

  void _showUnavailableDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.info_outline_rounded,
            color: _green,
            size: 35,
          ),
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.6,
              color: _muted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  BoxDecoration _cardDecoration({
    double radius = 22,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: _line.withValues(alpha: 0.75)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF17251C).withValues(alpha: 0.055),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  TextStyle get _sectionTitle => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: _text,
      );

  TextStyle get _bodyStyle => GoogleFonts.inter(
        fontSize: 11,
        height: 1.5,
        color: _muted,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(13, 14, 13, 28),
        children: [
          _buildCommunityCard(),
          const SizedBox(height: 15),
          _buildBillCard(context),
          const SizedBox(height: 15),
          _buildCashTransparencyCard(context),
          const SizedBox(height: 17),
          _buildPaymentHistory(),
          const SizedBox(height: 17),
          _buildHelpCard(context),
        ],
      ),
    );
  }

  // ============================================================
  // KARTU INFORMASI WARGA
  // ============================================================

  Widget _buildCommunityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF006130),
            Color(0xFF107C41),
            Color(0xFF26975B),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF96F7AF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _communityLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: const Color(0xFFB6FFC5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Iuran Tepat Waktu, Warga Tenang',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Warga: $_residentName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFFD9FBE3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _residentAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: const Color(0xFFD9FBE3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 67,
            height: 67,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAGIHAN DAN RINCIAN IURAN
  // ============================================================

  Widget _buildBillCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(radius: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 19,
                color: _muted,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Periode Tagihan',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Belum tersedia',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(
                label: 'Belum tersedia',
                color: const Color(0xFFFFF3DB),
                textColor: const Color(0xFF966000),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Total kewajiban.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total Kewajiban Iuran',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: _muted,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Jatuh Tempo: Belum ditentukan',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: _green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  'Belum tersedia',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Nominal tagihan akan ditampilkan setelah data tersedia.',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Rincian iuran.
          Text(
            'Rincian Iuran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 9),
          _emptyInformation(
            icon: Icons.receipt_long_outlined,
            title: 'Rincian iuran belum tersedia',
            description:
                'Informasi jenis iuran dan nominalnya akan ditampilkan di sini.',
          ),
          const SizedBox(height: 14),

          // Rekening resmi.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2FF),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFE1E6F5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_rounded,
                      color: _green,
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Rekening Resmi Kas RT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _text,
                        ),
                      ),
                    ),
                    _statusChip(
                      label: 'Belum tersedia',
                      color: const Color(0xFFE1E9F2),
                      textColor: _muted,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: _muted,
                        size: 18,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi rekening',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: _muted,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Belum tersedia',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _text,
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
          ),
          const SizedBox(height: 13),

          // Tombol unggah bukti transfer.
          SizedBox(
            width: double.infinity,
            height: 43,
            child: FilledButton.icon(
              onPressed: () {
                _showUnavailableDialog(
                  context,
                  title: 'Unggah Bukti Transfer',
                  message: 'Fitur unggah bukti transfer belum tersedia. '
                      'Fitur ini akan diaktifkan setelah layanan '
                      'keuangan terhubung.',
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(
                Icons.upload_file_rounded,
                size: 17,
              ),
              label: Text(
                'Upload Bukti Transfer Manual',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSPARANSI KAS RT
  // ============================================================

  Widget _buildCashTransparencyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: _softBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Color(0xFF2678B9),
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transparansi Kas RT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Ringkasan pemasukan dan pengeluaran lingkungan',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(
                label: 'Belum tersedia',
                color: const Color(0xFFEAF3FF),
                textColor: const Color(0xFF2678B9),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _cashMetric(
                  icon: Icons.south_rounded,
                  label: 'Masuk',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _cashMetric(
                  icon: Icons.north_rounded,
                  label: 'Keluar',
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),

          // Ringkasan kas tanpa angka rekaan.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: _green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Kas Lingkungan',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Data pemasukan dan pengeluaran belum tersedia.',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          height: 1.4,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: () {
                _showUnavailableDialog(
                  context,
                  title: 'Laporan Kas RT',
                  message: 'Unduhan PDF laporan kas belum tersedia '
                      'karena data keuangan belum terhubung.',
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _green,
                backgroundColor: const Color(0xFFF7F8FF),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.download_for_offline_outlined,
                size: 17,
              ),
              label: Text(
                'Unduh PDF Laporan Kas RT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cashMetric({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2FF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 15,
                color: _green,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: _muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Belum tersedia',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RIWAYAT PEMBAYARAN
  // ============================================================

  Widget _buildPaymentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Riwayat Pembayaran',
                  style: _sectionTitle,
                ),
              ),
              Text(
                'Belum tersedia',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: _green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: _cardDecoration(radius: 18),
          child: _emptyInformation(
            icon: Icons.receipt_long_outlined,
            title: 'Riwayat pembayaran belum tersedia',
            description: 'Riwayat pembayaran iuran warga akan ditampilkan '
                'setelah data transaksi tersedia.',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BANTUAN BENDAHARA RT
  // ============================================================

  Widget _buildHelpCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUTUH BANTUAN?',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: const Color(0xFF2678B9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hubungi Bendahara RT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Konsultasikan kendala pembayaran atau informasi '
                  'iuran lingkungan.',
                  style: _bodyStyle,
                ),
                const SizedBox(height: 11),
                OutlinedButton.icon(
                  onPressed: () {
                    _showUnavailableDialog(
                      context,
                      title: 'Kontak Bendahara RT',
                      message: 'Informasi kontak bendahara RT belum tersedia. '
                          'Silakan hubungi pengurus RT secara langsung '
                          'untuk sementara.',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _text,
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(
                    Icons.chat_outlined,
                    size: 15,
                    color: _green,
                  ),
                  label: Text(
                    'Chat Bendahara',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 62,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: _green,
              size: 39,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KOMPONEN BANTU
  // ============================================================

  Widget _statusChip({
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  Widget _emptyInformation({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _line,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: const BoxDecoration(
              color: _softGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _greenLight,
              size: 20,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              height: 1.5,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }
}
