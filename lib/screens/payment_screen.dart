import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../theme/app_colors.dart';

/// หน้าจ่ายเงิน — เข้ามาตอน user กดการ์ดจากหน้า "รายการการจอง"
///
/// ทำไมต้องเป็น StatefulWidget?
/// - มี "ตัวนับเวลาถอยหลัง" ที่ต้องอัปเดตทุกวินาที → ต้องเก็บ state (เวลาที่เหลือ)
///   และมี Timer ที่ต้องสร้างตอนเปิดหน้า + ยกเลิกตอนปิดหน้า (กัน memory leak)
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, this.market});

  /// ชื่อตลาดที่ส่งมาทาง extra (กดมาจากการ์ดการจอง) — อาจเป็น null ถ้าเข้าตรง ๆ
  final String? market;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // เวลาที่ให้สแกนจ่าย: เริ่มต้น 3 ชั่วโมง แล้วนับถอยหลัง
  static const Duration _initialDuration = Duration(hours: 3);
  Duration _remaining = _initialDuration;

  // Timer ที่ยิงทุก 1 วินาที — เก็บไว้เพื่อยกเลิกตอน dispose
  Timer? _timer;

  // กันกดปุ่ม "โหลด QR" รัว ๆ ระหว่างกำลังเซฟอยู่
  bool _saving = false;

  // ข้อความที่ฝังใน QR (mock) — ของจริงจะเป็น payload จาก backend/ระบบจ่ายเงิน
  static const String _qrData = 'spacedee://payment/mock-booking-0001';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    // สำคัญ: ต้องยกเลิก Timer ตอนปิดหน้า ไม่งั้นมันจะยิงต่อไปเรื่อย ๆ
    // แล้วไป setState บน widget ที่ถูกทำลายแล้ว → error / memory leak
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 0) {
        timer.cancel(); // หมดเวลาแล้ว หยุดนับ
        return;
      }
      // ลดเวลาที่เหลือทีละ 1 วินาที แล้ว setState ให้ UI วาดใหม่
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  /// แปลง Duration → "H:MM:SS" (เช่น 2:59:59)
  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// บันทึก QR ลงแกลเลอรีจริง (package gal)
  ///
  /// ขั้นตอน:
  /// 1. เรนเดอร์ QR เป็นรูป PNG (bytes) ด้วย QrPainter.toImageData()
  /// 2. ขอสิทธิ์เข้าถึงแกลเลอรี (gal จัดการ dialog ให้)
  /// 3. เซฟ bytes ลงแกลเลอรี
  Future<void> _downloadQr() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      // 1. เรนเดอร์ QR เป็น PNG ขนาด 512px (พร้อมพื้นหลังขาว)
      final bytes = await _renderQrWithWhiteBackground(512);

      // 2. ขอสิทธิ์ (ถ้ายังไม่ได้รับ)
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      // 3. เซฟลงแกลเลอรี (ไม่ต้องใส่นามสกุลไฟล์)
      await Gal.putImageBytes(bytes, name: 'spacedee_qr');

      if (!mounted) return;
      _showSnack('บันทึก QR ลงแกลเลอรีแล้ว');
    } on GalException catch (e) {
      // error เฉพาะของ gal (เช่น ไม่ได้รับสิทธิ์)
      if (!mounted) return;
      _showSnack('บันทึกไม่สำเร็จ: ${e.type.message}');
    } catch (e) {
      if (!mounted) return;
      _showSnack('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// เรนเดอร์ QR เป็น PNG bytes พร้อม "พื้นหลังขาว"
  ///
  /// ทำไมต้องวาดเอง? `QrPainter.toImageData()` วาด QR บนพื้น "โปร่งใส"
  /// พอเซฟเป็น PNG แล้วเปิดในแกลเลอรี (พื้นหลังมักเป็นสีดำ) จะมองไม่เห็น QR
  /// → เราเลยสร้าง Canvas เอง: วาดสี่เหลี่ยมขาวก่อน แล้ววาด QR ทับ
  Future<Uint8List> _renderQrWithWhiteBackground(double size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 1. วาดพื้นหลังขาวเต็มพื้นที่
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size, size),
      Paint()..color = Colors.white,
    );

    // 2. วาด QR ทับลงไป
    final painter = QrPainter(
      data: _qrData,
      version: QrVersions.auto,
      gapless: true,
    );
    painter.paint(canvas, Size(size, size));

    // 3. แปลง Canvas → รูป → PNG bytes
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('เรนเดอร์ QR ไม่สำเร็จ');
    }
    return byteData.buffer.asUint8List();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// กด "ยืนยันการจ่ายเงิน" — ตอนนี้เป็น mock (ยังไม่มี backend จ่ายเงินจริง)
  Future<void> _confirmPayment() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('ชำระเงินสำเร็จ'),
        content: const Text('ระบบได้รับการชำระเงินของคุณแล้ว'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
    // ปิด dialog แล้วกลับไปหน้ารายการการจอง
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _remaining.inSeconds <= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('จ่ายเงิน'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── QR สำหรับสแกนจ่าย ──
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: QrImageView(
                    data: _qrData,
                    size: 220,
                    gapless: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── ปุ่มดาวน์โหลด QR ──
              Center(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _downloadQr,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(_saving ? 'กำลังบันทึก...' : 'โหลด Qr Code'),
                ),
              ),
              const SizedBox(height: 20),

              // ── ตัวนับเวลาถอยหลัง ──
              Center(
                child: Text(
                  isExpired
                      ? 'หมดเวลาชำระเงินแล้ว'
                      : 'ภายใน ${_formatDuration(_remaining)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isExpired ? Colors.red : AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── สรุปรายการ ──
              _SummaryBox(market: widget.market ?? 'ตลาด'),
              const SizedBox(height: 24),

              // ── ปุ่มยืนยันการจ่ายเงิน ──
              ElevatedButton(
                onPressed: isExpired ? null : _confirmPayment,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'ยืนยันการจ่ายเงิน',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// กล่องสรุปรายการที่ต้องจ่าย — ชื่อตลาด + รายการ (mock) + ยอดรวม
class _SummaryBox extends StatelessWidget {
  const _SummaryBox({required this.market});
  final String market;

  // รายการสินค้า/ค่าเช่า (mock) — ของจริงจะมาจากการจอง
  static const List<({String label, int price})> _items = [
    (label: 'ค่าเช่าแผง 1 วัน', price: 300),
    (label: 'ค่าบริการ', price: 50),
  ];

  @override
  Widget build(BuildContext context) {
    final total = _items.fold<int>(0, (sum, item) => sum + item.price);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ชื่อตลาด (มีจุดนำหน้า ● ตามดีไซน์)
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: AppColors.brandYellow),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  market,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // รายการแต่ละบรรทัด
          for (final item in _items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.label),
                  Text('${item.price} บาท'),
                ],
              ),
            ),
          const Divider(height: 24),

          // ยอดรวม
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'รวม',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '$total บาท',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
