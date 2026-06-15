import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

/// สถานะการจองที่ "พร้อมให้จ่ายเงิน" — มีสถานะนี้เท่านั้นถึงกดเข้าหน้าจ่ายเงินได้
const String kStatusPendingPayment = 'รอการจ่ายเงิน';

/// ข้อมูลการจอง (mock) — ยังไม่มี backend
class _Booking {
  const _Booking({
    required this.market,
    required this.status,
    required this.dateText,
  });

  final String market;
  final String status; // เช่น "รอการยืนยัน", "รอการจ่ายเงิน"
  final String dateText;

  /// จ่ายเงินได้ก็ต่อเมื่อสถานะเป็น "รอการจ่ายเงิน"
  /// ("รอการยืนยัน" = ยังรอผู้ดูแลยืนยัน ยังจ่ายไม่ได้)
  bool get canPay => status == kStatusPendingPayment;
}

// mock 2 ชุด: รายวัน / รายเดือน
const List<_Booking> _dailyBookings = [
  _Booking(
    market: 'ตลาดโกโก้',
    status: 'รอการยืนยัน',
    dateText: 'จองไว้  พุธ 27 กรกฎาคม 2569',
  ),
  _Booking(
    market: 'ตลาดโกโก้',
    status: 'รอการจ่ายเงิน',
    dateText: 'จองไว้  พุธ 27 กรกฎาคม 2569',
  ),
];

const List<_Booking> _monthlyBookings = [
  _Booking(
    market: 'ตลาดนัดสวนจตุจักร',
    status: 'รอการยืนยัน',
    dateText: 'จองไว้  กรกฎาคม 2569',
  ),
];

/// แท็บ "การจอง" — หน้า "รายการการจอง" มี 2 sub-tab (จองรายวัน / จองรายเดือน)
class BookingListTab extends StatelessWidget {
  const BookingListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'รายการการจอง',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              const TabBar(
                labelColor: AppColors.textDark,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.brandYellow,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'จองรายวัน'),
                  Tab(text: 'จองรายเดือน'),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    _BookingList(bookings: _dailyBookings),
                    _BookingList(bookings: _monthlyBookings),
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

/// list การ์ดการจองของแต่ละ sub-tab
class _BookingList extends StatelessWidget {
  const _BookingList({required this.bookings});
  final List<_Booking> bookings;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(child: Text('ยังไม่มีรายการจอง'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _BookingCard(booking: bookings[i]),
    );
  }
}

/// การ์ดการจอง — กดแล้วไปหน้าจ่ายเงิน
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final _Booking booking;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 3, // เงาของการ์ด
      shadowColor: Colors.black45,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // กดการ์ด:
        // - ถ้าสถานะ "รอการจ่ายเงิน" → ไปหน้าจ่ายเงิน (ส่งชื่อตลาดผ่าน extra)
        // - ถ้ายัง "รอการยืนยัน" → เด้ง snackbar บอกว่ายังจ่ายไม่ได้
        onTap: () {
          if (booking.canPay) {
            context.push('/payment', extra: booking.market);
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('รอผู้ดูแลยืนยันก่อนจึงจะชำระเงินได้'),
                ),
              );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      booking.market,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(
                    booking.status,
                    style: TextStyle(
                      fontSize: 13,
                      // "รอการจ่ายเงิน" = ส้ม (กดได้/ต้องจัดการ),
                      // "รอการยืนยัน" = เทา (ยังกดจ่ายไม่ได้)
                      color: booking.canPay ? Colors.orange[800] : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                booking.dateText,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
