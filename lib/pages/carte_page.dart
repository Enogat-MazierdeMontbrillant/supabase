import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class CartePage extends StatefulWidget {
  const CartePage({super.key});
  static const route = '/carte';

  @override
  State<CartePage> createState() => _MapOsmState();
}

class _MapOsmState extends State<CartePage> {
  // Greta GBS
  static final LatLng _greta = LatLng(47.64816378970705, -2.775053361868542);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Center(child: Text('Cartographie')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: _greta, initialZoom: 15),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _greta,
                width: 40,
                height: 40,
                child:
                    const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                '© OpenStreetMap contributors',
                onTap: () => launchUrl(
                  Uri.parse('https://www.openstreetmap.org/copyright'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
