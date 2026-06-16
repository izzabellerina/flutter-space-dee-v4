import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/booking_summary_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/register_screen.dart';
import '../screens/select_market_screen.dart';
import '../screens/splash_screen.dart';

/// ── ระบบนำทางด้วย go_router ──
///
/// รวม "เส้นทาง (route)" ทั้งแอปไว้ที่เดียว — แต่ละหน้ามี path ของตัวเอง
/// การย้ายหน้าใช้:
///   context.go('/login')   = ไปหน้านั้นแล้วล้าง stack (เช่น splash → login)
///   context.push('/register') = ซ้อนหน้าใหม่ (กด back กลับได้)
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/payment',
      // ชื่อตลาดถูกส่งมาผ่าน extra (กดมาจากการ์ดการจอง)
      builder: (context, state) => PaymentScreen(market: state.extra as String?),
    ),
    GoRoute(
      path: '/select-market',
      // เปิดเมื่อกดปุ่ม "จองรายวัน" ในหน้า Home
      builder: (context, state) => const SelectMarketScreen(),
    ),
    GoRoute(
      path: '/booking-summary',
      // เปิดเมื่อกด "ถัดไป" ในขั้นรายละเอียด (ค่าฟอร์มส่งมาผ่าน extra)
      builder: (context, state) =>
          BookingSummaryScreen(summary: state.extra as Map<String, dynamic>?),
    ),
  ],
);
