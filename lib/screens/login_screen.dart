import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../models/response_model.dart';
import '../services/auth_service.dart';
import '../services/facebook_auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/line_auth_service.dart';
import '../state/session.dart';
import '../theme/app_colors.dart';

/// หน้า Login — มีปุ่มเข้าสู่ระบบ 3 ทาง: LINE / Gmail / Facebook
///
/// ตอนนี้ยังไม่ต่อ SDK จริง (รอ credentials) เมื่อกดปุ่ม เราจะ "log โครงสร้าง
/// ข้อมูลที่ provider จะคืนมา" ออก console (ดู [AuthLogger]) + เด้ง SnackBar บอก
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      _onLineLogin(context, ref), // ← ของจริงแล้ว (ไม่ใช่ mock)
                ),
                const SizedBox(height: 16),
                _LoginButton(
                  label: 'เข้าสู่ระบบด้วย Gmail',
                  icon: FontAwesomeIcons.google, // โลโก้ Google จริง
                  iconColor: const Color(0xFFEA4335), // แดง Google
                  onPressed: () => _onGoogleLogin(context, ref),
                ),
                const SizedBox(height: 16),
                _LoginButton(
                  label: 'เข้าสู่ระบบด้วย Facebook',
                  icon: FontAwesomeIcons.facebook, // โลโก้ Facebook จริง
                  iconColor: const Color(0xFF1877F2), // น้ำเงิน Facebook
                  onPressed: () => _onFacebookLogin(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ผลลัพธ์รวมจาก social SDK (แปลงจาก outcome แต่ละเจ้าให้หน้าตาเดียวกัน)
  // record = โครงสร้างข้อมูลเล็ก ๆ ไม่ต้องสร้าง class

  void _onLineLogin(BuildContext context, WidgetRef ref) => _handleSocialLogin(
    context,
    ref,
    provider: 'line',
    signIn: (nonce) async {
      final o = await LineAuthService.signIn(nonce: nonce);
      return (success: o.success, message: o.message, token: o.token);
    },
  );

  void _onGoogleLogin(BuildContext context, WidgetRef ref) =>
      _handleSocialLogin(
        context,
        ref,
        provider: 'google', // ยืนยันแล้ว: backend รับ 'google' ('gmail' = 400)
        signIn: (nonce) async {
          final o = await GoogleAuthService.signIn(nonce: nonce);
          return (success: o.success, message: o.message, token: o.token);
        },
      );

  void _onFacebookLogin(
    BuildContext context,
    WidgetRef ref,
  ) => _handleSocialLogin(
    context,
    ref,
    provider: 'facebook',
    signIn: (nonce) async {
      // Facebook SDK ไม่รองรับ nonce — รับ param ไว้เฉย ๆ ให้ signature ตรงกัน
      final o = await FacebookAuthService.signIn();
      return (success: o.success, message: o.message, token: o.token);
    },
  );

  /// flow login กลาง: ดึง nonce → social SDK login (ใส่ nonce) → เรียก login API
  /// → ลงทะเบียนแล้วไป /home, ยังไม่ลงทะเบียนไป /register
  Future<void> _handleSocialLogin(
    BuildContext context,
    WidgetRef ref, {
    required String provider,
    required Future<({bool success, String message, String token})> Function(
      String nonce,
    )
    signIn,
  }) async {
    // 1) ดึง nonce จาก backend
    final nonceRes = await AuthService.nonce();
    if (!context.mounted) return;
    if (nonceRes.responseEnum != ResponseEnum.success) {
      _snack(context, 'ขอ nonce ไม่สำเร็จ ลองใหม่อีกครั้ง');
      return;
    }
    final nonce = nonceRes.data.nonce;

    // 2) login ด้วย social SDK (ฝัง nonce ลง token)
    final outcome = await signIn(nonce);
    if (!context.mounted) return;
    if (!outcome.success) {
      _snack(context, outcome.message);
      return;
    }

    // 3) ส่ง token ให้ backend verify
    final loginRes = await AuthService.login(
      provider: provider,
      token: outcome.token,
      nonce: nonce,
    );
    if (!context.mounted) return;

    // 4) นำทางตามผลลัพธ์
    switch (loginRes.responseEnum) {
      case ResponseEnum.success:
        // ลงทะเบียนแล้ว → เก็บ session (token/user) แล้วเข้าหน้าหลัก
        ref.read(sessionProvider.notifier).setFromLogin(loginRes.data);
        context.go('/home');
      case ResponseEnum.accountNotRegistered:
        // ยังไม่ลงทะเบียน → ไปหน้าลงทะเบียน (ส่ง provider + token ไปใช้ตอน register)
        context.go(
          '/register',
          extra: {'provider': provider, 'token': outcome.token},
        );
      default:
        _snack(context, 'เข้าสู่ระบบไม่สำเร็จ');
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
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
