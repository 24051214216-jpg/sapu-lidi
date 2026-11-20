class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.location,
    required this.availableStock,
    required this.totalStock,
    this.condition = 'Baik',
    this.maxPerRequest,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final String location;
  final int availableStock;
  final int totalStock;
  final String condition;

  /// Null berarti batas peminjaman mengikuti stok tersedia.
  final int? maxPerRequest;

  /// Jumlah barang yang sedang dipinjam.
  int get borrowedStock {
    final borrowed = totalStock - availableStock;
    return borrowed < 0 ? 0 : borrowed;
  }

  /// Batas maksimum peminjaman dalam satu pengajuan.
  int get effectiveMaxRequest {
    if (availableStock <= 0) return 0;

    final configuredMax = maxPerRequest;

    if (configuredMax == null) return availableStock;
    if (configuredMax <= 0) return 0;

    return availableStock < configuredMax ? availableStock : configuredMax;
  }

  bool get isAvailable => availableStock > 0;
}
