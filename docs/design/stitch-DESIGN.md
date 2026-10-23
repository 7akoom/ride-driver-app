---
name: Serene Night Driver
colors:
  surface: '#faf8ff'
  surface-dim: '#d8d9e6'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#ecedfa'
  surface-container-high: '#e6e7f4'
  surface-container-highest: '#e1e2ee'
  on-surface: '#191b24'
  on-surface-variant: '#4e4639'
  inverse-surface: '#2e303a'
  inverse-on-surface: '#eff0fd'
  outline: '#807667'
  outline-variant: '#d1c5b4'
  surface-tint: '#78591c'
  primary: '#6f5214'
  on-primary: '#ffffff'
  primary-container: '#8a6a2b'
  on-primary-container: '#fff2e0'
  inverse-primary: '#e9c179'
  secondary: '#715b2c'
  on-secondary: '#ffffff'
  secondary-container: '#fddfa3'
  on-secondary-container: '#786131'
  tertiary: '#004cca'
  on-tertiary: '#ffffff'
  tertiary-container: '#2865ed'
  on-tertiary-container: '#f2f2ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdea7'
  primary-fixed-dim: '#e9c179'
  on-primary-fixed: '#271900'
  on-primary-fixed-variant: '#5d4203'
  secondary-fixed: '#fddfa3'
  secondary-fixed-dim: '#e0c389'
  on-secondary-fixed: '#261a00'
  on-secondary-fixed-variant: '#584416'
  tertiary-fixed: '#dbe1ff'
  tertiary-fixed-dim: '#b4c5ff'
  on-tertiary-fixed: '#00174b'
  on-tertiary-fixed-variant: '#003ea8'
  background: '#faf8ff'
  on-background: '#191b24'
  surface-variant: '#e1e2ee'
typography:
  headline-xl:
    fontFamily: IBM Plex Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 44px
  headline-lg:
    fontFamily: IBM Plex Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: IBM Plex Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 30px
  headline-sm:
    fontFamily: IBM Plex Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  body-lg:
    fontFamily: IBM Plex Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: IBM Plex Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: IBM Plex Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: IBM Plex Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  label-md:
    fontFamily: IBM Plex Sans
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-sm:
    fontFamily: IBM Plex Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 18px
  numeric-fare:
    fontFamily: IBM Plex Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system serves professional captains in Erbil and across Iraq who operate during long evening, night, and early-morning shifts. The driver interface must project composure, dignity, and absolute clarity under demanding, variable road and lighting conditions. Rather than an overstimulating, frantic gig-economy aesthetic, the design adopts a restrained, luxury-utilitarian ethos: warm architectural neutrals, deep high-contrast inks, and a refined amber-gold accent inspired by ambient dashboard illumination.

Key visual pillars:
- **Calm Authority:** Decluttered layouts eliminate cognitive load. Vital ride actions, turn-by-turn alerts, and fare updates are instantly parseable from arm's-length phone mounts.
- **RTL-Native Ergonomics:** Built ground-up for Arabic typography with logical right-to-left layout flows, natural thumb sweep arcs, and contextual glanceability.
- **Instrument Precision:** Tactile feedback, physical sliding actions to prevent accidental accepts/completions over rough terrain, and assertive status states that never compromise night driving safety.

## Colors

The palette establishes an intentional daytime-to-dusk light mode balance that minimizes blinding glare while preserving crisp, daylight-proof contrast ratios (exceeding WCAG AAA for core typography).

- **Base Surfaces:**
  - `background`: `#F7F6F2` (Warm, non-glare alabaster canvas that shields night-adapted eyes from raw white light shock)
  - `surface`: `#FFFFFF` (Elevated modules, primary bottom sheets, and route cards)
  - `surface-2`: `#F1EFE9` (Segmented controls, inactive chips, and recessed metadata containers)
  - `border`: `#E6E2D8` (Subtle boundary definition for daylight edge clarity)

- **Typography & Inks:**
  - `text-primary` / `ink`: `#05070F` (Pitch obsidian for maximum structural contrast)
  - `text-secondary`: `#4A5060` (Neutral slate for secondary trip meta and directional context)
  - `text-tertiary`: `#8A90A0` (Muted timestamps, inactive states, and placeholder texts)

- **Brand & Accents:**
  - `brand-gold`: `#F3D59A` (Warm champagne glow for highlights, ratings, and driver tier surfaces)
  - `brand-strong`: `#8A6A2B` (Deep antique gold for high-contrast interactive links and badges)

- **Operational Telemetry:**
  - `route/info`: `#2563EB` (Cobalt blue reserved exclusively for active navigation, pickup vectors, and critical guidance)
  - `success`: `#15803D` (Driver online, fare settled, surge multipliers)
  - `warning`: `#B45309` (Wait-time countdowns, detours, dispatch alerts)
  - `danger`: `#DC2626` (Ride cancellations, SOS, critical system disconnects)

## Typography

Typography relies on IBM Plex Sans Arabic for its structural authority, clear glyph boundaries, and open counters that remain legible in vibration-prone vehicle mounts.

- **Numerals & Currency:** Western Arabic numerals (0-9) are paired with the Iraqi Dinar glyph `د.ع`. Numeric figures in fare cards and ETA indicators maintain tabular layout metrics to prevent line jitter during active distance calculations.
- **Vertical Metrics:** Line-height values are calibrated wider than standard Latin baselines (+25% line headroom) to account for Arabic ascenders, descenders, and accent marks without clipping.
- **RTL Hierarchy:** Headline and label alignments default to `right`. Numbers within body copy remain natural LTR blocks while maintaining overall RTL paragraph flow.

## Layout & Spacing

The layout is optimized for an Android handheld viewport measuring 390x844 dp, scaled along a rigid 4pt spatial grid. 

- **Thumb Zone Allocation:** Primary call-to-actions, confirmation sliders, and map interaction triggers reside within the lower 40% vertical envelope (the ergonomic thumb zone for one-handed right or left-handed operation).
- **Edge Offsets:** Margins use `16px` (`margin`) outer gutters to insulate interactive components against curved glass edges and screen protector borders.
- **Safe Area Insets:** The top 48dp accommodates the system status bar and network telemetry; the bottom 34dp provides a persistent clear buffer for gesture navigation.
- **Touch Target Integrity:** All touchable interactive elements adhere to a strict minimum target bounding box of 56x56 dp, well above accessibility baselines, preventing mis-taps while driving.

## Elevation & Depth

Visual hierarchy uses a hybrid strategy of warm-tinted ambient shadows and tonal surface nesting rather than harsh skeuomorphic drop shadows.

- **Surface Tiers:**
  - **Level 0 (Map Canvas / System Base):** `#F7F6F2` canvas.
  - **Level 1 (Docked HUD & Route Cards):** `#FFFFFF` with a crisp `1px solid #E6E2D8` border, accompanied by an ambient diffused shadow: `0 4px 20px -2px rgba(5, 7, 15, 0.05)`.
  - **Level 2 (Interactive Floating Actions & Modals):** `#FFFFFF` with `0 10px 25px -4px rgba(5, 7, 15, 0.09)`.
  - **Level 3 (Modal Bottom Sheets):** Full overlay sheets featuring `0 -8px 32px 0 rgba(5, 7, 15, 0.12)` anchored above a tinted backdrop scrim (`rgba(5, 7, 15, 0.45)`).
- **Border Integration:** Low-contrast borders (`#E6E2D8`) are paired with ambient depth to preserve edge fidelity when viewed under glare or low dashboard display brightness.

## Shapes

The geometric architecture pairs soft structural contours with functional predictability:

- **Buttons & Interactive Controls:** Defined with an exact `14px` border-radius to create a modern, pill-adjacent silhouette that feels tactile yet stable.
- **Cards, Panels & Floats:** Standardized at `16px` border-radius. Nested content boxes inside cards take an `8px` or `10px` radius to maintain geometric concentricity.
- **Bottom Sheets:** Configured with `24px` top-start and top-end radii, transitioning to zero radius along the device baseline.
- **Grab Handles & Status Pills:** Fully rounded capsule (pill) geometry (`9999px`).

## Components

### Buttons & Touch Drivers
- **Slide-to-Confirm Bar:** Primary trip commitment mechanism (Accept Request, Arrived, Start Trip, Complete Ride). Built at 64px height with a full-width track in `#F1EFE9` and a 56px draggable rounded pill button (`#05070F` with `#F3D59A` directional chevron icon sliding right-to-left for Arabic layout). Eliminates accidental activation from phone mount shakes.
- **Primary Button:** 56px minimum height, `#05070F` background, `#FFFFFF` text, 14px radius, centered `label-lg` Arabic text. Active state transitions to `#8A6A2B`.
- **Secondary / Utility Button:** 56px height, `#FFFFFF` background, `1px solid #E6E2D8`, `#05070F` text.

### Bottom Sheets
- Docked persistently to the bottom safe zone with a 24px top radius. 
- Integrated `#E6E2D8` drag handle (36x4px, 8px bottom margin).
- Contains trip itinerary, rider profile, payment mode badge (Cash / ZainCash / Card), and fare total.

### Route & Fare Cards
- 16px radius, `#FFFFFF` background, `1px solid #E6E2D8` stroke.
- Features stacked pickup-dropoff timeline nodes: pickup pin in `#2563EB`, drop-off pin in `#8A6A2B`, joined by a 2px vertical dotted track.
- Price display prominently presents the total using `numeric-fare` typography along with the `د.ع` currency mark positioned at the end of the figure according to Arabic typesetting conventions.

### Status Chips & Badges
- 32px height, 8px horizontal padding, 9999px pill radius.
- "Online" status: `#DCFCE7` background, `#15803D` text with a 6px pulsing green indicator dot.
- "Surge" status: `#FEF3C7` background, `#B45309` text.

### Inputs & Search Bars
- 56px height, `#F1EFE9` background with an active focus border in `#8A6A2B` (1.5px stroke).
- Right-aligned Arabic placeholder text in `#8A90A0` with a right-aligned inset search or map-pin glyph.