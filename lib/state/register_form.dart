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
    this.address = '',
    this.phone = '',
    this.sellTypes = const {},
  });

  final String firstName;
  final String lastName;
  final String address;
  final String phone;

  /// ประเภทที่ขาย (เลือกได้หลายอัน) — เก็บเป็น Set เพราะไม่ซ้ำ + เช็ก contains ง่าย
  final Set<String> sellTypes;

  RegisterForm copyWith({
    String? firstName,
    String? lastName,
    String? address,
    String? phone,
    Set<String>? sellTypes,
  }) {
    return RegisterForm(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      sellTypes: sellTypes ?? this.sellTypes,
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
  void setAddress(String v) => state = state.copyWith(address: v);
  void setPhone(String v) => state = state.copyWith(phone: v);

  /// ติ๊ก/เอาออก ประเภทที่ขาย
  void toggleSellType(String type) {
    final next = {...state.sellTypes}; // copy ออกมาก่อน (ห้ามแก้ Set เดิมตรง ๆ)
    if (next.contains(type)) {
      next.remove(type);
    } else {
      next.add(type);
    }
    state = state.copyWith(sellTypes: next);
  }

  void reset() => state = const RegisterForm();
}

/// provider ที่หน้าจอเอาไปใช้ — `ref.watch(registerFormProvider)` อ่านค่า,
/// `ref.read(registerFormProvider.notifier)` เรียกเมธอดแก้ค่า
final registerFormProvider =
    NotifierProvider<RegisterFormNotifier, RegisterForm>(
  RegisterFormNotifier.new,
);
