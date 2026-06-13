// Smoke test ของ SpaceDee
//
// ทดสอบคร่าว ๆ ว่าแอปเปิดมาแล้วแสดงหน้า Splash (มีโลโก้) ได้โดยไม่พัง

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_space_dee/main.dart';

void main() {
  testWidgets('แอปเปิดมาแล้วแสดงหน้า Splash พร้อมโลโก้', (WidgetTester tester) async {
    // สร้างแอปและ render หนึ่งเฟรม (ครอบ ProviderScope เพราะแอปใช้ riverpod)
    await tester.pumpWidget(const ProviderScope(child: SpaceDeeApp()));

    // หน้า Splash ควรมีโลโก้ SVG หนึ่งตัว
    expect(find.byType(SvgPicture), findsOneWidget);

    // เก็บกวาด timer ที่ตั้งไว้ใน splash (Future.delayed) ไม่ให้ค้างหลังจบเทสต์
    await tester.pump(const Duration(seconds: 3));
  });
}
