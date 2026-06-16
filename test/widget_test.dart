// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shike_guanjia/core/service_locator.dart';
import 'package:shike_guanjia/main.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();
  });

  testWidgets('App renders login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShikeGuanjiaApp());
    await tester.pumpAndSettle();

    expect(find.text('Lesson Butler'), findsOneWidget);
    expect(find.text('让课程管理变得如拆开贴纸书般轻松'), findsOneWidget);
  });
}
