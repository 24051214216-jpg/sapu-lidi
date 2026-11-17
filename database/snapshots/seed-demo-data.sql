-- ============================================================================
-- Sapu Lidi - Data awal (referensi) untuk demo (PostgreSQL)
-- Jalankan SETELAH schema.sql. Akun pengguna TIDAK dibuat di sini karena butuh
-- password hash bcrypt; akun demo dibuat lewat backend/prisma/seed.js.
-- ============================================================================

-- Wilayah demo (data fiktif)
INSERT INTO neighborhoods
  (name, rt, rw, kelurahan, kecamatan, city, latitude, longitude,
   bank_name, bank_account_number, bank_account_name)
VALUES
  ('RT 05 / RW 08 Menteng Asri', '05', '08', 'Menteng Atas', 'Setiabudi',
   'Jakarta Selatan', -6.1944000, 106.8229000,
   'Bank Mandiri', '1370019283740', 'KAS RT 05 MENTENG ASRI');

-- Kategori siaga darurat (dari layar Tombol Siaga Darurat)
INSERT INTO emergency_categories (code, name, title, description, icon) VALUES
  ('security', 'Pos Ronda',     'Pencurian & Kamtib', 'Penyusup, keributan, atau gerak-gerik mencurigakan', 'local_police'),
  ('fire',     'Damkar & Warga','Kebakaran / Gas',    'Ledakan tabung, korsleting listrik & api rumah',      'mode_heat'),
  ('medical',  'Ambulans RW',   'Darurat Medis',      'Serangan jantung, pingsan & luka kritis warga',       'medical_services'),
  ('disaster', 'Tim Reaksi',    'Pohon & Bencana',    'Pohon roboh, kabel putus & genangan air parah',       'storm');

-- Jenis iuran (dari layar Keuangan: 65.000 + 60.000 + 25.000 = 150.000)
INSERT INTO bill_types (neighborhood_id, code, name, default_amount)
SELECT n.id, v.code, v.name, v.amount
FROM neighborhoods n
CROSS JOIN (VALUES
  ('sanitation', 'Iuran Kebersihan & Sampah',  65000),
  ('security',   'Iuran Keamanan / Satpam',    60000),
  ('social',     'Dana Sosial & Kas Kematian', 25000)
) AS v(code, name, amount)
WHERE n.rt = '05' AND n.rw = '08';

-- Kategori berita
INSERT INTO announcement_categories (code, name) VALUES
  ('official',    'Pengumuman Resmi'),
  ('environment', 'Kebersihan & Lingkungan'),
  ('security',    'Keamanan'),
  ('social',      'Bansos & Layanan'),
  ('resident',    'Warta Warga');

-- Jenis surat (dari layar Form Pengajuan E-Surat)
INSERT INTO letter_types (neighborhood_id, code, name, description, icon, is_popular)
SELECT n.id, v.code, v.name, v.description, v.icon, v.is_popular
FROM neighborhoods n
CROSS JOIN (VALUES
  ('skck',     'Pengantar SKCK',                  'Keperluan Kepolisian / Rekrutmen Kerja / BUMN',            'policy',                    TRUE),
  ('domicile', 'Surat Keterangan Domisili',       'Bukti tempat tinggal sementara / buka rekening bank',      'location_away',             FALSE),
  ('marriage', 'Pengantar Nikah (Model N1-N4)',   'Pengurusan pendaftaran pernikahan di KUA / Catatan Sipil', 'favorite',                  FALSE),
  ('business', 'Keterangan Usaha (SKU)',          'Pengajuan KUR UMKM, izin usaha mikro, perbankan',          'storefront',                FALSE),
  ('moving',   'Pindah Domisili / Ket. Kematian', 'Penerbitan surat jalan pindah KK atau akta lelayu',        'transfer_within_a_station', FALSE)
) AS v(code, name, description, icon, is_popular)
WHERE n.rt = '05' AND n.rw = '08';

-- Alur persetujuan dinamis per jenis surat
INSERT INTO letter_type_steps (letter_type_id, step_order, approver_role, label)
SELECT id, 1, 'rt_admin'::approver_role, 'Verifikasi Ketua RT'
FROM letter_types;

INSERT INTO letter_type_steps (letter_type_id, step_order, approver_role, label)
SELECT id, 2, 'super_admin'::approver_role, 'Pengesahan Pengurus RW'
FROM letter_types
WHERE code IN ('marriage', 'moving');

-- Inventaris alat RT (dari layar Katalog Inventaris)
INSERT INTO inventory_items (neighborhood_id, name, description, category, total_stock)
SELECT n.id, v.name, v.description, v.category, v.total_stock
FROM neighborhoods n
CROSS JOIN (VALUES
  ('Tenda Terop 4x6m',              'Tenda untuk hajatan dan kegiatan warga', 'Perlengkapan Acara', 2),
  ('Tangga Lipat Aluminium 3.8m',   'Tangga lipat aluminium',                 'Perkakas',           3),
  ('Mesin Rumput Dorong Honda',     'Mesin pemotong rumput',                  'Perkakas',           1),
  ('Kursi Lipat Chitose',           'Kursi lipat untuk acara warga',          'Perlengkapan Acara', 100),
  ('Cangkul & Sekop Gotong Royong', 'Peralatan kerja bakti',                  'Perkakas',           10),
  ('Sound System & Mic Wireless',   'Pengeras suara untuk kegiatan warga',    'Elektronik',         1)
) AS v(name, description, category, total_stock)
WHERE n.rt = '05' AND n.rw = '08';
