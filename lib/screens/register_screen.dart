import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/register_form.dart';
import '../theme/app_colors.dart';

/// หน้า "ลงทะเบียน" (mockup ทดสอบ flow)
///
/// เป็น [ConsumerWidget] = StatelessWidget เวอร์ชันที่เข้าถึง riverpod ได้ (มี `ref`)
/// - text field เขียนค่าเข้า provider ผ่าน onChanged (ไม่ใช้ controller — กัน cursor เด้ง)
/// - checkbox อ่านสถานะจาก provider (watch) + กดแล้ว toggle
class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  /// ตัวเลือก "ประเภทที่ขาย" ตาม mockup
  static const List<String> _sellTypeOptions = ['เสื้อผ้า', 'อาหาร', 'Street food'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch = อ่านค่า + rebuild เมื่อ state เปลี่ยน (ใช้แสดงสถานะ checkbox)
    final form = ref.watch(registerFormProvider);
    // notifier = ตัวเรียกเมธอดแก้ค่า (ไม่ทำให้ rebuild)
    final notifier = ref.read(registerFormProvider.notifier);

    return Scaffold(
      // AppBar ใช้สีจาก theme กลาง (เหลือง) — ไม่ override ที่นี่
      appBar: AppBar(
        title: const Text('ลงทะเบียน'),
      ),
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

            _label('ที่อยู่'),
            TextField(
              onChanged: notifier.setAddress,
              decoration: _decoration('ที่อยู่'),
            ),
            const SizedBox(height: 16),

            _label('ประเภทที่ขาย'),
            for (final type in _sellTypeOptions)
              CheckboxListTile(
                value: form.sellTypes.contains(type),
                onChanged: (_) => notifier.toggleSellType(type),
                title: Text(type),
                // สีติ๊กมาจาก checkboxTheme กลาง (เหลือง)
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
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
                onPressed: () => _onSubmit(context, ref),
                child: const Text(
                  'ลงทะเบียน',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// label เล็ก ๆ เหนือช่องกรอก
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );

  /// หน้าตาช่องกรอก (พื้นเหลืองอ่อนให้เข้ากับธีมเหลือง)
  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      );

  /// กด "ลงทะเบียน" (mockup) → อ่าน state จาก riverpod แล้วเด้ง dialog สรุป
  void _onSubmit(BuildContext context, WidgetRef ref) {
    final form = ref.read(registerFormProvider);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ข้อมูลที่กรอก (mockup)'),
        content: Text(
          'ชื่อ: ${form.firstName}\n'
          'นามสกุล: ${form.lastName}\n'
          'ที่อยู่: ${form.address}\n'
          'ประเภทที่ขาย: '
          '${form.sellTypes.isEmpty ? "-" : form.sellTypes.join(", ")}\n'
          'เบอร์โทร: ${form.phone}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}
