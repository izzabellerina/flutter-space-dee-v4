import 'package:go_router/go_router.dart';

import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
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
  ],
);
