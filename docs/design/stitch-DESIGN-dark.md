---
name: Serene Night Driver
colors:
  surface: '#0e1321'
  surface-dim: '#0e1321'
  surface-bright: '#343948'
  surface-container-lowest: '#090e1c'
  surface-container-low: '#161b2a'
  surface-container: '#1a1f2e'
  surface-container-high: '#252a39'
  surface-container-highest: '#303444'
  on-surface: '#dee2f6'
  on-surface-variant: '#cfc5b6'
  inverse-surface: '#dee2f6'
  inverse-on-surface: '#2b303f'
  outline: '#989082'
  outline-variant: '#4d463a'
  surface-tint: '#e0c389'
  primary: '#fff3e3'
  on-primary: '#3f2e02'
  primary-container: '#f3d59a'
  on-primary-container: '#715b2c'
  inverse-primary: '#715b2c'
  secondary: '#a4c9ff'
  on-secondary: '#00315d'
  secondary-container: '#0267b8'
  on-secondary-container: '#d6e5ff'
  tertiary: '#d7ffdb'
  on-tertiary: '#003919'
  tertiary-container: '#62f392'
  on-tertiary-container: '#006d35'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#fddfa3'
  primary-fixed-dim: '#e0c389'
  on-primary-fixed: '#261a00'
  on-primary-fixed-variant: '#584416'
  secondary-fixed: '#d4e3ff'
  secondary-fixed-dim: '#a4c9ff'
  on-secondary-fixed: '#001c39'
  on-secondary-fixed-variant: '#004883'
  tertiary-fixed: '#6dfe9c'
  tertiary-fixed-dim: '#4de082'
  on-tertiary-fixed: '#00210c'
  on-tertiary-fixed-variant: '#005227'
  background: '#0e1321'
  on-background: '#dee2f6'
  surface-variant: '#303444'
typography:
  headline-xl:
    fontFamily: IBM Plex Sans
    fontSize: 48px
    fontWeight: '600'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: IBM Plex Sans
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: IBM Plex Sans
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: IBM Plex Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: 0em
  headline-md:
    fontFamily: IBM Plex Sans
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 32px
    letterSpacing: 0em
  headline-sm:
    fontFamily: IBM Plex Sans
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
    letterSpacing: 0em
  title-md:
    fontFamily: IBM Plex Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0.01em
  body-lg:
    fontFamily: IBM Plex Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
    letterSpacing: 0em
  body-md:
    fontFamily: IBM Plex Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: IBM Plex Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-lg:
    fontFamily: IBM Plex Sans
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-md:
    fontFamily: IBM Plex Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: IBM Plex Sans
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.08em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1.25rem
  gutter-mobile: 0.75rem
  margin: 2rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

This design system channels the quiet, focused serenity of late-night navigation through empty highways and illuminated city grids. Designed for automotive dashboards, night telemetry, flight trackers, and dark-interface cockpit utilities, it delivers calm precision without visual fatigue.

The design movement combines **Minimalism** with an **Instrumental Modern** aesthetic. Deep, pitch-black canvases minimize cabin glare, while warm, luminous gold accents replicate the glow of vintage dashboard indicators and street lamps cutting through the dark. Surfaces remain structural and flat, relying on crisp, low-contrast ghost borders rather than aggressive drop shadows. The resulting atmosphere feels technical, luxurious, and restful—engineered for sustained focus under low-ambient-light conditions.

## Colors

The palette centers on absolute darkness accented by warm amber illumination and clear telemetry signals.

### Core Canvas & Surfaces
- **Canvas Background (`#05070F`)**: Deep midnight obsidian. Anchors the viewport to eliminate display glare.
- **Surface Level 1 (`#0D1220`)**: Elevated panels, side navigation rails, and card containers.
- **Surface Level 2 (`#151B2C`)**: Active rows, floating metric pods, dropdown sheets, and interactive hovers.
- **Surface Border (`rgba(255, 255, 255, 0.08)`)**: Hairline boundary maintaining visual separation between deep obsidian tiers.

### Brand Accents
- **Brand / Primary (`#F3D59A`)**: Soft incandescent gold. Used for key action triggers, primary routes, active toggles, and critical milestones. When used as a solid fill, contrast text is strictly `#05070F`.
- **Brand Strong (`#F3D59A`)**: Direct highlight for vital telemetry figures, speed caps, and navigational bearings.

### Typography Hierarchy
- **Text Primary (`#FFFFFF`)**: High-contrast readouts, essential metrics, and section titles.
- **Text Secondary (`#9BA1B0`)**: Metadata, descriptive copy, inactive menu labels, and axis markers.
- **Text Tertiary (`#6B7280`)**: Disabled states, peripheral legends, timestamps, and subtle divider glyphs.

### Status Indicators
- **Info (`#60A5FA`)**: Waypoints, meteorological updates, sensor synchronization.
- **Success (`#4ADE80`)**: Nominal vehicle health, active cruise control, completed paths.
- **Warning (`#FBBF24`)**: Low traction warnings, congestion delays, low fuel thresholds.
- **Danger (`#F87171`)**: Collision avoidance alerts, sensor fault warnings, route obstruction.

## Typography

The typography relies entirely on **IBM Plex Sans**, chosen for its industrial precision, grotesque legibility, and technical clarity under high-speed scanning conditions. 

- Use tabular numerical figures (`font-variant-numeric: tabular-nums`) across all speedometers, coordinate indicators, timestamps, and numerical telemetric readings to avoid layout jitter during real-time updates.
- Display and headline levels rely on tight letter spacing with medium-to-semibold weights to retain sharp edges against dark backgrounds.
- High-priority system badges, sensor titles, and unit definitions use `label-sm` rendered in full uppercase with expanded tracking (`0.08em`) to guarantee quick recognition at peripheral glance angles.

## Layout & Spacing

The layout philosophy follows a disciplined, instrumented **Fluid Grid** structure:

- **Desktop & In-Dash Displays (1024px and above)**: 12-column dynamic grid with `2rem` outer margin and `1.25rem` column gutters. Primary map canvas occupies full height or spans 8 to 9 columns, leaving a dedicated 3-to-4 column docking rack for route cards, diagnostics, and auxiliary toggles.
- **Tablet / Mid-tier Screens (768px - 1023px)**: 8-column layout with `1.5rem` margins and `1rem` gutters. Cockpit controls dock into a collapsible bottom or side sheet.
- **Mobile Viewport (up to 767px)**: 4-column layout with `1rem` margins and `0.75rem` gutters. Map layers serve as the persistent base background, while interactive elements float within stacked bottom sheets and anchored quick-action bars.
- Spacing rhythm strictly utilizes base-4 multiples (`space-xs` = 4px, `space-sm` = 8px, `space-md` = 16px, `space-lg` = 24px, `space-xl` = 40px) to balance tight grouping in technical clusters with adequate breathing room around primary navigation controls.

## Elevation & Depth

Visual hierarchy is established using **Tonal Layering** coupled with **Low-Contrast Outlines**, avoiding blurred cast shadows that wash out dark displays.

1. **Base Layer (Elevation 0 - `#05070F`)**: The cartographic vector canvas or primary app backdrop. Completely flat and non-interactive.
2. **Container Tier (Elevation 1 - `#0D1220`)**: Side navigation rails, route overviews, and metric monitors. Bound by a structural 1px ghost border (`rgba(255, 255, 255, 0.08)`).
3. **Floating Overlay (Elevation 2 - `#151B2C`)**: Active turn indicators, flyout tooltips, hovering route action buttons, and modal dialogs. Features an emphasized border (`rgba(255, 255, 255, 0.12)`) and an ultra-subtle ambient perimeter illumination: `0 8px 32px rgba(5, 7, 15, 0.75)`.
4. **Active Instrument Glow**: Selected indicators and brand elements apply a localized gold backlight hue (`0 0 16px rgba(243, 213, 154, 0.15)`) to signal operational vitality without creating glare.

## Shapes

The design system adopts a **Soft (Level 1)** corner geometry, evoking refined hardware engineering, aerospace instrumentation, and precision-cut digital panels:

- **Default Components (Inputs, Buttons, Cards, Chips)**: Fixed at `0.25rem` (4px) to retain an architectural, tailored feel.
- **Intermediate Modals & Map Panels (`rounded-lg`)**: `0.5rem` (8px) for comfortable framing of dense visual content.
- **Flyout Drawers & Overlay Shells (`rounded-xl`)**: `0.75rem` (12px) to softly transition large spatial containers over the navigation plane.
- Avoid large circular or pill radii for primary containers; circular geometry is reserved strictly for iconic directional arrows and status beacon dots.

## Components

### Buttons
- **Primary**: Background `#F3D59A`, text `#05070F`, font weight 600. Hover shifts brightness down slightly (`#E5C78B`) with an ambient gold glow (`box-shadow: 0 0 12px rgba(243, 213, 154, 0.25)`). Focus outline: 2px solid `#F3D59A` with 2px offset in `#05070F`.
- **Secondary / Ghost**: Background `#151B2C`, border 1px solid `rgba(255, 255, 255, 0.08)`, text `#FFFFFF`. Hover elevates background to `#1C243B` and border to `rgba(255, 255, 255, 0.16)`.
- **Destructive**: Background `rgba(248, 113, 113, 0.12)`, border 1px solid `rgba(248, 113, 113, 0.3)`, text `#F87171`.

### Chips & Badges
- Background `#0D1220`, border 1px solid `rgba(255, 255, 255, 0.08)`, padding `0.25rem 0.5rem`.
- Active / Selected Chip: Border `#F3D59A`, text `#F3D59A`, background `rgba(243, 213, 154, 0.08)`.
- Telemetry Badges: Contain an embedded 6px circular LED indicator utilizing semantic colors (Success `#4ADE80`, Warning `#FBBF24`, Info `#60A5FA`).

### Lists & Data Grids
- Clean borders dividing list items using hairline `rgba(255, 255, 255, 0.06)`.
- Active or hover row state transitions background smoothly to `#151B2C`. Left edge displays an optional 2px inset vertical border in `#F3D59A` for tracking the currently targeted waypoint or telemetry stream.

### Checkboxes & Radio Buttons
- Base box: 18px × 18px, border 1.5px solid `rgba(255, 255, 255, 0.2)`, background `#0D1220`, corner radius 2px (checkboxes) or 50% (radios).
- Checked: Fill `#F3D59A`, checkmark/dot `#05070F`. Subtle gold halo glow on focus.

### Input Fields
- Base state: Background `#0D1220`, border 1px solid `rgba(255, 255, 255, 0.08)`, text `#FFFFFF`, placeholder `#6B7280`.
- Active / Focus: Border `#F3D59A`, background `#151B2C`, box shadow `0 0 0 1px #F3D59A`.
- Height standard: 40px for desktop, 48px for tactile touch interfaces.

### Cards & Telemetry Pods
- Background `#0D1220`, 1px border `rgba(255, 255, 255, 0.08)`, radius `0.25rem`. Padding standard `space-md` (16px).
- Internal metrics: Primary measurement value formatted in `headline-md` (`#FFFFFF`), paired with a top-aligned unit label in `label-sm` (`#9BA1B0`).

### Night Map Waypoint Markers & HUD Overlays
- Floating turn-by-turn cards use `#151B2C` background with `rgba(255, 255, 255, 0.12)` border.
- Directional arrow glyphs and route lines use `#F3D59A` with an SVG drop filter generating a faint warm road illumination: `filter: drop-shadow(0 0 6px rgba(243, 213, 154, 0.4))`.