import 'package:flutter_test/flutter_test.dart';
import 'package:shike_guanjia/utils/date_utils.dart';

void main() {
  test('weekdayChinese maps DateTime.weekday correctly', () {
    expect(weekdayChinese(DateTime(2026, 6, 8)), '周一');
    expect(weekdayChinese(DateTime(2026, 6, 9)), '周二');
    expect(weekdayChinese(DateTime(2026, 6, 10)), '周三');
    expect(weekdayChinese(DateTime(2026, 6, 11)), '周四');
    expect(weekdayChinese(DateTime(2026, 6, 12)), '周五');
    expect(weekdayChinese(DateTime(2026, 6, 13)), '周六');
    expect(weekdayChinese(DateTime(2026, 6, 14)), '周日');
  });
}
