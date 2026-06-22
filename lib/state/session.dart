import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/response_model.dart';
import '../models/social_login_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// ── Session ของผู้ใช้ที่ login แล้ว ──
///
/// เก็บ token + ข้อมูล user ไว้ที่เดียว (Riverpod) ให้ทุกหน้าอ่าน/อัปเดตได้
/// หมายเหตุ: เก็บใน memory → ปิดแอปแล้วหาย (ยังไม่ทำ persistence/secure storage)
class Session {
  const Session({
    this.accessToken = '',
    this.refreshToken = '',
    this.expiresIn = 0,
    this.user,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn; // อายุ access_token (วินาที) เช่น 900 = 15 นาที
  final UserModel? user;

  /// login อยู่ไหม → ดูว่ามี access_token หรือยัง
  bool get isLoggedIn => accessToken.isNotEmpty;

  Session copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    UserModel? user,
  }) {
    return Session(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      user: user ?? this.user,
    );
  }
}

class SessionNotifier extends Notifier<Session> {
  // ตัวจับเวลา refresh ล่วงหน้า — ยิง refresh เมื่อใกล้ token หมดอายุ
  Timer? _refreshTimer;

  @override
  Session build() => const Session(); // เริ่มต้น = ยังไม่ login

  /// เก็บ session จากผลลัพธ์ login/register สำเร็จ
  void setFromLogin(SocialLoginModel m) {
    state = Session(
      accessToken: m.accessToken,
      refreshToken: m.refreshToken,
      expiresIn: m.expiresIn,
      user: m.user,
    );
    _scheduleRefresh(); // เริ่มจับเวลา refresh
  }

  /// อัปเดต access_token (และ refresh/expiresIn ถ้ามี) หลังเรียก refresh API
  void updateTokens({
    required String accessToken,
    String? refreshToken,
    int? expiresIn,
  }) {
    state = state.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
    );
    _scheduleRefresh(); // ตั้งจับเวลารอบใหม่ตามอายุ token ล่าสุด
  }

  /// ล้าง session (ตอน logout) — หยุดจับเวลาด้วย
  void clear() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    state = const Session();
  }

  /// ตั้งจับเวลา: ครบอายุ token (expiresIn วินาที) แล้วยิง refresh
  void _scheduleRefresh() {
    _refreshTimer?.cancel(); // ยกเลิกตัวเก่าก่อนเสมอ (กันซ้อน)
    final seconds = state.expiresIn;
    if (seconds <= 0) return; // ไม่มีข้อมูลอายุ → ไม่ตั้ง
    _refreshTimer = Timer(Duration(seconds: seconds), _doRefresh);
  }

  /// ยิง refresh API → ได้ token ใหม่ → อัปเดต session (ซึ่งจะตั้ง timer รอบใหม่)
  Future<void> _doRefresh() async {
    final res = await AuthService.refresh(refreshToken: state.refreshToken);
    if (res.responseEnum != ResponseEnum.success) {
      // refresh ไม่ผ่าน (เช่น refresh_token หมดอายุ) → ออกจากระบบเงียบ ๆ
      log('refresh ไม่สำเร็จ — เคลียร์ session', name: 'SESSION');
      clear();
      return;
    }
    final data = res.data as Map;
    updateTokens(
      accessToken: data['access_token'] as String? ?? state.accessToken,
      refreshToken: data['refresh_token'] as String?,
      expiresIn: data['expires_in'] as int?,
    );
  }
}

/// `ref.watch(sessionProvider)` อ่านค่า, `ref.read(sessionProvider.notifier)` แก้ค่า
final sessionProvider = NotifierProvider<SessionNotifier, Session>(
  SessionNotifier.new,
);
