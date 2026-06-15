import 'package:flutter/material.dart';

/// ศูนย์รวม "สีของแบรนด์" SpaceDee ไว้ที่เดียว
///
/// ทำไมต้องแยกไฟล์นี้ออกมา?
/// - ถ้าเขียนสี `Color(0xFF...)` กระจายทั่วโค้ด เวลาจะเปลี่ยนธีมต้องไล่แก้หลายที่
/// - รวมไว้จุดเดียว → แก้ทีเดียวเปลี่ยนทั้งแอป (single source of truth)
///
/// หมายเหตุเรื่องรหัสสี: Flutter ใช้รูปแบบ `0xAARRGGBB`
/// - AA = alpha (ความทึบ) `FF` = ทึบ 100%
/// - RR GG BB = แดง เขียว น้ำเงิน (เลขฐาน 16 เหมือน #rrggbb ในเว็บ)
/// เช่น `#fed24d` → `0xFFFED24D`
class AppColors {
  // กันไม่ให้ใครเผลอ `AppColors()` เพราะคลาสนี้มีไว้เก็บค่าคงที่เท่านั้น
  AppColors._();

  /// สีหลักของแบรนด์ (เหลือง) — ใช้กับโลโก้, ปุ่มเด่น, ตัวอักษรเน้น
  static const Color brandYellow = Color(0xFFFED24D);

  /// สีพื้นหลังหน้า login + splash (เขียวเข้ม) — เดิม (เก็บไว้อ้างอิง)
  static const Color loginGreen = Color(0xFF236925);

  /// พื้นหลังหน้า login + splash แบบไล่สี (teal อ่อน→เข้ม จากบนลงล่าง)
  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D9488), Color(0xFF115E59)],
  );

  /// สีตัวอักษรบนพื้นเขียว (ขาว) — อ่านง่าย ตัดกับพื้น
  static const Color onGreen = Colors.white;

  /// สีตัวอักษร/ไอคอนบนพื้นเหลือง (เทาเข้ม) — เหลืองสว่าง ต้องใช้ตัวอักษรเข้มถึงอ่านออก
  static const Color textDark = Color(0xFF333333);

  /// พื้นช่องกรอกข้อมูล (เทาอ่อน)
  static const Color fieldFill = Color(0xFFEEEEEE);

  /// สีเส้นขอบ (เทา) — ใช้กับ outline ของการ์ด
  static const Color borderGrey = Color(0xFFCCCCCC);

  /// เงาของการ์ด (ดำจาง ๆ) — ใช้แทนเส้นขอบ
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 3)),
  ];

  /// พื้นการ์ดทักทายแบบไล่เฉดเหลือง — อ่อนด้านบน → เข้มสุดด้านล่าง
  static const LinearGradient greetingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFEAA8), Color(0xFFF4C01E)],
  );
}
