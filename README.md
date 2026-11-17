# Sapu Lidi

> Super-app digital untuk Rukun Tetangga (RT) / Rukun Warga (RW): kas & iuran, e-surat,
> buku tamu, siaga darurat (SOS), inventaris alat, absensi kerja bakti, dan warta warga.

| | |
|---|---|
| **Nama** | Naufal Daffa Wimasurya |
| **NIM** | 24051214216 |
| **Mata Kuliah** | Pemrograman Aplikasi Bergerak (Tugas Akhir, individu) |
| **Judul** | Sapu Lidi: Super-App Layanan Warga RT/RW Berbasis Flutter dan Node.js |

## Abstrak (draf, sesuaikan nanti)

Sapu Lidi adalah aplikasi mobile untuk mendigitalkan layanan administrasi dan keamanan
lingkungan RT/RW. Warga dapat membayar iuran dan memantau transparansi kas, mengajukan
e-surat, melapor tamu menginap, meminjam inventaris, melakukan absensi kegiatan berbasis
kamera dan lokasi, serta menekan tombol siaga darurat yang diteruskan ke petugas ronda
secara real-time. Pengurus RT memverifikasi pembayaran, menyetujui surat, dan menyiarkan
pengumuman.

## Struktur Repository

```
sapu-lidi/
├── frontend/   Flutter (Clean Architecture + Feature-First, Cubit/BLoC)
├── api/        Kontrak API: OpenAPI, Postman, contoh request/response
├── backend/    Node.js + Express (Route > Controller > Service > Repository > Resource)
├── database/   Desain DB: ERD, kamus data, snapshot SQL (PostgreSQL, dikelola via DBeaver)
└── docs/       UCD (Double Diamond), ADR, traceability, artikel ilmiah, bahan video
```

## Aturan Emas

Flutter tidak pernah berbicara langsung ke database. Alurnya selalu
Flutter (klien) > API Node.js > PostgreSQL.
