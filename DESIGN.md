# Money Manager — Design System & Agent Brief
> Flutter/Dart implementation reference. This document is the single source of truth for visual design, component structure, data models, and UX patterns.

---

## 1. Aesthetic Stance

**Dark Premium Fintech** — near-black ground, vibrant accent colors for financial data, clean typographic hierarchy. Think: Bloomberg app, Revolut, Wise. Dense but breathable. No light mode.

---

## 2. Color Tokens

Deep navy-ink base (not generic charcoal). Gold as primary CTA — deliberately breaks the fintech green default.

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  // Backgrounds — deep navy-ink, not pure black
  static const bg        = Color(0xFF070B18);   // page scaffold
  static const surface   = Color(0xFF0B1022);   // bottom sheets, nav bar
  static const card      = Color(0xFF0F1630);   // cards, list tiles
  static const card2     = Color(0xFF141D3A);   // elevated / pressed cards

  // Primary — warm gold (distinctive, not the default fintech green)
  static const gold      = Color(0xFFF4C430);   // CTA buttons, FAB, active nav
  static const gold2     = Color(0xFFE8A800);   // gradient end for buttons

  // Semantic
  static const teal      = Color(0xFF22D4A6);   // income / positive
  static const rose      = Color(0xFFFF4757);   // expense / negative / danger
  static const sky       = Color(0xFF5E9BFF);   // transfer / info
  static const orange    = Color(0xFFFF9F43);   // warning / near-limit (80%)
  static const lilac     = Color(0xFFA78BFA);   // goals / multi-currency accent

  // Text
  static const textPrimary  = Color(0xFFEEF0FB);
  static const textMuted    = Color(0x6BEEF0FB); // ~42% white
  static const textDim      = Color(0x38EEF0FB); // ~22% white

  // Borders
  static const border    = Color(0x12FFFFFF);   // 7% white hairline
}
```

---

## 3. Typography

| Role | Font | Weight | Size |
|------|------|--------|------|
| Display / Page title | **Outfit** | 700–800 | 22–32px |
| Section heading | Outfit | 600 | 16–20px |
| Body default | **Inter** | 400–500 | 13–15px |
| Body emphasis | Inter | 600 | 13–15px |
| All numbers / amounts | **JetBrains Mono** | 500–700 | any |
| Labels / caps | Inter | 500–600 | 10–12px |

```dart
// pubspec.yaml fonts section
fonts:
  - family: Outfit
    fonts:
      - asset: assets/fonts/Outfit-Regular.ttf   weight: 400
      - asset: assets/fonts/Outfit-SemiBold.ttf  weight: 600
      - asset: assets/fonts/Outfit-Bold.ttf       weight: 700
      - asset: assets/fonts/Outfit-ExtraBold.ttf  weight: 800
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter-Regular.ttf    weight: 400
      - asset: assets/fonts/Inter-Medium.ttf     weight: 500
      - asset: assets/fonts/Inter-SemiBold.ttf   weight: 600
  - family: JetBrainsMono
    fonts:
      - asset: assets/fonts/JetBrainsMono-Regular.ttf  weight: 400
      - asset: assets/fonts/JetBrainsMono-Medium.ttf   weight: 500
      - asset: assets/fonts/JetBrainsMono-SemiBold.ttf weight: 600

// OR use google_fonts package:
// GoogleFonts.outfit(...)
// GoogleFonts.inter(...)
// GoogleFonts.jetBrainsMono(...)
```

---

## 3b. Color Intent Summary

| Token | Usage |
|-------|-------|
| `gold` | FAB, active nav indicator, CTA buttons, primary actions |
| `teal` | Income amounts, positive balances, success states |
| `rose` | Expense amounts, negative balances, danger/delete |
| `sky` | Transfer type, info banners, multi-currency |
| `orange` | Budget warning (80–99% used) |
| `lilac` | Goals, secondary accents, user avatar |

---

## 4. ThemeData (MaterialApp)

```dart
ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.bg,
  colorScheme: ColorScheme.dark(
    background: AppColors.bg,
    surface: AppColors.surface,
    primary: AppColors.emerald,
    secondary: AppColors.violet,
    error: AppColors.coral,
    onPrimary: Color(0xFF0A0A0F),
    onBackground: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
  ),
  fontFamily: 'Inter',
  cardColor: AppColors.card,
  dividerColor: AppColors.border,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.bg,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'Outfit', fontWeight: FontWeight.w700,
      fontSize: 20, color: AppColors.textPrimary,
    ),
  ),
)
```

---

## 5. Spacing & Radius

```dart
class AppSpacing {
  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 12.0;
  static const lg  = 16.0;
  static const xl  = 20.0;
  static const xxl = 24.0;
  static const page = 20.0; // horizontal page padding
}

class AppRadius {
  static const sm   = Radius.circular(8);
  static const md   = Radius.circular(12);
  static const lg   = Radius.circular(16);
  static const xl   = Radius.circular(20);
  static const xxl  = Radius.circular(24);
  static const pill = Radius.circular(100);
}
```

---

## 6. Data Models

### Currency
```dart
class Currency {
  final String code;   // 'IDR', 'USD', 'EUR', 'SGD', 'MYR', 'JPY'
  final String symbol; // 'Rp', '$', '€', 'S$', 'RM', '¥'
  final double rate;   // relative to USD (IDR=15800, USD=1, EUR=0.92 ...)
}
```

### Account
```dart
enum AccountType { checking, savings, credit, wallet }

class Account {
  final String id;
  final String name;        // 'BCA Utama'
  final String bank;        // 'BCA'
  final AccountType type;
  final double balance;     // negative for credit debt
  final String currency;    // currency code
  final Color color;        // brand color for card gradient
  final String icon;        // emoji or icon name
  final String? cardNumber; // last 4 digits
}
```

Sample accounts:
| Name | Bank | Type | Balance | Currency |
|------|------|------|---------|----------|
| BCA Utama | BCA | checking | 12,450,000 | IDR |
| Mandiri Tabungan | Mandiri | savings | 35,800,000 | IDR |
| GoPay | GoPay | wallet | 875,000 | IDR |
| Wise USD | Wise | checking | 2,340 | USD |
| BNI Credit | BNI | credit | -4,200,000 | IDR |

### Category
```dart
enum CategoryType { income, expense, both }

class Category {
  final String id;
  final String name;
  final String icon;       // emoji
  final Color color;
  final CategoryType type;
}
```

Expense categories: Makanan 🍜 `#FF8C42`, Transport 🚗 `#3B82F6`, Belanja 🛒 `#EC4899`, Kesehatan 🏥 `#00E096`, Hiburan 🎮 `#8B5CF6`, Pendidikan 📚 `#FFB800`, Tagihan 💡 `#FF5252`, Kafe ☕ `#92400E`

Income categories: Gaji 💼 `#00E096`, Freelance 💻 `#3B82F6`, Investasi 📈 `#8B5CF6`

### Transaction
```dart
enum TransactionType { income, expense, transfer }

class Transaction {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String accountId;
  final String? toAccountId; // only for transfer
  final String currency;
  final String? note;
}
```

### Budget
```dart
enum BudgetPeriod { monthly, weekly }

class Budget {
  final String id;
  final String categoryId;
  final double limit;
  final double spent;       // computed from transactions
  final BudgetPeriod period;
  final String currency;

  double get percentage => spent / limit;
  bool get isOver => spent > limit;
  Color get statusColor {
    if (isOver) return AppColors.coral;
    if (percentage > 0.8) return AppColors.amber;
    return AppColors.emerald;
  }
}
```

### Goal
```dart
class Goal {
  final String id;
  final String name;
  final double target;
  final double saved;
  final String currency;
  final DateTime deadline;
  final String icon;       // emoji
  final Color color;

  double get percentage => saved / target;
  int get daysLeft => deadline.difference(DateTime.now()).inDays;
}
```

### Debt
```dart
enum DebtType { owed, lent }

class Debt {
  final String id;
  final String name;
  final DebtType type;
  final double amount;
  final double remaining;
  final String currency;
  final DateTime dueDate;
  final String description;
  final String person;

  bool get isUrgent => dueDate.difference(DateTime.now()).inDays <= 14;
}
```

---

## 7. App Navigation

**Bottom navigation bar** — 5 tabs, no labels visible except active (or show all short labels):

| Index | Label | Icon | Route |
|-------|-------|------|-------|
| 0 | Home | home_outlined | `/` |
| 1 | Transaksi | receipt_long_outlined | `/transactions` |
| 2 | Akun | account_balance_outlined | `/accounts` |
| 3 | Anggaran | pie_chart_outline | `/budgets` |
| 4 | Lainnya | menu | `/more` |

Bottom nav styling:
```dart
BottomNavigationBar(
  backgroundColor: AppColors.surface,  // with blur effect via BackdropFilter
  selectedItemColor: AppColors.emerald,
  unselectedItemColor: AppColors.textDisabled,
  type: BottomNavigationBarType.fixed,
  elevation: 0,
  // add top border: Border(top: BorderSide(color: AppColors.border))
)
```

**FAB** — fixed above bottom nav, right side:
```dart
FloatingActionButton(
  backgroundColor: AppColors.emerald,
  foregroundColor: AppColors.bg,
  // box shadow: BoxShadow(color: AppColors.emerald.withOpacity(0.4), blurRadius: 24, offset: Offset(0, 8))
  child: Icon(Icons.add),
  onPressed: () => showAddTransactionSheet(context),
)
```

---

## 8. Screen Specifications

### 8.1 Home Screen (`/`)

**Header:**
- Greeting text: small muted "Selamat Pagi 👋" + user name in Outfit Bold 22
- Avatar: circular 40×40, violet tinted border

**Total Balance Card:**
- Full-width, `BorderRadius.circular(20)`
- Background: `LinearGradient` from `#1a1a2e` → `#16213e` → `#0f3460`
- Decorative radial glow (top-right, emerald, 10% opacity)
- Label "Total Saldo" muted 12px, amount in JetBrains Mono 32px Bold
- Sub-row: income (emerald) + expense (coral) this month with mini circular icon buttons

**Accounts Horizontal Scroll:**
- Cards 140×110dp, `BorderRadius.circular(16)`
- Each card: gradient from `accountColor.withOpacity(0.13)` to `accountColor.withOpacity(0.07)`
- Border: `accountColor.withOpacity(0.2)`
- Shows: emoji icon, bank name (muted), balance (JetBrains Mono), account name

**Recent Transactions:**
- Grouped by date — date label muted 12px uppercase
- Each row: category emoji icon (40×40 rounded, category color bg 13%), description + account/category subtitle, amount right-aligned colored by type

### 8.2 Transactions Screen (`/transactions`)

- Search field (rounded, dark fill)
- Filter chips: Semua / Pemasukan / Pengeluaran / Transfer — active chip uses emerald bg + dark text
- Grouped list by date (descending)
- Each TransactionTile: same as Home recent rows

### 8.3 Accounts Screen (`/accounts`)

- Total balance header in emerald JetBrains Mono 24px
- Grouped sections: Rekening / Tabungan / Dompet Digital / Kartu Kredit (section header = muted caps 12px)
- Each AccountTile → navigate to AccountDetail
- AccountDetail: large card with gradient bg, full balance, currency, card number; transaction history below

### 8.4 Budgets Screen (`/budgets`)

- Summary row: Total Anggaran | Terpakai | (Melebihi count if any)
- BudgetCard per category:
  - Category icon + name + period
  - "Melebihi!" pill badge (coral) when over
  - Spent / Limit in JetBrains Mono
  - Progress bar (height 6, rounded, color from `budget.statusColor`)
  - Footer: "Sisa Rp X" or "Melebihi Rp X"

### 8.5 More Screen (`/more`)

Menu list with `MenuRow` (icon + color-tinted bg, title, subtitle, chevron). Items:
- Target Tabungan → GoalsScreen
- Hutang & Piutang → DebtsScreen
- Transfer → TransferScreen
- Analitik → AnalyticsScreen
- Kategori → CategoriesScreen
- **Pengaturan** → SettingsScreen
- **Tentang Aplikasi** → AboutScreen

Currency selector: horizontal wrap of pill buttons (one per currency, active = lilac).

### 8.10 Settings Screen

**Profile card**: avatar (lilac/sky gradient), name (editable inline), email. "Edit" button toggles inline text field.

**Notifikasi section** (grouped card):
- Transaksi Baru — toggle
- Budget Mendekati Limit — toggle

**Keamanan section** (grouped card):
- Biometrik / PIN — toggle
- Ganti PIN — chevron row

**Data section** (grouped card):
- Ekspor Data (sky icon) — chevron
- Backup ke Cloud (teal icon) — chevron

**Danger section** (rose-border card):
- Hapus Semua Data — rose text, trash icon

All toggles: pill shape `44×24`, active = `gold` bg, knob slides left↔right with CSS transition.

### 8.11 About Screen

**App identity block** (centered):
- Icon: 💰 in navy gradient card with gold border glow
- App name: Outfit ExtraBold 22
- Version: JetBrains Mono 12 muted
- "● STABLE" badge: gold tinted pill

**Stats row** (3-column grid cards):
- Jumlah transaksi (sky)
- Jumlah akun (teal)
- Jumlah kategori (lilac)

**Links section** (grouped card, chevron rows):
- Kebijakan Privasi (shield icon, sky)
- Syarat & Ketentuan (info icon, lilac)
- Beri Rating Bintang 5 ⭐ (star icon, gold)
- Laporkan Bug (flag icon, orange)

**Credits footer**:
- Heart icon + "Dibuat dengan sepenuh hati"
- Copyright line
- Tech stack in JetBrains Mono muted

---

Menu list with icon + title + subtitle + chevron. Items:
- Target Tabungan → GoalsScreen
- Hutang & Piutang → DebtsScreen
- Transfer → TransferScreen
- Analitik → AnalyticsScreen
- Kategori → CategoriesScreen

Currency selector: horizontal wrap of pill buttons (one per currency, active = violet)

### 8.6 Goals Screen

- GoalCard: large emoji icon (44×44 rounded, color-tinted bg), name, days-left, progress bar, saved/target amounts

### 8.7 Debts Screen

- Summary: 2-column grid — Hutang Saya (coral) / Piutang Saya (emerald)
- Sections: Hutang / Piutang with DebtRow cards
- DebtRow: name + person, remaining amount (color by type), due date; urgent = amber "⚠ Xh lagi"

### 8.8 Transfer Screen

- From / To dropdowns (filter toList to exclude selected from account)
- Swap button between them (violet tinted)
- Multi-currency info banner when currencies differ (violet tint)
- Amount input: large JetBrains Mono right-aligned, currency symbol prefix
- Quick-amount chips: 100K / 500K / 1M / 5M
- Note input (optional)
- Submit button: full-width, emerald gradient

### 8.9 Analytics Screen

- Period toggle: 7 Hari / Bulan Ini
- Daily bar chart (last 7 days): custom `CustomPainter` or `fl_chart`; today's bar = emerald, others = white 12%; height 80dp
- Category breakdown: category row with emoji, name, amount right, horizontal progress bar + percentage

### 8.10 Add Transaction Bottom Sheet

- Type toggle: Pengeluaran (coral) / Pemasukan (emerald)
- Large amount input (JetBrains Mono 22px, right-aligned)
- Description text field
- Account selector + Category selector (side by side or separate)
- Submit button (color matches type)
- Success state: centered checkmark in emerald circle

---

## 9. Reusable Component Patterns

### AppCard
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.border),
  ),
  padding: EdgeInsets.all(AppSpacing.lg),
  child: ...,
)
```

### SectionHeader
```dart
Text(
  title.toUpperCase(),
  style: TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.textMuted, letterSpacing: 0.8,
    fontFamily: 'Inter',
  ),
)
```

### AmountText (always JetBrains Mono)
```dart
Text(
  formatCurrency(amount, currency),
  style: TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: amount < 0 ? AppColors.coral : AppColors.textPrimary,
  ),
)
```

### FilterChip
```dart
// active: bg = AppColors.emerald, text = AppColors.bg, no border
// inactive: bg = AppColors.card, text = AppColors.textMuted, border = AppColors.border
```

### ProgressBar
```dart
// height: 6, borderRadius: pill
// track: AppColors.border (white 8%)
// fill: statusColor (emerald / amber / coral), animated width
```

### CategoryIcon
```dart
Container(
  width: 36, height: 36,
  decoration: BoxDecoration(
    color: category.color.withOpacity(0.13),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Center(child: Text(category.icon, style: TextStyle(fontSize: 18))),
)
```

---

## 10. Formatting Helpers

```dart
// Currency formatting
String formatCurrency(double amount, String currency, {bool compact = false}) {
  final currencies = {'IDR': 'Rp', 'USD': '\$', 'EUR': '€', 'SGD': 'S\$', 'MYR': 'RM', 'JPY': '¥'};
  final symbol = currencies[currency] ?? currency;
  final abs = amount.abs();
  String formatted;
  if (compact && abs >= 1000000) {
    formatted = '${(abs / 1000000).toStringAsFixed(1)}M';
  } else if (compact && abs >= 1000) {
    formatted = '${(abs / 1000).toStringAsFixed(0)}K';
  } else if (currency == 'IDR') {
    formatted = NumberFormat('#,###', 'id_ID').format(abs);
  } else {
    formatted = NumberFormat('#,##0.00').format(abs);
  }
  return '${amount < 0 ? '-' : ''}$symbol$formatted';
}

// Date formatting
String formatDate(DateTime date) {
  final now = DateTime.now();
  if (DateUtils.isSameDay(date, now)) return 'Hari Ini';
  if (DateUtils.isSameDay(date, now.subtract(Duration(days: 1)))) return 'Kemarin';
  return DateFormat('d MMMM', 'id_ID').format(date);
}

// Currency conversion
double convertCurrency(double amount, String from, String to) {
  // using rates map: IDR=15800, USD=1, EUR=0.92, SGD=1.34, MYR=4.65, JPY=149
  final rates = {'IDR': 15800.0, 'USD': 1.0, 'EUR': 0.92, 'SGD': 1.34, 'MYR': 4.65, 'JPY': 149.0};
  return (amount / rates[from]!) * rates[to]!;
}
```

---

## 11. Suggested Package Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.0.0        # Outfit, Inter, JetBrains Mono
  fl_chart: ^0.68.0           # bar/line/pie charts for Analytics
  intl: ^0.19.0               # number & date formatting
  provider: ^6.1.0            # or riverpod/bloc for state
  go_router: ^13.0.0          # routing (optional)
  shared_preferences: ^2.2.0  # local persistence
  uuid: ^4.0.0                # ID generation
```

---

## 12. File / Folder Structure (suggested)

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── app_text_styles.dart
│   └── utils/
│       ├── currency_utils.dart
│       └── date_utils.dart
├── data/
│   ├── models/
│   │   ├── account.dart
│   │   ├── transaction.dart
│   │   ├── budget.dart
│   │   ├── goal.dart
│   │   ├── debt.dart
│   │   └── category.dart
│   └── sample_data.dart
├── features/
│   ├── home/
│   ├── transactions/
│   ├── accounts/
│   ├── budgets/
│   ├── goals/
│   ├── debts/
│   ├── transfer/
│   ├── analytics/
│   └── categories/
├── shared/
│   ├── widgets/
│   │   ├── app_card.dart
│   │   ├── amount_text.dart
│   │   ├── category_icon.dart
│   │   ├── progress_bar.dart
│   │   ├── filter_chips.dart
│   │   └── transaction_tile.dart
│   └── bottom_nav.dart
└── main.dart
```

---

## 13. UX Micro-patterns

- **Tap feedback**: `InkWell` with `borderRadius` matching container, splash color = `AppColors.emerald.withOpacity(0.08)`
- **Bottom sheets**: `showModalBottomSheet` with `backgroundColor: AppColors.surface`, `shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))`, `isScrollControlled: true`
- **Scrollbars**: hidden by default (`ScrollbarTheme` with `thumbVisibility: false`)
- **Safe area**: always wrap with `SafeArea` or respect `MediaQuery.of(context).padding`
- **Empty states**: centered emoji (large) + muted description text, no illustrations needed
- **Success states**: emerald checkmark in circular container, auto-dismiss after 1.5s
- **Loading**: `CircularProgressIndicator(color: AppColors.emerald, strokeWidth: 2)`

---

## 14. Transaction Sign Convention

| Type | Amount display | Color |
|------|---------------|-------|
| income | `+Rp X` | `AppColors.emerald` |
| expense | `-Rp X` | `AppColors.coral` |
| transfer | `→Rp X` | `AppColors.violet` |
