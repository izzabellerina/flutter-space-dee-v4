import 'package:google_sign_in/google_sign_in.dart';

/// ผลลัพธ์การ login Google ที่ส่งกลับให้หน้าจอ
class GoogleLoginOutcome {
  const GoogleLoginOutcome({
    required this.success,
    required this.message,
    this.token = '',
  });

  final bool success;
  final String message;

  /// idToken (JWT) ที่ได้จาก Google — ส่งให้ backend verify
  final String token;
}

/// บริการ login ด้วย Google (Gmail) ผ่าน google_sign_in ตรง ๆ (ไม่ผ่าน Firebase)
class GoogleAuthService {
  GoogleAuthService._();

  /// Web client ID (client_type 3) จาก google-services.json
  /// ใส่เป็น serverClientId เพื่อให้ idToken มี audience = web client
  /// → backend เอาไป verify ได้
  static const String _serverClientId =
      '664212462295-5lp51s8etk5k7i34q1f7tsdk1o2d4gs3.apps.googleusercontent.com';

  static Future<GoogleLoginOutcome> signIn({String? nonce}) async {
    try {
      // initialize ใหม่ทุกครั้งเพื่อส่ง nonce ล่าสุด (nonce เปลี่ยนทุก login)
      // nonce ฝังใน idToken → backend verify ได้ (กัน replay attack)
      await GoogleSignIn.instance.initialize(
        serverClientId: _serverClientId,
        nonce: nonce,
      );

      // บางแพลตฟอร์ม (เช่น web) ใช้ปุ่มของ Google เอง ไม่รองรับ authenticate()
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return const GoogleLoginOutcome(
          success: false,
          message: 'แพลตฟอร์มนี้ไม่รองรับ authenticate()',
        );
      }

      // ── เปิดหน้าเลือกบัญชี Google (ของจริง) ──
      // (nonce ถูกส่งผ่าน initialize ด้านบนแล้ว ไม่ใช่ที่ authenticate)
      final account = await GoogleSignIn.instance.authenticate();

      final name = account.displayName ?? account.email;
      return GoogleLoginOutcome(
        success: true,
        message: 'เข้าสู่ระบบสำเร็จ: $name',
        token: account.authentication.idToken ?? '',
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const GoogleLoginOutcome(
          success: false,
          message: 'ยกเลิกการเข้าสู่ระบบ',
        );
      }
      return GoogleLoginOutcome(
        success: false,
        message: 'เข้าสู่ระบบไม่สำเร็จ: ${e.description ?? e.code.name}',
      );
    }
  }
}
