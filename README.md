# SnapMeal

AI meal planner + grocery list — marketing landing page.

Built from the Claude Design project **"SnapMeal Mobile App Design"**
(`SnapMeal Landing.dc.html`), using the JMV Design System tokens.

## Run

It's a static site — just open `index.html` in a browser, or serve the folder:

```powershell
python -m http.server 8000   # then visit http://localhost:8000
```

## Structure

- `index.html` — the landing page (nav, hero + phone mockup, features, how-it-works,
  compare, pricing, testimonials, FAQ, CTA, footer).
- `css/tokens.css` — design tokens: colors, typography, spacing, fonts (from the JMV design system).
- `css/landing.css` — page layout + component styles (Button, StatCard, SectionHeader,
  TestimonialCard realized as plain HTML/CSS).

## Notes

- Fonts load from Google Fonts (Space Grotesk / Manrope / JetBrains Mono) — matches the
  design system's declared substitutions.
- Icons are inline SVGs (Lucide), so the page needs no JS.
- Store links and prices are sample copy, as in the source design.
