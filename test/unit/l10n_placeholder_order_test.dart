import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/l10n/app_localizations.dart';

// gen-l10n orders positional params alphabetically by placeholder name,
// NOT by their order in the message. Call sites written in message order
// silently swap args. These pin the generated order.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final id = lookupAppLocalizations(const Locale('id'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('trend direction keys order is (lastMonth, percent)', () {
    expect(
      id.trendHigherVsLastMonth('Juli', '3.500,0'),
      '3.500,0% lebih tinggi dari bulan lalu (Juli)',
    );
    expect(
      id.trendLowerVsLastMonth('Juli', '4,2'),
      '4,2% lebih rendah dari bulan lalu (Juli)',
    );
    expect(id.trendSameVsLastMonth('Juli'), 'Tidak berubah dari bulan lalu (Juli)');
    expect(
      en.trendHigherVsLastMonth('July', '3,500.0'),
      '3,500.0% higher than last month (July)',
    );
    expect(en.trendLowerVsLastMonth('July', '4.2'), '4.2% lower than last month (July)');
    expect(en.trendSameVsLastMonth('July'), 'No change vs last month (July)');
  });

  test('trendPosTip order is (month, pct)', () {
    expect(
      id.trendPosTip('Juli', '4.2'),
      'Pengeluaran bulan ini 4.2% lebih rendah dari bulan lalu (Juli). Pertahankan!',
    );
  });

  test('pocketLabel order is (balance, name)', () {
    final idOut = id.pocketLabel('Rp10.000', 'MyPocket');
    expect(idOut, contains('MyPocket'));
    expect(idOut.indexOf('MyPocket'), lessThan(idOut.indexOf('Rp10.000')),
        reason: 'name must render before balance');
    final enOut = en.pocketLabel('Rp10.000', 'MyPocket');
    expect(enOut.indexOf('MyPocket'), lessThan(enOut.indexOf('Rp10.000')));
  });
}
