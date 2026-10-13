import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../models/adresse.dart';
import '../models/client.dart';

/// Tampon entre les modèles et la base Hive (CRUD).
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  final Logger logger = Logger();
  Box<Client>? _box;

  /// À appeler une seule fois dans main().
  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ClientAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(AdresseAdapter());
    _box = await Hive.openBox<Client>('clients');
  }

  Box<Client> get _clientBox => _box!;

  /// Insère ou met à jour un client (put = upsert sur la clé id).
  Future<void> insertClient(Client client) async =>
      _clientBox.put(client.id, client);

  Future<void> replaceClients(List<Client> clients) async {
    await _clientBox.clear();
    await _clientBox.putAll({
      for (final client in clients) client.id: client,
    });
  }

  Future<void> updateClient(Client client) async =>
      _clientBox.put(client.id, client);

  Future<List<Client>> getClients() async => _clientBox.values.toList();

  Future<Client?> getClient(int id) async => _clientBox.get(id);

  Future<int> getNbClients() async => _clientBox.length;

  Future<void> clearClients() async => _clientBox.clear();

  Future<void> close() async => _clientBox.close();

  Future<void> deleteAllHive() async => Hive.deleteFromDisk();
}
