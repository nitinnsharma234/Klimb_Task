import 'package:sqflite/sqflite.dart';

class LocationModel {
  final String id;
  final double latitude;
  final double longitude;

  LocationModel({required this.id, required this.latitude, required this.longitude/*,required this.themeColor, required this.textSize*/});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static LocationModel fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}





