import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// ข้อมูลตลาด (mock) — ยังไม่มี backend
class _Market {
  const _Market({required this.name, required this.location});

  final String name;
  final String location; // ที่ตั้ง เช่น "ตู้บอน 27 แยก 10"
}

// รายการตลาด (mock) — ของจริงจะดึงจาก backend
const List<_Market> _markets = [
  _Market(name: 'ตลาดโกโก้', location: 'ตู้บอน 27 แยก 10'),
  _Market(name: 'ตลาดยิ่งเจริญ', location: 'ตู้บอน 27 แยก 10'),
  _Market(name: 'ตลาดนัดสวนจตุจักร', location: 'จตุจักร กรุงเทพฯ'),
  _Market(name: 'ตลาดน้ำอัมพวา', location: 'อัมพวา สมุทรสงคราม'),
];

/// หน้า "เลือกตลาด" — เปิดเมื่อกดปุ่ม "จองรายวัน" จากหน้า Home
///
/// ทำไมต้องเป็น StatefulWidget?
/// - มี "ช่องค้นหา" ที่พอพิมพ์แล้วต้องกรองรายการใหม่ → คำค้นหาเป็น state
///   ที่เปลี่ยนแล้วต้อง rebuild list ตาม
class SelectMarketScreen extends StatefulWidget {
  const SelectMarketScreen({super.key});

  @override
  State<SelectMarketScreen> createState() => _SelectMarketScreenState();
}

class _SelectMarketScreenState extends State<SelectMarketScreen> {
  // คำค้นหาปัจจุบัน — พิมพ์แล้วใช้กรอง list
  String _query = '';

  @override
  Widget build(BuildContext context) {
    // กรองตามชื่อตลาด (ไม่สนตัวพิมพ์เล็ก/ใหญ่) — ตอน query ว่างได้ทั้งหมด
    final filtered = _markets
        .where((m) => m.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกตลาด'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── แถวค้นหา: ช่องพิมพ์ + ปุ่มตัวกรอง ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      // พิมพ์แล้วเก็บคำค้นหา → setState ให้กรอง list ใหม่
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'ค้นหาตลาด',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.fieldFill, // พื้นเทาตามธีม
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none, // ไม่มีเส้นขอบ ใช้พื้นเทาแทน
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ปุ่มตัวกรอง (ยังไม่ทำ flow จริง)
                  IconButton.filledTonal(
                    onPressed: () => _showSnack('ตัวกรองกำลังพัฒนา'),
                    icon: const Icon(Icons.filter_list),
                  ),
                ],
              ),
            ),

            // ── รายการตลาด (กรองตามคำค้นหา) ──
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('ไม่พบตลาดที่ค้นหา'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _MarketCard(
                        market: filtered[i],
                        onTap: () => _showSnack('กำลังพัฒนา flow ถัดไป'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// การ์ดตลาด — รูป (placeholder) + ชื่อ + ที่ตั้ง
/// สไตล์เดียวกับการ์ด/ปุ่มอื่นในแอป (Material + InkWell + เงา, พื้นเหลืองตามธีม)
class _MarketCard extends StatelessWidget {
  const _MarketCard({required this.market, required this.onTap});

  final _Market market;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandYellow, // เหลืองตามกฎธีม
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      shadowColor: Colors.black45,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // รูปตลาด = placeholder (รอรูปจริงจาก backend/asset)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.fieldFill, // กล่องเทา
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: AppColors.textDark,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              // ชื่อ + ที่ตั้ง
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      market.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textDark,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            market.location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
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
      ),
    );
  }
}
