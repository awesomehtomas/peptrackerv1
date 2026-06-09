# Peptide Tracker

A single-file peptide-tracking web app (`index.html`) — no build step, all HTML/CSS/JS inline.
Sign in with **email + password** and your data is saved to the cloud (Supabase) and synced across
your devices. Each user's data is private to them. **Settings → Export/Import** still works as a
manual backup.

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
Serve the folder with any static server (e.g. `python -m http.server`) and open `index.html`,
then sign in. (Login/cloud sync need a network connection.)

## Hosting
`index.html` is at the repo root, so connect this repo to a static host (Cloudflare Pages, GitHub
Pages, or Netlify) for a shareable `https://` link. Every push auto-deploys. Anyone can sign up;
each user gets their own private, cloud-synced data.

## Backend
Auth + storage use **Supabase** (email/password). Each user's full app state is stored as one JSON
row in the `trackers` table, isolated per-user via Row-Level Security.

---
Built with [Claude Code](https://claude.com/claude-code).
