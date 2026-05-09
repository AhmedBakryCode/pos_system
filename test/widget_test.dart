import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_system/app/app.dart';
import 'package:pos_system/app/di/injection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(configureDependencies);

  testWidgets('dashboard shell renders', (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PosSystemApp());
    await tester.pumpAndSettle();

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('دخول'), findsOneWidget);
  });
}
