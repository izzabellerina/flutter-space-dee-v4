import 'dart:io';

class Configuration {
  static String server = 'https://v4.spacedee.co';

  static String https({required String service, required String path}) {
    return '$server/api/v1/$service/$path';
  }
}

class PortConfig {
  static const String authPort = 'auth';
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
