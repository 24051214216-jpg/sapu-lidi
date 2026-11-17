-- ============================================================================
-- Sapu Lidi - Skema Database (PostgreSQL 14+)
-- Sumber kebenaran tunggal (SSOT) untuk struktur data.
-- Prinsip dari materi: UUID untuk endpoint publik (anti-IDOR), soft delete
-- (deleted_at) untuk data transaksional, indeks untuk eager loading / hindari N+1.
--
-- Cara menjalankan: lihat database/README.md
-- Prasyarat: database `sapulidi` sudah dibuat dan koneksi DBeaver mengarah ke
-- database tersebut (bukan ke database `postgres`).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. BERSIHKAN (aman dijalankan ulang)
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS audit_logs, notifications, attendances, agendas, loans,
  inventory_items, guest_reports, approval_steps, letter_requests,
  letter_type_steps, letter_types, announcement_comments, announcement_likes,
  announcements, announcement_categories, cash_transactions, payments,
  bill_items, bills, bill_types, emergency_logs, emergency_responders,
  emergencies, emergency_categories, device_tokens, refresh_tokens, otp_codes,
  users, households, neighborhoods CASCADE;

DROP TYPE IF EXISTS user_role, household_role, user_status, residency_type,
  otp_purpose, device_platform, emergency_status, bill_status, payment_method,
  payment_status, cash_type, announcement_status, letter_status, approver_role,
  approval_status, guest_status, item_condition, loan_status,
  attendance_status CASCADE;

DROP FUNCTION IF EXISTS set_updated_at() CASCADE;

-- ----------------------------------------------------------------------------
-- 1. TIPE ENUM
-- Menambah divisi/role baru cukup: ALTER TYPE user_role ADD VALUE 'juri';
-- (efek domino pada materi 14: database menyerap perubahan secara terisolasi)
-- ----------------------------------------------------------------------------

CREATE TYPE user_role          AS ENUM ('resident', 'security', 'rt_admin', 'super_admin');
CREATE TYPE household_role     AS ENUM ('head', 'spouse', 'child', 'other');
CREATE TYPE user_status        AS ENUM ('pending', 'active', 'suspended');
CREATE TYPE residency_type     AS ENUM ('permanent', 'contract', 'boarding');
CREATE TYPE otp_purpose        AS ENUM ('register', 'login', 'reset_password');
CREATE TYPE device_platform    AS ENUM ('android', 'ios');
CREATE TYPE emergency_status   AS ENUM ('received', 'dispatched', 'on_scene', 'resolved', 'cancelled');
CREATE TYPE bill_status        AS ENUM ('unpaid', 'waiting_verification', 'paid', 'overdue');
CREATE TYPE payment_method     AS ENUM ('transfer_manual', 'qris', 'cash');
CREATE TYPE payment_status     AS ENUM ('pending', 'verified', 'rejected');
CREATE TYPE cash_type          AS ENUM ('income', 'expense');
CREATE TYPE announcement_status AS ENUM ('pending', 'published', 'rejected');
CREATE TYPE letter_status      AS ENUM ('submitted', 'in_review', 'approved', 'rejected', 'completed');
CREATE TYPE approver_role      AS ENUM ('rt_admin', 'security', 'super_admin');
CREATE TYPE approval_status    AS ENUM ('pending', 'approved', 'rejected', 'skipped');
CREATE TYPE guest_status       AS ENUM ('reported', 'verified', 'checked_out');
CREATE TYPE item_condition     AS ENUM ('good', 'fair', 'damaged');
CREATE TYPE loan_status        AS ENUM ('pending', 'approved', 'rejected', 'borrowed', 'returned', 'cancelled');
CREATE TYPE attendance_status  AS ENUM ('valid', 'rejected');

-- Fungsi pengganti "ON UPDATE CURRENT_TIMESTAMP"
CREATE FUNCTION set_updated_at() RETURNS trigger AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- 2. WILAYAH & PENGGUNA
-- ----------------------------------------------------------------------------

CREATE TABLE neighborhoods (
  id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid                UUID          NOT NULL DEFAULT gen_random_uuid(),
  name                VARCHAR(100)  NOT NULL,              -- "RT 05 / RW 08 Menteng Asri"
  rt                  VARCHAR(3)    NOT NULL,
  rw                  VARCHAR(3)    NOT NULL,
  kelurahan           VARCHAR(100)  NOT NULL,
  kecamatan           VARCHAR(100),
  city                VARCHAR(100),
  latitude            NUMERIC(10,7),
  longitude           NUMERIC(10,7),
  bank_name           VARCHAR(50),                         -- rekening kas resmi
  bank_account_number VARCHAR(30),
  bank_account_name   VARCHAR(100),
  created_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at          TIMESTAMPTZ,
  CONSTRAINT uq_neighborhoods_uuid UNIQUE (uuid),
  CONSTRAINT uq_neighborhoods_rt_rw UNIQUE (kelurahan, rw, rt)
);

CREATE TABLE households (
  id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            UUID          NOT NULL DEFAULT gen_random_uuid(),
  neighborhood_id BIGINT        NOT NULL REFERENCES neighborhoods (id),
  block           VARCHAR(10),                             -- "B3"
  house_number    VARCHAR(10)   NOT NULL,                  -- "12"
  address         VARCHAR(255)  NOT NULL,
  residency_type  residency_type NOT NULL DEFAULT 'permanent',
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ,
  CONSTRAINT uq_households_uuid UNIQUE (uuid),
  CONSTRAINT uq_households_unit UNIQUE (neighborhood_id, block, house_number)
);

CREATE TABLE users (
  id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              UUID          NOT NULL DEFAULT gen_random_uuid(),
  neighborhood_id   BIGINT        NOT NULL REFERENCES neighborhoods (id),
  household_id      BIGINT        REFERENCES households (id),
  full_name         VARCHAR(120)  NOT NULL,
  phone             VARCHAR(20)   NOT NULL,                -- format 628xxxx (WhatsApp)
  email             VARCHAR(150),
  nik               CHAR(16),
  password_hash     VARCHAR(255)  NOT NULL,
  role              user_role     NOT NULL DEFAULT 'resident',
  household_role    household_role NOT NULL DEFAULT 'head',
  status            user_status   NOT NULL DEFAULT 'pending',
  avatar_url        VARCHAR(255),
  phone_verified_at TIMESTAMPTZ,
  last_login_at     TIMESTAMPTZ,
  created_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at        TIMESTAMPTZ,
  CONSTRAINT uq_users_uuid UNIQUE (uuid),
  CONSTRAINT uq_users_phone UNIQUE (phone),
  CONSTRAINT uq_users_nik UNIQUE (nik)
);
CREATE INDEX idx_users_neighborhood_role ON users (neighborhood_id, role);
CREATE INDEX idx_users_household ON users (household_id);

CREATE TABLE otp_codes (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  phone       VARCHAR(20)   NOT NULL,
  purpose     otp_purpose   NOT NULL,
  code_hash   VARCHAR(255)  NOT NULL,                      -- jangan simpan OTP polos
  attempts    SMALLINT      NOT NULL DEFAULT 0 CHECK (attempts >= 0),
  expires_at  TIMESTAMPTZ   NOT NULL,
  consumed_at TIMESTAMPTZ,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_otp_phone_purpose ON otp_codes (phone, purpose, expires_at);

CREATE TABLE refresh_tokens (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id     BIGINT        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  token_hash  CHAR(64)      NOT NULL,                      -- SHA-256 dari refresh token
  device_info VARCHAR(255),
  expires_at  TIMESTAMPTZ   NOT NULL,
  revoked_at  TIMESTAMPTZ,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_refresh_token_hash UNIQUE (token_hash)
);
CREATE INDEX idx_refresh_user ON refresh_tokens (user_id);

CREATE TABLE device_tokens (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id    BIGINT          NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  fcm_token  VARCHAR(255)    NOT NULL,
  platform   device_platform NOT NULL,
  created_at TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_device_fcm UNIQUE (fcm_token)
);
CREATE INDEX idx_device_user ON device_tokens (user_id);

-- ----------------------------------------------------------------------------
-- 3. SIAGA DARURAT (SOS)
-- ----------------------------------------------------------------------------

CREATE TABLE emergency_categories (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code        VARCHAR(30)   NOT NULL,                      -- security, fire, medical, disaster
  name        VARCHAR(80)   NOT NULL,                      -- "Pos Ronda"
  title       VARCHAR(80)   NOT NULL,                      -- "Pencurian & Kamtib"
  description VARCHAR(255),
  icon        VARCHAR(50),
  is_active   BOOLEAN       NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_emergency_categories_code UNIQUE (code)
);

CREATE TABLE emergencies (
  id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid             UUID          NOT NULL DEFAULT gen_random_uuid(),
  neighborhood_id  BIGINT        NOT NULL REFERENCES neighborhoods (id),
  reporter_id      BIGINT        NOT NULL REFERENCES users (id),
  category_id      BIGINT        NOT NULL REFERENCES emergency_categories (id),
  status           emergency_status NOT NULL DEFAULT 'received',
  latitude         NUMERIC(10,7),
  longitude        NUMERIC(10,7),
  address_snapshot VARCHAR(255),
  note             VARCHAR(500),
  eta_minutes      SMALLINT      CHECK (eta_minutes >= 0),
  triggered_at     TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  resolved_at      TIMESTAMPTZ,
  cancelled_at     TIMESTAMPTZ,
  cancel_reason    VARCHAR(255),
  created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at       TIMESTAMPTZ,
  CONSTRAINT uq_emergencies_uuid UNIQUE (uuid)
);
CREATE INDEX idx_emergencies_active ON emergencies (neighborhood_id, status, triggered_at);
CREATE INDEX idx_emergencies_reporter ON emergencies (reporter_id);

CREATE TABLE emergency_responders (
  id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  emergency_id  BIGINT        NOT NULL REFERENCES emergencies (id) ON DELETE CASCADE,
  user_id       BIGINT        NOT NULL REFERENCES users (id),
  unit_label    VARCHAR(80),                               -- "Komandan Regu B", "Motor Patroli"
  assigned_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  arrived_at    TIMESTAMPTZ,
  CONSTRAINT uq_responder_unique UNIQUE (emergency_id, user_id)
);

CREATE TABLE emergency_logs (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  emergency_id BIGINT        NOT NULL REFERENCES emergencies (id) ON DELETE CASCADE,
  actor_id     BIGINT        REFERENCES users (id),
  status       emergency_status NOT NULL,
  message      VARCHAR(255)  NOT NULL,                     -- baris timeline progres penanganan
  created_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_emergency_logs ON emergency_logs (emergency_id, created_at);

-- ----------------------------------------------------------------------------
-- 4. KEUANGAN: IURAN & KAS
-- ----------------------------------------------------------------------------

CREATE TABLE bill_types (
  id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  neighborhood_id  BIGINT        NOT NULL REFERENCES neighborhoods (id),
  code             VARCHAR(30)   NOT NULL,                 -- sanitation, security, social
  name             VARCHAR(100)  NOT NULL,
  default_amount   NUMERIC(12,2) NOT NULL CHECK (default_amount >= 0),
  is_active        BOOLEAN       NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_bill_types UNIQUE (neighborhood_id, code)
);

CREATE TABLE bills (
  id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid             UUID          NOT NULL DEFAULT gen_random_uuid(),
  neighborhood_id  BIGINT        NOT NULL REFERENCES neighborhoods (id),
  household_id     BIGINT        NOT NULL REFERENCES households (id),
  period           CHAR(7)       NOT NULL,                 -- 'YYYY-MM'
  total_amount     NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
  due_date         DATE          NOT NULL,
  status           bill_status   NOT NULL DEFAULT 'unpaid',
  paid_at          TIMESTAMPTZ,
  created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at       TIMESTAMPTZ,
  CONSTRAINT uq_bills_uuid UNIQUE (uuid),
  CONSTRAINT uq_bills_household_period UNIQUE (household_id, period)
);
CREATE INDEX idx_bills_status_due ON bills (neighborhood_id, status, due_date);

CREATE TABLE bill_items (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  bill_id      BIGINT        NOT NULL REFERENCES bills (id) ON DELETE CASCADE,
  bill_type_id BIGINT        NOT NULL REFERENCES bill_types (id),
  label        VARCHAR(100)  NOT NULL,                     -- snapshot nama saat tagihan dibuat
  amount       NUMERIC(12,2) NOT NULL CHECK (amount >= 0)
);
CREATE INDEX idx_bill_items_bill ON bill_items (bill_id);

CREATE TABLE payments (
  id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              UUID           NOT NULL DEFAULT gen_random_uuid(),
  bill_id           BIGINT         NOT NULL REFERENCES bills (id),
  paid_by_user_id   BIGINT         NOT NULL REFERENCES users (id),
  method            payment_method NOT NULL DEFAULT 'transfer_manual',
  amount            NUMERIC(12,2)  NOT NULL CHECK (amount >= 0),
  proof_url         VARCHAR(255),                          -- bukti transfer
  status            payment_status NOT NULL DEFAULT 'pending',
  verified_by       BIGINT         REFERENCES users (id),
  verified_at       TIMESTAMPTZ,
  reject_reason     VARCHAR(255),
  created_at        TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  deleted_at        TIMESTAMPTZ,
  CONSTRAINT uq_payments_uuid UNIQUE (uuid)
);
CREATE INDEX idx_payments_bill ON payments (bill_id);
CREATE INDEX idx_payments_status ON payments (status, created_at);

CREATE TABLE cash_transactions (
  id                 BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid               UUID          NOT NULL DEFAULT gen_random_uuid(),
  neighborhood_id    BIGINT        NOT NULL REFERENCES neighborhoods (id),
  type               cash_type     NOT NULL,
  category           VARCHAR(60)   NOT NULL,               -- "Iuran Warga", "Perbaikan Pos Ronda"
  description        VARCHAR(255),
  amount             NUMERIC(14,2) NOT NULL CHECK (amount >= 0),
  transaction_date   DATE          NOT NULL,
  related_payment_id BIGINT        REFERENCES payments (id),
  created_by         BIGINT        NOT NULL REFERENCES users (id),
  is_public          BOOLEAN       NOT NULL DEFAULT TRUE,  -- tampil di Transparansi Kas
  created_at         TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at         TIMESTAMPTZ,
  CONSTRAINT uq_cash_uuid UNIQUE (uuid)
);
CREATE INDEX idx_cash_period ON cash_transactions (neighborhood_id, transaction_date, type);

-- ----------------------------------------------------------------------------
-- 5. BERITA & PENGUMUMAN
-- ----------------------------------------------------------------------------

CREATE TABLE announcement_categories (
  id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(30) NOT NULL,
  name VARCHAR(60) NOT NULL,
  CONSTRAINT uq_announcement_categories_code UNIQUE (code)
);

CREATE TABLE announcements (
  id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            UUID          NOT NULL DEFAULT gen_random_uuid(),
  neighborhood_id BIGINT        NOT NULL REFERENCES neighborhoods (id),
  category_id     BIGINT        NOT NULL REFERENCES announcement_categories (id),
  author_id       BIGINT        NOT NULL REFERENCES users (id),
  title           VARCHAR(200)  NOT NULL,
  body            TEXT          NOT NULL,
  image_url       VARCHAR(255),
  is_official     BOOLEAN       NOT NULL DEFAULT FALSE,    -- pengumuman resmi pengurus
  status          announcement_status NOT NULL DEFAULT 'pending', -- warta warga dimoderasi
  published_at    TIMESTAMPTZ,
  like_count      INTEGER       NOT NULL DEFAULT 0 CHECK (like_count >= 0),
  comment_count   INTEGER       NOT NULL DEFAULT 0 CHECK (comment_count >= 0),
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ,
  CONSTRAINT uq_announcements_uuid UNIQUE (uuid)
);
CREATE INDEX idx_announcements_feed ON announcements (neighborhood_id, status, published_at);
CREATE INDEX ft_announcements_search ON announcements
  USING GIN (to_tsvector('simple', title || ' ' || body));

CREATE TABLE announcement_likes (
  announcement_id BIGINT      NOT NULL REFERENCES announcements (id) ON DELETE CASCADE,
  user_id         BIGINT      NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (announcement_id, user_id)
);

CREATE TABLE announcement_comments (
  id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            UUID          NOT NULL DEFAULT gen_random_uuid(),
  announcement_id BIGINT        NOT NULL REFERENCES announcements (id) ON DELETE CASCADE,
  user_id         BIGINT        NOT NULL REFERENCES users (id),
  body            VARCHAR(500)  NOT NULL,
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ,
  CONSTRAINT uq_comments_uuid UNIQUE (uuid)
);
CREATE INDEX idx_comments_announcement ON announcement_comments (announcement_id, created_at);

-- ----------------------------------------------------------------------------
-- 6. E-SURAT (jumlah tahap persetujuan dinamis, tanpa hardcode di UI Flutter)
-- ----------------------------------------------------------------------------

CREATE TABLE letter_types (
  id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  neighborhood_id BIGINT        NOT NULL REFERENCES neighborhoods (id),
  code            VARCHAR(40)   NOT NULL,                  -- skck, domicile, marriage, business, moving
  name            VARCHAR(120)  NOT NULL,
  description     VARCHAR(255),
  icon            VARCHAR(50),
  required_fields JSONB,                                   -- field tambahan per jenis surat
  is_popular      BOOLEAN       NOT NULL DEFAULT FALSE,
  is_active       BOOLEAN       NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_letter_types UNIQUE (neighborhood_id, code)
);

-- Template alur persetujuan per jenis surat
CREATE TABLE letter_type_steps (
  id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  letter_type_id BIGINT        NOT NULL REFERENCES letter_types (id) ON DELETE CASCADE,
  step_order     SMALLINT      NOT NULL CHECK (step_order > 0),
  approver_role  approver_role NOT NULL,
  label          VARCHAR(100)  NOT NULL,                   -- "Verifikasi Ketua RT"
  CONSTRAINT uq_letter_type_steps UNIQUE (letter_type_id, step_order)
);

CREATE TABLE letter_requests (
  id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid           UUID          NOT NULL DEFAULT gen_random_uuid(),
  letter_type_id BIGINT        NOT NULL REFERENCES letter_types (id),
  applicant_id   BIGINT        NOT NULL REFERENCES users (id),
  purpose        VARCHAR(500)  NOT NULL,                   -- min. 10 karakter divalidasi di API
  form_data      JSONB,
  status         letter_status NOT NULL DEFAULT 'submitted',
  current_step   SMALLINT      NOT NULL DEFAULT 1,
  letter_number  VARCHAR(60),
  file_url       VARCHAR(255),                             -- PDF surat hasil
  created_at     TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at     TIMESTAMPTZ,
  CONSTRAINT uq_letter_requests_uuid UNIQUE (uuid),
  CONSTRAINT uq_letter_number UNIQUE (letter_number)
);
CREATE INDEX idx_letter_requests_applicant ON letter_requests (applicant_id, created_at);
CREATE INDEX idx_letter_requests_status ON letter_requests (status, created_at);

-- Salinan (snapshot) tahap persetujuan untuk setiap pengajuan
CREATE TABLE approval_steps (
  id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  letter_request_id BIGINT          NOT NULL REFERENCES letter_requests (id) ON DELETE CASCADE,
  step_order        SMALLINT        NOT NULL CHECK (step_order > 0),
  approver_role     approver_role   NOT NULL,
  label             VARCHAR(100)    NOT NULL,
  status            approval_status NOT NULL DEFAULT 'pending',
  acted_by          BIGINT          REFERENCES users (id),
  acted_at          TIMESTAMPTZ,
  note              VARCHAR(255),
  CONSTRAINT uq_approval_steps UNIQUE (letter_request_id, step_order)
);

-- ----------------------------------------------------------------------------
-- 7. BUKU TAMU
-- ----------------------------------------------------------------------------

CREATE TABLE guest_reports (
  id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            UUID          NOT NULL DEFAULT gen_random_uuid(),
  neighborhood_id BIGINT        NOT NULL REFERENCES neighborhoods (id),
  household_id    BIGINT        NOT NULL REFERENCES households (id),
  host_user_id    BIGINT        NOT NULL REFERENCES users (id),
  guest_name      VARCHAR(120)  NOT NULL,
  guest_nik       CHAR(16)      NOT NULL,
  relationship    VARCHAR(60)   NOT NULL,
  start_date      DATE          NOT NULL,
  end_date        DATE          NOT NULL,
  status          guest_status  NOT NULL DEFAULT 'reported',
  verified_by     BIGINT        REFERENCES users (id),
  checked_out_at  TIMESTAMPTZ,
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ,
  CONSTRAINT uq_guest_reports_uuid UNIQUE (uuid),
  CONSTRAINT ck_guest_dates CHECK (end_date >= start_date)
);
CREATE INDEX idx_guest_host ON guest_reports (host_user_id, start_date);
CREATE INDEX idx_guest_neighborhood ON guest_reports (neighborhood_id, status, start_date);

-- ----------------------------------------------------------------------------
-- 8. INVENTARIS & PEMINJAMAN
-- ----------------------------------------------------------------------------

CREATE TABLE inventory_items (
  id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid            UUID          NOT NULL DEFAULT gen_random_uuid(),
  neighborhood_id BIGINT        NOT NULL REFERENCES neighborhoods (id),
  name            VARCHAR(150)  NOT NULL,
  description     VARCHAR(500),
  category        VARCHAR(60),
  image_url       VARCHAR(255),
  total_stock     INTEGER       NOT NULL DEFAULT 1 CHECK (total_stock >= 0),
  item_condition  item_condition NOT NULL DEFAULT 'good',
  is_active       BOOLEAN       NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ,
  CONSTRAINT uq_inventory_uuid UNIQUE (uuid)
);
CREATE INDEX idx_inventory_catalog ON inventory_items (neighborhood_id, is_active, name);

CREATE TABLE loans (
  id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              UUID          NOT NULL DEFAULT gen_random_uuid(),
  item_id           BIGINT        NOT NULL REFERENCES inventory_items (id),
  borrower_id       BIGINT        NOT NULL REFERENCES users (id),
  quantity          INTEGER       NOT NULL DEFAULT 1 CHECK (quantity > 0),
  start_date        DATE          NOT NULL,
  end_date          DATE          NOT NULL,
  purpose           VARCHAR(255)  NOT NULL,
  status            loan_status   NOT NULL DEFAULT 'pending',
  approved_by       BIGINT        REFERENCES users (id),
  handed_over_at    TIMESTAMPTZ,
  returned_at       TIMESTAMPTZ,
  return_note       VARCHAR(255),
  created_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at        TIMESTAMPTZ,
  CONSTRAINT uq_loans_uuid UNIQUE (uuid),
  CONSTRAINT ck_loans_dates CHECK (end_date >= start_date)
);
CREATE INDEX idx_loans_availability ON loans (item_id, status, start_date, end_date);
CREATE INDEX idx_loans_borrower ON loans (borrower_id, created_at);

-- ----------------------------------------------------------------------------
-- 9. AGENDA & ABSENSI
-- ----------------------------------------------------------------------------

CREATE TABLE agendas (
  id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              UUID          NOT NULL DEFAULT gen_random_uuid(),
  neighborhood_id   BIGINT        NOT NULL REFERENCES neighborhoods (id),
  title             VARCHAR(200)  NOT NULL,
  description       TEXT,
  location_name     VARCHAR(150),
  latitude          NUMERIC(10,7),
  longitude         NUMERIC(10,7),
  geofence_radius_m SMALLINT      NOT NULL DEFAULT 100 CHECK (geofence_radius_m > 0), -- batas jarak absensi sah
  start_at          TIMESTAMPTZ   NOT NULL,
  end_at            TIMESTAMPTZ   NOT NULL,
  is_mandatory      BOOLEAN       NOT NULL DEFAULT FALSE,
  created_by        BIGINT        NOT NULL REFERENCES users (id),
  created_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at        TIMESTAMPTZ,
  CONSTRAINT uq_agendas_uuid UNIQUE (uuid),
  CONSTRAINT ck_agendas_time CHECK (end_at >= start_at)
);
CREATE INDEX idx_agendas_upcoming ON agendas (neighborhood_id, start_at);

CREATE TABLE attendances (
  id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid             UUID          NOT NULL DEFAULT gen_random_uuid(),
  agenda_id        BIGINT        NOT NULL REFERENCES agendas (id),
  user_id          BIGINT        NOT NULL REFERENCES users (id),
  receipt_code     VARCHAR(20)   NOT NULL,                 -- "SL-7782"
  photo_url        VARCHAR(255)  NOT NULL,
  latitude         NUMERIC(10,7) NOT NULL,
  longitude        NUMERIC(10,7) NOT NULL,
  accuracy_m       NUMERIC(6,2),
  face_match_score NUMERIC(5,2),
  captured_at      TIMESTAMPTZ   NOT NULL,                 -- timestamp dari perangkat
  status           attendance_status NOT NULL DEFAULT 'valid',
  created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at       TIMESTAMPTZ,
  CONSTRAINT uq_attendances_uuid UNIQUE (uuid),
  CONSTRAINT uq_attendances_receipt UNIQUE (receipt_code),
  CONSTRAINT uq_attendances_agenda_user UNIQUE (agenda_id, user_id)
);
CREATE INDEX idx_attendances_user ON attendances (user_id, captured_at);

-- ----------------------------------------------------------------------------
-- 10. NOTIFIKASI & AUDIT
-- ----------------------------------------------------------------------------

CREATE TABLE notifications (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid       UUID          NOT NULL DEFAULT gen_random_uuid(),
  user_id    BIGINT        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  type       VARCHAR(40)   NOT NULL,                       -- bill_due, sos, letter_update, ...
  title      VARCHAR(150)  NOT NULL,
  body       VARCHAR(500)  NOT NULL,
  data       JSONB,
  read_at    TIMESTAMPTZ,
  created_at TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_notifications_uuid UNIQUE (uuid)
);
CREATE INDEX idx_notifications_inbox ON notifications (user_id, read_at, created_at);

CREATE TABLE audit_logs (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id     BIGINT        REFERENCES users (id) ON DELETE SET NULL,
  action      VARCHAR(60)   NOT NULL,                      -- payment.verified, letter.approved, ...
  entity_type VARCHAR(40)   NOT NULL,
  entity_uuid UUID,
  ip_address  VARCHAR(45),
  meta        JSONB,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_audit_entity ON audit_logs (entity_type, entity_uuid);
CREATE INDEX idx_audit_user ON audit_logs (user_id, created_at);

-- ----------------------------------------------------------------------------
-- 11. TRIGGER updated_at (otomatis untuk semua tabel yang punya kolom updated_at)
-- ----------------------------------------------------------------------------

DO $$
DECLARE t TEXT;
BEGIN
  FOR t IN
    SELECT table_name FROM information_schema.columns
    WHERE table_schema = 'public' AND column_name = 'updated_at'
  LOOP
    EXECUTE format(
      'CREATE TRIGGER trg_%I_updated_at BEFORE UPDATE ON %I
         FOR EACH ROW EXECUTE FUNCTION set_updated_at()', t, t);
  END LOOP;
END $$;
