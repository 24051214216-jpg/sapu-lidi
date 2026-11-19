import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.user,
  });

  final Map<String, dynamic> user;

  static const Color _green = Color(0xFF006130);
  static const Color _text = Color(0xFF17251C);
  static const Color _muted = Color(0xFF718078);

  String get _name {
    final value = user['nama']?.toString().trim();
    return value == null || value.isEmpty ? 'Warga SapuLidi' : value;
  }

  String get _address {
    final block = user['blokRumah']?.toString() ?? '-';
    final number = user['noRumah']?.toString() ?? '-';

    return 'Blok $block • No. $number';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          const SizedBox(height: 22),
          _buildResidentCard(),
          const SizedBox(height: 26),
          _buildSectionTitle(
            'Layanan Warga',
            'Akses layanan lingkungan',
          ),
          const SizedBox(height: 14),
          _buildServices(),
          const SizedBox(height: 25),
          _buildInformationCard(),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat datang,',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _muted,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Senang melihatmu kembali di SapuLidi.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: _muted,
          ),
        ),
      ],
    );
  }

  Widget _buildResidentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF084C27),
            Color(0xFF107C41),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.home_work_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 9),
              Text(
                'PROFIL WARGA',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: const Color(0xFFD2F5D9),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'AKTIF',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            _name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _address,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFFD2F5D9),
                size: 16,
              ),
              const SizedBox(width: 7),
              Text(
                'Akun warga telah aktif',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: _muted,
          ),
        ),
      ],
    );
  }

  Widget _buildServices() {
    const services = [
      _ServiceItem(
        icon: Icons.receipt_long_rounded,
        title: 'Iuran Warga',
        subtitle: 'Informasi iuran',
      ),
      _ServiceItem(
        icon: Icons.description_rounded,
        title: 'Surat Warga',
        subtitle: 'Pengajuan surat',
      ),
      _ServiceItem(
        icon: Icons.event_rounded,
        title: 'Agenda',
        subtitle: 'Kegiatan lingkungan',
      ),
      _ServiceItem(
        icon: Icons.campaign_rounded,
        title: 'Pengumuman',
        subtitle: 'Info lingkungan',
      ),
      _ServiceItem(
        icon: Icons.inventory_2_rounded,
        title: 'Inventaris',
        subtitle: 'Barang bersama',
      ),
      _ServiceItem(
        icon: Icons.emergency_rounded,
        title: 'Darurat',
        subtitle: 'Bantuan warga',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final item = services[index];

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE8EEE9),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5ED),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  item.icon,
                  color: _green,
                  size: 21,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: GoogleFonts.inter(
                  fontSize: 8,
                  color: _muted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD9EBDD),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: _green,
            size: 20,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'Selamat bergabung di SapuLidi. '
              'Gunakan aplikasi ini untuk mendapatkan informasi '
              'dan mengakses layanan lingkungan tempat tinggalmu.',
              style: GoogleFonts.inter(
                fontSize: 11,
                height: 1.6,
                color: const Color(0xFF315C40),
              ),
            ),
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
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
