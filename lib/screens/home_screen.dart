import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'booking_list_tab.dart';
import 'home_tab.dart';
import 'more_tab.dart';

/// หน้าหลักหลัง login/ลงทะเบียน — มี bottom navigation 4 แท็บ
///
/// ใช้ IndexedStack = เก็บ state ของทุกแท็บไว้ (สลับไปมาแล้วไม่รีเซ็ต)
/// แสดงทีละแท็บตาม index ที่เลือก
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0; // แท็บที่กำลังเปิด

  // 4 แท็บ — ตอนนี้มีแค่ "หน้าหลัก" ที่ทำจริง อีก 3 เป็น placeholder
  static const List<Widget> _tabs = [
    HomeTab(),
    BookingListTab(),
    _PlaceholderTab(label: 'ประวัติ'),
    MoreTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: AppColors.brandYellow, // pill เหลืองหลังไอคอนที่เลือก
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'การจอง',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'ประวัติ'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'อื่น ๆ'),
        ],
      ),
    );
  }
}

/// แท็บที่ยังไม่ทำ — แสดงข้อความ "กำลังพัฒนา"
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.construction, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text('กำลังพัฒนา', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
