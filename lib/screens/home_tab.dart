import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/register_form.dart';
import '../theme/app_colors.dart';

/// แท็บ "หน้าหลัก" — dashboard ตามรูป mockup (โทนเหลืองตามธีม)
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select = อ่านเฉพาะ firstName → rebuild เมื่อ "ชื่อ" เปลี่ยนเท่านั้น (ไม่ใช่ทุก field)
    final firstName =
        ref.watch(registerFormProvider.select((f) => f.firstName));
    final name = firstName.isEmpty ? 'ผู้ใช้' : firstName;
    // ความสูงของ status bar (เวลา/แบต) — เอามาเป็น padding บนของแถบหัว
    // เพื่อให้ gradient ไล่ขึ้นไปหลัง status bar แต่การ์ดไม่โดน status bar ทับ
    final topInset = MediaQuery.of(context).padding.top;

    // AnnotatedRegion: ทำให้ status bar โปร่งใส (gradient ทะลุขึ้นไป) + ไอคอนสีเข้ม (อ่านบนเหลืองออก)
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── แถบหัว: พื้นหลัง gradient เหลือง (ชั้นหลังสุด, ขึ้นถึงหลัง status bar) ──
            // การ์ดทักทาย (สีขาว) ลอยอยู่บนแถบนี้
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: AppColors.greetingGradient),
              padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 16),
              child: _GreetingCard(name: name),
            ),

            // ── เนื้อหาส่วนล่าง (พื้นขาวของ body) ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'รายการจองที่จะถึง',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  // ข้อมูลการจอง = mock (ยังไม่มี backend)
                  const _UpcomingBookingCard(
                    market: 'ตลาดโกโก้',
                    dateText: 'จองไว้  พุธ 27 กรกฎาคม 2569',
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _BookingButton(
                          title: 'จองรายวัน',
                          subtitle: 'สัญญาระยะสั้น\nรายวัน',
                          icon: Icons.wb_sunny,
                          onTap: () => _comingSoon(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BookingButton(
                          title: 'จองรายเดือน',
                          subtitle: 'สัญญาระยะยาว\nรายเดือน',
                          icon: Icons.nightlight_round,
                          onTap: () => _comingSoon(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('กำลังพัฒนา flow การจอง'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// การ์ดทักทาย: avatar + "สวัสดีคุณ<ชื่อ>"
class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // การ์ดสีขาว ลอยบนแถบหัว gradient
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow, // เงาแทนเส้นขอบ
      ),
      child: Row(
        children: [
          // avatar เป็น placeholder (ยังไม่มีรูปจริงจาก backend)
          const CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.fieldFill, // เทาอ่อน เห็นวงบนการ์ดขาว
            child: Icon(Icons.person, color: AppColors.textDark, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'สวัสดีคุณ$name',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// การ์ดการจองที่จะถึง (พื้นขาว ขอบเหลือง — ให้ต่างจากการ์ดอื่น)
class _UpcomingBookingCard extends StatelessWidget {
  const _UpcomingBookingCard({required this.market, required this.dateText});
  final String market;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow, // ใช้เงาแทนเส้นขอบ
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            market,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dateText,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

/// ปุ่มการ์ดจอง (รายวัน/รายเดือน) — ใช้ซ้ำได้ทั้งสองปุ่ม
class _BookingButton extends StatelessWidget {
  const _BookingButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandYellow,
      borderRadius: BorderRadius.circular(16),
      elevation: 3, // เงาของการ์ด
      shadowColor: Colors.black45,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(icon, size: 40, color: AppColors.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
