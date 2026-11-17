---
name: SapuLidi SuperApp
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#3f4940'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#6f7a6f'
  outline-variant: '#becabd'
  surface-tint: '#006d37'
  primary: '#006130'
  on-primary: '#ffffff'
  primary-container: '#107c41'
  on-primary-container: '#b6ffc5'
  inverse-primary: '#7ada95'
  secondary: '#994700'
  on-secondary: '#ffffff'
  secondary-container: '#fb7800'
  on-secondary-container: '#592600'
  tertiary: '#005988'
  on-tertiary: '#ffffff'
  tertiary-container: '#0072ad'
  on-tertiary-container: '#e4f0ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#96f7af'
  primary-fixed-dim: '#7ada95'
  on-primary-fixed: '#00210c'
  on-primary-fixed-variant: '#005228'
  secondary-fixed: '#ffdbc8'
  secondary-fixed-dim: '#ffb68b'
  on-secondary-fixed: '#321200'
  on-secondary-fixed-variant: '#753400'
  tertiary-fixed: '#cce5ff'
  tertiary-fixed-dim: '#93ccff'
  on-tertiary-fixed: '#001d31'
  on-tertiary-fixed-variant: '#004b73'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '800'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.25rem
  space-xl: 1.5rem
  space-2xl: 2rem
---

## Brand & Style

This design system establishes a welcoming, secure, and hyper-reliable civic experience for modern neighborhood governance (Rukun Tetangga & Rukun Warga) across Indonesia. Drawing inspiration from consumer giants like Gojek and Traveloka, the interface combines civic responsibility with the friction-free fluidity of premier consumer tech.

The brand personality centers on:
- **Gotong Royong (Mutual Cooperation):** Community-first warmth, high accessibility, and conversational clarity that respects both tech-savvy youth and community elders (*Ketua RT/RW*).
- **Fintech-Grade Transparency:** Precision, security, and administrative trust for collection of dues (*iuran sampah, keamanan*), financial statements, and emergency reporting.
- **Dynamic Energy:** Confident action triggers that make day-to-day civic tasks feel as effortless as ordering food or hailing a ride.

The visual style blends **Corporate / Modern SuperApp architecture** with **soft tactile surfaces and glassmorphic camera overlays**. It balances crisp information density with spacious, pill-shaped UI components, friendly 3D accents, and rounded elevation surfaces that sit comfortably in high-density mobile environments.

## Colors

The palette establishes an immediate sense of growth, governance, and community warmth:

- **Primary (`#107C41` - Emerald Green):** The core civic anchor representing security, community harmony, verified resident status, and official notices. Deep emerald variations (`#0E6635`) are reserved for high-contrast headers, active tab highlights, and authoritative badges.
- **Secondary (`#FF7A00` - Bright Tangerine Orange):** High-energy accent driven by urgency and prompt action. Used exclusively for immediate transaction buttons, panic alarms (*Tombol Darurat*), bill pay reminders (*Bayar Iuran*), and community celebration banners.
- **Tertiary (`#0284C7` - Civic Sky Blue):** Utility color utilized for administrative records, civil documents (*Surat Pengantar*), and verification flags.
- **Neutral Palette:**
  - Canvas Surface: `#F8FAFC` and `#F5F7FA`, providing a clean, warm off-white canvas that prevents glare during daytime outdoor usage.
  - Cards & Floating Surfaces: Pure `#FFFFFF`.
  - Body Text & Typography: `#0F172A` (Slate 900) for sharp legibility, cascading down to `#475569` (Slate 600) for secondary details and `#94A3B8` (Slate 400) for subtle borders and placeholders.
  - Semantic Status: Emerald `#16A34A` (Paid / Lunas), Crimson `#DC2626` (Urgent / Belum Bayar), and Amber `#F59E0B` (Pending / Diproses).

## Typography

The type system prioritizes clarity and modern Indonesian warmth by leveraging **Plus Jakarta Sans** for brand identity, editorial headings, and interactive actions, complemented by **Inter** for data grids, monetary ledgers, and micro-labels.

- **Headlines & Titles:** Set with tighter letter-spacing and strong weights (700 and 800) to convey authority and structure without feeling cold or overly bureaucratic.
- **Body & Paragraphs:** Tuned to comfortable line heights (140–150%) using balanced weights to preserve readability under variable screen brightness and ambient daylight.
- **Numbers & Metrics:** Ledger counters, currency figures (*IDR / Rp*), and door/block numbers leverage tabular numeric figures within **Inter** to ensure perfect alignment in billing and community ledger tables.

## Layout & Spacing

The layout operates on a flexible, mobile-first grid model tailored for one-handed thumb interaction while adapting gracefully to tablets and administration dashboards.

- **Mobile Canvas:** A 4-column layout with `1rem` outer canvas margins and `0.75rem` to `1rem` gutters. Primary interactive targets remain within bottom navigation zones and thumb-reachable cards.
- **Tablet & Split-Pane:** Switches to an 8-column layout with `1.5rem` margins, enabling concurrent citizen directory and detail views.
- **Desktop (Web Admin for RT/RW Officers):** A standard 12-column layout maxing out at `1280px` canvas width, backed by `2rem` margins and `1.5rem` gutters.
- **Rhythm Rules:** Internal component padding scales predictably using `space-sm` (8px) for badge internals, `space-md` (16px) for standard card padding, and `space-xl` (24px) for prominent balance and quick-action module headers.

## Elevation & Depth

Visual depth combines soft ambient lighting with subtle, tinted perimeter shadows, avoiding stark drop shadows in favor of a soft-touch, approachable aesthetic:

- **Level 0 (Canvas):** Flat base `#F8FAFC`. Zero elevation.
- **Level 1 (Feed & Content Cards):** `0 2px 8px -2px rgba(15, 23, 42, 0.04), 0 1px 3px 0 rgba(15, 23, 42, 0.02)`. Accompanied by a 1px soft border in `rgba(226, 232, 240, 0.8)` to preserve structure on sunlight-exposed mobile screens.
- **Level 2 (Interactive Modules & Fintech Wallets):** `0 10px 25px -5px rgba(16, 124, 65, 0.08), 0 4px 10px -2px rgba(15, 23, 42, 0.03)`. A slight green-tinted ambient glow reinforces brand presence on citizen balance and billing cards.
- **Level 3 (Modals, Action Sheets, Floating Buttons):** `0 20px 32px -8px rgba(15, 23, 42, 0.12), 0 8px 16px -4px rgba(15, 23, 42, 0.06)`.
- **Glassmorphic Overlays (Camera, Guard Scanning, Story Banners):** Background blur `backdrop-filter: blur(16px)` with a semi-translucent fill `rgba(255, 255, 255, 0.72)` and an inner rim reflection `inset 0 1px 1px 0 rgba(255, 255, 255, 0.6)`. Used during guest QR code verification and security camera streams.

## Shapes

The shape system employs generous, human-centric curves that evoke community friendliness, warmth, and modern app craftsmanship:

- **Base Elements:** Rounded corners set at `0.5rem` (8px) for micro-inputs, chips, and small notification toasts.
- **Cards & Content Panels:** Containers default to `rounded-lg` (`1rem` / 16px) and prominent hero cards scale to `rounded-xl` (`1.5rem` / 24px) to create approachable, tactile touch targets.
- **Floating Controls & Quick Actions:** Buttons, pill counters, active badges, and search bars utilize full pill rounding (`9999px`) to maintain superapp agility and intuitive thumb-targets.
- **Sheet Corners:** Bottom draw-sheets, citizen verification dialogs, and payment confirmations feature continuous curvature with top radii set to `1.5rem` (24px).

## Components

### Buttons
- **Primary Action (Community & Pay):** Tangerine Orange `#FF7A00` solid fill, white text, bold weight (`label-lg`), pill-shaped (`9999px`), with horizontal padding `space-xl` and height 48px. Features a subtle orange ambient hover/pressed shadow (`0 6px 16px -2px rgba(255, 122, 0, 0.35)`).
- **Secondary (Administrative / Civic):** Emerald Green `#107C41` solid fill or `#107C41` 1.5px border on `#F0FDF4` light green tint background.
- **Emergency Button (*Tombol Darurat*):** High-alert crimson `#DC2626` circular or pill button with pulsating multi-layer ring animation.

### Fintech-Grade Cards (*Kas RT & Iuran*)
- Card surface structured in `#FFFFFF` with `rounded-xl` (20–24px) corners.
- Top section houses a deep emerald gradient banner (`#107C41` to `#0E6635`) showing neighborhood fund balances (*Total Kas RT 04*), masked account identifiers, and quick shortcut icons (Top Up, Bayar, Riwayat).
- Subtle card edge highlights using low-contrast `#E2E8F0` borders.

### Input Fields & Search Bars
- Search inputs styled with full pill bounds (`9999px`), `#FFFFFF` background, left-aligned search icon in `#64748B`, and subtle boundary line `#E2E8F0`. Focus state replaces border with a 2px `#107C41` ring and zero-offset bloom.
- Form inputs feature floating labels in `label-sm`, 48px height, and `rounded-lg` corners.

### Chips & Badges
- **Status Badges:** Small pill badges with 4px vertical, 10px horizontal padding.
  - *Lunas (Paid):* Light green background (`#DCFCE7`) with deep green text (`#15803D`).
  - *Warga Tetap (Permanent Resident):* Light sky background (`#E0F2FE`) with sky blue text (`#0369A1`).
  - *Tamu (Visitor):* Light amber background (`#FEF3C7`) with warm bronze text (`#B45309`).
- **Category Filter Chips:** Floating pill chips that toggle between inactive (white surface, slate border) and active (Emerald Green fill, white text).

### Lists & Resident Directory
- Row height of 64px to 72px with separated divider lines (`#F1F5F9`).
- Left side includes a 44px rounded avatar or unit code pill (e.g., `Blok B2 / No. 14`), middle section features resident name and head-of-household (*Kepala Keluarga*) tag, and right side displays contact or verification icons.

### Checkboxes & Radio Buttons
- 20px rounded squares (checkbox) and 20px circles (radio).
- Active state fills with Emerald Green `#107C41` and crisp white checkmark / inner dot.
- Tap targets padded out to 44px for effortless tapping by all demographics.

### Glassmorphic Camera & Security Overlay
- Semi-transparent HUD overlay on live CCTV and gate QR scanners.
- Frosted pill controls (`rgba(15, 23, 42, 0.6)` backdrop blur 12px) for torch toggles, plate recognition indicators, and visitor confirmation gates.