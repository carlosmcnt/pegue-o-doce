import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class LocalEntrega {
  final String nome;
  final LatLng coordenadas;

  LocalEntrega({required this.nome, required this.coordenadas});

  factory LocalEntrega.fromMap(Map<String, dynamic> data) {
    final GeoPoint geo = data['coordenadas'] as GeoPoint;

    return LocalEntrega(
      nome: data['nome'] ?? '',
      coordenadas: LatLng(geo.latitude, geo.longitude),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'coordenadas': GeoPoint(
        coordenadas.latitude,
        coordenadas.longitude,
      ),
    };
  }
}
