# Design System Strategy: The Academic Atelier

## 1. Overview & Creative North Star
This design system is built upon the "Creative North Star" of **The Academic Atelier**. It moves away from the sterile, cookie-cutter "SaaS dashboard" aesthetic toward a digital environment that feels like a premium educational institution or a high-end architectural studio.

The vision is to balance **Geometric Clarity** with **Tonal Depth**. We achieve this by moving away from traditional grid-heavy layouts and embracing intentional asymmetry and a "stacking" philosophy. By utilizing varying surface tiers instead of borders, we create a UI that feels curated, quiet, and profoundly authoritative. The user experience should feel like flipping through a thick, beautifully bound editorial journal—modern, clean, and intellectually stimulating.

---

## 2. Colors & Surface Philosophy
The palette shifts from standard vibrant tones to a sophisticated, deep-ocean and charcoal foundation.

### The "No-Line" Rule
**Explicit Instruction:** You are prohibited from using 1px solid borders to section off content. Sectioning must be achieved through background color shifts. A `surface-container-low` section sitting on a `surface` background provides all the definition needed. If a boundary is not clear, reconsider your spacing, not your borders.

### Surface Hierarchy & Nesting
Think of the UI as physical layers of fine paper. 
- Use `surface-container-lowest` (#ffffff) for the most prominent interactive elements (like cards) to make them "pop" against a `surface-container-low` (#f3f4f5) background.
- Higher importance areas should reside on `surface-bright` or `surface-container-highest` to create an inverted focus.
- **The Glass & Gradient Rule:** For floating headers or navigation rails, use a semi-transparent `surface` with a 20px backdrop-blur. To add "soul," apply a subtle linear gradient to Hero CTA backgrounds, transitioning from `primary` (#091c2d) to `primary_container` (#1f3143).

---

## 3. Typography
The type system uses a dual-font approach to blend editorial authority with modern readability.

*   **Display & Headlines (Manrope):** Chosen for its geometric precision. Use `display-lg` (3.5rem) and `headline-md` (1.75rem) to establish a strong, rhythmic hierarchy. These should feel architectural and "set in stone."
*   **Body & Labels (Inter):** Inter provides the functional clarity required for educational content. The transition from `headline-sm` (Manrope) to `body-lg` (Inter) creates a clear distinction between "statement" and "information."
*   **Intentional Contrast:** Always pair a `display-md` heading with a `label-md` uppercase subtitle. This high-contrast scale is the hallmark of the "Atelier" look.

---

## 4. Elevation & Depth
We eschew the standard Material Design drop-shadow in favor of **Tonal Layering**.

*   **The Layering Principle:** Create a soft, natural lift by stacking tokens. Place a card with `surface-container-lowest` on a base of `surface-container`. This achieves hierarchy through light values rather than shadows.
*   **Ambient Shadows:** If an element must float (e.g., a modal), use a shadow with a blur value of `32px` or higher at `4%` opacity. The shadow color must be a tinted version of `on-surface` (#191c1d), never pure black.
*   **The "Ghost Border" Fallback:** If accessibility requires a stroke, use `outline-variant` (#c6c5d4) at **15% opacity**. It should be felt, not seen.
*   **Glassmorphism:** Use `surface_variant` at 70% opacity with a blur for context-aware overlays. This ensures the layout feels integrated, allowing the secondary and tertiary accents to bleed through softly.

---

## 5. Components

### Buttons
*   **Primary:** Solid `primary` (#091c2d) with `on_primary` (#ffffff) text. Use `md` (0.375rem) roundedness for a sharp, professional finish.
*   **Secondary:** `secondary_container` (#d5e2e3) background. These should feel softer and less urgent.
*   **Tertiary:** No background; use `primary` text. These rely on the Spacing Scale (`3` or `4`) to define their hit area.

### Cards & Lists
*   **Strict Rule:** No dividers. Use `spacing.8` (2.75rem) to separate list groups. 
*   **Interactive Cards:** Use `surface_container_lowest`. On hover, shift the background to `surface_container_high` instead of increasing shadow. This mimics the feeling of "pressing" into the paper.

### Chips & Tags
*   Use `secondary_fixed` (#d8e5e6) for a muted, premium look. For "Educational" highlights, use `tertiary_fixed` (#ffdcc5) to draw the eye without the "danger" associated with reds.

### Input Fields
*   Background: `surface_container_low`.
*   Border: None.
*   Focus State: A 2px "Ghost Border" using `primary` at 40% opacity. This maintains the "Urbanist" minimalist feel while providing clear feedback.

---

## 6. Do's and Don'ts

### Do
*   **DO** use white space as a structural element. The `spacing.12` and `spacing.16` tokens are your best friends for creating an "Editorial" feel.
*   **DO** mix the typography. A `display-sm` heading next to a `label-sm` caption creates a sophisticated, boutique look.
*   **DO** use `tertiary` (#2f1400) accents for specific callouts to break the cool-tone monotony of the primary blues.

### Don't
*   **DON'T** use 1px solid black or grey borders. This instantly "cheapens" the design and makes it look like a template.
*   **DON'T** use standard 0.25 opacity shadows. They create "mud" in a premium UI. Stick to Tonal Layering.
*   **DON'T** crowd the edges. If a component is near a screen edge, ensure at least `spacing.6` (2rem) of breathing room.
*   **DON'T** use fully rounded (pill) buttons for everything. Stick to `md` (0.375rem) or `lg` (0.5rem) to maintain the geometric, architectural intent.