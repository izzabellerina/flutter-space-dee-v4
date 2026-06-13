import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

/// หน้า Splash — จอแรกที่โผล่ตอนเปิดแอป
///
/// ════════════════════════════════════════════════════════════════════
/// ทำไมเป็น StatefulWidget?
/// ────────────────────────────────────────────────────────────────────
/// เพราะหน้านี้มี "พฤติกรรมที่เกิดตามเวลา" คือรอ ~2.5 วิ แล้วเด้งไปหน้า login
/// งานแบบนี้ต้องเริ่มทำงาน "ครั้งเดียวตอนหน้าจอถูกสร้าง" → ใช้ initState()
/// ซึ่งมีเฉพาะใน State ของ StatefulWidget (StatelessWidget ไม่มี lifecycle นี้)
/// ════════════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // initState ทำงาน "ครั้งเดียว" ตอน widget ถูกสร้างเข้า tree
    // เหมาะกับการตั้งเวลา/โหลดข้อมูลเริ่มต้น
    _goToLoginAfterDelay();
  }

  Future<void> _goToLoginAfterDelay() async {
    // หน่วงเวลาให้ user เห็นโลโก้ก่อน (ปกติจริงจะใช้ช่วงนี้โหลด config/เช็ค session)
    await Future.delayed(const Duration(milliseconds: 2500));

    // ⚠️ จุดสำคัญของ logic: ต้องเช็ค `mounted` ก่อนใช้ context เสมอ
    // เพราะระหว่างที่เรา await 2.5 วิ user อาจปิดหน้านี้ไปแล้ว
    // ถ้าหน้าถูกทำลายไปแล้วยังไปยุ่งกับ context จะ crash
    if (!mounted) return;

    // context.go('/login') = ไปหน้า login แล้ว "แทนที่" stack ทิ้ง (ผ่าน go_router)
    // → user กดปุ่ม back แล้วจะไม่ย้อนกลับมาเห็น splash อีก (ถูกต้องตาม UX)
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // พื้นหลังเขียวเข้มตามดีไซน์ (ใช้สีกลางจาก AppColors)
      backgroundColor: AppColors.loginGreen,
      body: Center(
        // โลโก้ SVG กลางจอ — flutter_svg เรนเดอร์ไฟล์ .svg ให้คมทุกขนาด
        child: SvgPicture.asset(
          'assets/images/logo_spacedee.svg',
          width: 180,
        ),
      ),
    );
  }
}
