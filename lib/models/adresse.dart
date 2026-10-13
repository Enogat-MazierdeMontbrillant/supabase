import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class Adresse {
  @HiveField(0)
  String rue;
  @HiveField(1)
  String codePostal;
  @HiveField(2)
  String ville;

  Adresse({required this.rue, required this.codePostal, required this.ville});

  factory Adresse.fromJson(Map<String, dynamic> json) {
    return Adresse(
      rue: json['rue'] as String,
      // codepostal est un int8 dans Supabase -> on le convertit en String
      codePostal: json['codepostal'].toString(),
      ville: json['ville'] as String,
    );
  }

  @override
  String toString() => '$rue $codePostal $ville';
}

/// Adapter Hive (équivalent de adresse.g.dart généré par build_runner)
class AdresseAdapter extends TypeAdapter<Adresse> {
  @override
  final int typeId = 2;

  @override
  Adresse read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return Adresse(
      rue: f[0] as String,
      codePostal: f[1] as String,
      ville: f[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Adresse obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.rue)
      ..writeByte(1)
      ..write(obj.codePostal)
      ..writeByte(2)
      ..write(obj.ville);
  }
}
