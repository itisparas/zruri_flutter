class Location {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String locality;
  final String administrativeArea;
  final String country;

  Location({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.locality,
    required this.administrativeArea,
    required this.country,
  });

  // Factory method to create a Location object from a map
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: map['latitude'] is String
          ? double.parse(map['latitude'])
          : map['latitude'] as double,
      longitude: map['longitude'] is String
          ? double.parse(map['longitude'])
          : map['longitude'] as double,
      formattedAddress: map['formattedAddress'],
      locality: map['locality'],
      administrativeArea: map['administrativeArea'],
      country: map['country'],
    );
  }

  // Method to convert Location object to a map
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': formattedAddress,
      'locality': locality,
      'administrativeArea': administrativeArea,
      'country': country,
    };
  }
}
