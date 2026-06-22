import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ── State Management ด้วย riverpod ──
///
/// ไฟล์นี้เก็บ "ข้อมูลของฟอร์มลงทะเบียน" ไว้ที่เดียว (single source of truth)
/// แทนที่จะเก็บใน State ของหน้าจอ → หน้าจอไหนก็อ่าน/แก้ค่านี้ได้ และแยกตรรกะ
/// ออกจาก UI

/// โมเดลข้อมูลฟอร์ม (immutable — เปลี่ยนค่าด้วยการสร้างชุดใหม่ผ่าน copyWith)
class RegisterForm {
  const RegisterForm({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  RegisterForm copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) {
    return RegisterForm(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

/// Notifier = ตัวที่ "ถือ state + มีเมธอดแก้ state"
/// แก้ค่าด้วยการ set `state = ...` (riverpod จะแจ้ง widget ที่ watch อยู่ให้ rebuild)
class RegisterFormNotifier extends Notifier<RegisterForm> {
  @override
  RegisterForm build() => const RegisterForm(); // ค่าเริ่มต้น

  void setFirstName(String v) => state = state.copyWith(firstName: v);
  void setLastName(String v) => state = state.copyWith(lastName: v);
  void setEmail(String v) => state = state.copyWith(email: v);
  void setPhone(String v) => state = state.copyWith(phone: v);

  void reset() => state = const RegisterForm();
}

/// provider ที่หน้าจอเอาไปใช้ — `ref.watch(registerFormProvider)` อ่านค่า,
/// `ref.read(registerFormProvider.notifier)` เรียกเมธอดแก้ค่า
final registerFormProvider =
    NotifierProvider<RegisterFormNotifier, RegisterForm>(
      RegisterFormNotifier.new,
    );
