```markdown
# Design System Specification: The Fluid Scholar

## 1. Overview & Creative North Star
**Creative North Star: "The Ethereal Academy"**
This design system moves away from the rigid, "grid-locked" feel of traditional EdTech platforms. Instead of a digital textbook, the UI is treated as a series of floating, organic layers. We prioritize **Tonal Depth** over structural lines and **Intentional Asymmetry** over repetitive blocks. The goal is to create an environment that feels scholarly yet weightless—encouraging focus through soft transitions and sophisticated editorial hierarchy.

We break the "template" look by utilizing extreme corner radii (`xl` for containers) and a "No-Line" philosophy. The experience should feel like high-end stationery: tactile, premium, and deeply personalized.

---

## 2. Colors & Surface Philosophy
The palette is rooted in a flexible indigo/violet, utilizing Material 3’s tonal palettes to ensure legibility across all lighting conditions.

### The "No-Line" Rule
**Strict Mandate:** 1px solid borders for sectioning are prohibited. 
Structural boundaries must be defined exclusively through background color shifts. For example, a `surface-container-low` card sitting on a `surface` background provides all the definition a user needs. If you feel the need to "box" something in, you haven't used your tonal tokens correctly.

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of semi-translucent materials.
*   **Base:** `surface` (#fdf7fe)
*   **Level 1 (Sections):** `surface-container-low` (#f8f1fa)
*   **Level 2 (Cards/Interaction):** `surface-container` (#f2ecf5)
*   **Level 3 (High Prominence):** `surface-container-highest` (#e7e0ec)

### The "Glass & Gradient" Rule
To elevate the experience beyond "standard" Material You, use **Glassmorphism** for floating headers and navigation bars.
*   **Token:** `surface` at 70% opacity + 20px Backdrop Blur.
*   **Signature Texture:** Use a subtle linear gradient for Hero sections or Primary CTAs: `primary` (#655789) to `primary_container` (#d4c3fd) at a 135-degree angle. This adds "soul" to the interface that flat fills cannot replicate.

---

## 3. Typography: Editorial Authority
We utilize a pairing of **Be Vietnam Pro** (Display/Headlines) and **Inter** (Body/Labels) to balance character with readability.

*   **Display (Be Vietnam Pro):** Used for "Momentum Moments" (e.g., Course Titles, Achievement Headers). The wide apertures and modern cuts signal a contemporary, premium institution.
*   **Body (Inter):** Used for dense learning content. Inter's tall x-height ensures that even at `body-sm` (0.75rem), educational material remains accessible.
*   **Editorial Scaling:** Use dramatic shifts between `display-lg` (3.5rem) and `body-md` (0.875rem) to create clear visual entry points. Avoid "middle-ground" sizing; either make a statement or get out of the way.

---

## 4. Elevation & Depth
In this system, elevation is a factor of **Luminance and Blur**, not heavy shadows.

### The Layering Principle
Stacking tiers creates natural lift. 
*   *Example:* Place a `surface-container-lowest` card on a `surface-container-low` background. The slight shift in hex value creates a "soft lift" that feels integrated into the OS.

### Ambient Shadows
Where floating elements (like FABs or Modals) require shadows:
*   **Color:** Use a tinted shadow based on `on-surface` (#34313a) at 6% opacity.
*   **Properties:** Blur: 24px–40px, Offset-Y: 8px. 
*   **The "Ghost Border" Fallback:** If accessibility requires a border, use `outline-variant` (#b5b0bb) at **15% opacity**. Never use a 100% opaque border.

---

## 5. Components

### Buttons
*   **Shape:** `full` (9999px) for all primary actions.
*   **Primary:** Background: `primary` (#655789); Text: `on-primary` (#fdf7ff).
*   **Secondary:** Background: `secondary-container` (#e8def8); Text: `on-secondary-container` (#554f63).
*   **Interaction:** On hover, increase the tonal weight by one tier (e.g., `primary` moves to `primary_dim`).

### Cards & Learning Modules
*   **Shape:** `xl` (3rem) for parent containers; `lg` (2rem) for nested items.
*   **Layout:** Forbid divider lines. Use `spacing-8` (2rem) of vertical white space to separate lessons or modules.
*   **Content:** Text should never touch the edge; minimum internal padding is `spacing-6` (1.5rem).

### Input Fields
*   **Style:** Filled (not outlined). 
*   **Color:** `surface-container-highest` (#e7e0ec).
*   **Active State:** Transition background to `primary-container` (#d4c3fd) with a subtle `primary` indicator line (2px) at the bottom.

### Progress Orbs (Custom Component)
Instead of linear bars, use thick-stroked circular "Orbs" for course completion. 
*   **Stroke:** `primary` (#655789).
*   **Track:** `surface-container-highest` (#e7e0ec).

---

## 6. Do’s and Don’ts

### Do
*   **Do** use asymmetrical margins (e.g., more padding on the left than the right in hero sections) to create an editorial, magazine-like feel.
*   **Do** embrace "White Space as a Feature." If a screen feels crowded, increase spacing tokens rather than adding borders.
*   **Do** use `tertiary` (#7b5270) for "Delight" moments—badges, streak counters, and rewards.

### Don’t
*   **Don't** use pure black (#000000) for text. Use `on-surface` (#34313a) to maintain the soft, premium indigo-wash.
*   **Don't** use standard Material shadows. They are too aggressive for this system’s "Ethereal Academy" aesthetic. 
*   **Don't** use `none` or `sm` roundedness. Every corner must feel "melted" and approachable; sharp corners are forbidden unless they are part of a 3rd party logo.

---

## 7. Spacing Scale Reference
Consistency in the "gap" is what makes a line-free UI work.
*   **Micro (2, 3, 4):** Internal component padding, icon-to-label.
*   **Macro (8, 10, 12):** Section-to-section breathing room.
*   **Hero (16, 20):** Screen margins and major layout breaks.```