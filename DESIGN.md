# Design System — "Money Manager" Personal Finance App

Extracted from 10 mobile mockup screens (Indonesian language, IDR currency). This
document is a design-token + component + screen spec for implementing the app
consistently. Colors are visually estimated from the mockups (not sampled with
a color picker) — treat hex values as a strong starting point and fine-tune
against the source file if you have it.

## 1. App identity

- **Category:** Personal finance / budget & expense tracker
- **Platform:** Mobile (iOS/Android-style single-column, bottom tab nav)
- **Locale:** Indonesian (id-ID), currency IDR ("Rp")
- **Tone:** Calm, trustworthy, "banking app" seriousness softened with warm
  accent colors and friendly copy ("Selamat pagi, Elon" morning greeting)
- **Sample/seed data:** user "Mas Elon" (maselon@email.com), avatar = initials
  "ME" — treat as placeholder seed content, not a hardcoded value

## 2. Scope of this reference — designing the missing pages

The mockups only cover 10 screens. Several are referenced but not shown in
full: the expanded "Lihat semua" transaction list, the Filter and Analitik
tabs on the Transactions screen, category management, notes management,
subscription management ("Kelola" on Langganan), Tema (theme picker), Backup
& Restore, Keamanan & privasi, and Notifikasi.

For every page not shown, **do not invent a new visual language** — derive it
from what's already here:
- Reuse the exact header pattern from §4 (bold title + gray subtitle +
  optional trailing action).
- Build lists out of the same row anatomy as the transaction/account/settings
  rows in §6 (leading icon, title+subtitle stack, trailing value or chevron).
- Reuse the same card radius, spacing, button, and badge styles — a new
  screen should look like it shipped with the other 10, not like a
  bolt-on.
- Only introduce a new component if none of the existing ones fit (e.g. a
  toggle switch for settings, a search-result empty state) — and when you
  do, keep it inside the token system in §3/§7, not a one-off style.
- For a settings sub-page (e.g. Keamanan & privasi, Notifikasi), the pattern
  is: a list of grouped rows identical to the ones on the Lainnya screen,
  now with switches/inputs instead of chevrons where the row needs a value.

## 3. Color system

Semantic usage matters more than the exact hex — keep these roles distinct.
Both a light and dark variant are given; the **hue stays the same across
themes** (green = positive, red = negative, amber = warning, blue = info,
purple = featured) — only lightness/saturation shifts for contrast.

### Light (default)

| Token | Approx. hex | Usage |
|---|---|---|
| `primary` (deep green) | `#0E4D3C` – `#145C43` | Hero/balance card fill, primary buttons, active nav icon, FAB, "healthy" progress bars, selected calendar day |
| `background` | `#F7F6F2` – `#FAFAF8` | App background (warm off-white, not pure white) |
| `surface` | `#FFFFFF` | Cards, sheets, list rows |
| `text-primary` | `#161C1A` | Headings, amounts |
| `text-secondary` | `#7A8580` | Subtitles, labels, timestamps |
| `expense / negative` | `#E0473F` – `#D9453D` | Expense amounts, over-budget bars (≥90%), debt totals, credit-card balances |
| `income / positive` | `#1E9E63` (matches primary green) | Income amounts, "Aktif" badges, positive trend text |
| `warning / amber` | `#E0A23D` – `#D9A356` | Mid-range budget bars (~70–89%), chart secondary bars, "Perlu perhatian" callout bg (light tint `#FBF1DF`) |
| `info / blue` | `#2E6FDB` on `#EAF3FC` bg | "Tren positif" insight callouts |
| `featured / purple` | `#7C5CFC` on `#EDE9FB` bg | Priority savings-goal card (visually distinct from red/green — "this one matters most" emphasis) |
| `divider` | `#ECEAE4` | Hairlines between list rows |

### Dark

| Token | Approx. hex | Notes |
|---|---|---|
| `primary` | `#22B37E` – `#2ECC8F` | Brighten/saturate the green so it doesn't recede into a dark background; keep it as the hero-card fill and active-state color |
| `background` | `#12151A` – `#15181C` | Warm near-black, not pure `#000` |
| `surface` | `#1E2226` – `#20242A` | Cards sit one step lighter than the background — dark mode uses **elevation via lighter surface tone**, not drop shadows |
| `surface-elevated` (sheets/modals) | `#262B31` | One step lighter again, for anything stacked above a card (e.g. bottom sheet over a list) |
| `text-primary` | `#F2F1EE` | |
| `text-secondary` | `#93A19B` | |
| `expense / negative` | `#FF7A70` | Lightened red for AA contrast on dark surfaces |
| `income / positive` | `#34D399` | |
| `warning / amber` | `#F0B65C` on `#332A18` bg | |
| `info / blue` | `#6FA0FF` on `#182A3D` bg | |
| `featured / purple` | `#A98BFF` on `#241E3D` bg | |
| `divider` | `#2A2E33` | |

Progress-bar color thresholds (used for budgets and goals, both themes):
- `< 70%` → green (on track)
- `70–89%` → amber (watch)
- `≥ 90%` → red (over/near limit)

**Theme switching:** the Lainnya (Settings) screen already has a "Tema —
Pilih tampilan aplikasi" row — wire this to a Light / Dark / System choice
using the token tables above, rather than a single hardcoded palette.

## 4. Typography

- **Family:** Modern geometric/humanist sans-serif (e.g. Inter, Plus Jakarta
  Sans, or similar) — no serif anywhere in the UI
- **Scale (approx.):**
  - Hero amount (balance card): ~28–32px, bold
  - Screen title (H1, e.g. "Transaksi"): ~20–22px, bold
  - Section header (e.g. "Transaksi terbaru"): ~15–16px, semibold
  - List item title: ~14–15px, medium/semibold
  - List item subtitle / meta: ~12–13px, regular, `text-secondary`
  - Form field labels ("KATEGORI", "TANGGAL"): ~11px, semibold, uppercase,
    letter-spaced, `text-secondary`
  - Micro labels (badges, tab bar): ~10–11px

## 5. Layout & spacing

- 8px base grid; card padding ~16–20px; gap between stacked cards ~12–16px
- Card corner radius: large, ~16–20px throughout (buttons, cards, sheets,
  chips) — no sharp corners anywhere
- Screen structure is consistent across all pages:
  1. Header row: page title (bold) + one-line gray subtitle, with an optional
     trailing action (`+ Tambah`, `+ Buat`, `+ Akun`, or `Tutup`/close on
     modals)
  2. Primary content (hero card, list, chart, calendar, or form)
  3. Fixed bottom tab bar (all main screens) — modals/sheets omit it
- Light mode: soft drop shadows lift cards off the warm background. Dark
  mode: skip shadows (they don't read well on dark backgrounds) and rely on
  the `surface` / `surface-elevated` tone steps from §3 instead.

## 6. Navigation

Bottom tab bar, 4 items, icon + label, fixed on every top-level screen:
`Beranda` (Home) · `Transaksi` (Transactions) · `Akun` (Accounts) · `Lainnya`
(More/Settings). Active tab = filled icon + `primary` green + bold label;
inactive = outline icon + gray.

A circular floating action button (dark green, `+` icon, drop shadow in
light mode / flat fill in dark mode) sits bottom-right on the Home screen
for quick-add, separate from the tab bar.

"Tambah transaksi" (add transaction) opens as a bottom sheet / modal over the
current screen (`Tutup` to dismiss) rather than a full navigation push.

## 7. Core components

| Component | Description |
|---|---|
| **Hero balance card** | Full-width, `primary` green fill, white text. Big total balance, then a two-column income/expense sub-row with ↗/↘ arrow icons. |
| **Stat trio row** | Three inline stats (e.g. "Hari ini / Bulan ini / Total") under the hero card, plain text, no card chrome. |
| **Bar chart ("Arus kas")** | Simple monthly/period bar chart, bars colored green/amber/cream by month or magnitude; used on Home and Statistik. |
| **Donut chart** | Category breakdown; green-toned ring + a text legend list with percentages. |
| **Transaction list row** | Leading 40px circular icon (tinted background by category), title + "category • account/time" subtitle, trailing amount (red for expense, green with `+` for income). |
| **Section header** | Bold label + trailing link (`Lihat semua`, `Kelola`, `Buka`). |
| **Segmented control** | Pill-shaped 2–3 way tab (e.g. `Pengeluaran / Pemasukan / Transfer`), active segment filled dark green. |
| **Form field group** | Uppercase gray label above a row showing an icon/emoji + current value + chevron (opens a picker). Used for category, account, date, notes. |
| **Primary button** | Full-width, `primary` green, white bold label, large radius. |
| **Progress bar (linear)** | Track in light gray / dark `surface-elevated`, fill colored by the threshold rule in §3; percentage shown as a right-aligned badge or inline text. |
| **Budget category card** | Icon + category name + "used / total" text + % badge + progress bar. |
| **Insight/alert callout** | Colored-tint rounded box with a short recommendation sentence. Amber tint = warning ("Perlu perhatian"), blue tint = positive insight ("Tren positif"). |
| **Featured/priority card** | Purple-tinted card with a small "PRIORITAS" pill + star icon, used to visually separate one highlighted goal from the regular list. |
| **Goal / debt card** | Icon, name, amount, and either a % progress bar (goals) or a due-date line (debt). |
| **Calendar grid** | Standard month grid; days with activity get a small dot; today/selected day is a filled green circle. A tapped day expands a detail panel below (in/out totals + that day's transactions). |
| **Account card** | Icon (colored by account type: cash, debit, savings, e-wallet, credit, investment), masked number ("•••• 2841"), one-line meta (interest rate, promo, due date), balance (red if it's a debt/credit balance). |
| **Settings list row** | Icon + label + optional subtitle/count, trailing chevron (or a toggle switch, for on/off settings on pages like Notifikasi). |
| **Status badge/pill** | Small rounded pill, e.g. green "Aktif" for active recurring items. |
| **Toggle switch** *(new, for settings sub-pages)* | Standard iOS/Android-style switch; on = `primary` green fill, off = gray track — matches the "Aktif" badge color language. |

## 8. Screen inventory

**Covered in the mockups:**

1. **Beranda (Home)** — greeting header, hero balance card, stat trio, 6-month
   cash-flow bar chart, recent transactions list, FAB
2. **Transaksi (Transactions)** — search bar, filter/analytics/calendar tabs,
   week date strip, transactions grouped by day with daily totals, quick
   links to manage categories/notes
3. **Tambah transaksi (Add transaction)** — modal/sheet, expense/income/
   transfer segmented control, large amount field, category/account/date/
   note fields, primary save button
4. **Anggaran (Budget)** — remaining-budget summary card with overall
   progress bar, per-category budget cards, contextual warning callout
5. **Target & Hutang (Goals & Debt)** — toggle between savings goals and
   debts; one featured/priority goal card; secondary goal cards; debt
   summary list; total-debt-remaining card
6. **Transaksi Berulang (Recurring)** — next-month net projection, upcoming
   30-day recurring items with cadence + "Aktif" badges, subscriptions
   mini-section (Netflix/Spotify style cards)
7. **Statistik (Statistics)** — expense/income tabs, total + trend delta,
   bar chart, daily average/peak-day stats, category donut + legend,
   positive-trend insight callout
8. **Kalender Keuangan (Financial calendar)** — month grid with activity
   dots, selected-day summary (in/out totals) and that day's transaction list
9. **Akun & Dompet (Accounts & Wallet)** — total net balance card, editable
   account list across account types, mini transaction history for the
   selected account
10. **Lainnya (More/Settings)** — profile row, appearance (theme), feature
    shortcuts (categories, recurring, budgets/goals, currency), data &
    security (backup, security/privacy, notifications), about/app version

**Not shown — design using §2's rules:**

- **Full transaction list ("Lihat semua")** — same grouped-by-day list as
  screen 2, without the Home screen's truncation, plus a persistent filter
  bar
- **Filter sheet** — bottom sheet with category/account/date-range/amount
  filters, using the same form-field-group style as Tambah transaksi
- **Analitik tab** (on Transaksi) — likely a condensed version of Statistik
- **Kategori management** — list of categories (icon + name + edit/delete),
  add-category flow reusing the form-field-group + primary-button pattern
- **Catatan (notes) management** — simple list/editor, same list-row style
- **Kelola langganan (manage subscriptions)** — list of subscription rows
  (icon, name, price/cycle, cancel/edit action)
- **Tema (theme picker)** — Light / Dark / System selector, likely three
  selectable cards or a segmented control, previewing the palettes in §3
- **Backup & Restore, Keamanan & privasi, Notifikasi** — grouped settings
  rows per §7's Settings list row / Toggle switch, following Lainnya's
  section layout

## 9. Content & formatting conventions

- **Currency:** `Rp` prefix, period as thousands separator, no decimals for
  whole rupiah (`Rp 18.750.000`). Abbreviate in tight spaces: `jt` = juta
  (million), `rb` = ribu (thousand) — e.g. `Rp 7,8 jt`, `Rp 261 rb`.
- **Sign convention:** expenses shown as red, optionally with a leading `-`;
  income shown green with a leading `+`.
- **Dates:** Indonesian day/month names, e.g. `Sabtu, 19 September`; short
  form `17 Sep` in list rows.
- **Masked identifiers:** account numbers shown as `•••• 2841` (last 4
  digits only).
- **Language:** all UI copy is Indonesian; keep new copy in the same
  register (short, plain, sentence case, no filler — matches labels like
  "Simpan transaksi", "Kurangi Rp 12.000 per hari agar tetap sesuai rencana").

## 10. Notes / open questions for implementation

- Exact hex values, font family, and icon set are estimated from the mockup
  images — confirm against a Figma/design file if one exists.
- Category icons appear to mix emoji (🍽) and line icons — decide on one
  consistent icon system before building, and make sure it has both a
  light-mode and dark-mode-friendly rendering (line icons should invert or
  use `text-primary`, not a fixed dark color).
- The pages listed under "Not shown" in §8 are inferred from links/labels in
  the mockups ("Lihat semua", "Kelola", "Ubah/Atur", settings rows) — treat
  their layouts as a reasonable default to implement, not a fixed spec.