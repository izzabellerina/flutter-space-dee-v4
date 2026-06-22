import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

import '../config/line_config.dart';

/// ผลลัพธ์ของการ login LINE ที่เราส่งกลับให้หน้าจอใช้ตัดสินใจแสดงผล
class LineLoginOutcome {
  const LineLoginOutcome({
    required this.success,
    required this.message,
    this.token = '',
  });

  final bool success;
  final String message;

  /// id_token (JWT) ที่ได้จาก LINE — ส่งให้ backend verify
  final String token;
}

/// บริการ login ด้วย LINE จริง (เรียก flutter_line_sdk)
class LineAuthService {
  LineAuthService._();

  // nonce fallback (ทดสอบ) — ปกติ backend จะ generate ส่งมาทาง param
  static const String _idTokenNonce = '64090ae77ae19d3bf915e92e803dec5d';

  static Future<LineLoginOutcome> signIn({String? nonce}) async {
    // กันพลาด: ถ้ายังไม่ได้กรอก Channel ID จริง อย่าเพิ่งเรียก SDK
    if (!isLineChannelConfigured) {
      return const LineLoginOutcome(
        success: false,
        message: 'ยังไม่ได้ตั้งค่า LINE Channel ID',
      );
    }

    try {
      // scope: profile → ได้ชื่อ/รูป, openid → ได้ idToken
      // option.idTokenNonce → ส่ง nonce ไปด้วย (ฝังใน id_token เพื่อ verify)
      final result = await LineSDK.instance.login(
        scopes: ['profile', 'openid'],
        option: LoginOption(false, 'normal')
          ..idTokenNonce = nonce ?? _idTokenNonce,
      );

      final name =
          result.userProfile?.data['displayName'] as String? ?? 'ผู้ใช้ LINE';
      final idToken =
          (result.data['accessToken'] as Map?)?['id_token'] as String? ?? '';
      return LineLoginOutcome(
        success: true,
        message: 'เข้าสู่ระบบสำเร็จ: $name',
        token: idToken,
      );
    } on PlatformException catch (e) {
      // โค้ด CANCEL = ผู้ใช้กดยกเลิกเอง ไม่ใช่ error จริง
      if (e.code == 'CANCEL') {
        return const LineLoginOutcome(
          success: false,
          message: 'ยกเลิกการเข้าสู่ระบบ',
        );
      }
      return LineLoginOutcome(
        success: false,
        message: 'เข้าสู่ระบบไม่สำเร็จ: ${e.message ?? e.code}',
      );
    }
  }
}
