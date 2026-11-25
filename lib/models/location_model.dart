// Model data untuk lokasi hasil pencarian Geocoding Open-Meteo
class LocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1; // Provinsi atau wilayah tingkat 1

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  // Membuat instance LocationModel dari data JSON API Open-Meteo
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] is int ? json['id'] as int : (json['id'] as num).toInt(),
      name: json['name'] as String? ?? 'Tidak Diketahui',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
    );
  }

  // Mengubah instance ke bentuk Map/JSON untuk disimpan ke SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
    };
  }

  // Helper untuk menampilkan lokasi lengkap (misal: Banyumas, Indonesia)
  String get fullAddress {
    final List<String> parts = [];
    if (admin1 != null && admin1!.isNotEmpty) {
      parts.add(admin1!);
    }
    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }
    return parts.isEmpty ? 'Lokasi' : parts.join(', ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
