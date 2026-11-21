import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BeritaPage extends StatefulWidget {
  const BeritaPage({super.key});

  @override
  State<BeritaPage> createState() => _BeritaPageState();
}

class _NewsItem {
  const _NewsItem({
    required this.title,
    required this.category,
    required this.source,
    required this.date,
    required this.body,
    required this.type,
    required this.image,
    this.views = 0,
    this.comments = 0,
    this.supports = 0,
    this.featured = false,
  });

  final String title;
  final String category;
  final String source;
  final String date;
  final String body;
  final String type;
  final String image;
  final int views;
  final int comments;
  final int supports;
  final bool featured;
}

class _BeritaPageState extends State<BeritaPage> {
  static const Color green = Color(0xFF107C41);
  static const Color darkGreen = Color(0xFF084C27);
  static const Color mint = Color(0xFFE8FFF0);
  static const Color background = Color(0xFFF4FBF6);
  static const Color border = Color(0xFFBDEFD2);
  static const Color textDark = Color(0xFF17251C);
  static const Color muted = Color(0xFF718078);

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  String _selectedCategory = 'semua';
  String _selectedTab = 'internal';
  String _selectedFormCategory = 'Kabar Duka';

  final List<_NewsItem> _articles = const [
    _NewsItem(
      title: 'Penyemprotan Fogging Serentak & Pemeriksaan Jentik Nyamuk DBD',
      category: 'pengumuman',
      source: 'Sie Kesehatan & Pengurus RT 05',
      date: '2 jam lalu',
      type: 'internal',
      image:
          'https://images.unsplash.com/photo-1584483766114-2cea6facdf57?auto=format&fit=crop&w=800&q=80',
      body:
          'Guna pencegahan siklus demam berdarah di musim penghujan, Sie Kesehatan RT 05 bekerja sama dengan Puskesmas Kelurahan akan melaksanakan fogging massal besok pagi. Seluruh warga dimohon mengamankan makanan dan hewan peliharaan serta membuka ventilasi rumah.',
      featured: true,
    ),
    _NewsItem(
      title: 'Hasil Rapat Evaluasi Portal Masuk: Penambahan Akses Kartu RFID',
      category: 'keamanan',
      source: 'Sie Keamanan Lingkungan RT 05',
      date: 'Kemarin',
      type: 'internal',
      image:
          'https://images.unsplash.com/photo-1541888946425-d0fbb186156a?auto=format&fit=crop&w=300&q=80',
      body:
          'Mulai 1 Desember, portal gerbang timur akan dipasang sistem palang RFID otomatis. Setiap kepala keluarga berhak mendapatkan 2 kartu akses gratis yang dapat diambil di Pos Ronda Utama.',
      views: 42,
      comments: 14,
    ),
    _NewsItem(
      title: 'Laporan Bersih Selokan RW 08: 12 Karung Sedimen Terangkat',
      category: 'kerja_bakti',
      source: 'Sie Kerja Bakti & Lingkungan',
      date: '17 Nov 2024',
      type: 'lingkungan',
      image:
          'https://images.unsplash.com/photo-1593113598332-cd288d649433?auto=format&fit=crop&w=300&q=80',
      body:
          'Terima kasih atas partisipasi aktif seluruh warga RT 05 pada agenda gotong royong massal pembersihan saluran induk air jelang puncak musim hujan. Aliran parit kini terpantau lancar.',
      supports: 88,
    ),
    _NewsItem(
      title:
          'Penyaluran Bantuan Beras Cadangan Pangan Nasional untuk 18 KK Terdaftar',
      category: 'pengumuman',
      source: 'Bansos & Layanan Warga RT 05',
      date: '14 Nov 2024',
      type: 'internal',
      image: '',
      body:
          'Penyaluran bantuan beras cadangan pangan nasional dari Bapanas dialokasikan bagi 18 KK penerima manfaat terdaftar di RT 05. Harap membawa identitas asli KTP dan KK.',
    ),
    _NewsItem(
      title:
          'Jadwal Penjemputan Bank Sampah Mandiri: Cara Setor Minyak Jelantah',
      category: 'kerja_bakti',
      source: 'Sie Kebersihan & Lingkungan Hidup',
      date: '12 Nov 2024',
      type: 'lingkungan',
      image:
          'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=300&q=80',
      body:
          'Pengumpulan limbah minyak goreng bekas atau jelantah dapat disetor setiap hari Sabtu pagi di gerai Bank Sampah Bersih Berseri RT 05 untuk ditukar reward poin iuran.',
    ),
  ];

  List<_NewsItem> get _filteredArticles {
    final keyword = _searchController.text.trim().toLowerCase();

    return _articles.where((article) {
      final matchesCategory =
          _selectedCategory == 'semua' || article.category == _selectedCategory;

      final matchesTab = article.type == _selectedTab;

      final matchesSearch = keyword.isEmpty ||
          article.title.toLowerCase().contains(keyword) ||
          article.body.toLowerCase().contains(keyword) ||
          article.source.toLowerCase().contains(keyword);

      return matchesCategory && matchesTab && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(fontSize: 12),
          ),
          backgroundColor: darkGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      );
  }

  void _openDetail(_NewsItem article) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _categoryBadge(article.category),
                          const SizedBox(height: 10),
                          Text(
                            article.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${article.source} • ${article.date}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5EBE7)),
                  ),
                  child: Text(
                    article.body,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.7,
                      color: const Color(0xFF47534B),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: mint,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Telah terverifikasi oleh Sie Humas & Sekretariat RT 05 / RW 08',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: darkGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showToast(
                          'Fitur berbagi akan tersedia pada integrasi berikutnya.');
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Bagikan Berita'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
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
        );
      },
    );
  }

  void _openSubmitForm() {
    _titleController.clear();
    _bodyController.clear();
    _selectedFormCategory = 'Kabar Duka';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
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
                              color: mint,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.campaign_rounded,
                              color: green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kirim Kabar Warga',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Akan ditinjau pengurus RT sebelum disiarkan',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: muted,
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
                      _formLabel('Kategori Warta'),
                      DropdownButtonFormField<String>(
                        value: _selectedFormCategory,
                        decoration: _inputDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Kabar Duka',
                            child: Text('Kabar Lelayu / Duka Cita'),
                          ),
                          DropdownMenuItem(
                            value: 'Syukuran & Hajatan',
                            child: Text('Syukuran / Undangan Warga'),
                          ),
                          DropdownMenuItem(
                            value: 'Barang Hilang / Ditemukan',
                            child: Text('Barang Hilang / Ditemukan'),
                          ),
                          DropdownMenuItem(
                            value: 'Kabar Umum',
                            child: Text('Kabar Umum Lingkungan'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setSheetState(() {
                              _selectedFormCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      _formLabel('Judul Kabar *'),
                      TextField(
                        controller: _titleController,
                        decoration: _inputDecoration(
                          hint: 'Contoh: Undangan Aqiqah Ananda Rizky...',
                        ),
                      ),
                      const SizedBox(height: 15),
                      _formLabel('Rincian Informasi & Lokasi *'),
                      TextField(
                        controller: _bodyController,
                        minLines: 4,
                        maxLines: 6,
                        decoration: _inputDecoration(
                          hint:
                              'Tuliskan hari, tanggal, waktu, alamat rumah, dan informasi penting lainnya...',
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_titleController.text.trim().isEmpty ||
                                _bodyController.text.trim().isEmpty) {
                              _showToast(
                                  'Mohon lengkapi judul dan rincian kabar.');
                              return;
                            }

                            Navigator.pop(sheetContext);
                            _showToast(
                              'Kabar berhasil diajukan secara lokal untuk simulasi verifikasi RT.',
                            );
                          },
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('Kirim untuk Verifikasi RT'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
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
    );
  }

  Widget _formLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: muted,
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
      fillColor: const Color(0xFFF7F9F8),
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE1E8E3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE1E8E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: green, width: 1.4),
      ),
    );
  }

  Widget _categoryBadge(String category) {
    Color color;
    Color backgroundColor;

    switch (category) {
      case 'keamanan':
        color = const Color(0xFF1D4ED8);
        backgroundColor = const Color(0xFFEFF6FF);
        break;
      case 'kerja_bakti':
        color = const Color(0xFF087443);
        backgroundColor = mint;
        break;
      default:
        color = const Color(0xFF087443);
        backgroundColor = mint;
    }

    final label = switch (category) {
      'keamanan' => 'Keamanan Lingkungan',
      'kerja_bakti' => 'Kerja Bakti & Lingkungan',
      _ => 'Pengumuman RT',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0x40BDEFD2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: mint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Center(
              child: Text(
                'SL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: green,
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAPULIDI RT 05',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: green,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Berita & Pengumuman',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showToast('Ada 2 pengumuman baru dari pengurus RT 05.');
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: darkGreen,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 20,
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
        border: Border.all(color: border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.inter(fontSize: 11),
        decoration: InputDecoration(
          hintText: 'Cari warta warga, edaran RT, bansos...',
          hintStyle: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.grey.shade400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.grey,
            size: 20,
          ),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      ('semua', 'Semua (8)'),
      ('pengumuman', 'Pengumuman RT'),
      ('kerja_bakti', 'Kerja Bakti'),
      ('keamanan', 'Keamanan'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((item) {
          final selected = _selectedCategory == item.$1;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(item.$2),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedCategory = item.$1);
              },
              selectedColor: green,
              backgroundColor: Colors.white,
              labelStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : muted,
              ),
              side: BorderSide(
                color: selected ? green : const Color(0xFFE0E6E2),
              ),
              shape: const StadiumBorder(),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeatured() {
    final article = _articles.first;

    return GestureDetector(
      onTap: () => _openDetail(article),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 175,
                  width: double.infinity,
                  child: Image.network(
                    article.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: darkGreen,
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: Colors.white,
                        size: 55,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _imageBadge('PENGUMUMAN RESMI RT 05'),
                      _imageBadge('● MENDESAK', warning: true),
                    ],
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.alarm_rounded,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Wajib Buka Pintu / Jendela Pukul 08.00 WIB',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      height: 1.4,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Guna pencegahan siklus demam berdarah di musim penghujan, Sie Kesehatan RT 05 dan Puskesmas Kelurahan akan melaksanakan fogging massal besok pagi.',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      height: 1.6,
                      color: muted,
                    ),
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 15,
                        color: green,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Pengurus RW 08 & Sie Kesehatan • 2 jam lalu',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _showToast(
                          'Fitur berbagi akan tersedia pada integrasi berikutnya.',
                        ),
                        icon: const Icon(Icons.share_rounded, size: 17),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageBadge(String label, {bool warning = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: warning ? darkGreen : green,
        borderRadius: BorderRadius.circular(8),
        border: warning ? Border.all(color: const Color(0xFF96F7AF)) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: warning ? const Color(0xFF96F7AF) : Colors.white,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE1E6E3)),
      ),
      child: Row(
        children: [
          _tabButton('internal', 'Pengumuman Internal RT', '3'),
          _tabButton('lingkungan', 'Warta Lingkungan', '5'),
        ],
      ),
    );
  }

  Widget _tabButton(String value, String label, String count) {
    final selected = _selectedTab == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected ? Border.all(color: border) : null,
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
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    color: selected ? green : muted,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: selected ? mint : const Color(0xFFE1E5E3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: selected ? green : muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(_NewsItem article) {
    return GestureDetector(
      onTap: () => _openDetail(article),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: _categoryBadge(article.category)),
                      const SizedBox(width: 5),
                      Text(
                        article.date,
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    article.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      height: 1.4,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      height: 1.5,
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      if (article.views > 0) ...[
                        const Icon(
                          Icons.visibility_outlined,
                          size: 12,
                          color: muted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${article.views} Warga',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            color: muted,
                          ),
                        ),
                      ],
                      if (article.comments > 0) ...[
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 12,
                          color: muted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${article.comments} Diskusi',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            color: muted,
                          ),
                        ),
                      ],
                      if (article.supports > 0) ...[
                        const Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 12,
                          color: green,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${article.supports} Dukungan',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            color: green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (article.image.isNotEmpty) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  article.image,
                  width: 76,
                  height: 82,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 76,
                    height: 82,
                    color: mint,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: green,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.article_outlined,
            color: green,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            'Berita tidak ditemukan',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Coba ubah kata pencarian, kategori, atau tab berita.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBanner() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, green, Color(0xFF0D6B38)],
        ),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '◉ WARGA PEDULI',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFB9F5CA),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Punya Kabar atau Hajat Warga?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Laporkan berita kehilangan, undangan syukuran, atau kabar duka untuk disiarkan ke satu RT.',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    height: 1.5,
                    color: const Color(0xFFE3F8E9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          ElevatedButton.icon(
            onPressed: _openSubmitForm,
            icon: const Icon(Icons.add_rounded, size: 15),
            label: const Text('Kirim Kabar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: green,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 11,
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final articles = _filteredArticles;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(17, 16, 17, 25),
                children: [
                  _buildSearch(),
                  const SizedBox(height: 13),
                  _buildCategoryFilters(),
                  const SizedBox(height: 14),
                  _buildFeatured(),
                  const SizedBox(height: 17),
                  _buildTabs(),
                  const SizedBox(height: 13),
                  if (articles.isEmpty)
                    _buildEmptyState()
                  else
                    ...articles.map(
                      (article) => Padding(
                        padding: const EdgeInsets.only(bottom: 11),
                        child: _buildArticleCard(article),
                      ),
                    ),
                  const SizedBox(height: 5),
                  _buildSubmitBanner(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
