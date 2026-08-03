# Flutter UI/UX Design System — API Scout

## What This Is

A complete design system export for rebuilding the Flutter mobile app to match the web admin dashboard's **"Monolithic Technical Interface"** — a Brutalist-Minimalist hybrid aesthetic.

**This directory contains only UI, styles, themes, colors, fonts, components, layouts, and UX patterns. No API contracts, no data models.**

## Design Philosophy

**Monolithic Technical Interface**
- Strictly monochromatic (black primary `#000000`)
- `0px` border-radius on ALL elements (no exceptions except status dots/avatars)
- 1px grid architecture for structural separation
- Hard-offset shadows ONLY on modals: `4px 4px 0px #000000`
- Hard-offset shadows on focused inputs: `2px 2px 0px #000000`
- Tonal layering via surface containers instead of shadows
- 100% uppercase for labels and navigation
- High data density with minimal decorative elements
- Square spinner with 700ms rotation

## Files

| File | What's Inside |
|------|---------------|
| `DESIGN_SYSTEM.json` | Complete token system: colors, typography scale, spacing, borders, shadows, elevation, responsive breakpoints, accessibility specs, animation system, icon system, scrollbar, UX patterns |
| `COMPONENTS.json` | All 20 component schemas with states & interactions: sidebar, topNav, button, input, textarea, select, card, table, chip, modal, spinner, codeBlock, checkbox, separator, tabs, toast, footer, dialog, dropdown, tooltip, progressBar, badge |
| `PAGES.json` | All 9 page layouts: login, dashboard, APIs catalog, categories, submissions, jobs, API tester, audit logs, settings |
| `theme.dart` | Flutter `ThemeData` with all tokens: colors, typography (Geist/Inter/JetBrains Mono), spacing, shadows, borders, button themes. Copy-paste ready |

## Color Tokens

### Primary
| Token | Hex | Usage |
|-------|-----|-------|
| primary | `#000000` | Buttons, active states, focus rings |
| onPrimary | `#ffffff` | Text on primary backgrounds |
| primaryContainer | `#1b1b1b` | Dark containers |
| onPrimaryContainer | `#848484` | Text on dark containers |

### Surface
| Token | Hex | Usage |
|-------|-----|-------|
| background | `#f9f9f9` | Page canvas |
| surfaceContainerLowest | `#ffffff` | Cards, inputs (white) |
| surfaceContainerLow | `#f3f3f3` | Sidebar, code blocks, inset wells |
| surfaceContainer | `#eeeeee` | Table headers, active nav items |
| surfaceContainerHigh | `#e8e8e8` | Selected rows |
| surfaceContainerHighest | `#e2e2e2` | Borders, dividers |

### Outline
| Token | Hex | Usage |
|-------|-----|-------|
| outline | `#7e7576` | Muted text, secondary icons |
| outlineVariant | `#cfc4c5` | Borders, separators |

### Semantic
| Token | Hex | Usage |
|-------|-----|-------|
| success | `#16a34a` | Alive status, approve actions |
| successBg | `#dcfce7` | Success chip background |
| danger | `#dc2626` | Dead status, delete actions |
| dangerBg | `#fee2e2` | Error chip background |
| warning | `#ca8a04` | Warning states |
| warningBg | `#fef9c3` | Warning chip background |
| info | `#2563eb` | Info states |
| infoBg | `#dbeafe` | Info chip background |

## Typography

| Style | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| headlineLg | Geist | 32px | 600 | Page titles |
| headlineMd | Geist | 24px | 600 | Section headers |
| headlineSm | Geist | 18px | 600 | Modal titles |
| bodyLg | Inter | 16px | 400 | Descriptions |
| bodyMd | Inter | 14px | 400 | Table cells, inputs |
| labelSm | Inter | 12px | 600 | Table headers, field labels (ALWAYS UPPERCASE) |
| codeMd | JetBrains Mono | 13px | 450 | API keys, endpoints |

### Font Loading (Flutter)

```dart
import 'package:google_fonts/google_fonts.dart';

// Headlines
GoogleFonts.geist()

// Body text
GoogleFonts.inter()

// Code / technical data
GoogleFonts.jetBrainsMono()
```

## Spacing

Base unit: `8px`. Scale: `[0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64]`.

| Context | Value |
|---------|-------|
| Page padding (horizontal) | 32px |
| Page padding (vertical) | 24px |
| Sidebar width | 256px |
| Top nav height | 64px |
| Container max width | 1440px |
| Gutter between columns | 24px |

## Borders & Shadows

- **All elements**: 0px border-radius
- **Structural borders**: 1px `#e2e2e2`
- **Focus borders**: 1px `#000000` with `2px 2px 0px #000000` shadow
- **Modal shadows**: `4px 4px 0px #000000` (hard offset, no blur)
- **No shadows** on cards, buttons, or any other element — use tonal layering instead

## Button Variants

| Variant | Background | Text | Border | Hover |
|---------|-----------|------|--------|-------|
| primary | `#000000` | `#ffffff` | `1px #000000` | Invert to white bg |
| secondary | `#ffffff` | `#000000` | `1px #e2e2e2` | Gray bg `#f3f3f3` |
| ghost | transparent | `#7e7576` | none | Gray bg `#f3f3f3` |
| destructive | `#dc2626` | `#ffffff` | `1px #dc2626` | Invert to white bg |

All buttons: uppercase, 600 weight, 0.05 letter-spacing, 0px border-radius.

## Spinner

Square shape, not circular. 700ms linear rotation.

| Size | Dimensions | Border | Shadow |
|------|-----------|--------|--------|
| sm | 12x12 | 1.5px | none |
| default | 16x16 | 2px | `1px 1px 0px #000000` |
| lg | 32x32 | 3px | `2px 2px 0px #000000` |

## Responsive Breakpoints

| Breakpoint | Width | Layout |
|-----------|-------|--------|
| mobile | <640px | Single column, sidebar hidden, 16px padding |
| tablet | 641-1024px | Single column, sidebar collapsed, 24px padding |
| desktop | 1025px+ | Sidebar 256px + content, 32px padding |
| wide | 1440px+ | Max content width 1440px |

## Accessibility

- **Focus visible**: 2px solid `#000000` outline with 2px offset
- **Touch targets**: Minimum 44x44px on mobile
- **Contrast ratios**: Normal text 4.5:1, large text 3:1
- **Reduced motion**: Disable all animations, keep spinners static
- **Screen readers**: All images have alt text, forms have labels, dynamic content uses live regions
- **Color blindness**: Never use color alone for status — always pair with icons or text labels

## UX Patterns

### Loading States
- **Page load**: Centered spinner (lg), 32x32px
- **Table load**: Centered spinner in table body
- **Button load**: Replace text with spinner (sm), keep button width
- **Inline load**: Small spinner next to text ("Creating...")

### Empty States
- **No data**: Centered muted text message
- **No results**: Search icon + "No results found" + clear filters button
- **No items**: Action button to create first item

### Error Handling
- **Inline error**: Red text below failed field
- **Toast error**: Bottom-right, hard shadow, auto-dismiss 5s
- **Network error**: Toast with retry action, don't clear current data

### Success Feedback
- **Toast**: Bottom-right, green, auto-dismiss 3s
- **Inline**: Green checkmark or chip next to action
- **Navigation**: Navigate to created/updated item

### Confirmations
- **Destructive**: Modal dialog with hard shadow, cancel + confirm buttons
- **Soft destructive**: Toast with undo action (5s window)
- **Quick toggle**: Double-click or hold-to-confirm

### Detail Panel
- **Trigger**: Click table row
- **Position**: Right side, overlaying content
- **Width**: 384px
- **Close**: Backdrop click or Escape key
- **Animation**: Slide in from right, 200ms

### Toast Notifications
- **Position**: Bottom-right, 20px offset
- **Max visible**: 3
- **Auto-dismiss**: Success 3s, Error 5s, Info 3s
- **Stack**: Newest on top
- **Swipe to dismiss**: Enabled

### Search
- **Debounce**: 300ms
- **Min chars**: 2
- **Highlight matches**: Yes

### Pagination
- **Style**: Previous / Page numbers / Next
- **Page size**: 20
- **Info text**: "Showing X-Y of Z"
- **Max visible pages**: 5
