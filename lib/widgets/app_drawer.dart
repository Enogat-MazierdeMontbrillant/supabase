import 'package:flutter/material.dart';

import '../pages/carte_page.dart';
import '../pages/client_page.dart';
import '../pages/datagrid_page.dart';
import '../pages/login_page.dart';
import '../pages/picture_page.dart';
import '../pages/qrcode_page.dart';
import '../services/authentification_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Widget _item(
      BuildContext context, String label, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context); // ferme le drawer
        Navigator.pushNamed(context, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu',
                style: TextStyle(color: Colors.white, fontSize: 22)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mon Compte'),
            onTap: () => Navigator.pop(context),
          ),
          _item(context, 'Carte', Icons.map, CartePage.route),
          _item(context, 'Galerie', Icons.photo_library, PicturePage.route),
          _item(context, 'Photo', Icons.camera_alt, PicturePage.route),
          _item(context, 'Scanner', Icons.document_scanner, PicturePage.route),
          _item(context, 'Clients', Icons.people, ClientPage.route),
          _item(context, 'QrCode', Icons.qr_code_scanner, QrPage.route),
          _item(context, 'Datagrid', Icons.table_chart, DatagridPage.route),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () async {
              Navigator.pop(context);
              try {
                await AuthentificationService().logout();
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Déconnexion impossible : $error')),
                  );
                }
                return;
              }
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, LoginPage.route);
              }
            },
          ),
        ],
      ),
    );
  }
}
