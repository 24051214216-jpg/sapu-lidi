import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/inventory_item.dart';
import 'loan_form_page.dart';

class InventoryCatalogPage extends StatefulWidget {
  const InventoryCatalogPage({super.key});

  @override
  State<InventoryCatalogPage> createState() => _InventoryCatalogPageState();
}

class _InventoryCatalogPageState extends State<InventoryCatalogPage> {
  static const Color _green = Color(0xFF087A43);
  static const Color _greenSoft = Color(0xFFE5F5EB);
  static const Color _background = Color(0xFFF7F8F7);
  static const Color _text = Color(0xFF202A25);
  static const Color _muted = Color(0xFF77827C);
  static const Color _line = Color(0xFFE9EEEA);
  static const Color _orange = Color(0xFFB7791F);

  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Semua';
  bool _onlyAvailable = false;
  bool _availableFirst = true;

  final Set<String> _reminderItems = <String>{};

  static const List<String> _categories = <String>[
    'Semua',
    'Tenda & Panggung',
    'Kebersihan',
    'Perkakas',
    'Sound System',
    'Perlengkapan Acara',
  ];

  // DATA SIMULASI LOKAL.
  // Seluruh stok awal tersedia karena belum ada transaksi peminjaman
  // yang tercatat di server.
  static const List<_CatalogEntry> _sampleItems = <_CatalogEntry>[
    _CatalogEntry(
      item: InventoryItem(
        id: 'INV-001',
        name: 'Tenda Terop 4x6m',
        category: 'Tenda & Panggung',
        description: 'Tenda terop untuk kegiatan warga dan acara lingkungan.',
        location: 'Gudang Balai RT',
        availableStock: 3,
        totalStock: 3,
        condition: 'Prima',
      ),
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBAnCqGOfu7N7LviWxtJxNeup96hJmrbH-cGP3Q-E1ET6xBCCG359XyuMalTiqUjaVh2QKttjtsBEdURBaIIpER9qzlLAuyHLPlLqj4j9Sl8--lve7rTdqur21-pgAJ3ey16WRgyUKlJY8m4aUwE4asf6Y8vhN7DRm6NN8m3ZHHONPD4Wf01-7XHeDF5GxV9BHdAAR2MCHNokSMWmowqQ6hyIZtuvU6qV-52Vf_JNIP',
      imageLabel: '4x6 m',
      unit: 'Unit',
      icon: Icons.campaign_rounded,
      rule: 'Jumlah mengikuti stok tersedia',
    ),
    _CatalogEntry(
      item: InventoryItem(
        id: 'INV-002',
        name: 'Mesin Pemotong Rumput',
        category: 'Kebersihan',
        description: 'Mesin pemotong rumput untuk perawatan lingkungan.',
        location: 'Gudang Peralatan RT',
        availableStock: 1,
        totalStock: 1,
        condition: 'Bensin',
      ),
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCFAhYX2E8ktLqRY7kNg-mPMA8LjuHGO1XdRzHhvJHnwUsBHAG1BV0bvsPAt60-bOhhle5Bm5dS2mRRV49vMXoeQqfB0chGFLAtEuGwgeCwkdB6UOYgzVT89koyprczKnj2gchl6pSVjHB87yrPmsqTyb3krynxTEaXzGi144GInWhjkCJOoh8_g4b8lXE8gP6O76AW-cizjDNcXBc1dHB1hbmzw5aWBLYbzSE4G3At',
      imageLabel: '1 Unit',
      unit: 'Unit',
      icon: Icons.grass_rounded,
      rule: 'Jumlah mengikuti stok tersedia',
      note: 'Gunakan sesuai petunjuk keselamatan.',
    ),
    _CatalogEntry(
      item: InventoryItem(
        id: 'INV-003',
        name: 'Kursi Lipat Chitose',
        category: 'Tenda & Panggung',
        description: 'Kursi lipat untuk pertemuan dan acara warga.',
        location: 'Gudang Utama RT',
        availableStock: 30,
        totalStock: 30,
        condition: 'Bersih & Rapi',
      ),
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA4eBdyb1bBZL6cMUKUo84XKIPn_w99FWwfWK2hC7ZF357Bwe9Bjo0A3ClGh1lBUP3zcfN3Jkt_whaM3XEH0rcF3FLBMFAHLWELlyTpo8JVfUBxlGjG1Pb1pWw2hCo1KvxFqMcjTEo6O5Ghuzwjprv5rU8dNOwaSbanork5ct32u_RrILWNSrMZ4WRqv3wDJnGAewMztN2Y8S7K8yfT7AKErUrxv4-1j8EkXPSsFNe1',
      imageLabel: '30 Unit',
      unit: 'Unit',
      icon: Icons.chair_alt_rounded,
      rule: 'Jumlah mengikuti stok tersedia',
    ),
    _CatalogEntry(
      item: InventoryItem(
        id: 'INV-004',
        name: 'Tangga Lipat Aluminium 3.8m',
        category: 'Perkakas',
        description: 'Tangga lipat aluminium dengan pengunci engsel.',
        location: 'Pos Satpam Depan',
        availableStock: 3,
        totalStock: 3,
        condition: 'Kunci engsel kokoh',
      ),
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA1SG6PIGTbNf3BSBU0I6oVLQSynybY68JBqZHWewAhnbMSIu3PYtFPzHEu3BiQrlLqd05ND-UuvlV3WYYReq-UdkYhz2TTIsK7j3SEPwJYOLtKrpGzV5YbNCfg5sDqN3yuXooOM-QqjmTnzr54xabsXPY_F3WV3vJt8U0laq0qGutTryq32CQJTUHbzwQ3u2xjdWs-Fc27eV-FC3ju3B6Wp1vbXl4v50Yxh8busAHu',
      imageLabel: '3 Unit',
      unit: 'Unit',
      icon: Icons.stairs_rounded,
      rule: 'Jumlah mengikuti stok tersedia',
      note: 'Wajib hati-hati dekat kabel PLN.',
      noteIcon: Icons.warning_amber_rounded,
      noteColor: _orange,
    ),
    _CatalogEntry(
      item: InventoryItem(
        id: 'INV-005',
        name: 'Cangkul & Sekop Gotong Royong',
        category: 'Kebersihan',
        description: 'Alat kerja bakti untuk kegiatan kebersihan warga.',
        location: 'Gudang Kerja Bakti',
        availableStock: 12,
        totalStock: 12,
        condition: 'Mata cangkul tajam & bersih',
      ),
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAcd6R7Sh8G4Tpnhb1Ql3dI5Wq4UOAzLmX3Kd5BfGZGFFzQWIOiaiXwKwmhFKrABw67XF78LgseXLIY_WGeF4zF8UW_nTkzcELzHBdFd2oMj1LRISy50zwtr151273FQcQc4tUVimHohfZ0N0XRev1Xr2CDxw6sI33b1AAbSvLAxh1ImY-Nw4a1xGNvKzso9EITmTIyBDmSxOFMhQDmu6SLYk7f5lM1h6UpxMgojGE3',
      imageLabel: '12 Unit',
      unit: 'Unit',
      icon: Icons.agriculture_rounded,
      rule: 'Jumlah mengikuti stok tersedia',
      note: 'Cuci bersih sebelum dikembalikan.',
      noteIcon: Icons.cleaning_services_rounded,
    ),
    _CatalogEntry(
      item: InventoryItem(
        id: 'INV-006',
        name: 'Sound System & Mic Wireless',
        category: 'Sound System',
        description: 'Sound system portable dengan mikrofon wireless.',
        location: 'Rumah Bpk. RT (No. 01)',
        availableStock: 1,
        totalStock: 1,
        condition: 'Baterai penuh • Bluetooth aktif',
      ),
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD-5IcFDZEdayolDQsbW4iT9Ziqvrb8rU-KcmZPKsECqLddFpZpvx2c1egCL78JfIzlqQRHtBfVnPgkYI9Qi2QySncbmqN-G62Y7Pxe0rYtUZlDXYIfwdJc3NIpCcIBHqG-MR2A8ZDG5IGzmM4ndCx2Uz2k1jiRLvve5ZZZbrjjUfsgiEh8CWiQ0kCclPLFS9Y442T_oRD9O2WbwD6YQ4jppewkdDrift3jCFD-YemR',
      imageLabel: '1 Set',
      unit: 'Set',
      icon: Icons.speaker_rounded,
      rule: '1 Set per pengajuan',
      note: 'Termasuk mikrofon wireless.',
      noteIcon: Icons.mic_rounded,
    ),
    _CatalogEntry(
      item: InventoryItem(
        id: 'INV-007',
        name: 'Meja Lipat Serbaguna',
        category: 'Tenda & Panggung',
        description: 'Meja lipat untuk rapat, hajatan, dan kegiatan warga.',
        location: 'Gudang Utama RT',
        availableStock: 5,
        totalStock: 5,
        condition: 'Baik',
      ),
      imageLabel: '5 Unit',
      unit: 'Unit',
      icon: Icons.table_restaurant_rounded,
      rule: 'Jumlah mengikuti stok tersedia',
    ),
    _CatalogEntry(
      item: InventoryItem(
        id: 'INV-008',
        name: 'Lampu Sorot Portable',
        category: 'Perlengkapan Acara',
        description: 'Lampu sorot untuk kegiatan malam dan luar ruangan.',
        location: 'Gudang Peralatan RT',
        availableStock: 2,
        totalStock: 2,
        condition: 'Baik',
      ),
      imageLabel: '2 Unit',
      unit: 'Unit',
      icon: Icons.lightbulb_rounded,
      rule: 'Jumlah mengikuti stok tersedia',
    ),
    _CatalogEntry(
      item: InventoryItem(
        id: 'INV-009',
        name: 'Dispenser Air Panas Portable',
        category: 'Perlengkapan Acara',
        description: 'Dispenser untuk konsumsi kegiatan dan pertemuan warga.',
        location: 'Gudang Utama RT',
        availableStock: 2,
        totalStock: 2,
        condition: 'Baik',
      ),
      imageLabel: '2 Unit',
      unit: 'Unit',
      icon: Icons.local_drink_rounded,
      rule: 'Jumlah mengikuti stok tersedia',
    ),
    _CatalogEntry(
      item: InventoryItem(
        id: 'INV-010',
        name: 'Megafon',
        category: 'Sound System',
        description: 'Megafon untuk koordinasi kegiatan dan informasi warga.',
        location: 'Pos Satpam Depan',
        availableStock: 2,
        totalStock: 2,
        condition: 'Baik',
      ),
      imageLabel: '2 Unit',
      unit: 'Unit',
      icon: Icons.campaign_outlined,
      rule: 'Jumlah mengikuti stok tersedia',
    ),
  ];

  int get _totalInventory =>
      _sampleItems.fold(0, (sum, entry) => sum + entry.item.totalStock);

  int get _availableInventory =>
      _sampleItems.fold(0, (sum, entry) => sum + entry.item.availableStock);

  int get _borrowedInventory =>
      _sampleItems.fold(0, (sum, entry) => sum + entry.item.borrowedStock);

  List<_CatalogEntry> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();

    final result = _sampleItems.where((entry) {
      final categoryMatches = _selectedCategory == 'Semua' ||
          entry.item.category == _selectedCategory;

      final queryMatches = query.isEmpty ||
          entry.item.name.toLowerCase().contains(query) ||
          entry.item.category.toLowerCase().contains(query) ||
          entry.item.location.toLowerCase().contains(query);

      final availabilityMatches = !_onlyAvailable || entry.item.isAvailable;

      return categoryMatches && queryMatches && availabilityMatches;
    }).toList();

    if (_availableFirst) {
      result.sort((a, b) {
        if (a.item.isAvailable == b.item.isAvailable) return 0;
        return a.item.isAvailable ? -1 : 1;
      });
    }

    return result;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Container(
      color: _background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          _buildInventorySummary(),
          const SizedBox(height: 13),
          _buildSearchBar(),
          const SizedBox(height: 10),
          _buildCategoryChips(),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Katalog Sarana RT 05',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
              ),
              Text(
                '${items.length} Barang',
                style: GoogleFonts.inter(fontSize: 9, color: _muted),
              ),
            ],
          ),
          const SizedBox(height: 11),
          if (items.isEmpty)
            _buildEmptyState()
          else
            ...items.map(_buildInventoryCard),
          const SizedBox(height: 8),
          _buildBorrowingRules(),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'DATA SIMULASI • BELUM TERHUBUNG KE SERVER',
              style: GoogleFonts.inter(
                fontSize: 9,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
                color: _muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087A43), Color(0xFF075A35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.16),
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
              const Icon(Icons.inventory_2_rounded,
                  color: Colors.white, size: 21),
              const SizedBox(width: 8),
              Text(
                'INVENTARIS SARANA RT 05',
                style: GoogleFonts.inter(
                  color: const Color(0xFFC9F5D8),
                  fontSize: 9,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$_totalInventory Unit / Set',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '${_sampleItems.length} jenis inventaris tercatat',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryValue('Tersedia', '$_availableInventory'),
              const SizedBox(width: 22),
              _summaryValue('Dipinjam', '$_borrowedInventory'),
              const SizedBox(width: 22),
              _summaryValue('Total', '$_totalInventory'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _line),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              style: GoogleFonts.inter(fontSize: 11, color: _text),
              decoration: InputDecoration(
                hintText: 'Cari cangkul, kursi, tenda...',
                hintStyle: GoogleFonts.inter(fontSize: 10, color: _muted),
                prefixIcon:
                    const Icon(Icons.search_rounded, size: 19, color: _muted),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded, size: 16),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: _showFilterSheet,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _line),
              ),
              child: const Icon(Icons.tune_rounded, color: _text, size: 19),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = _selectedCategory == category;

          return ChoiceChip(
            label: Text(category),
            selected: selected,
            onSelected: (_) => setState(() {
              _selectedCategory = category;
            }),
            showCheckmark: false,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            labelStyle: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF65716A),
            ),
            selectedColor: _green,
            backgroundColor: Colors.white,
            side: BorderSide(color: selected ? _green : _line),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 7),
          );
        },
      ),
    );
  }

  Widget _buildInventoryCard(_CatalogEntry entry) {
    final item = entry.item;
    final available = item.isAvailable;
    final reminderAdded = _reminderItems.contains(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFF0F2F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemImage(entry),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatusBadge(entry)),
                        const SizedBox(width: 4),
                        Icon(entry.icon, size: 17, color: _muted),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: _text,
                        fontSize: 12,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded,
                            color: _green, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.condition,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: _muted,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildRuleLine(entry),
                    if (entry.note != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            entry.noteIcon ?? Icons.info_outline_rounded,
                            color: entry.noteColor ?? _green,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              entry.note!,
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                height: 1.2,
                                color: entry.noteColor ?? _muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: const Color(0xFFF1F3F1)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: _muted, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 9, color: _muted),
                ),
              ),
              const SizedBox(width: 6),
              if (available)
                SizedBox(
                  height: 34,
                  child: FilledButton(
                    onPressed: () => _openLoanForm(entry),
                    style: FilledButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pinjam Alat',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 33,
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleReminder(entry, reminderAdded),
                    icon: Icon(
                      reminderAdded
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      size: 14,
                    ),
                    label: Text(
                      reminderAdded ? 'Diingatkan' : 'Ingatkan Saya',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5366A5),
                      backgroundColor: const Color(0xFFF1F3FF),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(_CatalogEntry entry) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: SizedBox(
        width: 94,
        height: 96,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (entry.imageUrl != null)
              Image.network(
                entry.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imageFallback(entry),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFFEAF0EB),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _green,
                      ),
                    ),
                  );
                },
              )
            else
              _imageFallback(entry),
            Positioned(
              right: 5,
              bottom: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  entry.imageLabel,
                  style: GoogleFonts.inter(
                    color: _text,
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(_CatalogEntry entry) {
    return Container(
      color: const Color(0xFFEAF0EB),
      alignment: Alignment.center,
      child: Icon(entry.icon, color: _green, size: 32),
    );
  }

  Widget _buildStatusBadge(_CatalogEntry entry) {
    final available = entry.item.isAvailable;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: available ? const Color(0xFFE8F7ED) : const Color(0xFFFFF2DB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          available
              ? 'Tersedia ${entry.item.availableStock} ${entry.unit}'
              : 'Stok Habis',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: available ? _green : _orange,
            fontSize: 7,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildRuleLine(_CatalogEntry entry) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.rule_rounded, color: _green, size: 12),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            entry.rule,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _green,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '• Maks. 3 hari',
          style: GoogleFonts.inter(fontSize: 8, color: _muted),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: _greenSoft,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.search_off_rounded, color: _green, size: 27),
          ),
          const SizedBox(height: 12),
          Text(
            'Barang tidak ditemukan',
            style: GoogleFonts.plusJakartaSans(
              color: _text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Coba kata kunci lain atau ubah kategori pencarian.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _muted,
              fontSize: 10,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 13),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _selectedCategory = 'Semua';
                _onlyAvailable = false;
              });
            },
            child: Text(
              'Reset Pencarian',
              style: GoogleFonts.inter(
                color: _green,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBorrowingRules() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E4FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.badge_outlined,
                color: Color(0xFF5366A5), size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aturan Peminjaman Sarana RT 05',
                  style: GoogleFonts.plusJakartaSans(
                    color: _text,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Peminjaman bebas biaya untuk warga terdaftar di RT 05. '
                  'Masa pinjam maksimal 3 hari berturut-turut. '
                  'Jumlah barang mengikuti stok tersedia.',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF626B7C),
                    fontSize: 9,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _ruleTag('Sesuai Stok'),
                    _ruleTag('Tanpa Uang Jaminan'),
                    _ruleTag('Maks. 3 Hari'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleTag(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, color: _green, size: 11),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            color: _green,
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Future<void> _showFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDE3DE),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Filter Katalog',
                      style: GoogleFonts.plusJakartaSans(
                        color: _text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: _green,
                      title: Text(
                        'Tampilkan barang tersedia saja',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Sembunyikan barang yang stoknya habis',
                        style: GoogleFonts.inter(fontSize: 10, color: _muted),
                      ),
                      value: _onlyAvailable,
                      onChanged: (value) {
                        setState(() => _onlyAvailable = value);
                        sheetSetState(() {});
                      },
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: _green,
                      title: Text(
                        'Prioritaskan barang tersedia',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Barang tersedia ditampilkan lebih dahulu',
                        style: GoogleFonts.inter(fontSize: 10, color: _muted),
                      ),
                      value: _availableFirst,
                      onChanged: (value) {
                        setState(() => _availableFirst = value);
                        sheetSetState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: FilledButton.styleFrom(
                          backgroundColor: _green,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'Terapkan Filter',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openLoanForm(_CatalogEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LoanFormPage(
          item: entry.item,
          imageUrl: entry.imageUrl,
        ),
      ),
    );
  }

  void _toggleReminder(_CatalogEntry entry, bool alreadyAdded) {
    setState(() {
      if (alreadyAdded) {
        _reminderItems.remove(entry.item.id);
      } else {
        _reminderItems.add(entry.item.id);
      }
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            alreadyAdded
                ? 'Pengingat ${entry.item.name} dibatalkan.'
                : 'Pengingat ditambahkan (simulasi lokal).',
          ),
        ),
      );
  }
}

class _CatalogEntry {
  const _CatalogEntry({
    required this.item,
    this.imageUrl,
    required this.imageLabel,
    required this.unit,
    required this.icon,
    required this.rule,
    this.note,
    this.noteIcon,
    this.noteColor,
  });

  final InventoryItem item;
  final String? imageUrl;
  final String imageLabel;
  final String unit;
  final IconData icon;
  final String rule;
  final String? note;
  final IconData? noteIcon;
  final Color? noteColor;
}
