import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/response_model.dart';
import '../services/auth_service.dart';
import '../state/register_form.dart';
import '../state/session.dart';
import '../theme/app_colors.dart';

/// หน้า "ลงทะเบียน" — เปิดเมื่อ login social สำเร็จแต่ยังไม่มี account (404)
///
/// ต้องรับ [provider] + [token] ที่ได้จาก social login มาด้วย เพื่อส่งให้
/// `AuthService.register` ผูก account ใหม่กับ social นั้น
///
/// เป็น [ConsumerStatefulWidget] เพราะมี state `_submitting` (กันกดซ้ำตอนเรียก API)
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.provider, this.token});

  final String? provider;
  final String? token;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _submitting = false; // กำลังเรียก register API อยู่ไหม

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(registerFormProvider.notifier);

    return Scaffold(
      // AppBar ใช้สีจาก theme กลาง (เหลือง)
      appBar: AppBar(title: const Text('ลงทะเบียน')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('ชื่อ'),
            TextField(
              onChanged: notifier.setFirstName,
              decoration: _decoration('ชื่อ'),
            ),
            const SizedBox(height: 16),

            _label('นามสกุล'),
            TextField(
              onChanged: notifier.setLastName,
              decoration: _decoration('นามสกุล'),
            ),
            const SizedBox(height: 16),

            _label('อีเมล'),
            TextField(
              onChanged: notifier.setEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: _decoration('อีเมล'),
            ),
            const SizedBox(height: 16),

            _label('เบอร์โทร'),
            TextField(
              onChanged: notifier.setPhone,
              keyboardType: TextInputType.phone,
              decoration: _decoration('เบอร์โทร'),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              // ปุ่มใช้สีจาก elevatedButtonTheme กลาง (เหลือง + ตัวอักษรเข้ม)
              child: ElevatedButton(
                onPressed: _submitting ? null : _onSubmit,
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'ลงทะเบียน',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// กด "ลงทะเบียน" → validate → เรียก register API → เข้าหน้าหลัก
  Future<void> _onSubmit() async {
    final form = ref.read(registerFormProvider);

    // ── ตรวจข้อมูลเบื้องต้น ──
    if (form.firstName.isEmpty ||
        form.lastName.isEmpty ||
        form.email.isEmpty ||
        form.phone.isEmpty) {
      _snack('กรุณากรอกข้อมูลให้ครบทุกช่อง');
      return;
    }
    if (!form.email.contains('@')) {
      _snack('อีเมลไม่ถูกต้อง');
      return;
    }
    // ต้องมี provider + token จาก social login (ส่งมาทาง extra)
    if (widget.provider == null || widget.token == null) {
      _snack('ข้อมูลการเข้าสู่ระบบไม่ครบ ลองเข้าสู่ระบบใหม่');
      return;
    }

    setState(() => _submitting = true);
    final res = await AuthService.register(
      provider: widget.provider!,
      token: widget.token!,
      name: form.firstName,
      surname: form.lastName,
      phone: form.phone,
      email: form.email,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (res.responseEnum == ResponseEnum.success) {
      // เก็บ session (token/user) ที่ได้จากการสมัคร แล้วเข้าหน้าหลัก
      // go = แทนที่ stack → กด back จาก Home จะไม่ย้อนกลับมาหน้าลงทะเบียน
      ref.read(sessionProvider.notifier).setFromLogin(res.data);
      context.go('/home');
    } else {
      _snack('ลงทะเบียนไม่สำเร็จ ลองใหม่อีกครั้ง');
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// label เล็ก ๆ เหนือช่องกรอก
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  );

  /// หน้าตาช่องกรอก (พื้นเทาอ่อนตามธีม)
  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.fieldFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );
}
