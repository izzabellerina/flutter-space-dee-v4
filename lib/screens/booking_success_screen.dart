import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

/// หน้า "การจองสำเร็จ" — เปิดเมื่อกด "ยืนยันการจองล็อค" ในหน้าสรุป
///
/// เป็นหน้าจบ flow (terminal) → ไม่มีปุ่ม back, มีแค่ "กลับสู่หน้าหลัก"
///
/// ทำไม StatelessWidget?
/// - แค่แสดงผลสำเร็จ ไม่มี state ที่เปลี่ยนระหว่างใช้งาน
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, this.result});

  /// ค่าที่ส่งมาทาง extra: market, quantity
  final Map<String, dynamic>? result;

  // หมายเลขจอง (mock) — ของจริงจะมาจาก backend
  static const String _bookingNo = 'A0000001';

  @override
  Widget build(BuildContext context) {
    final market = result?['market'] as String? ?? 'ตลาด';
    final quantity = result?['quantity'] as int? ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('การจองสำเร็จ'),
        centerTitle: true,
        automaticallyImplyLeading: false, // ไม่มีปุ่ม back (เป็นหน้าจบ flow)
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── เนื้อหา (scroll) ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    // ตราสำเร็จ
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 72,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'YES',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'หมายเลขจอง $_bookingNo',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // การ์ดสรุปการจอง
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ชื่อตลาด
                          Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 10,
                                color: AppColors.textDark,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  market,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // วันที่ + จำนวนล็อค (mock 2 บรรทัด)
                          _DateLotRow(
                            date: 'ศุกร์ 27 ธันวาคม 2569',
                            lots: quantity,
                          ),
                          const SizedBox(height: 6),
                          _DateLotRow(
                            date: 'พุธ 27 ธันวาคม 2569',
                            lots: quantity,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // หมายเหตุ
                    Text(
                      'ระบบจะแจ้งผลการพิจารณาการจองของคุณอีกครั้ง '
                      'เมื่อยืนยันแล้วจะมีข้อความแจ้งเตือน แล้วค่อยชำระเงิน',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            // ── ปุ่มกลับหน้าหลัก (ติดล่าง) ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'กลับสู่หน้าหลัก',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// แถววันที่ + จำนวนล็อค (ขวา)
class _DateLotRow extends StatelessWidget {
  const _DateLotRow({required this.date, required this.lots});
  final String date;
  final int lots;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(date, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        Text(
          '$lots ล็อค',
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
        ),
      ],
    );
  }
}
