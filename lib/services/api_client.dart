import 'package:http/http.dart';

import '../models/response_model.dart';
import 'auth_service.dart';

/// ── ตัวห่อการเรียก API ที่ต้องใช้ access_token + auto-refresh ──
///
/// แนวคิด: access_token หมดอายุใน 15 นาที (900 วิ) เมื่อหมดอายุ backend จะตอบ 401
/// → เราเรียก refresh เอา access_token ใหม่ → อัปเดตเข้า session → ยิง API เดิมซ้ำ 1 ครั้ง
///
/// ใช้ยังไง (ตัวอย่าง page API ในอนาคต):
/// ```dart
/// final res = await authedRequest(
///   accessToken: session.accessToken,
///   refreshToken: session.refreshToken,
///   onRefreshed: (newAccess) =>
///       ref.read(sessionProvider.notifier).updateTokens(accessToken: newAccess),
///   onSessionExpired: () => ref.read(sessionProvider.notifier).clear(),
///   send: (token) => get(uri, headers: {'Authorization': 'Bearer $token'}),
/// );
/// ```
Future<Response> authedRequest({
  /// ฟังก์ชันยิง request จริง — รับ access_token ปัจจุบันไปแนบ header เอง
  required Future<Response> Function(String accessToken) send,
  required String accessToken,
  required String refreshToken,

  /// ถูกเรียกเมื่อ refresh สำเร็จ — เอา access_token ใหม่ไปเก็บใน session
  required void Function(String newAccessToken) onRefreshed,

  /// ถูกเรียกเมื่อ refresh ไม่สำเร็จ (เช่น refresh_token หมดอายุ) — ควร logout
  void Function()? onSessionExpired,
}) async {
  // 1) ยิงด้วย token ปัจจุบัน
  var res = await send(accessToken);

  // 2) ถ้าไม่ใช่ 401 (token ยังใช้ได้) → คืนผลเลย
  if (res.statusCode != 401) return res;

  // 3) 401 = token หมดอายุ → ขอ access_token ใหม่
  final refreshRes = await AuthService.refresh(refreshToken: refreshToken);
  if (refreshRes.responseEnum != ResponseEnum.success) {
    // refresh ไม่ผ่าน → session หมดอายุจริง ให้ผู้เรียกไป logout
    onSessionExpired?.call();
    return res; // คืน 401 เดิม
  }

  // 4) ได้ token ใหม่ → เก็บเข้า session → ยิงซ้ำ "ครั้งเดียว" (กัน loop)
  final newAccess = (refreshRes.data as Map)['access_token'] as String? ?? '';
  onRefreshed(newAccess);
  res = await send(newAccess);
  return res;
}
