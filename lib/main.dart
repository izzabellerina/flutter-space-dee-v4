import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/line_config.dart';
import 'router/app_router.dart';
import 'theme/app_colors.dart';

void main() {
  // ต้องเรียกก่อนใช้ plugin ใด ๆ ใน main() — รับประกันว่า engine ฝั่ง native
  // พร้อมรับคำสั่งแล้ว (ปกติ runApp เรียกให้เอง แต่พอเราจะเรียก setup() ก่อน
  // runApp ต้องเรียกเองให้ชัด)
  WidgetsFlutterBinding.ensureInitialized();

  // เตรียม LINE SDK ด้วย Channel ID — ทำครั้งเดียวตอนเปิดแอป
  // ข้ามถ้ายังไม่ได้กรอก Channel ID จริง (กัน error ตอน dev)
  if (isLineChannelConfigured) {
    LineSDK.instance.setup(kLineChannelId).then((_) {
      debugPrint('LineSDK setup เสร็จ (channelId=$kLineChannelId)');
    });
  } else {
    debugPrint(
      '⚠️ ยังไม่ได้ตั้ง LINE Channel ID — แก้ที่ lib/config/line_config.dart',
    );
  }

  // ProviderScope = "ราก" ของ riverpod — ต้องครอบทั้งแอป ไม่งั้นใช้ provider ไม่ได้
  runApp(const ProviderScope(child: SpaceDeeApp()));
}

/// Widget รากของแอป — กำหนด "ธีมรวม" ของทั้งแอปไว้ที่นี่ที่เดียว
class SpaceDeeApp extends StatelessWidget {
  const SpaceDeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router = ใช้ go_router จัดการนำทาง (แทน home/Navigator เดิม)
    return MaterialApp.router(
      title: 'SpaceDee',
      debugShowCheckedModeBanner: false, // ซ่อนแถบ "DEBUG" มุมขวาบน
      theme: ThemeData(
        // สร้างชุดสีทั้งธีมจาก "สีเมล็ด" (seed) สีหลักของแบรนด์
        // Flutter จะ generate เฉดสีที่เข้ากันให้อัตโนมัติ (Material 3)
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brandYellow),
        // ตั้งฟอนต์หลักของทั้งแอปเป็น Anuphan (ประกาศไว้ใน pubspec.yaml)
        fontFamily: 'Anuphan',
        useMaterial3: true,

        // พื้นหลัง body ของทุกหน้า = ขาว (login/splash override ด้วย gradient เอง)
        scaffoldBackgroundColor: Colors.white,

        // ── ธีมหลัก = เหลือง สำหรับ "หน้าที่ไม่ใช่ login" ──
        // (login/splash ใช้พื้นเขียวโดย override Scaffold/ปุ่มของตัวเอง จึงไม่โดนกระทบ)
        // ตั้งที่เดียวตรงนี้ → ทุกหน้าใหม่ได้สีเหลืองอัตโนมัติ
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.brandYellow,
          foregroundColor: AppColors.textDark, // ตัวอักษร/back บนเหลือง = เข้ม
          surfaceTintColor: Colors.transparent, // กัน M3 ลงสีจาง ๆ ตอน scroll
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandYellow,
            foregroundColor: AppColors.textDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.brandYellow
                : null,
          ),
          checkColor: WidgetStateProperty.all(AppColors.textDark),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
