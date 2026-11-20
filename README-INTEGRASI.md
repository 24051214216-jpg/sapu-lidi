# SapuLidi - Implementasi UI Inventaris & Peminjaman

Patch ini berisi:
- `frontend/lib/features/inventory/domain/entities/inventory_item.dart`
- `frontend/lib/features/inventory/presentation/pages/inventory_catalog_page.dart`
- `frontend/lib/features/inventory/presentation/pages/loan_form_page.dart`
- `frontend/lib/features/home/presentation/pages/main_shell_page.dart` (versi lengkap dengan tab Inventaris diarahkan ke katalog)

## Penerapan
Salin folder `frontend` dari ZIP ini ke `D:\sapu-lidi\frontend` dengan mempertahankan struktur folder dan izinkan penggantian `main_shell_page.dart`.

## Batas implementasi saat ini
- UI katalog dan formulir peminjaman berjalan secara lokal.
- Tidak ada data barang contoh yang ditanam sebagai data produksi.
- Katalog menampilkan empty state sampai data inventaris disediakan oleh backend/repository.
- Form hanya memvalidasi input dan tidak mengirim permohonan atau mengurangi stok.
- Tidak ada file backend, database, migrasi, atau `.env` yang diubah.
- Aturan UI: durasi maksimal 3 hari; batas jumlah per pengajuan mengikuti stok tersedia dan konfigurasi per barang (`maxPerRequest` null berarti mengikuti stok tersedia).
