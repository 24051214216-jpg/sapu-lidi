import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DispatchStatusPage extends StatefulWidget {
  const DispatchStatusPage({super.key});

  @override
  State<DispatchStatusPage> createState() => _DispatchStatusPageState();
}

class _DispatchStatusPageState extends State<DispatchStatusPage> {
  static const Color _green = Color(0xFF107C41);
  static const Color _greenDark = Color(0xFF084C27);
  static const Color _background = Color(0xFFF4FBF6);
  static const Color _text = Color(0xFF17251C);
  static const Color _muted = Color(0xFF718078);
  static const Color _red = Color(0xFFC62828);

  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      _showInfo('Tulis pesan terlebih dahulu.');
      return;
    }

    setState(() {
      _messages.insert(0, message);
      _messageController.clear();
    });

    _showInfo('Pesan ditambahkan pada simulasi lokal.');
  }

  Future<void> _cancelEmergency() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: _red,
            size: 40,
          ),
          title: Text(
            'Batalkan keadaan darurat?',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Apakah kamu yakin ingin menutup simulasi status darurat ini?',
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.5,
              color: _muted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Kembali ke Pemantauan'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _red,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Ya, Batalkan Darurat'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    Navigator.of(context).pop();
  }

  Widget _sectionCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(15),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFDFEEE4)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, {String? trailing}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _green,
            ),
          ),
      ],
    );
  }

  Widget _timelineItem({
    required String time,
    required String title,
    required String description,
    required bool completed,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    color: completed ? _green : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: completed ? _green : const Color(0xFFD6E0D9),
                      width: 2,
                    ),
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check,
                          size: 11,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFDCE9E0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _text,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      height: 1.5,
                      color: _muted,
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

  Widget _mapPlaceholder() {
    return Container(
      height: 175,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1E9),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),
          Positioned(
            left: 22,
            top: 22,
            child: _mapLabel(
              icon: Icons.location_on_rounded,
              label: 'Lokasi darurat',
              color: _red,
            ),
          ),
          Positioned(
            right: 18,
            bottom: 22,
            child: _mapLabel(
              icon: Icons.security_rounded,
              label: 'Pos Satpam',
              color: _green,
            ),
          ),
          const Center(
            child: Icon(
              Icons.route_rounded,
              size: 62,
              color: Color(0xFF80A98C),
            ),
          ),
          Positioned(
            left: 13,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ilustrasi peta • bukan lokasi GPS',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  color: _muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapLabel({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _unitCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Petugas yang merespons'),
          const SizedBox(height: 13),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FFF0),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: _green,
                  size: 26,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Koordinator Regu Jaga',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Petugas ronda lingkungan',
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
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FFF0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Menuju lokasi',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _green,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          _detailRow('Unit', 'Tim siaga lingkungan'),
          const SizedBox(height: 9),
          _detailRow('Kendaraan', 'Kendaraan patroli RT'),
          const SizedBox(height: 9),
          _detailRow('Status', 'Dalam simulasi perjalanan'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: _muted,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _messageSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Pesan tambahan'),
          const SizedBox(height: 5),
          Text(
            'Tambahkan informasi untuk melengkapi laporan simulasi.',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: _muted,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Contoh: Mohon masuk melalui gerbang samping...',
              hintStyle: GoogleFonts.inter(
                fontSize: 10,
                color: _muted,
              ),
              filled: true,
              fillColor: const Color(0xFFF7FAF8),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFDFEEE4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFDFEEE4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _green),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Tambahkan Pesan'),
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
          if (_messages.isNotEmpty) ...[
            const SizedBox(height: 15),
            Text(
              'Pesan yang ditambahkan',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
            const SizedBox(height: 8),
            for (final message in _messages)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FAF3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    height: 1.4,
                    color: _text,
                  ),
                ),
              ),
          ],
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
          'Status Dispatch Darurat',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _greenDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(17, 16, 17, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _greenDark,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9BE7B5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'STATUS AKTIF • SIMULASI RT',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: const Color(0xFFB9F2CC),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'TIM SIAGA MENUJU LOKASI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status ini merupakan simulasi tampilan dispatch. '
                  'Belum ada petugas yang menerima laporan dari aplikasi.',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 17),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFFB9F2CC),
                      size: 21,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estimasi kedatangan',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    Text(
                      '2–4 menit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Lokasi keadaan darurat'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: _red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lokasi pelaporan',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Alamat akan ditentukan dari data lokasi pengguna.',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              height: 1.4,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                _mapPlaceholder(),
                const SizedBox(height: 11),
                _detailRow('Pos bantuan', 'Pos keamanan lingkungan'),
                const SizedBox(height: 8),
                _detailRow('Jarak', 'Belum tersedia'),
              ],
            ),
          ),
          const SizedBox(height: 13),
          _unitCard(),
          const SizedBox(height: 13),
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  'Riwayat penanganan',
                  trailing: 'SIMULASI',
                ),
                const SizedBox(height: 17),
                _timelineItem(
                  time: '00:01',
                  title: 'Laporan SOS dibuat',
                  description: 'Aktivasi SOS berhasil pada simulasi aplikasi.',
                  completed: true,
                ),
                _timelineItem(
                  time: '00:35',
                  title: 'Dispatch petugas',
                  description:
                      'Status tim siaga ditampilkan sebagai menuju lokasi.',
                  completed: true,
                ),
                _timelineItem(
                  time: 'Menunggu',
                  title: 'Verifikasi di lokasi',
                  description: 'Menunggu pembaruan status penanganan.',
                  completed: false,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          _messageSection(),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: _cancelEmergency,
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Batalkan Simulasi Darurat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _red,
              side: const BorderSide(color: Color(0xFFE6BABA)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Center(
            child: Text(
              'Tampilan demonstrasi • Tidak terhubung ke petugas darurat',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: _muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final thinRoadPaint = Paint()
      ..color = const Color(0xFFD1E1D3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(-10, size.height * 0.35)
      ..lineTo(size.width * 0.4, size.height * 0.35)
      ..lineTo(size.width * 0.62, size.height * 0.7)
      ..lineTo(size.width + 10, size.height * 0.7);

    final path2 = Path()
      ..moveTo(size.width * 0.28, -10)
      ..lineTo(size.width * 0.28, size.height * 0.45)
      ..lineTo(size.width * 0.78, size.height + 10);

    canvas.drawPath(path1, roadPaint);
    canvas.drawPath(path2, roadPaint);

    final blockPaint = Paint()
      ..color = const Color(0xFFD8E8DA)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final rect = Rect.fromLTWH(
        12 + i * 57,
        12 + (i.isEven ? 0 : 100),
        35,
        22,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        blockPaint,
      );
    }

    canvas.drawPath(path1, thinRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
