-- ============================================================================
-- Sapu Lidi - Skema Database (MySQL 8.0+)
-- Sumber kebenaran tunggal (SSOT) untuk struktur data.
-- Prinsip dari materi: UUID untuk endpoint publik (anti-IDOR), soft delete
-- (deleted_at) untuk data transaksional, indeks untuk eager loading / hindari N+1.
-- Cara menjalankan: lihat database/README.md
-- ============================================================================

CREATE DATABASE IF NOT EXISTS sapulidi
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sapulidi;

SET FOREIGN_KEY_CHECKS = 0;

-- Hapus ulang (urutan terbalik tidak penting karena FK dimatikan)
DROP TABLE IF EXISTS audit_logs, notifications, attendances, agendas, loans,
  inventory_items, guest_reports, approval_steps, letter_requests,
  letter_type_steps, letter_types, announcement_comments, announcement_likes,
  announcements, announcement_categories, cash_transactions, payments,
  bill_items, bills, bill_types, emergency_logs, emergency_responders,
  emergencies, emergency_categories, device_tokens, refresh_tokens, otp_codes,
  users, households, neighborhoods;

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- 1. WILAYAH & PENGGUNA
-- ----------------------------------------------------------------------------

CREATE TABLE neighborhoods (
  id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid                CHAR(36)        NOT NULL,
  name                VARCHAR(100)    NOT NULL,              -- "RT 05 / RW 08 Menteng Asri"
  rt                  VARCHAR(3)      NOT NULL,
  rw                  VARCHAR(3)      NOT NULL,
  kelurahan           VARCHAR(100)    NOT NULL,
  kecamatan           VARCHAR(100)    NULL,
  city                VARCHAR(100)    NULL,
  latitude            DECIMAL(10,7)   NULL,
  longitude           DECIMAL(10,7)   NULL,
  bank_name           VARCHAR(50)     NULL,                  -- rekening kas resmi
  bank_account_number VARCHAR(30)     NULL,
  bank_account_name   VARCHAR(100)    NULL,
  created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at          TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_neighborhoods_uuid (uuid),
  UNIQUE KEY uq_neighborhoods_rt_rw (kelurahan, rw, rt)
) ENGINE=InnoDB;

CREATE TABLE households (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid            CHAR(36)        NOT NULL,
  neighborhood_id BIGINT UNSIGNED NOT NULL,
  block           VARCHAR(10)     NULL,                      -- "B3"
  house_number    VARCHAR(10)     NOT NULL,                  -- "12"
  address         VARCHAR(255)    NOT NULL,
  residency_type  ENUM('permanent','contract','boarding') NOT NULL DEFAULT 'permanent',
  created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_households_uuid (uuid),
  UNIQUE KEY uq_households_unit (neighborhood_id, block, house_number),
  CONSTRAINT fk_households_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods (id)
) ENGINE=InnoDB;

CREATE TABLE users (
  id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid              CHAR(36)        NOT NULL,
  neighborhood_id   BIGINT UNSIGNED NOT NULL,
  household_id      BIGINT UNSIGNED NULL,
  full_name         VARCHAR(120)    NOT NULL,
  phone             VARCHAR(20)     NOT NULL,                -- format 628xxxx (WhatsApp)
  email             VARCHAR(150)    NULL,
  nik               CHAR(16)        NULL,
  password_hash     VARCHAR(255)    NOT NULL,
  -- Menambah divisi/role baru cukup menambah nilai ENUM (efek domino materi 14)
  role              ENUM('resident','security','rt_admin','super_admin') NOT NULL DEFAULT 'resident',
  household_role    ENUM('head','spouse','child','other') NOT NULL DEFAULT 'head',
  status            ENUM('pending','active','suspended') NOT NULL DEFAULT 'pending',
  avatar_url        VARCHAR(255)    NULL,
  phone_verified_at TIMESTAMP       NULL,
  last_login_at     TIMESTAMP       NULL,
  created_at        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at        TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_uuid (uuid),
  UNIQUE KEY uq_users_phone (phone),
  UNIQUE KEY uq_users_nik (nik),
  KEY idx_users_neighborhood_role (neighborhood_id, role),
  KEY idx_users_household (household_id),
  CONSTRAINT fk_users_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods (id),
  CONSTRAINT fk_users_household FOREIGN KEY (household_id) REFERENCES households (id)
) ENGINE=InnoDB;

CREATE TABLE otp_codes (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  phone       VARCHAR(20)     NOT NULL,
  purpose     ENUM('register','login','reset_password') NOT NULL,
  code_hash   VARCHAR(255)    NOT NULL,                      -- jangan simpan OTP polos
  attempts    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  expires_at  TIMESTAMP       NOT NULL,
  consumed_at TIMESTAMP       NULL,
  created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_otp_phone_purpose (phone, purpose, expires_at)
) ENGINE=InnoDB;

CREATE TABLE refresh_tokens (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id     BIGINT UNSIGNED NOT NULL,
  token_hash  CHAR(64)        NOT NULL,                      -- SHA-256 dari refresh token
  device_info VARCHAR(255)    NULL,
  expires_at  TIMESTAMP       NOT NULL,
  revoked_at  TIMESTAMP       NULL,
  created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_refresh_token_hash (token_hash),
  KEY idx_refresh_user (user_id),
  CONSTRAINT fk_refresh_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE device_tokens (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id    BIGINT UNSIGNED NOT NULL,
  fcm_token  VARCHAR(255)    NOT NULL,
  platform   ENUM('android','ios') NOT NULL,
  created_at TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_device_fcm (fcm_token),
  KEY idx_device_user (user_id),
  CONSTRAINT fk_device_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. SIAGA DARURAT (SOS)
-- ----------------------------------------------------------------------------

CREATE TABLE emergency_categories (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code        VARCHAR(30)     NOT NULL,                      -- security, fire, medical, disaster
  name        VARCHAR(80)     NOT NULL,                      -- "Pos Ronda"
  title       VARCHAR(80)     NOT NULL,                      -- "Pencurian & Kamtib"
  description VARCHAR(255)    NULL,
  icon        VARCHAR(50)     NULL,
  is_active   TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_emergency_categories_code (code)
) ENGINE=InnoDB;

CREATE TABLE emergencies (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid             CHAR(36)        NOT NULL,
  neighborhood_id  BIGINT UNSIGNED NOT NULL,
  reporter_id      BIGINT UNSIGNED NOT NULL,
  category_id      BIGINT UNSIGNED NOT NULL,
  status           ENUM('received','dispatched','on_scene','resolved','cancelled') NOT NULL DEFAULT 'received',
  latitude         DECIMAL(10,7)   NULL,
  longitude        DECIMAL(10,7)   NULL,
  address_snapshot VARCHAR(255)    NULL,
  note             VARCHAR(500)    NULL,
  eta_minutes      TINYINT UNSIGNED NULL,
  triggered_at     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved_at      TIMESTAMP       NULL,
  cancelled_at     TIMESTAMP       NULL,
  cancel_reason    VARCHAR(255)    NULL,
  created_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at       TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_emergencies_uuid (uuid),
  KEY idx_emergencies_active (neighborhood_id, status, triggered_at),
  KEY idx_emergencies_reporter (reporter_id),
  CONSTRAINT fk_emergencies_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods (id),
  CONSTRAINT fk_emergencies_reporter FOREIGN KEY (reporter_id) REFERENCES users (id),
  CONSTRAINT fk_emergencies_category FOREIGN KEY (category_id) REFERENCES emergency_categories (id)
) ENGINE=InnoDB;

CREATE TABLE emergency_responders (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  emergency_id  BIGINT UNSIGNED NOT NULL,
  user_id       BIGINT UNSIGNED NOT NULL,
  unit_label    VARCHAR(80)     NULL,                        -- "Komandan Regu B", "Motor Patroli"
  assigned_at   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  arrived_at    TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_responder_unique (emergency_id, user_id),
  CONSTRAINT fk_responders_emergency FOREIGN KEY (emergency_id) REFERENCES emergencies (id) ON DELETE CASCADE,
  CONSTRAINT fk_responders_user FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB;

CREATE TABLE emergency_logs (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  emergency_id BIGINT UNSIGNED NOT NULL,
  actor_id     BIGINT UNSIGNED NULL,
  status       ENUM('received','dispatched','on_scene','resolved','cancelled') NOT NULL,
  message      VARCHAR(255)    NOT NULL,                     -- baris timeline progres penanganan
  created_at   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_emergency_logs (emergency_id, created_at),
  CONSTRAINT fk_elogs_emergency FOREIGN KEY (emergency_id) REFERENCES emergencies (id) ON DELETE CASCADE,
  CONSTRAINT fk_elogs_actor FOREIGN KEY (actor_id) REFERENCES users (id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 3. KEUANGAN: IURAN & KAS
-- ----------------------------------------------------------------------------

CREATE TABLE bill_types (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  neighborhood_id  BIGINT UNSIGNED NOT NULL,
  code             VARCHAR(30)     NOT NULL,                 -- sanitation, security, social
  name             VARCHAR(100)    NOT NULL,
  default_amount   DECIMAL(12,2)   NOT NULL,
  is_active        TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_bill_types (neighborhood_id, code),
  CONSTRAINT fk_bill_types_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods (id)
) ENGINE=InnoDB;

CREATE TABLE bills (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid             CHAR(36)        NOT NULL,
  neighborhood_id  BIGINT UNSIGNED NOT NULL,
  household_id     BIGINT UNSIGNED NOT NULL,
  period           CHAR(7)         NOT NULL,                 -- 'YYYY-MM'
  total_amount     DECIMAL(12,2)   NOT NULL,
  due_date         DATE            NOT NULL,
  status           ENUM('unpaid','waiting_verification','paid','overdue') NOT NULL DEFAULT 'unpaid',
  paid_at          TIMESTAMP       NULL,
  created_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at       TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_bills_uuid (uuid),
  UNIQUE KEY uq_bills_household_period (household_id, period),
  KEY idx_bills_status_due (neighborhood_id, status, due_date),
  CONSTRAINT fk_bills_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods (id),
  CONSTRAINT fk_bills_household FOREIGN KEY (household_id) REFERENCES households (id)
) ENGINE=InnoDB;

CREATE TABLE bill_items (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  bill_id      BIGINT UNSIGNED NOT NULL,
  bill_type_id BIGINT UNSIGNED NOT NULL,
  label        VARCHAR(100)    NOT NULL,                     -- snapshot nama saat tagihan dibuat
  amount       DECIMAL(12,2)   NOT NULL,
  PRIMARY KEY (id),
  KEY idx_bill_items_bill (bill_id),
  CONSTRAINT fk_bill_items_bill FOREIGN KEY (bill_id) REFERENCES bills (id) ON DELETE CASCADE,
  CONSTRAINT fk_bill_items_type FOREIGN KEY (bill_type_id) REFERENCES bill_types (id)
) ENGINE=InnoDB;

CREATE TABLE payments (
  id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid              CHAR(36)        NOT NULL,
  bill_id           BIGINT UNSIGNED NOT NULL,
  paid_by_user_id   BIGINT UNSIGNED NOT NULL,
  method            ENUM('transfer_manual','qris','cash') NOT NULL DEFAULT 'transfer_manual',
  amount            DECIMAL(12,2)   NOT NULL,
  proof_url         VARCHAR(255)    NULL,                    -- bukti transfer
  status            ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending',
  verified_by       BIGINT UNSIGNED NULL,
  verified_at       TIMESTAMP       NULL,
  reject_reason     VARCHAR(255)    NULL,
  created_at        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at        TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_payments_uuid (uuid),
  KEY idx_payments_bill (bill_id),
  KEY idx_payments_status (status, created_at),
  CONSTRAINT fk_payments_bill FOREIGN KEY (bill_id) REFERENCES bills (id),
  CONSTRAINT fk_payments_payer FOREIGN KEY (paid_by_user_id) REFERENCES users (id),
  CONSTRAINT fk_payments_verifier FOREIGN KEY (verified_by) REFERENCES users (id)
) ENGINE=InnoDB;

CREATE TABLE cash_transactions (
  id                 BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid               CHAR(36)        NOT NULL,
  neighborhood_id    BIGINT UNSIGNED NOT NULL,
  type               ENUM('income','expense') NOT NULL,
  category           VARCHAR(60)     NOT NULL,               -- "Iuran Warga", "Perbaikan Pos Ronda"
  description        VARCHAR(255)    NULL,
  amount             DECIMAL(14,2)   NOT NULL,
  transaction_date   DATE            NOT NULL,
  related_payment_id BIGINT UNSIGNED NULL,
  created_by         BIGINT UNSIGNED NOT NULL,
  is_public          TINYINT(1)      NOT NULL DEFAULT 1,     -- tampil di Transparansi Kas
  created_at         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at         TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_cash_uuid (uuid),
  KEY idx_cash_period (neighborhood_id, transaction_date, type),
  CONSTRAINT fk_cash_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods (id),
  CONSTRAINT fk_cash_payment FOREIGN KEY (related_payment_id) REFERENCES payments (id),
  CONSTRAINT fk_cash_creator FOREIGN KEY (created_by) REFERENCES users (id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 4. BERITA & PENGUMUMAN
-- ----------------------------------------------------------------------------

CREATE TABLE announcement_categories (
  id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(30)     NOT NULL,
  name VARCHAR(60)     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_announcement_categories_code (code)
) ENGINE=InnoDB;

CREATE TABLE announcements (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid            CHAR(36)        NOT NULL,
  neighborhood_id BIGINT UNSIGNED NOT NULL,
  category_id     BIGINT UNSIGNED NOT NULL,
  author_id       BIGINT UNSIGNED NOT NULL,
  title           VARCHAR(200)    NOT NULL,
  body            TEXT            NOT NULL,
  image_url       VARCHAR(255)    NULL,
  is_official     TINYINT(1)      NOT NULL DEFAULT 0,        -- pengumuman resmi pengurus
  status          ENUM('pending','published','rejected') NOT NULL DEFAULT 'pending', -- warta warga dimoderasi
  published_at    TIMESTAMP       NULL,
  like_count      INT UNSIGNED    NOT NULL DEFAULT 0,
  comment_count   INT UNSIGNED    NOT NULL DEFAULT 0,
  created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_announcements_uuid (uuid),
  KEY idx_announcements_feed (neighborhood_id, status, published_at),
  FULLTEXT KEY ft_announcements_search (title, body),
  CONSTRAINT fk_announcements_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods (id),
  CONSTRAINT fk_announcements_category FOREIGN KEY (category_id) REFERENCES announcement_categories (id),
  CONSTRAINT fk_announcements_author FOREIGN KEY (author_id) REFERENCES users (id)
) ENGINE=InnoDB;

CREATE TABLE announcement_likes (
  announcement_id BIGINT UNSIGNED NOT NULL,
  user_id         BIGINT UNSIGNED NOT NULL,
  created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (announcement_id, user_id),
  CONSTRAINT fk_likes_announcement FOREIGN KEY (announcement_id) REFERENCES announcements (id) ON DELETE CASCADE,
  CONSTRAINT fk_likes_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE announcement_comments (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid            CHAR(36)        NOT NULL,
  announcement_id BIGINT UNSIGNED NOT NULL,
  user_id         BIGINT UNSIGNED NOT NULL,
  body            VARCHAR(500)    NOT NULL,
  created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at      TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_comments_uuid (uuid),
  KEY idx_comments_announcement (announcement_id, created_at),
  CONSTRAINT fk_comments_announcement FOREIGN KEY (announcement_id) REFERENCES announcements (id) ON DELETE CASCADE,
  CONSTRAINT fk_comments_user FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 5. E-SURAT (jumlah tahap persetujuan dinamis, tanpa hardcode di UI Flutter)
-- ----------------------------------------------------------------------------

CREATE TABLE letter_types (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  neighborhood_id BIGINT UNSIGNED NOT NULL,
  code            VARCHAR(40)     NOT NULL,                  -- skck, domicile, marriage, business, moving
  name            VARCHAR(120)    NOT NULL,
  description     VARCHAR(255)    NULL,
  icon            VARCHAR(50)     NULL,
  required_fields JSON            NULL,                      -- field tambahan per jenis surat
  is_popular      TINYINT(1)      NOT NULL DEFAULT 0,
  is_active       TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_letter_types (neighborhood_id, code),
  CONSTRAINT fk_letter_types_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods (id)
) ENGINE=InnoDB;

-- Template alur persetujuan per jenis surat
CREATE TABLE letter_type_steps (
  id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  letter_type_id BIGINT UNSIGNED NOT NULL,
  step_order     TINYINT UNSIGNED NOT NULL,
  approver_role  ENUM('rt_admin','security','super_admin') NOT NULL,
  label          VARCHAR(100)    NOT NULL,                   -- "Verifikasi Ketua RT"
  PRIMARY KEY (id),
  UNIQUE KEY uq_letter_type_steps (letter_type_id, step_order),
  CONSTRAINT fk_lts_type FOREIGN KEY (letter_type_id) REFERENCES letter_types (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE letter_requests (
  id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid           CHAR(36)        NOT NULL,
  letter_type_id BIGINT UNSIGNED NOT NULL,
  applicant_id   BIGINT UNSIGNED NOT NULL,
  purpose        VARCHAR(500)    NOT NULL,                   -- min. 10 karakter divalidasi di API
  form_data      JSON            NULL,
  status         ENUM('submitted','in_review','approved','rejected','completed') NOT NULL DEFAULT 'submitted',
  current_step   TINYINT UNSIGNED NOT NULL DEFAULT 1,
  letter_number  VARCHAR(60)     NULL,
  file_url       VARCHAR(255)    NULL,                       -- PDF surat hasil
  created_at     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at     TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_letter_requests_uuid (uuid),
  UNIQUE KEY uq_letter_number (letter_number),
  KEY idx_letter_requests_applicant (applicant_id, created_at),
  KEY idx_letter_requests_status (status, created_at),
  CONSTRAINT fk_lr_type FOREIGN KEY (letter_type_id) REFERENCES letter_types (id),
  CONSTRAINT fk_lr_applicant FOREIGN KEY (applicant_id) REFERENCES users (id)
) ENGINE=InnoDB;

-- Salinan (snapshot) tahap persetujuan untuk setiap pengajuan
CREATE TABLE approval_steps (
  id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  letter_request_id BIGINT UNSIGNED NOT NULL,
  step_order        TINYINT UNSIGNED NOT NULL,
  approver_role     ENUM('rt_admin','security','super_admin') NOT NULL,
  label             VARCHAR(100)    NOT NULL,
  status            ENUM('pending','approved','rejected','skipped') NOT NULL DEFAULT 'pending',
  acted_by          BIGINT UNSIGNED NULL,
  acted_at          TIMESTAMP       NULL,
  note              VARCHAR(255)    NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_approval_steps (letter_request_id, step_order),
  CONSTRAINT fk_as_request FOREIGN KEY (letter_request_id) REFERENCES letter_requests (id) ON DELETE CASCADE,
  CONSTRAINT fk_as_actor FOREIGN KEY (acted_by) REFERENCES users (id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 6. BUKU TAMU
-- ----------------------------------------------------------------------------

CREATE TABLE guest_reports (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid            CHAR(36)        NOT NULL,
  neighborhood_id BIGINT UNSIGNED NOT NULL,
  household_id    BIGINT UNSIGNED NOT NULL,
  host_user_id    BIGINT UNSIGNED NOT NULL,
  guest_name      VARCHAR(120)    NOT NULL,
  guest_nik       CHAR(16)        NOT NULL,
  relationship    VARCHAR(60)     NOT NULL,
  start_date      DATE            NOT NULL,
  end_date        DATE            NOT NULL,
  status          ENUM('reported','verified','checked_out') NOT NULL DEFAULT 'reported',
  verified_by     BIGINT UNSIGNED NULL,
  checked_out_at  TIMESTAMP       NULL,
  created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_guest_reports_uuid (uuid),
  KEY idx_guest_host (host_user_id, start_date),
  KEY idx_guest_neighborhood (neighborhood_id, status, start_date),
  CONSTRAINT fk_guest_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods (id),
  CONSTRAINT fk_guest_household FOREIGN KEY (household_id) REFERENCES households (id),
  CONSTRAINT fk_guest_host FOREIGN KEY (host_user_id) REFERENCES users (id),
  CONSTRAINT fk_guest_verifier FOREIGN KEY (verified_by) REFERENCES users (id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 7. INVENTARIS & PEMINJAMAN
-- ----------------------------------------------------------------------------

CREATE TABLE inventory_items (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid            CHAR(36)        NOT NULL,
  neighborhood_id BIGINT UNSIGNED NOT NULL,
  name            VARCHAR(150)    NOT NULL,
  description     VARCHAR(500)    NULL,
  category        VARCHAR(60)     NULL,
  image_url       VARCHAR(255)    NULL,
  total_stock     INT UNSIGNED    NOT NULL DEFAULT 1,
  item_condition  ENUM('good','fair','damaged') NOT NULL DEFAULT 'good',
  is_active       TINYINT(1)      NOT NULL DEFAULT 1,
  created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_inventory_uuid (uuid),
  KEY idx_inventory_catalog (neighborhood_id, is_active, name),
  CONSTRAINT fk_inventory_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods (id)
) ENGINE=InnoDB;

CREATE TABLE loans (
  id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid              CHAR(36)        NOT NULL,
  item_id           BIGINT UNSIGNED NOT NULL,
  borrower_id       BIGINT UNSIGNED NOT NULL,
  quantity          INT UNSIGNED    NOT NULL DEFAULT 1,
  start_date        DATE            NOT NULL,
  end_date          DATE            NOT NULL,
  purpose           VARCHAR(255)    NOT NULL,
  status            ENUM('pending','approved','rejected','borrowed','returned','cancelled') NOT NULL DEFAULT 'pending',
  approved_by       BIGINT UNSIGNED NULL,
  handed_over_at    TIMESTAMP       NULL,
  returned_at       TIMESTAMP       NULL,
  return_note       VARCHAR(255)    NULL,
  created_at        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at        TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_loans_uuid (uuid),
  KEY idx_loans_availability (item_id, status, start_date, end_date),
  KEY idx_loans_borrower (borrower_id, created_at),
  CONSTRAINT fk_loans_item FOREIGN KEY (item_id) REFERENCES inventory_items (id),
  CONSTRAINT fk_loans_borrower FOREIGN KEY (borrower_id) REFERENCES users (id),
  CONSTRAINT fk_loans_approver FOREIGN KEY (approved_by) REFERENCES users (id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 8. AGENDA & ABSENSI
-- ----------------------------------------------------------------------------

CREATE TABLE agendas (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid             CHAR(36)        NOT NULL,
  neighborhood_id  BIGINT UNSIGNED NOT NULL,
  title            VARCHAR(200)    NOT NULL,
  description      TEXT            NULL,
  location_name    VARCHAR(150)    NULL,
  latitude         DECIMAL(10,7)   NULL,
  longitude        DECIMAL(10,7)   NULL,
  geofence_radius_m SMALLINT UNSIGNED NOT NULL DEFAULT 100,  -- batas jarak absensi sah
  start_at         DATETIME        NOT NULL,
  end_at           DATETIME        NOT NULL,
  is_mandatory     TINYINT(1)      NOT NULL DEFAULT 0,
  created_by       BIGINT UNSIGNED NOT NULL,
  created_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at       TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_agendas_uuid (uuid),
  KEY idx_agendas_upcoming (neighborhood_id, start_at),
  CONSTRAINT fk_agendas_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods (id),
  CONSTRAINT fk_agendas_creator FOREIGN KEY (created_by) REFERENCES users (id)
) ENGINE=InnoDB;

CREATE TABLE attendances (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid             CHAR(36)        NOT NULL,
  agenda_id        BIGINT UNSIGNED NOT NULL,
  user_id          BIGINT UNSIGNED NOT NULL,
  receipt_code     VARCHAR(20)     NOT NULL,                 -- "SL-7782"
  photo_url        VARCHAR(255)    NOT NULL,
  latitude         DECIMAL(10,7)   NOT NULL,
  longitude        DECIMAL(10,7)   NOT NULL,
  accuracy_m       DECIMAL(6,2)    NULL,
  face_match_score DECIMAL(5,2)    NULL,
  captured_at      DATETIME        NOT NULL,                 -- timestamp dari perangkat
  status           ENUM('valid','rejected') NOT NULL DEFAULT 'valid',
  created_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at       TIMESTAMP       NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_attendances_uuid (uuid),
  UNIQUE KEY uq_attendances_receipt (receipt_code),
  UNIQUE KEY uq_attendances_agenda_user (agenda_id, user_id),
  KEY idx_attendances_user (user_id, captured_at),
  CONSTRAINT fk_attendances_agenda FOREIGN KEY (agenda_id) REFERENCES agendas (id),
  CONSTRAINT fk_attendances_user FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 9. NOTIFIKASI & AUDIT
-- ----------------------------------------------------------------------------

CREATE TABLE notifications (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid       CHAR(36)        NOT NULL,
  user_id    BIGINT UNSIGNED NOT NULL,
  type       VARCHAR(40)     NOT NULL,                       -- bill_due, sos, letter_update, ...
  title      VARCHAR(150)    NOT NULL,
  body       VARCHAR(500)    NOT NULL,
  data       JSON            NULL,
  read_at    TIMESTAMP       NULL,
  created_at TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_notifications_uuid (uuid),
  KEY idx_notifications_inbox (user_id, read_at, created_at),
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id     BIGINT UNSIGNED NULL,
  action      VARCHAR(60)     NOT NULL,                      -- payment.verified, letter.approved, ...
  entity_type VARCHAR(40)     NOT NULL,
  entity_uuid CHAR(36)        NULL,
  ip_address  VARCHAR(45)     NULL,
  meta        JSON            NULL,
  created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_audit_entity (entity_type, entity_uuid),
  KEY idx_audit_user (user_id, created_at),
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB;
