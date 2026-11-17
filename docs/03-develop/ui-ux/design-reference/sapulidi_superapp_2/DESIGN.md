---
name: SapuLidi SuperApp
colors:
  surface: '#e8fff0'
  surface-dim: '#c3e1d0'
  surface-bright: '#e8fff0'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#ddfbe9'
  surface-container: '#d7f5e3'
  surface-container-high: '#d1efde'
  surface-container-highest: '#cce9d8'
  on-surface: '#062016'
  on-surface-variant: '#3f4940'
  inverse-surface: '#1c352a'
  inverse-on-surface: '#daf8e6'
  outline: '#6f7a6f'
  outline-variant: '#becabd'
  surface-tint: '#006d37'
  primary: '#006130'
  on-primary: '#ffffff'
  primary-container: '#107c41'
  on-primary-container: '#b6ffc5'
  inverse-primary: '#7ada95'
  secondary: '#006e2f'
  on-secondary: '#ffffff'
  secondary-container: '#6bff8f'
  on-secondary-container: '#007432'
  tertiary: '#006128'
  on-tertiary: '#ffffff'
  tertiary-container: '#007d35'
  on-tertiary-container: '#b9ffbe'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#96f7af'
  primary-fixed-dim: '#7ada95'
  on-primary-fixed: '#00210c'
  on-primary-fixed-variant: '#005228'
  secondary-fixed: '#6bff8f'
  secondary-fixed-dim: '#4ae176'
  on-secondary-fixed: '#002109'
  on-secondary-fixed-variant: '#005321'
  tertiary-fixed: '#7ffc97'
  tertiary-fixed-dim: '#62df7d'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005320'
  background: '#e8fff0'
  on-background: '#062016'
  surface-variant: '#cce9d8'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 30px
    fontWeight: '800'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.015em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.03em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  gutter-lg: 1.5rem
  margin: 1rem
  margin-sm: 1rem
  margin-md: 1.5rem
  margin-lg: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

This design system reflects an Indonesian civic-tech ethos rooted in collective action (*gotong royong*)—symbolized by the *sapu lidi* (broomstick bundle), where individual strands unite into an unbreakable force. 

The aesthetic is Modern Civic Humanism: warm, approachable, reliable, and optimistic. The visual tone bridges institutional dependability with grassroots community warmth through airy white space, ultra-smooth pill-like geometry, organic botanical undertones, and tactile micro-surfaces.

Visual principles:
- **Collective Warmth:** Generous curves, soft tints, and welcoming typography avoid cold governmental rigidity.
- **Clarity & Utility:** High contrast, legible typography, and distinct action targets ensure effortless access across varied digital literacy levels and outdoor display conditions.
- **Organic Modernism:** Botanical greens paired with crisp surfaces create a clean, forward-thinking public service environment.

## Colors

The palette draws directly from lush botanical greens balanced against pristine, breathable surfaces.

- **Primary (`#107C41` / Deep Emerald):** Anchor color for main interactions, primary navigation bars, active states, and core branding moments. Deep variant `#09532B` is reserved for pressed button states and high-emphasis headers.
- **Secondary (`#22C55E` / Leaf Green):** Fresh accent used for positive confirmations, live civic activity badges, and vibrant micro-illustrations.
- **Tertiary (`#16A34A` / Mint Green):** Functional highlight for secondary interactive items, progress indicators, and actionable tags.
- **Neutral Foreground (`#0F291E` / Dark Forest Slate):** Deep organic slate for primary typography and sharp icon rendering, replacing harsh pure blacks with a softer, high-contrast tone. Secondary text uses `#1F382B` (Forest Sage).
- **Backgrounds & Containers:** Base canvas is soft sage `#F7FBF8`, while actionable cards and dialogs sit on `#FFFFFF`. Tonal container fills leverage leafy wash `#DCFCE7` to frame verified civic badges, informational notices, and active category pills.

## Typography

Typography relies on **Plus Jakarta Sans** across all hierarchies to anchor the app in modern Indonesian design craftsmanship. Its geometric clarity, open counters, and humanistic touch make civic dashboards and dense mobile services legible and welcoming.

- **Headlines:** Set tightly in Bold (700) and ExtraBold (800) with slight negative tracking to give service titles punch and vitality.
- **Body:** Uses generous line-heights (1.5x–1.6x) to facilitate comfortable reading of community guidelines, public announcements, and administrative logs.
- **Labels & Badges:** Rendered in SemiBold (600) and Bold (700) with loose tracking for instant scannability on small screens.

## Layout & Spacing

The layout model is mobile-first, utilizing a fluid grid with a maximum content container of 1200px for desktop civic administration portals and a continuous 4-column flow on mobile viewports.

- **Mobile (<640px):** 4 columns, 16px margins, 12px to 16px gutters. UI spans full screen edge with contained cards.
- **Tablet (640px–1024px):** 8 columns, 24px margins, 16px gutters.
- **Desktop (>1024px):** 12 columns, 32px margins, 24px gutters centered within the canvas.

Spacing rhythm follows an organic 4px/8px module:
- `space-xs` (4px) and `space-sm` (8px) handle tight icon-to-label gaps and interior pill padding.
- `space-md` (16px) governs internal card padding and stack margins.
- `space-lg` (24px) separates modular service clusters (e.g., citizen reporting, digital permits, neighborhood boards).
- `space-xl` (40px) demarcates major landing sections.

## Elevation & Depth

This system avoids heavy, muddy drop shadows in favor of tinted ambient depth and crisp surface separations.

- **Canvas & Containers:** Base canvas is `#F7FBF8`. Elevated cards use pure `#FFFFFF` resting on top of a whisper-thin outline (`rgba(16, 124, 65, 0.08)`).
- **Ambient Shadow Levels:**
  - *Level 1 (Cards, Floating Lists):* `0 2px 8px -2px rgba(15, 41, 30, 0.04), 0 1px 3px 0 rgba(15, 41, 30, 0.02)`.
  - *Level 2 (Interactive Elements, Floating Bottom Bar):* `0 8px 24px -4px rgba(16, 124, 65, 0.08), 0 4px 12px -2px rgba(15, 41, 30, 0.03)`.
  - *Level 3 (Modals, Citizen Action Sheets):* `0 20px 32px -8px rgba(9, 83, 43, 0.12), 0 8px 16px -4px rgba(15, 41, 30, 0.06)`.
- **Backdrop Blur:** Overlay elements and sticky headers use `backdrop-filter: blur(12px)` over `rgba(247, 251, 248, 0.85)` to keep content contextually anchored during scrolling.

## Shapes

The shape system adopts hyper-soft, pill-inspired radii (`roundedness: 3`) to evoke a neighborly, approachable civic environment:

- **Pills (`rounded-full`):** Default for primary CTAs, filter chips, search input containers, avatar borders, and notification counters.
- **Cards & Surfaces (`rounded-2xl` / 1.5rem to 2rem):** Outer bounds of modules, citizen report cards, community boards, and modal sheets.
- **Inner Elements (`rounded-lg` / 0.75rem to 1rem):** Media thumbnails, icon badge backgrounds, and internal card callouts.

## Components

### Buttons
- **Primary:** Full pill radius (`rounded-full`), `#107C41` background, white text, bold label. Height: 48px on mobile for optimal touch ergonomics. Pressed: `#09532B`.
- **Secondary:** White or soft sage background, 1.5px border in `#107C41`, `#107C41` label text.
- **Tonal / Ghost:** `#DCFCE7` background with `#09532B` label text. Ideal for secondary municipal actions.

### Chips & Badges
- **Status Badges:** Small pill capsules with 6px vertical padding, 12px horizontal padding. Background `#DCFCE7`, text `#09532B`, paired with a 6px circular indicator in `#22C55E`.
- **Filter Chips:** Unselected chips use pure `#FFFFFF` with `#0F291E`/10% stroke. Selected chips transition to `#107C41` with crisp white text.

### Inputs & Search Bars
- **Citizen Search Bar:** Full pill container (`rounded-full`), `#FFFFFF` surface, subtle border `rgba(16, 124, 65, 0.15)`, leading icon in `#107C41`. Focused state: 2px ring in `#22C55E` with soft glow.
- **Form Fields:** Height 52px, `rounded-2xl`, `#FFFFFF` interior with placeholder text in `#1F382B` (muted 50%).

### Cards & Service Tiles
- **Community Card:** `#FFFFFF` background, `rounded-2xl` (24px radius), 16px internal padding, wrapped with Level 1 ambient emerald shadow.
- **Quick-Access Service Icon Tile:** 64x64px square with `rounded-2xl`, background `#DCFCE7`, containing deep emerald vector iconography (`#107C41`).

### Lists & Row Items
- Separated by dynamic inset dividers (`rgba(16, 124, 65, 0.06)`). Touch feedback manifests as a soft `#DCFCE7` ripple.

### Checkboxes & Radio Controls
- Circular or soft-cornered (`rounded-lg`), 22px diameter. Active state: filled `#107C41` with a clean white check icon. Focus state draws a concentric `#DCFCE7` aura.