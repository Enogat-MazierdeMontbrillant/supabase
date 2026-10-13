import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/carte_page.dart';
import 'pages/client_page.dart';
import 'pages/datagrid_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/picture_page.dart';
import 'pages/qrcode_page.dart';
import 'pages/splash_page.dart';
import 'services/app_config.dart';
import 'storage/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isSupabaseConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.effectiveSupabaseKey,
    );
  }

  await DatabaseHelper.instance.init();

  runApp(MyApp(supabaseConfigured: AppConfig.isSupabaseConfigured));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.supabaseConfigured = false});

  final bool supabaseConfigured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase',
      debugShowCheckedModeBanner: false,
      initialRoute: supabaseConfigured &&
              Supabase.instance.client.auth.currentSession != null
          ? SplashPage.route
          : LoginPage.route,
      routes: {
        LoginPage.route: (context) =>
            LoginPage(supabaseConfigured: supabaseConfigured),
        SplashPage.route: (context) => const SplashPage(),
        HomePage.route: (context) => const HomePage(),
        CartePage.route: (context) => const CartePage(),
        PicturePage.route: (context) => const PicturePage(),
        ClientPage.route: (context) => const ClientPage(),
        QrPage.route: (context) => const QrPage(),
        DatagridPage.route: (context) => const DatagridPage(),
      },
    );
  }
}
