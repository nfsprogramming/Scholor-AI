# Design System Specification: High-Contrast EdTech Premium

## 1. Overview & Creative North Star: "The Luminescent Scholar"
This design system moves beyond the "standard" dark mode to create a digital environment that feels like a high-end command center for learning. The Creative North Star, **"The Luminescent Scholar,"** balances the weight of deep, obsidian-like physical space with the kinetic energy of neon light.

To break the "template" look, we reject the rigid, flat grid. Instead, we use **intentional asymmetry**—such as oversized display type paired with tight, technical labels—and **layered depth**. We treat the UI not as a flat screen, but as a series of floating glass HUDs (Heads-Up Displays) suspended in a void. Every interaction should feel like activating a light source in a dark room.

---

## 2. Colors & Surface Philosophy
The palette is built on a foundation of absolute darkness, allowing our high-chroma accents to provide "visual electricity."

### The "No-Line" Rule
Traditional 1px solid borders are strictly prohibited for sectioning. Boundaries are defined through:
- **Tonal Shifts:** Placing a `surface_container_high` module on a `surface` background.
- **Luminescence:** Using a 10-20% opacity glow (Primary/Secondary) to define an edge rather than a stroke.

### Surface Hierarchy & Nesting
Use the `surface_container` tiers to create "nested" depth.
*   **Base:** `surface_dim` (#0c1324) for the main app background.
*   **Modules:** `surface_container_low` (#151b2d) for secondary content cards.
*   **Interaction Points:** `surface_container_highest` (#2e3447) for active or pressed states.

### The Glass & Gradient Rule
Floating elements (Modals, Navigation Bars) must use **Glassmorphism**. 
*   **Formula:** `surface_variant` at 60% opacity + 20px Backdrop Blur.
*   **Signature Textures:** For primary CTAs, use a linear gradient from `primary_container` (#00f2ff) to `secondary_container` (#ae05c6) at a 135° angle to inject "soul" into the futuristic aesthetic.

---

## 3. Typography: Editorial Technicality
We pair **Plus Jakarta Sans** (Headlines) with **Inter** (Utility/Body) to create a "Technical Editorial" feel. 

| Role | Token | Font | Size | Intent |
| :--- | :--- | :--- | :--- | :--- |
| **Hero Title** | `display-lg` | Plus Jakarta | 3.5rem | High-impact, tight tracking (-2%). |
| **Section Header** | `headline-sm` | Plus Jakarta | 1.5rem | Authoritative, bold weight. |
| **Primary Reading** | `body-lg` | Inter | 1rem | High readability, generous line height (1.6). |
| **Micro-Data** | `label-sm` | Inter | 0.6875rem | Uppercase, wide tracking (+5%) for a "HUD" feel. |

The typographic hierarchy relies on extreme scale contrast. A `display-lg` headline should often be paired directly with a `label-md` sub-header to create a bespoke, non-traditional layout.

---

## 4. Elevation & Depth
Depth is achieved through **Tonal Layering** and **Ambient Glows** rather than traditional drop shadows.

*   **The Layering Principle:** Stack `surface_container_lowest` (#070d1f) elements inside `surface_container_high` (#23293c) sections to create a "sunken" or "carved" look.
*   **Ambient Shadows:** For floating elements, use a diffused glow. Instead of a black shadow, use `primary_fixed_dim` (#00dbe7) at 8% opacity with a 32px blur.
*   **The Ghost Border:** If containment is required for accessibility, use `outline_variant` (#3a494b) at 15% opacity. Never use 100% opaque strokes.
*   **Neon Pulse:** Primary actions should feel "charged." Apply a subtle outer glow using `primary_container` to indicate that an element is interactive.

---

## 5. Components

### Buttons: The Kinetic Trigger
*   **Primary:** Gradient (Electric Blue to Purple), `xl` roundedness (1.5rem). Add a `primary_container` drop-shadow glow (blur: 12px, opacity: 0.3).
*   **Secondary:** `surface_variant` background with a `Ghost Border`. Text in `primary`.
*   **Tertiary:** Text-only in `tertiary_fixed_dim`. No background.

### Cards & Lists: The "No-Divider" Approach
*   **Rule:** Forbid divider lines. Separate list items using `spacing-4` (1rem) vertical gaps or by alternating backgrounds between `surface_container_low` and `surface_container_lowest`.
*   **Cards:** Use `lg` (1rem) corner radius. Apply a subtle top-left highlight using a 1px `Ghost Border` at 10% opacity to mimic light hitting the edge of glass.

### Input Fields: The HUD Input
*   **Default:** `surface_container_lowest` background, `outline_variant` ghost border. 
*   **Active:** Border shifts to `primary_container` (#00f2ff). Add a subtle inner glow (inset shadow) of the same color at 5% opacity.

### Selection Chips
*   **Unselected:** `surface_container_high` with `on_surface_variant` text.
*   **Selected:** `secondary_container` (#ae05c6) background with `on_secondary_container` text. Use `full` roundedness (9999px).

---

## 6. Do’s and Don'ts

### Do:
*   **DO** use `spacing-12` and `spacing-16` to create "breathing room" around hero content.
*   **DO** overlap elements (e.g., a glass card partially covering a background decorative gradient) to create a sense of three-dimensional space.
*   **DO** ensure all text on `surface` meets a 7:1 contrast ratio for extreme legibility.

### Don't:
*   **DON'T** use pure black (#000000). Use the obsidian `surface_dim` (#0c1324) to maintain depth and prevent "black crush" on OLED screens.
*   **DON'T** use 1px solid white borders. They feel "cheap" and break the immersion of the glass effect.
*   **DON'T** crowd the UI. If a screen feels busy, increase the background surface area to let the "Neon" accents shine.