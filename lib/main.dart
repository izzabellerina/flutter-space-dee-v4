import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

import 'config/line_config.dart';
import 'screens/splash_screen.dart';
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
    debugPrint('⚠️ ยังไม่ได้ตั้ง LINE Channel ID — แก้ที่ lib/config/line_config.dart');
  }

  // จุดเริ่มต้นของแอป Flutter ทุกตัว: runApp() เอา widget ราก (SpaceDeeApp)
  // ขึ้นไปวาดบนหน้าจอ
  runApp(const SpaceDeeApp());
}

/// Widget รากของแอป — กำหนด "ธีมรวม" ของทั้งแอปไว้ที่นี่ที่เดียว
class SpaceDeeApp extends StatelessWidget {
  const SpaceDeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceDee',
      debugShowCheckedModeBanner: false, // ซ่อนแถบ "DEBUG" มุมขวาบน
      theme: ThemeData(
        // สร้างชุดสีทั้งธีมจาก "สีเมล็ด" (seed) สีหลักของแบรนด์
        // Flutter จะ generate เฉดสีที่เข้ากันให้อัตโนมัติ (Material 3)
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brandYellow),
        // ตั้งฟอนต์หลักของทั้งแอปเป็น Anuphan (ประกาศไว้ใน pubspec.yaml)
        fontFamily: 'Anuphan',
        useMaterial3: true,
      ),
      // หน้าแรกที่แอปเปิดมา = Splash (แล้วมันจะพาไป Login เอง)
      home: const SplashScreen(),
    );
  }
}
