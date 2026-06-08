# Peptide Tracker

A personal peptide-tracking web app. **Single self-contained file** — no build step, no
backend, no dependencies. Open `peptide-tracker.html` directly in a browser.

- **Main file:** `peptide-tracker.html` (HTML + CSS + JS all inline). NOTE: the app file lives
  on the **Desktop root** (`C:\Users\thoma\OneDrive\Desktop\peptide-tracker.html`), NOT inside
  this `NexLabs Peptides` folder. This folder holds CLAUDE.md + `.claude/`. Edit the Desktop copy.
- **Local link:** `file:///C:/Users/thoma/OneDrive/Desktop/peptide-tracker.html`
- **Data storage:** browser `localStorage`, key `peptideTracker.v1` (per-browser, per-device).
  No data syncs across devices. Settings → Export/Import is the manual backup/transfer.
- `.claude/launch.json` runs `python -m http.server 8731 --directory <Desktop>` for previewing,
  so the server serves the Desktop folder; navigate to `/peptide-tracker.html`.

## How to run / preview
- For the user: just double-click the file, or use the `file://` link above.
- For testing changes here: `preview_start` the `peptide-tracker` config, navigate to
  `/peptide-tracker.html`, then drive it with `preview_eval` (the app exposes globals like
  `state`, `peptide()`, `vial()`, `renderAll()`, etc. on `window`). Always
  `localStorage.removeItem('peptideTracker.v1')` to clean up test data when done.
- There is **no Node** on this machine; Python is available.

## Architecture
- Single global `state` object persisted via `save()` / `load()` to localStorage.
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
