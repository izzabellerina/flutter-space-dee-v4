import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// หน้า "สรุปรายการจอง" — เปิดเป็นหน้าใหม่เมื่อกด "ถัดไป" ในขั้นรายละเอียด
///
/// ทำไม StatelessWidget?
/// - แค่ "แสดงสรุป" จากค่าที่ส่งมา ไม่มี state ที่เปลี่ยนระหว่างใช้งาน
class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key, this.summary});

  /// ค่าฟอร์มที่ส่งมาทาง extra: market, sellType, quantity, details, heavyPower
  final Map<String, dynamic>? summary;

  // ราคาต่อล็อค (mock) — ของจริงจะมาจาก backend
  static const int _pricePerLot = 50;
  static const int _heavyPowerPrice = 50;

  @override
  Widget build(BuildContext context) {
    final market = summary?['market'] as String? ?? 'ตลาด';
    final sellType = summary?['sellType'] as String? ?? '';
    final quantity = summary?['quantity'] as int? ?? 1;
    final details = summary?['details'] as String? ?? '';
    final heavyPower = summary?['heavyPower'] as bool? ?? false;

    // คำนวณยอดรวม (mock): ราคาต่อล็อค × จำนวน + ค่าไฟหนัก (ถ้าเลือก)
    final lotTotal = _pricePerLot * quantity;
    final total = lotTotal + (heavyPower ? _heavyPowerPrice : 0);

    return Scaffold(
      appBar: AppBar(title: const Text('สรุปรายการจอง'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            // ── เนื้อหา (scroll) ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่อตลาด + วันที่
                    Text(
                      market,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ศุกร์ 27 ธันวาคม 2569', // วันที่ mock
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),

                    // รายการสินค้า/บริการ
                    _SummaryLine(
                      label: sellType.isEmpty ? 'สินค้า' : sellType,
                      subtitle: details.isEmpty ? null : details,
                      trailing: '$quantity/฿$_pricePerLot',
                    ),
                    if (heavyPower) ...[
                      const SizedBox(height: 12),
                      const _SummaryLine(
                        label: 'ค่าไฟหนัก',
                        trailing: '฿$_heavyPowerPrice',
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── รวม + ปุ่มยืนยัน (ติดล่าง) ──
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'รวม',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '฿$total.-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _showSnack(context, 'กำลังพัฒนา flow ถัดไป'),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'ยืนยันการจองล็อค',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// บรรทัดสรุป 1 รายการ: ● label (+ subtitle) ... ราคา (ขวา)
class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.trailing,
    this.subtitle,
  });

  final String label;
  final String trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4, right: 8),
          child: Icon(Icons.circle, size: 8, color: AppColors.textDark),
        ),
        // ชื่อ + รายละเอียดย่อย
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 15, color: AppColors.textDark),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        // ราคา/จำนวน
        Text(
          trailing,
          style: const TextStyle(fontSize: 15, color: AppColors.textDark),
        ),
      ],
    );
  }
}
