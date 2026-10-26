# Design System Strategy: Intellectual Luxury

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Digital Atelier."** 

In an era of cluttered, loud EdTech platforms, this system moves in the opposite direction—toward precision, quiet confidence, and editorial clarity. We are not building a tool; we are crafting a sanctuary for high-level thought. We break the "template" look by favoring intentional asymmetry over rigid grids, allowing for generous white space that gives concepts room to breathe. By utilizing overlapping glass surfaces and high-contrast typography scales, we transform a functional interface into a premium, tactile experience that feels as much like a high-end physical portfolio as it does a digital platform.

---

## 2. Colors & Surface Philosophy
The palette is rooted in a Deep Indigo (`#4F46E5`), balanced by a sophisticated neutral scale that prioritizes depth and optics over flat color.

### The "No-Line" Rule
Standard 1px solid borders are strictly prohibited for sectioning. Boundaries must be defined through background color shifts. To separate a main content area from a sidebar, place a `surface-container-low` section directly against a `surface` background. The transition should be felt, not outlined.

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of semi-transparent layers. Use the surface tiers to create "nested" depth:
*   **Base:** `surface` (#faf8ff)
*   **Structural Sections:** `surface-container-low` (#f2f3ff)
*   **Secondary Modules:** `surface-container` (#eaedff)
*   **Elevated Components:** `surface-container-highest` (#dae2fd)

### The "Glass & Gradient" Rule
To achieve "Intellectual Luxury," floating elements (modals, navigation bars, hover cards) must use Glassmorphism. Apply a semi-transparent `surface_container_lowest` (white at 70-80% opacity) with a `backdrop-filter: blur(20px)`. 

### Signature Textures
Main CTAs and Hero backgrounds should move away from flat Indigo. Use a subtle linear gradient (135°) transitioning from `primary` (#3525cd) to `primary_container` (#4f46e5). This adds a "lithographic" quality that feels expensive and deliberate.

---

## 3. Typography: Editorial Precision
We use **Plus Jakarta Sans** exclusively. It provides the geometric clarity of a modern grotesque with the warmth of an organic humanist face.

*   **Display (lg/md/sm):** Used for "Hero" moments. Use `display-lg` (3.5rem) with a negative letter-spacing (-0.02em) to create a tight, authoritative editorial feel.
*   **Headlines:** Reserved for chapter starts or major module headers. Use `headline-lg` (2rem) in `on_surface` to anchor the page.
*   **Titles:** Use `title-lg` (1.375rem) for card headers. Ensure these are always high contrast.
*   **Body:** `body-lg` (1rem) is our workhorse. Use `on_surface_variant` (#464555) for secondary descriptions to maintain a soft, readable contrast that avoids the harshness of pure black.
*   **Labels:** Use `label-md` (0.75rem) in all-caps with +0.05em tracking for metadata or small UI hints, echoing the look of high-end architectural blueprints.

---

## 4. Elevation & Depth
In this system, depth is a function of light and material, not just shadow.

### The Layering Principle
Hierarchy is achieved by stacking. Place a `surface-container-lowest` card (the "lightest" paper) onto a `surface-container-low` background. This creates a natural "lift" through tonal value alone.

### Ambient Shadows
When a component must float (e.g., a dropdown or a premium course card):
*   **Blur:** Use large, expansive values (e.g., 40px to 60px).
*   **Opacity:** Keep it between 4% and 8%.
*   **Color:** Never use pure black. Use a tinted version of `on_surface` (#131b2e) to mimic natural ambient occlusion.

### The "Ghost Border" Fallback
If accessibility requirements demand a container edge, use a "Ghost Border": the `outline_variant` token (#c7c4d8) set to 15% opacity. It should be barely perceptible, acting more as a "specular highlight" than a boundary.

---

## 5. Components

### Buttons
*   **Primary:** Gradient fill (`primary` to `primary_container`), white text, `xl` (1.5rem) roundedness. No border.
*   **Secondary:** Glass background (`surface_container_lowest` at 40% opacity), `outline` text, and a 1px Ghost Border.
*   **Tertiary:** No background. `primary` text with an underline that only appears on hover.

### Cards & Lists
*   **No Dividers:** Dividers are banned. Use vertical white space from the spacing scale (e.g., `spacing-6` or `2rem`) or subtle tonal shifts (`surface-container-low` vs `surface-container`) to separate items.
*   **Nesting:** A course list item should be a `surface_container_lowest` card sitting on a `surface_container` background.

### Input Fields
*   **Styling:** Use `surface_container_low` for the field fill. On focus, transition the background to `surface_container_lowest` and apply a subtle `primary` Ghost Border.
*   **Typography:** Labels must use `label-md` and sit 0.5rem above the field, never inside.

### Interactive Chips
*   Used for category filtering. Use `secondary_fixed` (#e2dfff) backgrounds with `on_secondary_fixed` (#140f54) text. When selected, apply a soft inner glow using the `primary_container` color.

---

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical layouts. A text block on the left balanced by an overlapping glass image card on the right creates "Intellectual Luxury."
*   **Do** lean into the Spacing Scale. Use `spacing-12` (4rem) for section margins to maintain an "airy" feel.
*   **Do** use backdrop blurs on all navigation overlays.

### Don't
*   **Don't** use 100% opaque, high-contrast borders. This breaks the "Glass" illusion.
*   **Don't** use standard "Drop Shadows" from a library. Every shadow must be diffused and tinted.
*   **Don't** crowd the interface. If a screen feels full, increase the spacing and remove non-essential decorative elements.
*   **Don't** use sharp corners. Use the `xl` (1.5rem) or `lg` (1rem) tokens to maintain a soft, premium tactility.