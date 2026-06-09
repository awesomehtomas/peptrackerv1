# Peptide Tracker

A personal peptide-tracking web app. **Single self-contained file** (`index.html`) — no build
step, all HTML/CSS/JS inline. Loads `supabase-js` from CDN for auth + cloud storage.

- **Main file:** `index.html` (HTML + CSS + JS all inline), in THIS folder, which is a
  git repo (remote: github.com/awesomehtomas/peptrackerv1). Single source of truth — edit it.
  (An older standalone `peptide-tracker.html` copy may still exist on the Desktop root; ignore it.)
- **Local link:** `file:///C:/Users/thoma/OneDrive/Desktop/NexLabs%20Peptides/index.html`
  (but cloud sync/login work best when served over http/https, e.g. the preview server or hosting).
- **Auth + data storage:** **Supabase** (email/password). Each user's full `state` JSON is one row
  in the `trackers` table (`user_id`, `data jsonb`), isolated by Row-Level-Security. Config
  (`SUPABASE_URL`, `SUPABASE_ANON`) is inline near the top of the script; `sb` is the client.
  A per-user `localStorage` cache (`peptideTracker.v1:<uid>`) is an offline fallback only.
  Settings → Export/Import still works as manual backup.
- `.claude/launch.json` runs `python -m http.server 8731` (serves this folder); navigate to
  `/` (index.html). Email confirmation is OFF in Supabase, so signup gives an instant session.
- **Auto-sync to GitHub:** a `Stop` hook (`.claude/settings.json` → `.claude/sync.ps1`) stages,
  commits, and pushes to `origin/main` after each turn. Still commit with a DESCRIPTIVE message
  after meaningful changes; the hook is a backstop (it pushes your commit, or auto-commits any
  leftovers as "auto-sync: <timestamp>"). So GitHub always has the latest.

## How to run / preview
- For the user: open via the preview/hosting URL and sign in (login needs network for Supabase).
- For testing changes here: `preview_start` the `peptide-tracker` config, navigate to `/`, then
  drive it with `preview_eval` (globals like `state`, `peptide()`, `vial()`, `renderAll()`, `sb`,
  `currentUser` on `window`). To test the authed app, `await sb.auth.signUp({email,password})`
  with a **non-example.com** email (Supabase rejects example.com); confirm is off so you get an
  instant session. Sign out with `await sb.auth.signOut()` when done.
- There is **no Node** on this machine; Python is available.

## Architecture
- Single global `state` object; `save()` caches to localStorage + debounce-pushes to Supabase
  (`pushCloud`); `loadCloud()` fetches the user's row on login. App is gated behind an auth screen
  (`#authGate`); `onAuthStateChange` → `enterApp(user)` loads data and reveals the app.
- Tab views toggled by `showView(name)`; everything re-renders via `renderAll()`.
- All UI is string-template `innerHTML` rendered by per-section `renderX()` functions.
- Modals via `openModal(html)` / `closeModal()`. Inline `onclick` handlers call global funcs.
- 4 themes via `data-theme` on `<html>` + CSS variables: midnight (default), warm, crisp, retro.

### state shape
```
peptides[]    {id,name,color,notes,defaultDoseMcg,doseUnit:mcg|mg,vialMg,stock,reorderAt,halfLifeHours,costPerVial,schedules[],presets[]}
  NOTE: all doses stored canonically in MCG everywhere (defaultDoseMcg, schedule.doseMcg,
  dose.mcg, manualEvent.doseMcg). doseUnit only controls DISPLAY/INPUT. Helpers:
  fmtDose(mcg,p) / toDisplayDose(mcg,p) / fromDisplayDose(val,p) / peptideUnit(p).
  Add-peptide form has a quick-pick dropdown (COMMON_PEPTIDES) + mg/mcg toggle (MG_DOSED set).
  schedules[] {id,type:daily|weekdays|cycle|everyN,doseMcg,weekdays[],onDays,offDays,startDate,endDate}
  presets[]   {id,name,mgContent,bacWaterMl}        // reconstitution presets
vials[]       {id,peptideId,label,mgContent,bacWaterMl,dateMixed,stabilityDays,pricePaid,priceSold,archived,stockUsed,doses[]}
  doses[]     {id,date,mcg,route:SubQ|IM,site,notes,rating}
manualEvents[] {id,date,peptideId,doseMcg}          // one-off calendar doses
completions{}  key `${scheduleId}|${date}` or `manual|${eventId}` -> {takenDate,vialId,doseId}
weights[]     {id,date,weight,note}
settings      {theme,defaultStability,unitsPerMl,currency,siteRestDays,notifications,weightUnit}
```

## Features (all implemented + verified)
- **Peptides:** library w/ default dose, vial size (mg), dry-vial stock, reorder threshold,
  half-life, cost/dose, reconstitution presets, recurring schedules.
- **Vials:** reconstitute (mg + bac water → concentration); per-dose units/mL draw; remaining
  amount + doses left; 28-day (editable) stability w/ expiry countdown; price paid/sold;
  reconstituting deducts from dry stock; dose history.
- **Calendar:** recurring schedules auto-fill + manual one-off doses; check off doses as taken
  (decrements the chosen vial, records route/site/notes/rating). **Plan-ahead mode**: "+ Add dose"
  button (`planMode`, `planClick()`) — pick a peptide+dose, then click dates to stamp/remove
  manual events; live banner shows count.
- **Dose logging:** dose mcg → syringe units (unitsPerMl, default 100); injection route SubQ/IM,
  site, notes, 1-5 rating.
- **Sites tab:** SubQ/IM rotation status (rest period in settings), interactive **body map**
  (front/back SVG silhouette w/ status-colored markers, `siteInfo()` popup), recent injections.
- **Dashboard:** stats, Due Today, Expiring Soon (≤7d), Reorder reminders, Supply forecast
  (run-out date from schedule + remaining/stock), Adherence (30d taken vs scheduled),
  Active levels (half-life decay estimate + sparkline), active vial cards.
- **Progress tab:** bodyweight log + SVG line chart, current/since-start/30-day stats (lb/kg).
- **Finances:** price paid/sold per vial, totals, net. Peptide `costPerVial` auto-fills new vial
  prices and drives cost/dose (`peptideCostPerMcg`/`doseCost`). Calendar has a **Spend** panel
  (`renderCalFinance`): logged + scheduled for the viewed month (per-peptide), plus projected
  spend for the next 30/90 days from schedules + planned doses. **Finances tab** also has a
  "Spend over time" section (`currentSpendTotals`, `spendByPeriod`, `renderSpendBreakdown`):
  This week/month/quarter/year/all-time stat cards + a Weekly/Monthly/Quarterly/Yearly
  breakdown selector — all consumption-based (logged-dose cost via `doseCost`).
- **Settings (gear, top-right):** theme, default stability, syringe units/mL, currency,
  weight unit, site rest days, browser notifications, Export/Import/Erase data.

## Key calc reference
- concentration mg/mL = `mgContent / bacWaterMl`; total mcg = `mgContent * 1000`
- draw mL = `(doseMcg/1000) / concentration`; units = `mL * unitsPerMl`
- cost/dose = `pricePaid / (totalMcg / doseMcg)`
- active level mcg = Σ over recent doses `mcg * 0.5^(hoursSince / halfLifeHours)`

## Verifying changes
Prefer driving the live app with `preview_eval` over assumptions. After edits, re-run the
app, exercise the changed flow, and check `preview_console_logs` (level error) is clean.

## Possible next steps (discussed, not yet built)
- Goal-weight line on the progress chart
- Protocol cycle tracking (week X of Y, auto on/off)
- CSV export of dose/weight history
- PWA manifest + icon for clean mobile install
- Per-peptide site restrictions (e.g. force a peptide to specific sites)
- Hosting: Netlify Drop / Cloudflare Pages (rename to `index.html`) for a shareable URL;
  cloud sync would need a backend (Supabase/Firebase) — only if multi-device sync is required.
