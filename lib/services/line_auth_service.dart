import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

import '../config/line_config.dart';

/// ผลลัพธ์ของการ login LINE ที่เราส่งกลับให้หน้าจอใช้ตัดสินใจแสดงผล
class LineLoginOutcome {
  const LineLoginOutcome({required this.success, required this.message});

  final bool success;
  final String message;
}

/// บริการ login ด้วย LINE จริง (เรียก flutter_line_sdk)
class LineAuthService {
  LineAuthService._();

  static Future<LineLoginOutcome> signIn() async {
    // กันพลาด: ถ้ายังไม่ได้กรอก Channel ID จริง อย่าเพิ่งเรียก SDK
    if (!isLineChannelConfigured) {
      return const LineLoginOutcome(
        success: false,
        message: 'ยังไม่ได้ตั้งค่า LINE Channel ID',
      );
    }

    try {
      // scope: profile → ได้ชื่อ/รูป, openid → ได้ idToken
      final result = await LineSDK.instance.login(
        scopes: ['profile', 'openid'],
      );

      // TODO(backend): เมื่อมี API แล้ว ส่ง result.data (accessToken/idToken)
      //   ไปให้ backend verify + สร้าง session

      final name =
          result.userProfile?.data['displayName'] as String? ?? 'ผู้ใช้ LINE';
      return LineLoginOutcome(success: true, message: 'เข้าสู่ระบบสำเร็จ: $name');
    } on PlatformException catch (e) {
      // โค้ด CANCEL = ผู้ใช้กดยกเลิกเอง ไม่ใช่ error จริง
      if (e.code == 'CANCEL') {
        return const LineLoginOutcome(success: false, message: 'ยกเลิกการเข้าสู่ระบบ');
      }
      return LineLoginOutcome(
        success: false,
        message: 'เข้าสู่ระบบไม่สำเร็จ: ${e.message ?? e.code}',
      );
    }
  }
}
