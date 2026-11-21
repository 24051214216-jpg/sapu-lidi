import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.user,
    required this.onNavigate,
    required this.onSos,
    required this.onOpenBerita, // ✅ Tambahan parameter
  });

  final Map<String, dynamic> user;
  final ValueChanged<int> onNavigate;
  final VoidCallback onSos;
  final VoidCallback onOpenBerita; // ✅ Tambahan properti

  static const Color _green = Color(0xFF107C41);
  static const Color _greenDark = Color(0xFF084C27);
  static const Color _mint = Color(0xFFE8FFF0);
  static const Color _background = Color(0xFFF4FBF6);
  static const Color _text = Color(0xFF17251C);
  static const Color _muted = Color(0xFF718078);
  static const Color _border = Color(0xFFBDEFD2);

  String get _name {
    final value = user['nama']?.toString().trim();
    return value == null || value.isEmpty ? 'Warga SapuLidi' : value;
  }

  String get _initial => _name.isEmpty ? 'W' : _name[0].toUpperCase();

  String get _address {
    final block = user['blokRumah']?.toString().trim() ?? '';
    final number = user['noRumah']?.toString().trim() ?? '';

    final parts = <String>[
      if (block.isNotEmpty && block != '-') 'Blok $block',
      if (number.isNotEmpty && number != '-') 'No. $number',
    ];

    return parts.isEmpty ? 'Alamat belum tersedia' : parts.join(' • ');
  }

  String get _status {
    final value = user['status']?.toString().trim();
    return value == null || value.isEmpty ? 'Status belum tersedia' : value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 23),
                _buildGreeting(),
                const SizedBox(height: 20),
                _buildGotongRoyongBanner(context),
                const SizedBox(height: 14),
                _buildSosCard(),
                const SizedBox(height: 25),
                _buildFinanceCard(context),
                const SizedBox(height: 25),
                _buildAgendaCard(),
                const SizedBox(height: 25),
                _buildSectionTitle(
                  'Layanan Warga',
                  'Akses layanan lingkungan dengan mudah',
                  trailing: 'Lihat semua',
                  onTrailingTap: () => onNavigate(3),
                ),
                const SizedBox(height: 14),
                _buildServices(),
                const SizedBox(height: 25),
                _buildSectionTitle(
                  'Warta Terkini',
                  'Informasi terbaru lingkungan',
                  trailing: 'Lihat semua',
                  onTrailingTap: onOpenBerita, // ✅ Diubah ke onOpenBerita
                ),
                const SizedBox(height: 14),
                _buildNewsPreview(), // ✅ Diubah ke _buildNewsPreview
                const SizedBox(height: 23),
                _buildCommunitySlogan(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.home_work_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SAPULIDI',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: _greenDark,
                ),
              ),
              Text(
                'Beranda Warga',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: () => _showInfo(
            context,
            'Notifikasi',
            'Notifikasi warga belum tersedia.',
          ),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: _text,
            size: 25,
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          onTap: () => onNavigate(4),
          borderRadius: BorderRadius.circular(30),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: _mint,
            child: Text(
              _initial,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: _greenDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat datang,',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: _muted,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                _name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: _mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: _green,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _status.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: _greenDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 15,
              color: _green,
            ),
            const SizedBox(width: 4),
            Text(
              _address,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _muted,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.verified_rounded,
              color: _green,
              size: 13,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGotongRoyongBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_greenDark, _green, Color(0xFF36A765)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -5,
            bottom: -15,
            child: Icon(
              Icons.volunteer_activism_rounded,
              size: 112,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'SAPULIDI COMMUNITY',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bersama Membangun\nLingkungan yang Peduli',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Rukun warganya, nyaman lingkungannya.',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () => _showInfo(
                        context,
                        'Panduan Warga',
                        'Panduan penggunaan layanan SapuLidi '
                            'akan tersedia di bagian ini.',
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Panduan Warga',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _greenDark,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: _greenDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.cleaning_services_rounded,
                color: Color(0xFF96F7AF),
                size: 65,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSosCard() {
    return Material(
      color: const Color(0xFFFFF1EF),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onSos,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFD7D1)),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDEDA),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.sos_rounded,
                  color: Color(0xFFC62828),
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUTUH BANTUAN DARURAT?',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        color: const Color(0xFFB3261E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Akses bantuan darurat lingkungan',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF805C58),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC62828),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'SOS',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: _green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kas & Iuran Warga',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => onNavigate(1),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: _green,
                ),
                child: Text(
                  'Lihat',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAF3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.savings_outlined,
                  color: _green,
                  size: 25,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo Kas Lingkungan',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Belum tersedia',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _greenDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.lock_outline_rounded,
                  color: _green,
                  size: 17,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 19,
                color: _green,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Status Iuran Warga',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _text,
                  ),
                ),
              ),
              Text(
                'Belum tersedia',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: _muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => onNavigate(1),
              style: OutlinedButton.styleFrom(
                foregroundColor: _green,
                side: const BorderSide(color: _border),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: Text(
                'Buka Ringkasan Keuangan',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Agenda Wajib Warga',
          'Kegiatan dan jadwal lingkungan',
        ),
        const SizedBox(height: 13),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.event_available_outlined,
                color: _green,
                size: 31,
              ),
              const SizedBox(height: 9),
              Text(
                'Belum ada agenda',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Jadwal kegiatan dan informasi kehadiran '
                'akan ditampilkan di sini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  height: 1.5,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle, {
    String? trailing,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 4),
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
        if (trailing != null)
          TextButton(
            onPressed: onTrailingTap,
            style: TextButton.styleFrom(
              foregroundColor: _green,
              padding: const EdgeInsets.symmetric(horizontal: 3),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              trailing,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildServices() {
    final services = [
      _ServiceItem(
        icon: Icons.description_outlined,
        title: 'E-Surat',
        color: const Color(0xFFE8F3EB),
        onTap: () => onNavigate(3),
      ),
      _ServiceItem(
        icon: Icons.handyman_outlined,
        title: 'Pinjam Alat',
        color: const Color(0xFFFFF1E5),
        onTap: () => onNavigate(3),
      ),
      _ServiceItem(
        icon: Icons.person_search_outlined,
        title: 'Lapor Tamu',
        color: const Color(0xFFEAEFFF),
        onTap: () => onNavigate(3),
      ),
      _ServiceItem(
        icon: Icons.forum_outlined,
        title: 'Aspirasi',
        color: const Color(0xFFFFF4DC),
        onTap: () => onNavigate(3),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final item = services[index];

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFE5EEE8)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      item.icon,
                      color: _green,
                      size: 21,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ Method Baru: _buildNewsPreview() menggantikan _buildNewsEmpty()
  Widget _buildNewsPreview() {
    final news = [
      (
        category: 'PENGUMUMAN RT',
        title: 'Fogging Serentak & Pemeriksaan Jentik Nyamuk DBD',
        description:
            'Seluruh warga dimohon membuka ventilasi rumah saat kegiatan fogging berlangsung.',
        icon: Icons.campaign_rounded,
      ),
      (
        category: 'KEAMANAN',
        title: 'Penambahan Akses Kartu RFID Portal Masuk',
        description:
            'Setiap kepala keluarga berhak mendapatkan dua kartu akses gratis.',
        icon: Icons.security_rounded,
      ),
    ];

    return Column(
      children: [
        for (final item in news)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onOpenBerita,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5EEE8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: _mint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: _green,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.category,
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: _green,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                height: 1.4,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onOpenBerita,
            style: OutlinedButton.styleFrom(
              foregroundColor: _green,
              side: const BorderSide(color: _border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Lihat Semua Warta',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunitySlogan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 19,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FFF0),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.diversity_3_rounded,
            color: _green,
            size: 27,
          ),
          const SizedBox(height: 9),
          Text(
            'Rukun, Peduli, Terhubung',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _greenDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bersama warga, bangun lingkungan yang lebih baik.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 12,
            height: 1.5,
          ),
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
}

class _ServiceItem {
  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
}
