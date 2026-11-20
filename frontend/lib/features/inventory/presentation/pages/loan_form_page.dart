import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/inventory_item.dart';

class LoanFormPage extends StatefulWidget {
  final InventoryItem item;
  final String? imageUrl;

  const LoanFormPage({
    super.key,
    required this.item,
    this.imageUrl,
  });

  @override
  State<LoanFormPage> createState() => _LoanFormPageState();
}

class _LoanFormPageState extends State<LoanFormPage> {
  static const Color _green = Color(0xFF006130);
  static const Color _greenLight = Color(0xFFEAF5EE);
  static const Color _background = Color(0xFFF6F8F6);
  static const Color _textDark = Color(0xFF202820);
  static const Color _textMuted = Color(0xFF788078);
  static const Color _border = Color(0xFFE4EAE5);
  static const Color _orange = Color(0xFFE58A26);

  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  final List<String> _eventTypes = [
    'Hajatan & Syukuran',
    'Pengajian / Tahlilan',
    'Keluarga Berduka',
    'Kerja Bakti',
    'Kegiatan Keluarga Lainnya',
  ];

  String? _selectedEvent;

  late DateTime _startDate;
  late DateTime _endDate;

  int _quantity = 1;

  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  int get _maxQuantity {
    final available = widget.item.availableStock;
    final limit = widget.item.maxPerRequest;

    if (available <= 0) return 0;

    if (limit == null) return available;

    return available < limit ? available : limit;
  }

  int get _borrowedStock {
    final borrowed = widget.item.totalStock - widget.item.availableStock;

    return borrowed < 0 ? 0 : borrowed;
  }

  int get _duration {
    return _endDate.difference(_startDate).inDays + 1;
  }

  bool get _isAvailable {
    return widget.item.availableStock > 0;
  }

  @override
  void initState() {
    super.initState();

    _startDate = _today.add(const Duration(days: 1));
    _endDate = _startDate.add(const Duration(days: 1));

    if (_maxQuantity > 0) {
      _quantity = 1;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: _textMuted,
        fontSize: 12,
      ),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _green,
          width: 1.5,
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate.isBefore(_today) ? _today : _startDate,
      firstDate: _today,
      lastDate: _today.add(const Duration(days: 365)),
      helpText: 'Pilih tanggal mulai peminjaman',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      _startDate = DateTime(
        selected.year,
        selected.month,
        selected.day,
      );

      if (_endDate.isBefore(_startDate)) {
        _endDate = _startDate;
      }

      if (_endDate.difference(_startDate).inDays >= 3) {
        _endDate = _startDate.add(const Duration(days: 2));
      }
    });
  }

  Future<void> _selectEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 2)),
      helpText: 'Pilih tanggal pengembalian',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      _endDate = DateTime(
        selected.year,
        selected.month,
        selected.day,
      );
    });
  }

  void _changeQuantity(int amount) {
    final nextQuantity = _quantity + amount;

    if (nextQuantity < 1 || nextQuantity > _maxQuantity) {
      return;
    }

    setState(() {
      _quantity = nextQuantity;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_isAvailable) {
      _showMessage('Maaf, stok barang sedang tidak tersedia.');
      return;
    }

    if (_quantity < 1 || _quantity > _maxQuantity) {
      _showMessage('Jumlah barang melebihi stok yang tersedia.');
      return;
    }

    if (_selectedEvent == null) {
      _showMessage('Silakan pilih jenis kegiatan terlebih dahulu.');
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      _showMessage('Lokasi penggunaan barang wajib diisi.');
      return;
    }

    if (!_agreedToTerms) {
      _showMessage('Silakan setujui ketentuan peminjaman.');
      return;
    }

    if (_duration < 1 || _duration > 3) {
      _showMessage('Durasi peminjaman maksimal 3 hari.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: _greenLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: _green,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Simulasi Pengajuan Berhasil!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Simulasi pengajuan ${widget.item.name} '
                  'sebanyak $_quantity '
                  'untuk ${_formatShortDate(_startDate)} '
                  'sampai ${_formatShortDate(_endDate)} berhasil.\n\n'
                  'Data belum dikirim atau disimpan ke server.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.7,
                    color: _textMuted,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Kembali ke Katalog',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
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

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: _textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: _textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _stockCard({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 19),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: _textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectedItemCard() {
    final item = widget.item;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 92,
                  height: 92,
                  color: _background,
                  child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.inventory_2_outlined,
                              size: 35,
                              color: _green,
                            );
                          },
                        )
                      : const Icon(
                          Icons.inventory_2_outlined,
                          size: 35,
                          color: _green,
                        ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _greenLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category,
                        style: GoogleFonts.poppins(
                          color: _green,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        color: _textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: _green,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.condition,
                            style: GoogleFonts.poppins(
                              color: _textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.volunteer_activism_outlined,
                          color: _green,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'GRATIS',
                          style: GoogleFonts.poppins(
                            color: _green,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.description,
              style: GoogleFonts.poppins(
                color: _textMuted,
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ],
          const SizedBox(height: 14),
          _sectionTitle('Informasi Ketersediaan Stok'),
          const SizedBox(height: 10),
          Row(
            children: [
              _stockCard(
                label: 'Total inventaris',
                value: item.totalStock,
                color: _green,
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(width: 8),
              _stockCard(
                label: 'Tersedia',
                value: item.availableStock,
                color: const Color(0xFF238B58),
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 8),
              _stockCard(
                label: 'Dipinjam',
                value: _borrowedStock,
                color: _orange,
                icon: Icons.pending_actions_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _metaRow(
                  Icons.warehouse_outlined,
                  'Lokasi Simpan',
                  item.location,
                ),
                const SizedBox(height: 8),
                _metaRow(
                  Icons.person_pin_circle_outlined,
                  'Sie Sarana',
                  'Pak Joko (Bpk. Joko Susilo)',
                ),
              ],
            ),
          ),
          if (!_isAvailable) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F0),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Stok barang sedang habis. Pengajuan belum dapat dilakukan.',
                      style: GoogleFonts.poppins(
                        color: Colors.red.shade700,
                        fontSize: 10,
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

  Widget _metaRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: _green),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: _textMuted,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: _textDark,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _quantityCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Jumlah Barang',
            subtitle: 'Tentukan jumlah barang yang ingin dipinjam.',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Jumlah pinjam',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _quantityButton(
                icon: Icons.remove,
                enabled: _isAvailable && _quantity > 1,
                onTap: () => _changeQuantity(-1),
              ),
              Container(
                width: 48,
                alignment: Alignment.center,
                child: Text(
                  _quantity.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
              _quantityButton(
                icon: Icons.add,
                enabled: _isAvailable && _quantity < _maxQuantity,
                onTap: () => _changeQuantity(1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _greenLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: _green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Stok tersedia: ${widget.item.availableStock}. '
                    'Maksimal jumlah pengajuan ini: $_maxQuantity.',
                    style: GoogleFonts.poppins(
                      color: _green,
                      fontSize: 10,
                      height: 1.5,
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

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: enabled ? _greenLight : _background,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 35,
          height: 35,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? _green : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _dateCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Jadwal Peminjaman',
            subtitle: 'Atur tanggal pengambilan dan pengembalian barang.',
          ),
          const SizedBox(height: 14),
          _dateSelector(
            title: 'Tanggal Mulai Pinjam',
            date: _startDate,
            icon: Icons.calendar_today_outlined,
            onTap: _selectStartDate,
          ),
          const SizedBox(height: 12),
          _dateSelector(
            title: 'Tanggal Pengembalian',
            date: _endDate,
            icon: Icons.event_available_outlined,
            onTap: _selectEndDate,
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: _greenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_outlined,
                  size: 17,
                  color: _green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Durasi: $_duration hari. '
                    'Pengambilan pukul 08.00 WIB dan '
                    'pengembalian pukul 18.00 WIB. '
                    'Maksimal peminjaman 3 hari.',
                    style: GoogleFonts.poppins(
                      color: _green,
                      fontSize: 10,
                      height: 1.5,
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

  Widget _dateSelector({
    required String title,
    required DateTime date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 17, color: _green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: GoogleFonts.poppins(
                      color: _textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _eventSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Detail Kegiatan',
            subtitle: 'Berikan informasi penggunaan barang.',
          ),
          const SizedBox(height: 14),
          Text(
            'Jenis Kegiatan',
            style: GoogleFonts.poppins(
              color: _textDark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedEvent,
            isExpanded: true,
            decoration: _inputDecoration(
              hint: 'Pilih jenis kegiatan',
              prefixIcon: const Icon(
                Icons.event_note_outlined,
                color: _green,
                size: 19,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _textMuted,
            ),
            items: _eventTypes.map((event) {
              return DropdownMenuItem<String>(
                value: event,
                child: Text(
                  event,
                  style: GoogleFonts.poppins(fontSize: 11),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEvent = value;
              });
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Lokasi Penggunaan',
            style: GoogleFonts.poppins(
              color: _textDark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _locationController,
            style: GoogleFonts.poppins(
              color: _textDark,
              fontSize: 12,
            ),
            decoration: _inputDecoration(
              hint: 'Contoh: Rumah Bpk. Budi, RT 03',
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: _green,
                size: 19,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Catatan Tambahan (Opsional)',
            style: GoogleFonts.poppins(
              color: _textDark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: GoogleFonts.poppins(
              color: _textDark,
              fontSize: 12,
            ),
            decoration: _inputDecoration(
              hint: 'Tambahkan informasi lain jika diperlukan...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _termsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _agreedToTerms,
            activeColor: _green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    color: _textMuted,
                    fontSize: 10,
                    height: 1.6,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Saya menyetujui ',
                    ),
                    TextSpan(
                      text: 'ketentuan peminjaman inventaris RT',
                      style: TextStyle(
                        color: _green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ', menjaga kondisi barang, dan '
                          'mengembalikannya sesuai jadwal yang telah '
                          'ditentukan.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    final enabled = _isAvailable && !_isSubmitting;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.send_rounded,
                    size: 17,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    _isAvailable ? 'Ajukan Peminjaman' : 'Stok Tidak Tersedia',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _textDark,
          ),
        ),
        title: Text(
          'Form Peminjaman',
          style: GoogleFonts.poppins(
            color: _textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajukan Peminjaman Inventaris',
                style: GoogleFonts.poppins(
                  color: _textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lengkapi informasi berikut untuk mengajukan '
                'peminjaman barang inventaris RT.',
                style: GoogleFonts.poppins(
                  color: _textMuted,
                  fontSize: 11,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              _selectedItemCard(),
              const SizedBox(height: 16),
              _quantityCard(),
              const SizedBox(height: 16),
              _dateCard(),
              const SizedBox(height: 16),
              _eventSection(),
              const SizedBox(height: 16),
              _termsCard(),
              const SizedBox(height: 20),
              _submitButton(),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Simulasi lokal • Belum terhubung ke server',
                  style: GoogleFonts.poppins(
                    color: _textMuted,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
