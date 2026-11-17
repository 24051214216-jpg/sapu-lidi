# Database Sapu Lidi (MySQL 8 + DBeaver)

Skema database adalah sumber kebenaran tunggal (SSOT). Flutter tidak pernah terhubung
langsung ke database; hanya backend Node.js yang boleh.

| File | Fungsi |
|---|---|
| `snapshots/schema.sql` | Membuat database `sapulidi` beserta 30 tabel |
| `snapshots/seed-demo-data.sql` | Data referensi (kategori SOS, jenis iuran, jenis surat, inventaris) |
| `erd/sapulidi-erd.png` | Diagram ERD (diekspor dari DBeaver) |

## Langkah 1: Pasang MySQL 8

Unduh **MySQL Installer** dari https://dev.mysql.com/downloads/installer/ , pilih
*Server only*, lalu isi password root dan **catat password tersebut**. Port default `3306`.
Cek instalasi:

```bash
mysql --version
```

## Langkah 2: Sambungkan DBeaver

1. Database > New Database Connection > **MySQL** > Next.
2. Isi: Server Host `localhost`, Port `3306`, Username `root`, Password (dari langkah 1).
3. Klik **Test Connection**. Jika diminta mengunduh driver, klik Download.
4. Jika muncul error `Public Key Retrieval is not allowed`: tab *Driver properties*,
   set `allowPublicKeyRetrieval` = `true`.
5. Finish.

## Langkah 3: Jalankan skema

1. Klik kanan koneksi > SQL Editor > Open SQL script, atau menu File > Open File,
   pilih `database/snapshots/schema.sql`.
2. Jalankan seluruh skrip dengan **Alt+X** (Execute Script), bukan Ctrl+Enter.
3. Klik kanan koneksi > Refresh (F5). Database `sapulidi` akan muncul.

Verifikasi, hasilnya harus `30`:

```sql
SELECT COUNT(*) AS jumlah_tabel
FROM information_schema.tables
WHERE table_schema = 'sapulidi';
```

## Langkah 4: Buat user khusus aplikasi

Backend tidak boleh memakai `root`. Jalankan di SQL Editor (ganti password):

```sql
CREATE USER 'sapulidi_app'@'localhost' IDENTIFIED BY 'GANTI_PASSWORD_KUAT';
GRANT ALL PRIVILEGES ON sapulidi.* TO 'sapulidi_app'@'localhost';
FLUSH PRIVILEGES;
```

## Langkah 5: Isi data referensi

Buka dan jalankan `database/snapshots/seed-demo-data.sql` (Alt+X). Verifikasi:

```sql
USE sapulidi;
SELECT 'neighborhoods' AS tabel, COUNT(*) AS jumlah FROM neighborhoods
UNION ALL SELECT 'emergency_categories', COUNT(*) FROM emergency_categories
UNION ALL SELECT 'bill_types', COUNT(*) FROM bill_types
UNION ALL SELECT 'announcement_categories', COUNT(*) FROM announcement_categories
UNION ALL SELECT 'letter_types', COUNT(*) FROM letter_types
UNION ALL SELECT 'letter_type_steps', COUNT(*) FROM letter_type_steps
UNION ALL SELECT 'inventory_items', COUNT(*) FROM inventory_items;
```

Hasil yang benar: 1, 4, 3, 5, 5, 7, 6.

## Langkah 6: Ekspor ERD

Di DBeaver, buka `sapulidi` > Tables, pilih semua tabel, klik kanan > **View Diagram**.
Simpan gambar (ikon Save as image) ke `database/erd/sapulidi-erd.png`.

## Peta tabel

| Modul | Tabel |
|---|---|
| Wilayah & akun | `neighborhoods`, `households`, `users`, `otp_codes`, `refresh_tokens`, `device_tokens` |
| Siaga darurat | `emergency_categories`, `emergencies`, `emergency_responders`, `emergency_logs` |
| Keuangan | `bill_types`, `bills`, `bill_items`, `payments`, `cash_transactions` |
| Berita | `announcement_categories`, `announcements`, `announcement_likes`, `announcement_comments` |
| E-surat | `letter_types`, `letter_type_steps`, `letter_requests`, `approval_steps` |
| Buku tamu | `guest_reports` |
| Inventaris | `inventory_items`, `loans` |
| Agenda & absensi | `agendas`, `attendances` |
| Sistem | `notifications`, `audit_logs` |

## Keputusan desain (sesuai materi)

- **UUID (`CHAR(36)`)** di semua tabel yang diakses lewat endpoint publik. `id` auto-increment
  hanya dipakai internal, untuk mencegah IDOR (tebak ID).
- **Soft delete (`deleted_at`)** pada data transaksional dan arsip organisasi.
- **Indeks komposit** untuk query daftar yang sering dipakai, mendukung eager loading dan
  menghindari N+1.
- **Role berupa ENUM** di `users.role`: menambah divisi baru cukup menambah nilai ENUM.
- **Tahap persetujuan surat dinamis:** `letter_type_steps` (template) disalin ke
  `approval_steps` (per pengajuan), sehingga jumlah tahap tidak di-hardcode di UI Flutter.
- Password dan OTP hanya disimpan sebagai hash.

## Hubungan dengan Prisma (nanti di backend)

Skema ini yang menjadi acuan. Di backend kita membuat `schema.prisma` dengan
`npx prisma db pull`, lalu `npx prisma generate`. Folder `backend/prisma/migrations/` tidak dipakai.
