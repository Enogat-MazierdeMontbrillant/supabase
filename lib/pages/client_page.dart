import 'package:flutter/material.dart';

import '../models/client.dart';
import '../services/client_service.dart';

class ClientPage extends StatefulWidget {
  static const route = '/clients';
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final ClientService _service = ClientService();
  late Future<List<Client>> _future = _service.getClients();

  Future<void> _refresh() async {
    setState(() => _future = _service.getClients(forceRefresh: true));
    await _future.catchError((Object _) => const <Client>[]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Liste des clients')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: FutureBuilder<List<Client>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'Impossible de charger les clients : ${snapshot.error}'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          setState(() => _future = _service.getClients()),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }
          final clients = snapshot.data ?? const <Client>[];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: clients.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('Aucun client disponible.')),
                    ],
                  )
                : ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return ListTile(
                        title: Text('${client.prenom} ${client.nom}'),
                        subtitle: Text(
                          '${client.email ?? ''}  ${client.telephone}\n'
                          '${client.adresse}',
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
