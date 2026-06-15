import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// ข้อมูล "รอบ" การจอง (mock) — ยังไม่มี backend
class _Round {
  const _Round({
    required this.number,
    required this.dateRange,
    required this.price,
    required this.status,
    required this.isOpen,
  });

  final int number; // รอบที่เท่าไหร่
  final String dateRange; // ช่วงเวลาจอง (2 บรรทัด)
  final String price; // ราคาต่อล็อค เช่น "฿50 - ฿100"
  final String status; // "กำลังเปิดจอง" / "ยังไม่ถึงเวลาจอง"
  final bool isOpen; // เปิดให้จองอยู่ไหม → ใช้เลือกสีสถานะ
}

// รอบจอง (mock) — ของจริงจะดึงจาก backend
const List<_Round> _rounds = [
  _Round(
    number: 1,
    dateRange: '15 กรกฎาคม 2569 14:00 -\n15 กรกฎาคม 2569 14:00',
    price: '฿50 - ฿100',
    status: 'กำลังเปิดจอง',
    isOpen: true,
  ),
  _Round(
    number: 2,
    dateRange: '15 กรกฎาคม 2569 14:00 -\n15 กรกฎาคม 2569 14:00',
    price: '฿60 - ฿100',
    status: 'กำลังเปิดจอง',
    isOpen: true,
  ),
  _Round(
    number: 3,
    dateRange: '15 กรกฎาคม 2569 14:00 -\n15 กรกฎาคม 2569 14:00',
    price: '฿50.-',
    status: 'ยังไม่ถึงเวลาจอง',
    isOpen: false,
  ),
];

/// เปิดหน้า "จองล็อคตลาด" เป็น **modal sheet เต็มจอ** (เลื่อนขึ้นจากด้านล่าง)
///
/// เรียกตอนกดการ์ดตลาดในหน้า "เลือกตลาด"
/// - `isScrollControlled: true` = ให้ sheet สูงเกินครึ่งจอได้ (เรากำหนดเองเต็มจอ)
/// - `useSafeArea: false` + ความสูงเต็มจอ = แผ่นขึ้นเต็ม 100% (ใช้ SafeArea ด้านในแทน)
/// - มุมบนมน + drag handle = สไตล์ modal sheet มาตรฐาน
/// ปิด sheet ได้โดยปัดลงหรือแตะพื้นที่นอก sheet
Future<void> showBookMarketSheet(
  BuildContext context, {
  required String name,
  required String location,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // useSafeArea: false = ให้แผ่นขึ้นได้เต็มจอ 100% (ถึงขอบบนสุด ใต้ status bar)
    // แล้วค่อยใช้ SafeArea ด้านในกันเนื้อหาทับ status bar/ปุ่มล่างเอง
    useSafeArea: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _BookMarketSheet(name: name, location: location),
  );
}

/// กฎของตลาด (mock) — ไอคอน + ข้อความ
class _MarketRule {
  const _MarketRule({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

// กฎ (mock) — ของจริงจะดึงจาก backend
const List<_MarketRule> _marketRules = [
  _MarketRule(icon: Icons.no_drinks, label: 'ห้ามของมึนเมา'),
  _MarketRule(icon: Icons.block, label: 'ห้ามของซ้ำ'),
];

/// 3 ขั้นของแผ่น: เลือกรอบจอง → กฎของตลาด → รายละเอียดการจอง
enum _SheetStep { booking, rules, details }

/// ตัวเลือกการใช้ไฟฟ้า (radio เลือกได้อย่างเดียว)
enum _Power { light, heavy }

/// ประเภทการขาย (ใช้ชุดเดียวกับหน้าลงทะเบียน register_screen.dart)
const List<String> _sellTypeOptions = ['เสื้อผ้า', 'อาหาร', 'Street food'];

/// เนื้อหาภายใน modal sheet — มี 3 ขั้น (booking / rules / details) ในแผ่นเดียว
///
/// ทำไม StatefulWidget?
/// - ต้องจำว่าตอนนี้อยู่ขั้นไหน (`_step`), ติ๊ก checkbox รับทราบหรือยัง (`_agreed`)
///   และค่าฟอร์ม (ประเภทขาย/จำนวน/รายละเอียด/ไฟฟ้า) — เปลี่ยนแล้วต้อง rebuild
class _BookMarketSheet extends StatefulWidget {
  const _BookMarketSheet({required this.name, required this.location});

  final String name;
  final String location;

  @override
  State<_BookMarketSheet> createState() => _BookMarketSheetState();
}

class _BookMarketSheetState extends State<_BookMarketSheet> {
  _SheetStep _step = _SheetStep.booking; // ขั้นปัจจุบัน
  bool _agreed = false; // ติ๊ก "รับทราบข้อตกลง" แล้วหรือยัง

  // ── ค่าฟอร์มขั้น details ──
  String _sellType = _sellTypeOptions.first; // ประเภทการขาย (dropdown)
  int _quantity = 1; // จำนวนล็อค (ขั้นต่ำ 1)
  _Power _power = _Power.light; // การใช้ไฟฟ้า (radio)
  // ช่องกรอก "รายละเอียด" ต้องมี controller เก็บข้อความ → ปล่อยใน dispose กัน leak
  final TextEditingController _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRules = _step == _SheetStep.rules;
    final isDetails = _step == _SheetStep.details;

    return SizedBox(
      // เต็มจอ 100% (สูงเท่าความสูงจอทั้งหมด)
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        // กันเนื้อหาทับ status bar (บน) และปุ่ม/แถบล่างของเครื่อง
        child: Column(
          children: [
            // ── drag handle (ขีดเทาด้านบนบอกว่าปัดลงปิดได้) ──
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // หัวข้อ sheet (เปลี่ยนตามขั้น)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _titleForStep(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // ── เนื้อหา (scroll) ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // header (รูป + การ์ดตลาด) แสดงเหมือนกันทุกขั้น
                    _buildHeader(),
                    const SizedBox(height: 16),
                    // เนื้อหาเฉพาะขั้น
                    if (isRules)
                      _buildRulesContent()
                    else if (isDetails)
                      _buildDetailsContent()
                    else
                      _buildRoundsContent(),
                  ],
                ),
              ),
            ),

            // ── แถบล่าง (ปุ่ม/checkbox) เปลี่ยนตามขั้น ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _buildBottomAction(isRules, isDetails),
            ),
          ],
        ),
      ),
    );
  }

  /// header ที่ใช้ร่วมกันทั้ง 2 ขั้น: รูปตลาด (placeholder) + การ์ดชื่อ/ที่ตั้ง
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // รูปตลาด (placeholder)
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.fieldFill, // กล่องเทา รอรูปจริง
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.storefront,
            size: 56,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),

        // การ์ดข้อมูลตลาด (ชื่อ + ที่ตั้ง)
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
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppColors.textDark,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.location,
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ขั้น booking: รายการรอบจอง (การ์ดแสดงข้อมูล กดไม่ได้)
  Widget _buildRoundsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final round in _rounds) ...[
          _RoundCard(round: round),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  /// ขั้น rules: หัวข้อ "กฎของตลาด" + แถวไอคอนกฎ
  Widget _buildRulesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'กฎของตลาด',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final rule in _marketRules) ...[
              _RuleItem(rule: rule),
              const SizedBox(width: 24),
            ],
          ],
        ),
      ],
    );
  }

  /// แถบล่างขั้น booking: ปุ่ม "จองล็อค" → ไปขั้น rules
  Widget _buildBookingAction() {
    return SizedBox(
      width: double.infinity, // ยืดปุ่มเต็มกว้าง (เหมือนปุ่ม "ยืนยัน")
      child: ElevatedButton(
        onPressed: () => setState(() => _step = _SheetStep.rules),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'จองล็อค',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  /// แถบล่างขั้น rules: checkbox รับทราบ + ปุ่ม "ยืนยัน"
  Widget _buildRulesActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // แถว checkbox — แตะข้อความก็ติ๊กได้
        InkWell(
          onTap: () => setState(() => _agreed = !_agreed),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
              ),
              const Text('รับทราบข้อตกลงของตลาด'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          // ปุ่มกดได้ต่อเมื่อติ๊ก checkbox แล้ว (onPressed=null → ปุ่ม disable เอง)
          child: ElevatedButton(
            onPressed: _agreed
                ? () => setState(() => _step = _SheetStep.details)
                : null,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'ยืนยัน',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// หัวข้อแผ่นตามขั้นปัจจุบัน
  String _titleForStep() {
    switch (_step) {
      case _SheetStep.booking:
        return 'จองล็อคตลาด';
      case _SheetStep.rules:
        return 'กฎของตลาด';
      case _SheetStep.details:
        return 'รายละเอียดการจอง';
    }
  }

  /// เลือกแถบล่างตามขั้น
  Widget _buildBottomAction(bool isRules, bool isDetails) {
    if (isDetails) return _buildNextAction();
    if (isRules) return _buildRulesActions();
    return _buildBookingAction();
  }

  /// ขั้น details: ฟอร์มรายละเอียดการจอง
  Widget _buildDetailsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // หมายเหตุของโครงการ
        Text(
          'โครงการนี้จัดล็อคแบบสุ่ม',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),

        // ── ประเภทการขาย (dropdown) ──
        const _FieldLabel('ประเภทการขาย'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _sellType,
          decoration: _fieldDecoration(),
          items: [
            for (final type in _sellTypeOptions)
              DropdownMenuItem(value: type, child: Text(type)),
          ],
          onChanged: (value) => setState(() => _sellType = value ?? _sellType),
        ),
        const SizedBox(height: 16),

        // ── จำนวนล็อค (stepper) + ขนาด/ราคา ──
        Row(
          children: [
            // ปุ่ม − ปิดเมื่อจำนวน = 1 (กันติดลบ)
            IconButton(
              onPressed: _quantity > 1
                  ? () => setState(() => _quantity--)
                  : null,
              icon: const Icon(Icons.remove_circle),
              color: Colors.green,
              iconSize: 32,
            ),
            Text(
              '$_quantity',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _quantity++),
              icon: const Icon(Icons.add_circle),
              color: Colors.green,
              iconSize: 32,
            ),
            const Spacer(),
            // ขนาด/ราคา (mock)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text('1X4 ตรม', style: TextStyle(color: AppColors.textDark)),
                Text(
                  '฿50/ล็อค',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── รายละเอียด (text) ──
        const _FieldLabel('*รายละเอียด'),
        const SizedBox(height: 6),
        TextField(
          controller: _detailsController,
          decoration: _fieldDecoration(hint: 'รายละเอียดสินค้า'),
        ),
        const SizedBox(height: 16),

        // ── การใช้ไฟฟ้า (radio เลือกอย่างเดียว) ──
        const _FieldLabel('*การใช้ไฟฟ้า'),
        // RadioGroup = ตัวจัดการค่าที่เลือกของกลุ่ม radio (API ใหม่แทน groupValue เดิม)
        RadioGroup<_Power>(
          groupValue: _power,
          onChanged: (v) => setState(() => _power = v ?? _power),
          child: Column(
            children: [
              _PowerRadioTile(
                label: 'ใช้ไฟเบา',
                price: '฿0',
                value: _Power.light,
                onTap: () => setState(() => _power = _Power.light),
              ),
              _PowerRadioTile(
                label: 'ใช้ไฟหนัก',
                price: '฿50',
                value: _Power.heavy,
                onTap: () => setState(() => _power = _Power.heavy),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// แถบล่างขั้น details: ปุ่ม "ถัดไป"
  Widget _buildNextAction() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showSnack('กำลังพัฒนา flow ถัดไป'),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'ถัดไป',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  /// กล่องตกแต่งช่องกรอก (พื้นเทาตามธีม ไม่มีเส้นขอบ)
  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// การ์ดแสดงข้อมูลรอบจอง — **กดไม่ได้** (เป็นแค่ข้อมูล)
///
/// ใช้ Container เฉย ๆ (ไม่ใช่ Material+InkWell) → ไม่มี ripple ไม่ตอบสนองการกด
class _RoundCard extends StatelessWidget {
  const _RoundCard({required this.round});
  final _Round round;

  @override
  Widget build(BuildContext context) {
    // สถานะ: เปิดจอง = เขียว, ยังไม่ถึงเวลา = เทา
    final statusColor = round.isOpen ? Colors.green[700] : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandYellow, // เหลืองตามกฎธีม
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // หัวการ์ด: ไอคอน + "รอบที่ N" (ซ้าย) ... สถานะ (ขวา)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                round.isOpen ? Icons.event_available : Icons.lock_clock,
                size: 20,
                color: AppColors.textDark,
              ),
              const SizedBox(width: 6),
              Text(
                'รอบที่ ${round.number}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                round.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ช่วงเวลาจอง
          _InfoRow(label: 'ช่วงเวลาจอง', value: round.dateRange),
          const SizedBox(height: 8),

          // ราคาต่อล็อค
          _InfoRow(label: 'ราคาต่อล็อค', value: round.price, valueBold: true),
        ],
      ),
    );
  }
}

/// ไอคอนกฎของตลาด — วงกลมขอบแดง + ไอคอนแดง + ข้อความใต้ไอคอน
class _RuleItem extends StatelessWidget {
  const _RuleItem({required this.rule});
  final _MarketRule rule;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Icon(rule.icon, color: Colors.red, size: 32),
        ),
        const SizedBox(height: 6),
        Text(
          rule.label,
          style: const TextStyle(fontSize: 12, color: AppColors.textDark),
        ),
      ],
    );
  }
}

/// label ของช่องกรอก (ตัวหนาเล็ก ๆ เหนือ field)
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }
}

/// แถว radio เลือกการใช้ไฟฟ้า: ปุ่ม radio + ชื่อ (ซ้าย) + ราคา (ขวา)
///
/// ค่า groupValue/การเปลี่ยนค่า จัดการโดย `RadioGroup` ที่ครอบอยู่ด้านนอก
/// (Radio รับแค่ `value` ของตัวเอง); `onTap` ให้แตะทั้งแถวแล้วเลือกได้
class _PowerRadioTile extends StatelessWidget {
  const _PowerRadioTile({
    required this.label,
    required this.price,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String price;
  final _Power value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Radio<_Power>(value: value),
          Expanded(child: Text(label)),
          Text(price, style: const TextStyle(color: AppColors.textDark)),
        ],
      ),
    );
  }
}

/// แถวข้อมูล: label (ซ้าย) + value (ขวา ชิดขวา)
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  final String label;
  final String value;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              fontWeight: valueBold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
