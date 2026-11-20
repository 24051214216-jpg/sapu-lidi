import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dispatch_status_page.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  static const Color _green = Color(0xFF107C41);
  static const Color _greenDark = Color(0xFF084C27);
  static const Color _red = Color(0xFFC62828);
  static const Color _background = Color(0xFFF4FBF6);
  static const Color _text = Color(0xFF17251C);
  static const Color _muted = Color(0xFF718078);

  Timer? _holdTimer;
  bool _isHolding = false;
  // ignore: unused_field
  bool _holdCompleted = false;
  int _remainingSeconds = 3;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHold() {
    if (_isHolding) return;

    _holdTimer?.cancel();

    setState(() {
      _isHolding = true;
      _holdCompleted = false;
      _remainingSeconds = 3;
    });

    _holdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();

        setState(() {
          _remainingSeconds = 0;
          _isHolding = false;
          _holdCompleted = true;
        });

        _showActivationConfirmation();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _cancelHold() {
    if (!_isHolding) return;

    _holdTimer?.cancel();

    setState(() {
      _isHolding = false;
      _holdCompleted = false;
      _remainingSeconds = 3;
    });
  }

  Future<void> _showActivationConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: _red,
            size: 42,
          ),
          title: Text(
            'Konfirmasi keadaan darurat',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Pastikan kamu benar-benar membutuhkan bantuan darurat. '
            'Aktivasi ini akan membuka simulasi status penanganan '
            'darurat di aplikasi.',
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.6,
              color: _muted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Tidak, kembali'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _red,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Ya, aktifkan SOS'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (confirmed == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DispatchStatusPage(),
        ),
      );
    } else {
      setState(() {
        _holdCompleted = false;
        _remainingSeconds = 3;
      });
    }
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Column(
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
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              height: 1.5,
              color: _muted,
            ),
          ),
        ],
      ],
    );
  }

  Widget _emergencyCategory({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFDFEEE4)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    height: 1.4,
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
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDFEEE4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _green, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 3),
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
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _greenDark),
        ),
        title: Text(
          'Tombol Siaga Darurat (SOS)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _greenDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(17, 17, 17, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              color: _greenDark,
              borderRadius: BorderRadius.circular(21),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: Color(0xFF9BE7B5),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SIAGA LINGKUNGAN 24 JAM',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: const Color(0xFFB9F2CC),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Text(
                  'Butuh bantuan segera?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Gunakan tombol darurat untuk membuka alur '
                  'pelaporan keadaan darurat lingkungan.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    height: 1.6,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 17),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFB9F2CC),
                        size: 18,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Tekan dan tahan tombol SOS selama 3 detik.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDFEEE4)),
            ),
            child: Column(
              children: [
                Text(
                  'TEKAN DAN TAHAN UNTUK SOS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 17),
                GestureDetector(
                  onLongPressStart: (_) => _startHold(),
                  onLongPressEnd: (_) => _cancelHold(),
                  child: Listener(
                    onPointerDown: (_) => _startHold(),
                    onPointerUp: (_) => _cancelHold(),
                    onPointerCancel: (_) => _cancelHold(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 154,
                      height: 154,
                      decoration: BoxDecoration(
                        color: _isHolding ? const Color(0xFF9D1717) : _red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _red.withValues(alpha: 0.20),
                            blurRadius: _isHolding ? 8 : 22,
                            spreadRadius: _isHolding ? 1 : 5,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFFFD8D8),
                          width: 5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.sos_rounded,
                            color: Colors.white,
                            size: 54,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _isHolding ? 'TAHAN $_remainingSeconds' : 'DARURAT',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isHolding
                      ? 'Tahan terus sampai hitungan selesai'
                      : 'Tekan dan tahan selama 3 detik',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _isHolding ? _red : _text,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Lepaskan tombol sebelum 3 detik untuk membatalkan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 19),
          _sectionTitle(
            'Pusat Bantuan Darurat',
            subtitle: 'Pilih kategori bantuan sesuai kondisi darurat.',
          ),
          const SizedBox(height: 11),
          _emergencyCategory(
            icon: Icons.security_rounded,
            title: 'Pos Ronda',
            description: 'Gangguan keamanan, pencurian, dan kamtibmas.',
            color: const Color(0xFF2676C9),
          ),
          const SizedBox(height: 9),
          _emergencyCategory(
            icon: Icons.local_fire_department_rounded,
            title: 'Damkar & Warga',
            description: 'Kebakaran, asap, kebocoran gas, dan sejenisnya.',
            color: _red,
          ),
          const SizedBox(height: 9),
          _emergencyCategory(
            icon: Icons.medical_services_rounded,
            title: 'Ambulans RW',
            description: 'Keadaan darurat medis dan kebutuhan ambulans.',
            color: const Color(0xFF168B68),
          ),
          const SizedBox(height: 9),
          _emergencyCategory(
            icon: Icons.flood_rounded,
            title: 'Tim Reaksi Bencana',
            description: 'Pohon roboh, kabel putus, dan genangan.',
            color: const Color(0xFFB7791F),
          ),
          const SizedBox(height: 20),
          _sectionTitle(
            'Kontak Penting Lingkungan',
            subtitle:
                'Daftar kontak referensi. Tombol panggilan belum diaktifkan.',
          ),
          const SizedBox(height: 11),
          _contactTile(
            icon: Icons.security_rounded,
            title: 'Pos Kamling RT',
            subtitle: 'Koordinator keamanan lingkungan',
          ),
          _contactTile(
            icon: Icons.local_hospital_rounded,
            title: 'Ambulans RW',
            subtitle: 'Layanan bantuan medis lingkungan',
          ),
          _contactTile(
            icon: Icons.local_police_rounded,
            title: 'Bhabinkamtibmas',
            subtitle: 'Petugas pembinaan keamanan masyarakat',
          ),
          _contactTile(
            icon: Icons.local_fire_department_rounded,
            title: 'Pos Pemadam Kebakaran',
            subtitle: 'Layanan penanganan kebakaran',
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF2D9AC)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFB7791F),
                  size: 20,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Jangan gunakan fitur darurat untuk uji coba tanpa '
                    'kebutuhan. Pada versi ini, aktivasi hanya simulasi '
                    'dan belum mengirim laporan kepada petugas.',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      height: 1.5,
                      color: const Color(0xFF79551D),
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
}
