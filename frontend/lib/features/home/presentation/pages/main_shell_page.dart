import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../../../finance/presentation/pages/finance_page.dart';
import '../../../inventory/presentation/pages/inventory_catalog_page.dart';
import '../../../e_letter/presentation/pages/letter_request_page.dart';
import '../../../guest_book/presentation/pages/guest_book_page.dart';
import '../../../aspiration/presentation/pages/aspirasi_page.dart';
import '../../../news/presentation/pages/berita_page.dart';
import 'home_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  static const Color _green = Color(0xFF107C41);
  static const Color _greenDark = Color(0xFF084C27);
  static const Color _background = Color(0xFFF4FBF6);
  static const Color _text = Color(0xFF17251C);
  static const Color _muted = Color(0xFF718078);

  final SecureStorage _storage = SecureStorage();

  int _selectedIndex = 0;
  Map<String, dynamic> _user = <String, dynamic>{};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _storage.getUser();

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Keluar dari akun?',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Kamu perlu login kembali untuk mengakses layanan warga.',
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _green,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _storage.deleteSession();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const OnboardingPage(),
      ),
      (route) => false,
    );
  }

  void _navigateTo(int index) {
    if (index < 0 || index > 4) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  void _openESurat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LetterRequestPage(user: _user),
      ),
    );
  }

  void _openGuestBook() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuestBookPage(user: _user),
      ),
    );
  }

  void _openAspirasi() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AspirasiPage(
          onSos: _showSosDialog,
          onNavigateRoot: (index) {
            Navigator.pop(context);
            _navigateTo(index);
          },
        ),
      ),
    );
  }

  void _openBerita() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BeritaPage(),
      ),
    );
  }

  // ✅ Tambahan: Fungsi navigasi untuk membuka katalog inventaris dari Layanan
  void _openInventory() {
    _navigateTo(2);
  }

  void _showSosDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.sos_rounded,
          size: 38,
          color: Color(0xFFC62828),
        ),
        title: Text(
          'Bantuan Darurat',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Fitur kontak darurat lingkungan belum terhubung. '
          'Jika terjadi keadaan darurat, segera hubungi layanan '
          'darurat resmi yang sesuai dengan kondisi kamu.',
          style: GoogleFonts.inter(
            fontSize: 12,
            height: 1.6,
            color: _muted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String get _pageTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Beranda Warga';
      case 1:
        return 'Keuangan Warga';
      case 2:
        return 'Inventaris Warga';
      case 3:
        return 'Layanan Warga';
      case 4:
        return 'Profil Warga';
      default:
        return 'SapuLidi';
    }
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return HomePage(
          user: _user,
          onNavigate: _navigateTo,
          onSos: _showSosDialog,
          onOpenBerita: _openBerita, // ✅ Tambahan onOpenBerita
        );

      case 1:
        return FinancePage(user: _user);

      case 2:
        return const InventoryCatalogPage();

      case 3:
        return _ServicesPage(
          onOpenESurat: _openESurat,
          onOpenGuestBook: _openGuestBook,
          onOpenAspirasi: _openAspirasi,
          onOpenInventory: _openInventory, // ✅ Tambahan onOpenInventory
        );

      case 4:
        return _buildProfile();

      default:
        return HomePage(
          user: _user,
          onNavigate: _navigateTo,
          onSos: _showSosDialog,
          onOpenBerita: _openBerita, // ✅ Tambahan onOpenBerita di default
        );
    }
  }

  Widget _buildPageHeader() {
    if (_selectedIndex == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: const Color(0xFFE8FFF0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.home_work_rounded,
              color: _green,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              _pageTitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _greenDark,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Keluar',
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: _green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    final nama = _user['nama']?.toString().trim().isNotEmpty == true
        ? _user['nama'].toString()
        : 'Warga SapuLidi';

    final noHp = _user['noHp']?.toString() ?? '-';
    final blok = _user['blokRumah']?.toString() ?? '-';
    final rumah = _user['noRumah']?.toString() ?? '-';
    final status = _user['status']?.toString() ?? '-';
    final role = _user['role']?.toString() ?? '-';

    final initial = nama.isEmpty ? 'W' : nama[0].toUpperCase();

    return Container(
      color: _background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(17, 25, 17, 30),
        children: [
          Center(
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFE8FFF0),
                borderRadius: BorderRadius.circular(27),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: _green,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            nama,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Profil Warga SapuLidi',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: _muted,
            ),
          ),
          const SizedBox(height: 25),
          _profileItem(
            Icons.phone_android_rounded,
            'Nomor WhatsApp',
            noHp,
          ),
          _profileItem(
            Icons.location_on_outlined,
            'Blok Rumah',
            blok,
          ),
          _profileItem(
            Icons.home_outlined,
            'Nomor Rumah',
            rumah,
          ),
          _profileItem(
            Icons.verified_user_outlined,
            'Status Akun',
            status,
          ),
          _profileItem(
            Icons.badge_outlined,
            'Role',
            role,
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Keluar dari Akun'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Color(0xFFE9B7B7)),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFDFEEE4),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: _green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _muted,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final selected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _navigateTo(index),
        child: SizedBox(
          height: 65,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 22,
                color: selected ? _green : _muted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? _green : _muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 67,
          child: Row(
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Beranda',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.account_balance_wallet_outlined,
                selectedIcon: Icons.account_balance_wallet_rounded,
                label: 'Keuangan',
                index: 1,
              ),
              Expanded(
                child: InkWell(
                  onTap: _showSosDialog,
                  child: SizedBox(
                    height: 67,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC62828),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC62828)
                                    .withValues(alpha: 0.22),
                                blurRadius: 9,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.sos_rounded,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildNavItem(
                icon: Icons.inventory_2_outlined,
                selectedIcon: Icons.inventory_2_rounded,
                label: 'Inventaris',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.grid_view_rounded,
                selectedIcon: Icons.grid_view_rounded,
                label: 'Layanan',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(
          child: CircularProgressIndicator(color: _green),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildPageHeader(),
            Expanded(child: _buildCurrentPage()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}

// ✅ _ServicesPage diganti dengan kode baru Anda
class _ServicesPage extends StatelessWidget {
  const _ServicesPage({
    required this.onOpenESurat,
    required this.onOpenGuestBook,
    required this.onOpenAspirasi,
    required this.onOpenInventory,
  });

  final VoidCallback onOpenESurat;
  final VoidCallback onOpenGuestBook;
  final VoidCallback onOpenAspirasi;
  final VoidCallback onOpenInventory;

  static const Color _green = Color(0xFF107C41);
  static const Color _text = Color(0xFF17251C);
  static const Color _muted = Color(0xFF718078);

  @override
  Widget build(BuildContext context) {
    final services = [
      (
        icon: Icons.description_outlined,
        title: 'E-Surat',
        description: 'Pengajuan surat administrasi warga.',
        onTap: onOpenESurat,
      ),
      (
        icon: Icons.handyman_outlined,
        title: 'Pinjam Alat',
        description: 'Informasi peminjaman barang bersama.',
        onTap: onOpenInventory,
      ),
      (
        icon: Icons.person_search_outlined,
        title: 'Lapor Tamu',
        description: 'Pelaporan informasi tamu lingkungan.',
        onTap: onOpenGuestBook,
      ),
      (
        icon: Icons.forum_outlined,
        title: 'Aspirasi',
        description: 'Sampaikan saran dan masukan warga.',
        onTap: onOpenAspirasi,
      ),
    ];

    return Container(
      color: const Color(0xFFF4FBF6),
      child: ListView(
        padding: const EdgeInsets.all(17),
        children: [
          Text(
            'Semua layanan warga dalam satu tempat.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: _muted,
            ),
          ),
          const SizedBox(height: 17),
          for (final service in services)
            Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: service.onTap,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFDFEEE4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8FFF0),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            service.icon,
                            color: _green,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.description,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: _muted,
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
              ),
            ),
          const SizedBox(height: 5),
          Text(
            'Informasi',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _muted,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Pilih layanan yang ingin kamu gunakan.',
            style: GoogleFonts.inter(
              fontSize: 10,
              height: 1.5,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }
}
