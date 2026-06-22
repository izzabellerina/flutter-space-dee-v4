import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../state/session.dart';

/// แท็บ "อื่น ๆ" — ตอนนี้มีแค่ปุ่มออกจากระบบ
///
/// ConsumerStatefulWidget เพราะมี state `_loading` (กันกดซ้ำตอนเรียก logout API)
class MoreTab extends ConsumerStatefulWidget {
  const MoreTab({super.key});

  @override
  ConsumerState<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends ConsumerState<MoreTab> {
  bool _loading = false;

  Future<void> _logout() async {
    final session = ref.read(sessionProvider);

    setState(() => _loading = true);
    // เรียก logout API (revoke refresh_token ฝั่ง server)
    await AuthService.logout(refreshToken: session.refreshToken);
    if (!mounted) return;

    // เคลียร์ session ฝั่งแอป "เสมอ" แม้ API จะ fail (เน็ตหลุด ฯลฯ)
    // — ผู้ใช้ควรหลุดออกจากแอปจริง ๆ
    ref.read(sessionProvider.notifier).clear();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'อื่น ๆ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _logout,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: Text(_loading ? 'กำลังออก...' : 'ออกจากระบบ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
