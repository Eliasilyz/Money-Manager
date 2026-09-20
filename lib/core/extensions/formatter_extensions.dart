import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

extension CurrencyFormatter on BuildContext {
  NumberFormat get currencyFormat {
    final locale = Localizations.localeOf(this).toString();
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter;
  }
}

String formatCurrency(BuildContext context, int amount) {
  final locale = Localizations.localeOf(context).toString();
  final realAmount = amount / 100;
  const symbol = 'Rp ';
  final formatter = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 0);
  return formatter.format(realAmount.abs());
}

String formatCurrencySigned(BuildContext context, int amount) {
  final locale = Localizations.localeOf(context).toString();
  final value = amount / 100;
  const symbol = 'Rp ';
  final formatter = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 0);
  final sign = value >= 0 ? '+' : '−';
  return '$sign${formatter.format(value.abs())}';
}

String formatCurrencyCompact(BuildContext context, int amount) {
  final locale = Localizations.localeOf(context).toString();
  final value = (amount / 100).abs();
  final isId = locale.startsWith('id');
  final sign = amount < 0 ? '−' : '+';

  if (value >= 1e9) {
    final div = value / 1e9;
    final s = isId
        ? '${div.toStringAsFixed(div >= 10 ? 0 : 1)} M'
        : '${div.toStringAsFixed(div >= 10 ? 0 : 1)}B';
    return '$sign$s';
  } else if (value >= 1e6) {
    final div = value / 1e6;
    final s = isId
        ? '${div.toStringAsFixed(div >= 10 ? 0 : 1)} jt'
        : '${div.toStringAsFixed(div >= 10 ? 0 : 1)}M';
    return '$sign$s';
  } else if (value >= 1e3) {
    final div = value / 1e3;
    final s = isId
        ? '${div.toStringAsFixed(div >= 10 ? 0 : 1)} rb'
        : '${div.toStringAsFixed(div >= 10 ? 0 : 1)}K';
    return '$sign$s';
  } else {
    return '$sign${value.toStringAsFixed(0)}';
  }
}

String formatDateShort(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  initializeDateFormatting(locale, null);
  if (locale.startsWith('id')) {
    return DateFormat('EEEE, d MMMM', locale).format(date);
  } else {
    return DateFormat('EEEE, MMMM d', locale).format(date);
  }
}

String formatDateFull(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  initializeDateFormatting(locale, null);
  if (locale.startsWith('id')) {
    return DateFormat('d MMMM yyyy • HH:mm', locale).format(date);
  } else {
    return DateFormat('MMMM d, yyyy • h:mm a', locale).format(date);
  }
}

String formatTimeAgo(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  final locale = Localizations.localeOf(context).toString();

  if (diff.inSeconds < 60) {
    return _tr(locale, 'secondsAgo', {'count': diff.inSeconds.toString()});
  } else if (diff.inMinutes < 60) {
    return _tr(locale, 'minutesAgo', {'count': diff.inMinutes.toString()});
  } else if (diff.inHours < 24) {
    return _tr(locale, 'hoursAgo', {'count': diff.inHours.toString()});
  } else if (diff.inDays < 2) {
    return _tr(locale, 'yesterday');
  } else if (diff.inDays < 7) {
    return _tr(locale, 'daysAgo', {'count': diff.inDays.toString()});
  } else if (diff.inDays < 30) {
    final weeks = diff.inDays ~/ 7;
    return _tr(locale, 'weeksAgo', {'count': weeks.toString()});
  } else if (diff.inDays < 365) {
    final months = diff.inDays ~/ 30;
    return _tr(locale, 'monthsAgo', {'count': months.toString()});
  } else {
    final years = diff.inDays ~/ 365;
    return _tr(locale, 'yearsAgo', {'count': years.toString()});
  }
}

String formatDaysUntil(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final diff = date.difference(now);
  final locale = Localizations.localeOf(context).toString();

  if (diff.isNegative) {
    return _tr(locale, 'overdue', {'count': diff.inDays.abs().toString()});
  } else if (diff.inDays < 1) {
    return _tr(locale, 'today');
  } else if (diff.inDays < 7) {
    return _tr(locale, 'daysLeft', {'count': diff.inDays.toString()});
  } else if (diff.inDays < 30) {
    final weeks = diff.inDays ~/ 7;
    if (weeks < 2) {
      return _tr(locale, 'daysLeft', {'count': diff.inDays.toString()});
    }
    return _tr(locale, 'weeksLeft', {'count': weeks.toString()});
  } else if (diff.inDays < 365) {
    final months = diff.inDays ~/ 30;
    return _tr(locale, 'monthsLeft', {'count': months.toString()});
  } else {
    final years = diff.inDays ~/ 365;
    return _tr(locale, 'yearsLeft', {'count': years.toString()});
  }
}

String _tr(String locale, String key, [Map<String, String>? params]) {
  final map = {
    'id': {
      'secondsAgo': '{count} detik lalu',
      'minutesAgo': '{count} menit lalu',
      'hoursAgo': '{count} jam lalu',
      'yesterday': 'Kemarin',
      'daysAgo': '{count} hari lalu',
      'weeksAgo': '{count} minggu lalu',
      'monthsAgo': '{count} bulan lalu',
      'yearsAgo': '{count} tahun lalu',
      'today': 'Hari ini',
      'daysLeft': '{count} hari lagi',
      'weeksLeft': '{count} minggu lagi',
      'monthsLeft': '{count} bulan lagi',
      'yearsLeft': '{count} tahun lagi',
      'overdue': '{count} hari lewat',
    },
    'en': {
      'secondsAgo': '{count}s ago',
      'minutesAgo': '{count}m ago',
      'hoursAgo': '{count}h ago',
      'yesterday': 'Yesterday',
      'daysAgo': '{count}d ago',
      'weeksAgo': '{count}w ago',
      'monthsAgo': '{count}mo ago',
      'yearsAgo': '{count}y ago',
      'today': 'Today',
      'daysLeft': '{count}d left',
      'weeksLeft': '{count}w left',
      'monthsLeft': '{count}mo left',
      'yearsLeft': '{count}y left',
      'overdue': '{count}d overdue',
    },
  };
  final isId = locale.startsWith('id');
  final t = map[isId ? 'id' : 'en']![key] ?? key;
  if (params == null) return t;
  var result = t;
  params.forEach((k, v) => result = result.replaceAll('{$k}', v));
  return result;
}

List<DateTime> getWeekDates(DateTime date, {bool startMonday = true}) {
  final normalize = DateTime(date.year, date.month, date.day);
  final firstWeekday = startMonday ? 1 : 7;
  final currentWeekday = normalize.weekday;
  final diff = (currentWeekday - firstWeekday + 7) % 7;
  final monday = normalize.subtract(Duration(days: diff));
  return List.generate(7, (i) => monday.add(Duration(days: i)));
}

List<DateTime> monthDates(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final last = DateTime(month.year, month.month + 1, 0);
  return List.generate(last.day, (i) => DateTime(first.year, first.month, i + 1));
}
