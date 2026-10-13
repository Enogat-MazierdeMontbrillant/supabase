import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/client_service.dart';
import 'home_page.dart';

/// Écran de chargement : met en cache les clients Supabase dans Hive.
class SplashPage extends StatefulWidget {
  static const route = '/splash';
  final String? email;
  const SplashPage({super.key, this.email});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadAndGo();
  }

  Future<void> _loadAndGo() async {
    try {
      // Chargement en cache + durée minimale d'affichage de 2 s
      await Future.wait([
        ClientService().syncFromSupabase(),
        Future.delayed(const Duration(seconds: 2)),
      ]);
    } catch (e) {
      logger.e('Chargement du cache impossible : $e');
    }
    final email = widget.email ??
        (await SharedPreferences.getInstance()).getString('email');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(email: email)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _controller,
              child: const Icon(Icons.cloud_download,
                  size: 90, color: Colors.blue),
            ),
            const SizedBox(height: 24),
            const Text('Chargement des données...'),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
