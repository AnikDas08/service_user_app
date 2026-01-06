class LocationModel {
  final String displayName;
  final String lat;
  final String lon;

  LocationModel({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      displayName: json['display_name'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}
