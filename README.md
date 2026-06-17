# Peptide Tracker

A personal, single-file peptide-tracking web app — no build step, no backend, no dependencies.
Just open **`peptide-tracker.html`** in any browser. All data is stored locally in your browser
(`localStorage`); use **Settings → Export/Import** to back up or move it between devices.

## Features
- **Peptides library** — quick-pick dropdown of common peptides, default dose (mcg **or** mg),
  vial size, dry-vial stock with reorder reminders, half-life, cost per vial, and recurring
  schedules (daily / weekdays / cycles / every-N-days).
- **Reconstitution & vials** — enter mg + bac water → concentration; converts any dose to
  syringe units & mL; tracks remaining amount, doses left, and 28-day (editable) stability with
  expiry countdown. Reconstituting deducts from dry stock.
- **Calendar** — recurring schedules auto-fill; plan ahead by clicking dates; check doses off as
  taken (decrements the chosen vial, logs route/site/notes/rating). Per-month + projected spend.
- **Injection sites** — SubQ/IM rotation tracking with an interactive body map and rest-period
  warnings.
- **Dashboard** — due today, expiring-soon and reorder alerts, supply forecast, adherence (30d),
  and estimated active levels from half-life.
- **Progress** — bodyweight log with a line chart (lb/kg).
- **Finances** — cost per vial/dose, totals, and spend over time (weekly / monthly / quarterly /
  yearly running totals).
- **4 themes** — Midnight, Warm, Crisp, Retro (gear icon, top-right).

## Run
Double-click `peptide-tracker.html`, or serve the folder with any static server
(e.g. `python -m http.server`) and open the file.

## Hosting (optional)
Rename to `index.html` and drop it on a static host (Netlify Drop, Cloudflare Pages, GitHub
Pages) for a shareable link. Each visitor keeps their own data in their own browser.

---
Built with [Claude Code](https://claude.com/claude-code).
