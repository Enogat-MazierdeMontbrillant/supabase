import 'package:hive/hive.dart';
import 'adresse.dart';

@HiveType(typeId: 1)
class Client {
  @HiveField(0)
  int id;
  @HiveField(1)
  String prenom;
  @HiveField(2)
  String nom;
  @HiveField(3)
  String? email;
  @HiveField(4)
  String telephone;
  @HiveField(5)
  Adresse adresse;

  Client({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.telephone,
    required this.adresse,
    this.email,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['tel'],
      adresse: Adresse.fromJson(json['adresse']),
    );
  }

  @override
  String toString() =>
      'Client{id: $id, prenom: $prenom, nom: $nom, email: $email, telephone: $telephone, adresse: $adresse}';
}

/// Adapter Hive (équivalent de client.g.dart généré par build_runner)
class ClientAdapter extends TypeAdapter<Client> {
  @override
  final int typeId = 1;

  @override
  Client read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return Client(
      id: f[0] as int,
      prenom: f[1] as String,
      nom: f[2] as String,
      email: f[3] as String?,
      telephone: f[4] as String,
      adresse: f[5] as Adresse,
    );
  }

  @override
  void write(BinaryWriter writer, Client obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.prenom)
      ..writeByte(2)
      ..write(obj.nom)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.telephone)
      ..writeByte(5)
      ..write(obj.adresse);
  }
}
