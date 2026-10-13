import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/client.dart';
import '../storage/database_helper.dart';

/// Récupère les clients sur Supabase (jointure adresse) et les met en cache Hive.
class ClientService {
  final Logger logger = Logger();
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Télécharge depuis Supabase et met à jour le cache local.
  Future<List<Client>> syncFromSupabase() async {
    final data = await Supabase.instance.client.from('client').select(
          'id,nom,prenom,tel,email,adresse(rue,codepostal,ville)',
        );

    final clients = data.map(Client.fromJson).toList();

    await _db.replaceClients(clients);
    logger.i('nb clients en cache : ${await _db.getNbClients()}');
    return clients;
  }

  /// Cache d'abord ; si vide ou pas de réseau, on tente Supabase.
  Future<List<Client>> getClients({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final local = await _db.getClients();
      if (local.isNotEmpty) return local;
    }
    try {
      return await syncFromSupabase();
    } catch (error, stackTrace) {
      logger.e('Échec de synchronisation Supabase.',
          error: error, stackTrace: stackTrace);
      final cached = await _db.getClients();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }
}
