import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.email});
  static const route = '/home';
  final String? email;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _email;

  @override
  void initState() {
    super.initState();
    _email = widget.email;
    // Si on arrive via la route nommée (retour depuis une autre page),
    // on récupère l'email sérialisé dans shared_preferences.
    if (_email == null) {
      SharedPreferences.getInstance().then((p) {
        if (mounted) setState(() => _email = p.getString('email'));
      });
    }
  }

  Future<bool> checkInternet() async {
    try {
      return await InternetConnectionChecker.instance.hasConnection;
    } catch (_) {
      return false;
    }
  }

  Future<void> _launch(String url, {bool needInternet = false}) async {
    if (needInternet && !await checkInternet()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Probleme de connexion Internet.')),
      );
      return;
    }
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible d'ouvrir $url")),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible d'ouvrir $url : $error")),
        );
      }
    }
  }

  Widget _tile(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text('Accueil - Bienvenue ${_email ?? ''}',
            style: const TextStyle(fontSize: 16)),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _tile(Icons.public, 'Lequipe', 'https://lequipe.fr',
              () => _launch('https://lequipe.fr', needInternet: true)),
          _tile(
              Icons.calendar_month,
              'Agenda',
              'content://com.android.calendar/time/',
              () => _launch('content://com.android.calendar/time/')),
          _tile(
              Icons.email,
              'Email',
              'mailto:contact@greta.fr',
              () => _launch('mailto:contact@greta.fr?subject=Contact',
                  needInternet: true)),
          _tile(Icons.phone, 'Telephone', 'tel:0512345534',
              () => _launch('tel:0512345534')),
          _tile(Icons.sms, 'SMS', 'sms:0550101234',
              () => _launch('sms:0550101234')),
        ],
      ),
    );
  }
}
