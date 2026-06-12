import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// ผลลัพธ์การ login Facebook ที่ส่งกลับให้หน้าจอ
class FacebookLoginOutcome {
  const FacebookLoginOutcome({required this.success, required this.message});

  final bool success;
  final String message;
}

/// บริการ login ด้วย Facebook ผ่าน flutter_facebook_auth ตรง ๆ (ไม่ผ่าน Firebase)
class FacebookAuthService {
  FacebookAuthService._();

  static Future<FacebookLoginOutcome> signIn() async {
    try {
      // loginTracking.enabled = ได้ "classic token" (graph access token)
      final result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
        loginTracking: LoginTracking.enabled,
      );

      if (result.status == LoginStatus.cancelled) {
        return const FacebookLoginOutcome(
          success: false,
          message: 'ยกเลิกการเข้าสู่ระบบ',
        );
      }
      if (result.status != LoginStatus.success || result.accessToken == null) {
        return FacebookLoginOutcome(
          success: false,
          message: 'เข้าสู่ระบบไม่สำเร็จ: ${result.message ?? result.status.name}',
        );
      }

      // ดึงข้อมูลโปรไฟล์จาก Graph API (ไว้โชว์ชื่อ)
      final userData = await FacebookAuth.instance.getUserData(
        fields: 'id,name,first_name,last_name,email,picture.width(400)',
      );

      // TODO(backend): เมื่อมี API แล้ว ส่ง result.accessToken!.tokenString
      //   ไปให้ backend verify + สร้าง session

      final name = userData['name'] as String? ?? 'ผู้ใช้ Facebook';
      return FacebookLoginOutcome(
        success: true,
        message: 'เข้าสู่ระบบสำเร็จ: $name',
      );
    } catch (e) {
      return FacebookLoginOutcome(
        success: false,
        message: 'เข้าสู่ระบบไม่สำเร็จ: $e',
      );
    }
  }
}
