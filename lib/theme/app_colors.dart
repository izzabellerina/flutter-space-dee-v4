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

  /// สีพื้นหลังหน้า login + splash (เขียวเข้ม)
  static const Color loginGreen = Color(0xFF236925);

  /// สีตัวอักษรบนพื้นเขียว (ขาว) — อ่านง่าย ตัดกับพื้น
  static const Color onGreen = Colors.white;
}
