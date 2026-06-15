---
name: Nurture & Play
colors:
  surface: '#fff8f9'
  surface-dim: '#dfd8d9'
  surface-bright: '#fff8f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f9f2f3'
  surface-container: '#f3eced'
  surface-container-high: '#ede7e8'
  surface-container-highest: '#e7e1e2'
  on-surface: '#1d1b1c'
  on-surface-variant: '#554244'
  inverse-surface: '#323031'
  inverse-on-surface: '#f6eff0'
  outline: '#887274'
  outline-variant: '#dbc0c2'
  surface-tint: '#9d3f51'
  primary: '#9d3f51'
  on-primary: '#ffffff'
  primary-container: '#ff8c9e'
  on-primary-container: '#782235'
  inverse-primary: '#ffb2bc'
  secondary: '#805434'
  on-secondary: '#ffffff'
  secondary-container: '#fdc39b'
  on-secondary-container: '#794e2e'
  tertiary: '#884d58'
  on-tertiary: '#ffffff'
  tertiary-container: '#e39ba7'
  on-tertiary-container: '#67313c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9dd'
  primary-fixed-dim: '#ffb2bc'
  on-primary-fixed: '#400012'
  on-primary-fixed-variant: '#7e273a'
  secondary-fixed: '#ffdcc5'
  secondary-fixed-dim: '#f4ba93'
  on-secondary-fixed: '#301400'
  on-secondary-fixed-variant: '#653d1f'
  tertiary-fixed: '#ffd9de'
  tertiary-fixed-dim: '#feb2be'
  on-tertiary-fixed: '#370b17'
  on-tertiary-fixed-variant: '#6d3641'
  background: '#fff8f9'
  on-background: '#1d1b1c'
  surface-variant: '#e7e1e2'
  success-green: '#4CD964'
  warning-orange: '#FF9500'
  danger-red: '#FF3B30'
  text-main: '#4A3F3F'
  text-muted: '#8E7F7F'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Be Vietnam Pro
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 20px
  gutter: 12px
---

## Brand & Style

The design system embodies a **"Digital Sticker Book"** aesthetic—warm, encouraging, and tactile. It is specifically designed to reduce the mental load for mothers managing complex schedules while creating a playful, rewarding environment for children. 

The style blends **Modern Minimalism** with **Tactile Softness**. It avoids corporate rigidity in favor of organic shapes, "squishy" interactive elements, and high-quality whitespace that feels like a clean, organized nursery. The UI should evoke feelings of competence for the parent and joyful accomplishment for the child.

**Key Visual Principles:**
- **Encouraging:** Use of success states that feel like earning a physical sticker.
- **Warmth:** Soft, layered depth rather than harsh shadows.
- **Simplicity:** High legibility and clear visual hierarchy to aid busy parents.

## Colors

The palette is centered around **Coral Pink**, a color that is energetic yet soft. **Warm Peach** serves as the primary accent for secondary actions and "kid-centric" elements like check-ins.

- **Primary (#FF8C9E):** Used for main action buttons, progress indicators, and active states.
- **Secondary (#FFC49C):** Used for "fun" elements, rewards, and highlighting today’s specific tasks.
- **Neutral Background (#FFF8F9):** A warm white base that prevents the "clinical" feel of pure white, providing a cozy paper-like texture.
- **Semantic Colors:** Green, Orange, and Red are softened to match the pastel-adjacent palette while remaining highly functional for status alerts.

## Typography

The system utilizes **Plus Jakarta Sans** for headlines to provide a modern, slightly rounded, and friendly geometric feel. **Be Vietnam Pro** is used for body text and labels for its contemporary warmth and excellent legibility at smaller sizes.

- **Headlines:** Should use generous line heights to feel airy and unhurried.
- **Body:** Keeps a slightly tighter tracking for better readability during long-form data entry (like class descriptions).
- **Labels:** Used for metadata like "Lesson Remaining" or "Class Time," often paired with icons.

## Layout & Spacing

This design system uses a **Fluid Grid** model with a mobile-first philosophy. The layout relies on generous internal padding within cards to emphasize the "sticker" feel.

- **Rhythm:** An 8px base grid governs all spatial relationships.
- **Margins:** A standard 20px side margin for mobile ensures content doesn't feel cramped.
- **Breakpoints:** 
    - Mobile: < 600px (1-column focused)
    - Tablet: 600px - 1024px (2-column card layout)
- **Grouping:** Related information (e.g., class name and remaining lessons) should be grouped within a single card with `md` (16px) spacing, while distinct cards use `lg` (24px) spacing to prevent visual clutter.

## Elevation & Depth

Depth is conveyed through **Tonal Layers** and **Ambient Shadows**. This avoids the "flat" look of modern SaaS in favor of something more physical and inviting.

- **Surfaces:** The background is the lowest level (`#FFF8F9`). Cards sit on top of this background.
- **Shadows:** Use extremely soft, diffused shadows with a slight tint of the Primary color (e.g., `rgba(255, 140, 158, 0.12)`). Shadows should have a large blur radius (12-20px) and minimal offset to simulate an object resting softly on a surface.
- **Interactivity:** On press/active states, elements should scale down slightly (98%) and shadows should diminish, creating a tactile "push" effect.

## Shapes

The shape language is defined by **High Circularity**. 

- **Cards & Containers:** Use a consistent 16px (rounded-lg) radius.
- **Buttons:** Use 12px (rounded-md) for secondary actions or 100px (pill-shaped) for primary call-to-actions to make them feel friendly and tappable.
- **Avatars:** Always perfectly circular to represent the children's profiles.
- **Progress Bars:** Use fully rounded caps to maintain the soft aesthetic.

## Components

- **Buttons:** Primary buttons use a solid `#FF8C9E` fill with white text. Secondary buttons use a `#FFB3BF` ghost border or a light peach fill. Every button must have a minimum height of 48px for easy thumb-tapping.
- **Chips:** Used for "Child Filters" (e.g., "Lele," "Mimi"). When active, chips should bounce slightly and change to a solid Primary color.
- **Cards:** The "Lesson Card" is the core unit. It includes a progress bar for "Lessons Remaining," a bold title, and a "Check-in" button. The card background should be white or a very pale version of the primary color.
- **Check-in "Sticker":** When a user confirms a class, a temporary overlay animation of a "Sticker" (e.g., a star or a heart) should appear over the card to provide positive reinforcement.
- **Inputs:** Fields should have a light peach border that thickens and turns Coral Pink when focused. Labels should always be visible above the field to reduce cognitive load.
- **Progress Bars:** Use a dual-tone approach. The background of the bar is a 20% opacity version of the accent color, while the fill is the solid accent.