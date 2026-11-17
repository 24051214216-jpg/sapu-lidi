# Database Sapu Lidi (PostgreSQL + DBeaver)

Skema database adalah sumber kebenaran tunggal (SSOT). Flutter tidak pernah terhubung
langsung ke database; hanya backend Node.js yang boleh.

| File | Fungsi |
|---|---|
| `snapshots/schema.sql` | Membuat 30 tabel, 19 tipe ENUM, dan trigger `updated_at` |
| `snapshots/seed-demo-data.sql` | Data referensi (kategori SOS, jenis iuran, jenis surat, inventaris) |
| `erd/sapulidi-erd.png` | Diagram ERD (diekspor dari DBeaver) |

Kedua file SQL sudah diuji di PostgreSQL 16 (jalan dua kali tanpa error, jumlah tabel dan
seed sesuai). Versi minimum: PostgreSQL 14.

## Langkah 1: Pasang PostgreSQL

Unduh installer dari https://www.postgresql.org/download/windows/ (tombol *Download the installer*,
dikelola EDB), pilih versi 16 atau 17. Saat instalasi:

- Komponen: centang **PostgreSQL Server** dan **Command Line Tools**. Stack Builder boleh dilewati.
- **Password** untuk superuser `postgres`: isi dan **catat**.
- Port: biarkan `5432`.

Verifikasi (buka PowerShell baru):

```powershell
Get-Service postgresql*
```

Statusnya harus `Running`. Perintah `psql` boleh tidak dikenali; DBeaver tidak membutuhkannya.

## Langkah 2: Sambungkan DBeaver

1. Database > New Database Connection > **PostgreSQL** > Next.
2. Isi: Host `localhost`, Port `5432`, Database `postgres`, Username `postgres`, Password (langkah 1).
3. Klik **Test Connection**. Jika diminta mengunduh driver, klik Download.
4. Finish.

## Langkah 3: Buat database `sapulidi`

Klik kanan koneksi > SQL Editor > New SQL script, jalankan:

```sql
CREATE DATABASE sapulidi;
```

Lalu arahkan koneksi ke database baru: klik kanan koneksi > Edit Connection, ubah kolom
**Database** dari `postgres` menjadi `sapulidi`, OK. (Penting: skema harus dijalankan di
dalam `sapulidi`, bukan di `postgres`.)

## Langkah 4: Jalankan skema

1. File > Open File, pilih `database/snapshots/schema.sql`. Pastikan editor terhubung ke
   koneksi yang mengarah ke `sapulidi`.
2. Jalankan seluruh skrip dengan **Alt+X** (Execute Script), bukan Ctrl+Enter.
3. Refresh koneksi (F5), buka *Schemas > public > Tables*.

Verifikasi, hasilnya harus `30`:

```sql
SELECT COUNT(*) AS jumlah_tabel
FROM information_schema.tables
WHERE table_schema = 'public';
```

Skrip aman dijalankan ulang: ia menghapus dan membuat ulang semua tabel (data ikut hilang).

## Langkah 5: Isi data referensi

Buka dan jalankan `database/snapshots/seed-demo-data.sql` (Alt+X). Verifikasi:

```sql
SELECT 'neighborhoods' AS tabel, COUNT(*) AS jumlah FROM neighborhoods
UNION ALL SELECT 'emergency_categories', COUNT(*) FROM emergency_categories
UNION ALL SELECT 'bill_types', COUNT(*) FROM bill_types
UNION ALL SELECT 'announcement_categories', COUNT(*) FROM announcement_categories
UNION ALL SELECT 'letter_types', COUNT(*) FROM letter_types
UNION ALL SELECT 'letter_type_steps', COUNT(*) FROM letter_type_steps
UNION ALL SELECT 'inventory_items', COUNT(*) FROM inventory_items;
```

Hasil yang benar: 1, 4, 3, 5, 5, 7, 6.

## Langkah 6: Buat user khusus aplikasi

Backend tidak boleh memakai `postgres`. Jalankan di database `sapulidi` (ganti password,
dan catat):

```sql
CREATE USER sapulidi_app WITH PASSWORD 'GANTI_PASSWORD_KUAT';
GRANT CONNECT ON DATABASE sapulidi TO sapulidi_app;
GRANT USAGE, CREATE ON SCHEMA public TO sapulidi_app;
GRANT ALL ON ALL TABLES IN SCHEMA public TO sapulidi_app;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO sapulidi_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO sapulidi_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO sapulidi_app;
```

Jika nanti skema dijalankan ulang (Langkah 4), jalankan lagi dua baris `GRANT ALL ON ALL ...`.

## Langkah 7: Ekspor ERD

Di DBeaver, buka `sapulidi` > Schemas > public > Tables, pilih semua tabel, klik kanan >
**View Diagram**. Simpan gambar (ikon Save as image) ke `database/erd/sapulidi-erd.png`.

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

- **UUID bawaan PostgreSQL** (`uuid DEFAULT gen_random_uuid()`) di semua tabel yang diakses
  lewat endpoint publik. `id` (identity) hanya dipakai internal, untuk mencegah IDOR.
- **Soft delete (`deleted_at`)** pada data transaksional dan arsip organisasi.
- **Indeks komposit** untuk query daftar yang sering dipakai, mendukung eager loading dan
  menghindari N+1. Pencarian berita memakai indeks GIN full-text.
- **Role berupa tipe ENUM**: menambah divisi baru cukup
  `ALTER TYPE user_role ADD VALUE 'juri';` (efek domino pada materi pertemuan 9).
- **Tahap persetujuan surat dinamis:** `letter_type_steps` (template) disalin ke
  `approval_steps` (per pengajuan), sehingga jumlah tahap tidak di-hardcode di UI Flutter.
- **Constraint di level database**: nominal tidak negatif, tanggal selesai tidak boleh
  sebelum tanggal mulai, stok dan jumlah pinjam valid.
- **Trigger `updated_at`** otomatis di 14 tabel, jadi edit manual lewat DBeaver pun tercatat.
- Password dan OTP hanya disimpan sebagai hash.

## Hubungan dengan Prisma (nanti di backend)

Skema ini yang menjadi acuan. Di backend kita membuat `schema.prisma` dengan
`npx prisma db pull`, lalu `npx prisma generate`. Folder `backend/prisma/migrations/`
tidak dipakai.
