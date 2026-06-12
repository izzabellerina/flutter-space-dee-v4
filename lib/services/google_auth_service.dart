import 'package:google_sign_in/google_sign_in.dart';

/// ผลลัพธ์การ login Google ที่ส่งกลับให้หน้าจอ
class GoogleLoginOutcome {
  const GoogleLoginOutcome({required this.success, required this.message});

  final bool success;
  final String message;
}

/// บริการ login ด้วย Google (Gmail) ผ่าน google_sign_in ตรง ๆ (ไม่ผ่าน Firebase)
class GoogleAuthService {
  GoogleAuthService._();

  /// Web client ID (client_type 3) จาก google-services.json
  /// ใส่เป็น serverClientId เพื่อให้ idToken มี audience = web client
  /// → backend เอาไป verify ได้
  static const String _serverClientId =
      '664212462295-5lp51s8etk5k7i34q1f7tsdk1o2d4gs3.apps.googleusercontent.com';

  // initialize() ต้องเรียกครั้งเดียวก่อน authenticate() — กันเรียกซ้ำด้วย flag
  static bool _initialized = false;

  static Future<GoogleLoginOutcome> signIn() async {
    try {
      if (!_initialized) {
        await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
        _initialized = true;
      }

      // บางแพลตฟอร์ม (เช่น web) ใช้ปุ่มของ Google เอง ไม่รองรับ authenticate()
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return const GoogleLoginOutcome(
          success: false,
          message: 'แพลตฟอร์มนี้ไม่รองรับ authenticate()',
        );
      }

      // ── เปิดหน้าเลือกบัญชี Google (ของจริง) ──
      final account = await GoogleSignIn.instance.authenticate();

      // TODO(backend): เมื่อมี API แล้ว ส่ง account.authentication.idToken
      //   ไปให้ backend verify + สร้าง session

      final name = account.displayName ?? account.email;
      return GoogleLoginOutcome(success: true, message: 'เข้าสู่ระบบสำเร็จ: $name');
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const GoogleLoginOutcome(
            success: false, message: 'ยกเลิกการเข้าสู่ระบบ');
      }
      return GoogleLoginOutcome(
        success: false,
        message: 'เข้าสู่ระบบไม่สำเร็จ: ${e.description ?? e.code.name}',
      );
    }
  }
}
