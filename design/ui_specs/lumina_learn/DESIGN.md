# Design System Strategy: The Cognitive Nebula

## 1. Overview & Creative North Star
The Creative North Star for this system is **"The Intelligent Atmosphere."** 

Unlike traditional education apps that feel like digital textbooks (rigid, boxed, and static), this system treats the UI as a living, breathing environment. We are merging the structured clarity of *Notion* with the content-first immersion of *Netflix*. 

To break the "template" look, we move away from traditional grids in favor of **Intentional Asymmetry**. Significant information is anchored, while supporting AI-generated content "floats" in the periphery using layered surfaces. We avoid a "flat" appearance by treating the screen as a 3D space where the AI tutor exists in the foreground and the curriculum resides in a deep, textured background.

---

## 2. Colors & Surface Philosophy
The palette transitions from a deep, scholarly `primary` (#4a40e0) to a visionary `secondary` (#702ae1).

### The "No-Line" Rule
**Borders are prohibited for sectioning.** To separate a lesson module from the navigation or a chat interface, you must use background shifts. 
*   **Example:** A lesson card (`surface-container-lowest`) sits on a workspace background (`surface-container-low`). The contrast is felt, not seen as a line.

### Surface Hierarchy & Nesting
Treat the UI as stacked sheets of frosted glass.
*   **Level 0 (Base):** `surface` (#faf4ff) - The vast "canvas."
*   **Level 1 (Sections):** `surface-container-low` (#f5eeff) - Groups of related lessons.
*   **Level 2 (Active Components):** `surface-container-highest` (#e2d7ff) - Interactive input zones or high-priority AI insights.

### Signature Textures: The "Nebula Gradient"
For primary CTAs and Hero states, use a linear gradient:
`linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%)`.
This provides the "visual soul" that flat colors lack, conveying the energy of active AI processing.

---

## 3. Typography: Editorial Authority
We pair **Plus Jakarta Sans** (Display/Headlines) with **Inter** (Body/Labels) to balance futuristic character with high-legibility "utility."

*   **The Power Scale:** Use `display-lg` (3.5rem) sparingly for "Aha!" moments or level completions. It should feel monumental.
*   **The Narrative Flow:** `headline-sm` (1.5rem) serves as the primary "tutor voice." It uses a tighter letter-spacing (-0.02em) to feel modern and "editorial."
*   **The Utility:** `body-md` (0.875rem) in `on-surface-variant` is used for descriptions, ensuring the UI doesn't feel cluttered even when content is dense.

---

## 4. Elevation & Depth
In this system, depth is a functional tool, not just an aesthetic.

*   **Tonal Layering:** Instead of a shadow, lift a `surface-container-lowest` card from a `surface-dim` background. This creates a soft, sophisticated "lift" that feels native to the screen.
*   **Ambient Shadows:** For floating AI elements (modals/tutor bubbles), use `shadow-xl`. The shadow must be tinted with `on-surface` (#32294f) at 6% opacity with a 32px blur. No "dirty" grey shadows.
*   **Glassmorphism:** Use `surface` at 70% opacity with a `blur(20px)` for bottom navigation bars. This allows the curriculum content to bleed through, maintaining the "Content-Focused" Netflix inspiration.

---

## 5. Components

### The "Pulse" Button (Primary)
*   **Style:** `16px (xl)` roundedness. Background: Nebula Gradient.
*   **Interaction:** On hover/tap, the gradient shifts 15% in hue.
*   **Padding:** `spacing-4` vertical, `spacing-8` horizontal.

### Knowledge Chips
*   **Style:** `surface-container-high` background with `on-surface` text.
*   **Constraint:** No border. Use `label-md` for typography.

### AI Chat Input
*   **Style:** A `surface-container-lowest` pill. 
*   **Visual:** Instead of a cursor line, use a soft `tertiary` (#006576) glow on the left edge to indicate the AI is "listening" or ready.

### Progress "Cards"
*   **Prohibition:** Never use dividers. 
*   **Solution:** Use `spacing-6` (1.5rem) of vertical white space and a subtle shift from `surface` to `surface-container-low` to define the end of a module.

### Contextual Tooltips
*   **Style:** `inverse-surface` background with `inverse-on-surface` text. 
*   **Animation:** Scale-in from 0.9x with a slight "bounce" to mimic the playful nature of *Duolingo*.

---

## 6. Do’s and Don’ts

### Do
*   **Do** use asymmetrical margins (e.g., 24px left, 32px right) for header text to create a high-end editorial feel.
*   **Do** use `tertiary` (#006576) for success states and "correct" answers—it feels more academic and sophisticated than a generic lime green.
*   **Do** nest containers (Lowest on Low) to create natural focus areas.

### Don't
*   **Don't** use 1px solid borders. If accessibility requires a stroke, use a "Ghost Border": `outline-variant` at 15% opacity.
*   **Don't** use pure black (#000000) for dark mode. Use `inverse-surface` (#10062d) to maintain the deep purple/blue "atmospheric" tone.
*   **Don't** use standard "drop shadows" on flat surfaces. Depth must come from color first, blur second.