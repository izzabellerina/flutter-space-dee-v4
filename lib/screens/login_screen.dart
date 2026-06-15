import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../services/facebook_auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/line_auth_service.dart';
import '../theme/app_colors.dart';

/// หน้า Login — มีปุ่มเข้าสู่ระบบ 3 ทาง: LINE / Gmail / Facebook
///
/// ตอนนี้ยังไม่ต่อ SDK จริง (รอ credentials) เมื่อกดปุ่ม เราจะ "log โครงสร้าง
/// ข้อมูลที่ provider จะคืนมา" ออก console (ดู [AuthLogger]) + เด้ง SnackBar บอก
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // พื้นหลังไล่สี teal (ห่อ body ด้วย Container เพราะ Scaffold ใส่ gradient ตรง ๆ ไม่ได้)
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.loginGradient),
        child: SafeArea(
          // SafeArea กันไม่ให้เนื้อหาทับรอยบาก/แถบสถานะของมือถือ
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── โลโก้ (มีคำว่า "spacedee" ในตัวอยู่แล้ว จึงไม่ต้องมีชื่อซ้ำ) ──
                SvgPicture.asset('assets/images/logo_spacedee.svg', width: 140),
                const SizedBox(height: 20),

                // ── ข้อความต้อนรับ ──
                const Text(
                  'ยินดีต้อนรับ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onGreen,
                  ),
                ),
                const SizedBox(height: 40),

                // ── ปุ่ม login 3 ทาง ──
                // ดีไซน์: ทุกปุ่ม "พื้นขาว + ตัวอักษรเข้ม" เหมือนกันหมด
                // แล้วแยกแบรนด์ด้วย "สีไอคอน" เท่านั้น → ลดจำนวนสีบนจอ
                // ทำให้ identity เหลือง/เขียวของ SpaceDee เด่น และปุ่มดูเป็นชุดเดียวกัน
                // หมายเหตุ: ไอคอนยังเป็น Material icon ชั่วคราว (placeholder)
                // ตอนต่อ SDK จริงค่อยเปลี่ยนเป็นโลโก้แบรนด์จริง
                _LoginButton(
                  label: 'เข้าสู่ระบบด้วย LINE',
                  icon: FontAwesomeIcons.line, // โลโก้ LINE จริง
                  iconColor: const Color(0xFF06C755), // เขียว LINE
                  onPressed: () =>
                      _onLineLogin(context), // ← ของจริงแล้ว (ไม่ใช่ mock)
                ),
                const SizedBox(height: 16),
                _LoginButton(
                  label: 'เข้าสู่ระบบด้วย Gmail',
                  icon: FontAwesomeIcons.google, // โลโก้ Google จริง
                  iconColor: const Color(0xFFEA4335), // แดง Google
                  onPressed: () => _onGoogleLogin(context), // ← ของจริงแล้ว
                ),
                const SizedBox(height: 16),
                _LoginButton(
                  label: 'เข้าสู่ระบบด้วย Facebook',
                  icon: FontAwesomeIcons.facebook, // โลโก้ Facebook จริง
                  iconColor: const Color(0xFF1877F2), // น้ำเงิน Facebook
                  onPressed: () => _onFacebookLogin(context), // ← ของจริงแล้ว
                ),

                // ⚠️ TEMP (mockup): ปุ่มชั่วคราวไว้ทดสอบ flow ไปหน้าลงทะเบียน
                // ของจริงจะไปหน้าลงทะเบียนหลัง login สำเร็จ — อันนี้ไว้เทสเฉย ๆ ลบทีหลังได้
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text(
                    '🧪 ทดสอบ: ไปหน้าลงทะเบียน',
                    style: TextStyle(color: AppColors.onGreen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// LINE — ของจริง: เรียก SDK login แล้ว log payload จริง + เด้งผลลัพธ์
  ///
  /// เป็น async เพราะต้อง "รอ" ผู้ใช้ทำ login บนหน้าจอ LINE ให้เสร็จก่อน
  Future<void> _onLineLogin(BuildContext context) async {
    final outcome = await LineAuthService.signIn();

    // ⚠️ หลัง await ต้องเช็ค context.mounted ก่อนใช้ context เสมอ
    // (หน้าจ ออาจถูกปิดไประหว่างที่ผู้ใช้ค้างอยู่หน้า login ของ LINE)
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(outcome.message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Gmail (Google) — ของจริง: google_sign_in → firebase_auth → log payload
  Future<void> _onGoogleLogin(BuildContext context) async {
    final outcome = await GoogleAuthService.signIn();

    if (!context.mounted) return; // กัน crash ถ้าหน้าถูกปิดระหว่าง await

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(outcome.message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Facebook — ของจริง: flutter_facebook_auth → firebase_auth → log payload
  Future<void> _onFacebookLogin(BuildContext context) async {
    final outcome = await FacebookAuthService.signIn();

    if (!context.mounted) return; // กัน crash ถ้าหน้าถูกปิดระหว่าง await

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(outcome.message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// ปุ่ม login แบบใช้ซ้ำ — แยกเป็น widget ของตัวเองเพื่อลดโค้ดซ้ำ 3 รอบ
///
/// นี่คือหลักการสำคัญของ Flutter: "compose UI จาก widget เล็ก ๆ ที่ใช้ซ้ำได้"
class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  });

  final String label;

  /// ไอคอนแบรนด์ (FontAwesome) — เป็นชนิด FaIconData ต้องเรนเดอร์ด้วย FaIcon
  final FaIconData icon;

  /// สีของไอคอนแบรนด์ (ส่วนเดียวที่ต่างกันในแต่ละปุ่ม)
  final Color iconColor;
  final VoidCallback onPressed;

  // พื้นและตัวอักษรเหมือนกันทุกปุ่ม → ตั้งเป็นค่าคงที่ในตัว widget เลย
  static const Color _background = Colors.white;
  static const Color _textColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // กว้างเต็มพื้นที่ของ parent
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: FaIcon(icon, color: iconColor, size: 20), // ← โลโก้แบรนด์จริง
        label: Text(
          label,
          style: const TextStyle(
            color: _textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
