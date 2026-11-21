import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AspirasiPage extends StatefulWidget {
  const AspirasiPage({
    super.key,
    this.onNavigateRoot,
    this.onSos,
  });

  final ValueChanged<int>? onNavigateRoot;
  final VoidCallback? onSos;

  @override
  State<AspirasiPage> createState() => _AspirasiPageState();
}

class _AspirasiPageState extends State<AspirasiPage> {
  static const Color _green = Color(0xFF107C41);
  static const Color _greenDark = Color(0xFF084C27);
  static const Color _mint = Color(0xFFE8FFF0);
  static const Color _background = Color(0xFFF4FBF6);
  static const Color _border = Color(0xFFBDEFD2);
  static const Color _text = Color(0xFF17251C);
  static const Color _muted = Color(0xFF718078);

  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'semua';
  String _selectedTab = 'publik';
  String _searchKeyword = '';

  final List<Map<String, dynamic>> _aspirations = [
    {
      'id': 1,
      'name': 'Hendro Sukarno',
      'initial': 'HS',
      'address': 'Blok A2 / 05',
      'time': '2 hari yang lalu',
      'category': 'fasilitas',
      'categoryName': 'Fasilitas Umum',
      'title':
          'Penambahan Titik Lampu Jalan LED Tenaga Surya di Gang 3 & Pos Ronda',
      'description':
          'Kondisi jalan gang 3 cukup gelap saat malam hari, rawan bagi lansia dan anak-anak yang pulang les atau mengaji. Kami usulkan pengadaan 3 lampu solar panel otomatis.',
      'status': 'Sedang Dikerjakan',
      'votes': 142,
      'comments': 28,
      'image':
          'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=600&q=80',
      'imageCaption': 'Kondisi Tiang Gang 3 Saat Malam',
      'response':
          'Alhamdulillah usulan disetujui musyawarah warga. Material 3 set lampu solar cell 100W sudah dibeli via Kas RT. Pemasangan serentak Minggu besok saat kerja bakti.',
      'responseBy': 'Respon Resmi Ketua RT 05 (Pak Bambang)',
      'mine': false,
      'voted': false,
      'progress': null,
    },
    {
      'id': 2,
      'name': 'Siti Nurhaliza',
      'initial': 'SN',
      'address': 'Blok C1 / 08',
      'time': 'Kemarin',
      'category': 'kebersihan',
      'categoryName': 'Kebersihan & Saluran Air',
      'title':
          'Jadwal Kerja Bakti Khusus Pembersihan Gorong-gorong Induk Saluran RW',
      'description':
          'Menjelang musim hujan deras, endapan lumpur dan sampah daun di saluran depan gerbang barat sudah mengendap setinggi 30cm. Perlu pengerukan gotong royong sebelum terjadi luapan banjir.',
      'status': 'Ditinjau Pengurus',
      'votes': 96,
      'comments': 15,
      'image': null,
      'imageCaption': null,
      'response': null,
      'responseBy': null,
      'mine': false,
      'voted': false,
      'progress': 0.96,
    },
    {
      'id': 3,
      'name': 'Budi Santoso',
      'initial': 'BS',
      'address': 'Blok B1 / 02',
      'time': '1 pekan lalu',
      'category': 'kebersihan',
      'categoryName': 'Kebersihan & Lingkungan',
      'title':
          'Pengadaan Tong Sampah Terpilah (Organik & Anorganik) di Area Taman Bermain RT',
      'description':
          'Taman RT sering digunakan anak-anak sore hari. Butuh pemilahan wadah sampah agar tidak berserakan dan mendidik kepedulian lingkungan sejak dini.',
      'status': 'Selesai Terealisasi',
      'votes': 115,
      'comments': 0,
      'image':
          'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=600&q=80',
      'imageCaption': 'Realisasi Tong Sampah Terpilah',
      'response': null,
      'responseBy': null,
      'mine': false,
      'voted': false,
      'progress': null,
    },
  ];

  final List<Map<String, dynamic>> _myAspirations = [];

  final List<Map<String, String>> _categories = [
    {'value': 'semua', 'label': 'Semua'},
    {'value': 'fasilitas', 'label': 'Fasilitas Umum'},
    {'value': 'kebersihan', 'label': 'Kebersihan'},
    {'value': 'keamanan', 'label': 'Keamanan'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAspirations {
    final source = _selectedTab == 'publik' ? _aspirations : _myAspirations;

    return source.where((item) {
      final categoryMatches =
          _selectedCategory == 'semua' || item['category'] == _selectedCategory;

      final title = (item['title'] ?? '').toString().toLowerCase();
      final description = (item['description'] ?? '').toString().toLowerCase();
      final keyword = _searchKeyword.toLowerCase();

      final searchMatches = keyword.isEmpty ||
          title.contains(keyword) ||
          description.contains(keyword);

      return categoryMatches && searchMatches;
    }).toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(fontSize: 12),
          ),
          backgroundColor: _greenDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _toggleVote(Map<String, dynamic> item) {
    setState(() {
      final voted = item['voted'] == true;
      final currentVotes = item['votes'] as int;

      item['voted'] = !voted;
      item['votes'] = voted ? currentVotes - 1 : currentVotes + 1;
    });

    _showMessage(
      item['voted'] == true
          ? 'Dukungan berhasil diberikan.'
          : 'Dukungan berhasil dibatalkan.',
    );
  }

  Future<void> _shareAspirasi(String title) async {
    await Clipboard.setData(
      ClipboardData(
        text: 'Aspirasi Warga RT 05: $title',
      ),
    );

    if (!mounted) return;
    _showMessage('Informasi aspirasi berhasil disalin.');
  }

  void _openInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _mint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        color: _green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tata Tertib Musyawarah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _text,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _ruleItem(
                  'Setiap usulan yang mencapai 100 dukungan suara warga otomatis masuk ke agenda rapat pleno bulanan RT 05.',
                ),
                _ruleItem(
                  'Gunakan bahasa santun, beradab, dan hindari tuduhan tanpa bukti.',
                ),
                _ruleItem(
                  'Pengurus RT berkewajiban merespons status usulan paling lambat 3x24 jam kerja.',
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: FilledButton.styleFrom(
                      backgroundColor: _green,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(
                      'Saya Mengerti',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
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

  Widget _ruleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(
              Icons.circle,
              size: 6,
              color: _green,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11,
                height: 1.6,
                color: _muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAspirasiForm() {
    final formKey = GlobalKey<FormState>();
    final judulController = TextEditingController();
    final deskripsiController = TextEditingController();

    String kategori = 'Fasilitas Umum';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 30,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Form(
                  key: formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(21, 15, 21, 25),
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 43,
                            height: 43,
                            decoration: BoxDecoration(
                              color: _mint,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.rate_review_rounded,
                              color: _green,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sampaikan Aspirasi Baru',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _text,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Usulan akan dimusyawarahkan oleh warga & RT',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: _muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _formLabel('Kategori Usulan'),
                      DropdownButtonFormField<String>(
                        value: kategori,
                        decoration: _inputDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Fasilitas Umum',
                            child: Text('Fasilitas Umum & Sarana'),
                          ),
                          DropdownMenuItem(
                            value: 'Kebersihan',
                            child: Text('Kebersihan & Lingkungan'),
                          ),
                          DropdownMenuItem(
                            value: 'Keamanan',
                            child: Text('Keamanan & Pos Ronda'),
                          ),
                          DropdownMenuItem(
                            value: 'Sosial',
                            child: Text('Kegiatan Warga & Sosial'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setSheetState(() => kategori = value);
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      _formLabel('Judul Usulan / Keluhan'),
                      TextFormField(
                        controller: judulController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDecoration(
                          hint: 'Contoh: Perbaikan Cermin Tikungan Gang 4...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul aspirasi wajib diisi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _formLabel('Rincian Masalah & Solusi yang Diharapkan'),
                      TextFormField(
                        controller: deskripsiController,
                        minLines: 4,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDecoration(
                          hint:
                              'Jelaskan lokasi spesifik, kendala yang dialami, serta usulan solusi bersama...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Rincian aspirasi wajib diisi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 17),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FBF4),
                          border: Border.all(
                            color: _border,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_a_photo_outlined,
                              color: _green,
                              size: 20,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Lampirkan Foto Kondisi (Opsional)',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _text,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _showMessage(
                                  'Pemilihan foto akan tersedia setelah integrasi galeri ditambahkan.',
                                );
                              },
                              child: Text(
                                'Upload',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: _green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;

                            final title = judulController.text.trim();
                            final description = deskripsiController.text.trim();

                            final categoryKey = kategori == 'Fasilitas Umum'
                                ? 'fasilitas'
                                : kategori == 'Kebersihan'
                                    ? 'kebersihan'
                                    : kategori == 'Keamanan'
                                        ? 'keamanan'
                                        : 'sosial';

                            setState(() {
                              _myAspirations.insert(0, {
                                'id': DateTime.now().millisecondsSinceEpoch,
                                'name': 'Anda',
                                'initial': 'W',
                                'address': 'Warga SapuLidi',
                                'time': 'Baru saja',
                                'category': categoryKey,
                                'categoryName': kategori,
                                'title': title,
                                'description': description,
                                'status': 'Menunggu Verifikasi',
                                'votes': 0,
                                'comments': 0,
                                'image': null,
                                'imageCaption': null,
                                'response': null,
                                'responseBy': null,
                                'mine': true,
                                'voted': false,
                                'progress': null,
                              });

                              _selectedTab = 'aspirasiku';
                              _selectedCategory = 'semua';
                              _searchKeyword = '';
                              _searchController.clear();
                            });

                            Navigator.pop(sheetContext);
                            _showMessage(
                              'Aspirasi berhasil diajukan ke forum suara warga RT 05.',
                            );
                          },
                          icon: const Icon(Icons.send_rounded, size: 17),
                          label: Text(
                            'Publikasikan ke Forum Suara Warga',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      judulController.dispose();
      deskripsiController.dispose();
    });
  }

  Widget _formLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        '$text *',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: _muted,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 11,
        color: Colors.grey.shade400,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAF9),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE1EAE4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE1EAE4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _green, width: 1.3),
      ),
      errorStyle: GoogleFonts.inter(fontSize: 10),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF9),
                border: Border.all(color: const Color(0xFFE5EBE7)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 19,
                color: _text,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aspirasi & Suara Warga',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: _green,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'RT 05 / RW 08',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Bantuan',
            onPressed: _openInfoDialog,
            icon: const Icon(
              Icons.help_outline_rounded,
              color: _muted,
              size: 21,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _greenDark,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_greenDark, _green, Color(0xFF0D6B38)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.groups_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'MUSYAWARAH & TRANSPARANSI RT 05',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Oktober 2024',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB7F5C9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            'Suara Warga Membangun Lingkungan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Setiap usulan dan aduan warga dibahas bersama pengurus RT demi kenyamanan dan keamanan hunian kita.',
            style: GoogleFonts.inter(
              fontSize: 10,
              height: 1.6,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFD8F5E1),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem('18', 'Diusulkan'),
              const SizedBox(width: 8),
              _statItem('12', 'Diproses RT'),
              const SizedBox(width: 8),
              _statItem('8', 'Terealisasi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.13),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB7F5C9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWriteCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E8),
              border: Border.all(color: const Color(0xFFF5DCA8)),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.rate_review_rounded,
              color: Color(0xFF98620B),
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Punya Usulan atau Keluhan?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sampaikan langsung ke pengurus RT & warga',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          FilledButton.icon(
            onPressed: _openAspirasiForm,
            icon: const Icon(Icons.add_rounded, size: 15),
            label: Text(
              'Tulis',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE99A16),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border.withValues(alpha: 0.8)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchKeyword = value.trim());
        },
        style: GoogleFonts.inter(
          fontSize: 11,
          color: _text,
        ),
        decoration: InputDecoration(
          hintText: 'Cari usulan, aduan fasilitas, gorong-gorong...',
          hintStyle: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.grey.shade400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: Colors.grey,
          ),
          suffixIcon: _searchKeyword.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchKeyword = '');
                  },
                  icon: const Icon(Icons.close_rounded, size: 17),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in _categories)
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: ChoiceChip(
                label: Text(category['label']!),
                selected: _selectedCategory == category['value'],
                onSelected: (_) {
                  setState(() {
                    _selectedCategory = category['value']!;
                  });
                },
                showCheckmark: false,
                labelStyle: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _selectedCategory == category['value']
                      ? Colors.white
                      : _muted,
                ),
                backgroundColor: Colors.white,
                selectedColor: _green,
                side: BorderSide(
                  color: _selectedCategory == category['value']
                      ? _green
                      : const Color(0xFFE1E8E3),
                ),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
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
        color: const Color(0xFFEDF1EE),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8E3)),
      ),
      child: Row(
        children: [
          _tabButton(
            label: 'Aspirasi Publik & Voting',
            value: 'publik',
          ),
          _tabButton(
            label: 'Aspirasiku',
            value: 'aspirasiku',
            count: _myAspirations.length,
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required String value,
    int? count,
  }) {
    final selected = _selectedTab == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedTab = value);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(color: _border.withValues(alpha: 0.7))
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    color: selected ? _green : _muted,
                  ),
                ),
              ),
              if (count != null && count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE99A16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
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

  Widget _buildTimeline() {
    const steps = [
      'Diterima',
      'Ditinjau',
      'Musyawarah',
      'Dikerjakan',
      'Selesai',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.timeline_rounded,
                size: 17,
                color: _green,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Alur Aspirasi Warga RT 05',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _mint,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '5 Tahapan',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: List.generate(steps.length, (index) {
              final active = index < 3;
              final current = index == 3;

              final color = active
                  ? _green
                  : current
                      ? const Color(0xFFE99A16)
                      : const Color(0xFFE0E5E2);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == steps.length - 1 ? 0 : 4,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        steps[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: current || active
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: active
                              ? _green
                              : current
                                  ? const Color(0xFFB77A12)
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAspirasiCard(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final isDone = status == 'Selesai Terealisasi';
    final isWorking = status == 'Sedang Dikerjakan';

    final statusColor = isDone || isWorking ? _green : const Color(0xFF2466A8);

    final statusBackground =
        isDone || isWorking ? const Color(0xFFEAF8EF) : const Color(0xFFEEF5FF);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: _border.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7ED),
                  shape: BoxShape.circle,
                  border: Border.all(color: _border),
                ),
                child: Center(
                  child: Text(
                    item['initial'].toString(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: _green,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'].toString(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['address']} • ${item['time']}',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            item['title'].toString(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              height: 1.4,
              color: _text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item['description'].toString(),
            style: GoogleFonts.inter(
              fontSize: 10,
              height: 1.6,
              color: const Color(0xFF5F6B64),
            ),
          ),
          if (item['image'] != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  Image.network(
                    item['image'].toString(),
                    width: double.infinity,
                    height: 155,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        height: 155,
                        width: double.infinity,
                        color: const Color(0xFFEAF1EC),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: _muted,
                          size: 30,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 9,
                    bottom: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['imageCaption'].toString(),
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (item['response'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF8F0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _border.withValues(alpha: 0.7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: _green,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item['responseBy'].toString(),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: _green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${item['response']}"',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      height: 1.6,
                      color: const Color(0xFF48564D),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (item['progress'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F7),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFE5EAE7)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dukungan Dibutuhkan untuk Agenda Musyawarah',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: _muted,
                          ),
                        ),
                      ),
                      Text(
                        '${item['votes']} / 100 Suara',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: item['progress'] as double,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFE0E6E2),
                      color: _green,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEDF0EE)),
          const SizedBox(height: 10),
          if (isDone)
            Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: _green,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${item['votes']} Warga Mendukung & Selesai',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: _green,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _showMessage(
                      'Laporan pertanggungjawaban realisasi belum tersedia pada demo.',
                    );
                  },
                  icon: const Icon(Icons.visibility_rounded, size: 13),
                  label: Text(
                    'Laporan RT',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: _text,
                    backgroundColor: const Color(0xFFF0F2F1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _toggleVote(item),
                    borderRadius: BorderRadius.circular(11),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: item['voted'] == true ? _green : _mint,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['voted'] == true
                                ? Icons.thumb_up_rounded
                                : Icons.thumb_up_outlined,
                            size: 14,
                            color:
                                item['voted'] == true ? Colors.white : _green,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              '${item['votes']} Warga Mendukung',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: item['voted'] == true
                                    ? Colors.white
                                    : _green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                if ((item['comments'] as int) > 0) ...[
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 13,
                    color: _muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item['comments']}',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                InkWell(
                  onTap: () => _shareAspirasi(item['title'].toString()),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(
                      Icons.share_rounded,
                      size: 16,
                      color: _muted,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isMine = _selectedTab == 'aspirasiku';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Icon(
            isMine ? Icons.rate_review_outlined : Icons.search_off_rounded,
            color: _green,
            size: 38,
          ),
          const SizedBox(height: 12),
          Text(
            isMine ? 'Belum Ada Aspirasimu' : 'Aspirasi Tidak Ditemukan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: _text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isMine
                ? 'Aspirasi yang kamu ajukan akan muncul di halaman ini.'
                : 'Coba gunakan kata kunci atau kategori yang berbeda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              height: 1.5,
              color: _muted,
            ),
          ),
          if (isMine) ...[
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: _openAspirasiForm,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Tulis Aspirasi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _green,
                side: const BorderSide(color: _green),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFDCECE1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 65,
          child: Row(
            children: [
              _bottomItem(
                icon: Icons.home_outlined,
                label: 'Beranda',
                onTap: () => widget.onNavigateRoot?.call(0),
              ),
              _bottomItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Keuangan',
                onTap: () => widget.onNavigateRoot?.call(1),
              ),
              Expanded(
                child: InkWell(
                  onTap: widget.onSos,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC62828),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.18),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sos_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _bottomItem(
                icon: Icons.inventory_2_outlined,
                label: 'Inventaris',
                onTap: () => widget.onNavigateRoot?.call(2),
              ),
              _bottomItem(
                icon: Icons.forum_rounded,
                label: 'Komunitas',
                active: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 31,
              height: 30,
              decoration: BoxDecoration(
                color: active ? _mint : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 19,
                color: active ? _green : _muted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                color: active ? _green : _muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredAspirations;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
                children: [
                  _buildStatistics(),
                  const SizedBox(height: 13),
                  _buildWriteCard(),
                  const SizedBox(height: 13),
                  _buildSearch(),
                  const SizedBox(height: 12),
                  _buildCategoryFilters(),
                  const SizedBox(height: 12),
                  _buildTabs(),
                  const SizedBox(height: 13),
                  _buildTimeline(),
                  const SizedBox(height: 15),
                  if (items.isEmpty)
                    _buildEmptyState()
                  else
                    for (final item in items) ...[
                      _buildAspirasiCard(item),
                      const SizedBox(height: 13),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
