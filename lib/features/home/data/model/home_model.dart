// models/service_provider.dart

class HomeModel {
  final String name;
  final String service;
  final String distance;
  final num rating;
  final num reviews;
  final String price;
  final String image;
  final bool isFavorite;

  HomeModel({
    required this.name,
    required this.service,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.image,
    this.isFavorite = false,
  });

  HomeModel copyWith({
    String? name,
    String? service,
    String? distance,
    double? rating,
    int? reviews,
    String? price,
    String? image,
    bool? isFavorite,
  }) {
    return HomeModel(
      name: name ?? this.name,
      service: service ?? this.service,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      price: price ?? this.price,
      image: image ?? this.image,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}