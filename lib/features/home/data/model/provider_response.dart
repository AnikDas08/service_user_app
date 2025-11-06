class ProviderResponse {
  final bool? success;
  final String? message;
  final List<ProvidersData>? data;

  ProviderResponse({
    this.success,
    this.message,
    this.data,
  });

  factory ProviderResponse.fromJson(Map<String, dynamic> json) {
    return ProviderResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<ProvidersData>.from(
          json['data'].map((x) => ProvidersData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((x) => x.toJson()).toList() ?? [],
    };
  }
}

class ProvidersData {
  final String id;
  final UserData user;
  final String aboutMe;
  final List<Service> services;
  final List<String> serviceLanguage;
  final String primaryLocation;
  final LocationData location;
  final  num serviceDistance;
  final double pricePerHour;
  final List<String> serviceImages;
  final bool isRead;
  final bool isActive;
  final bool verified;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProvidersData({
    required this.id,
    required this.user,
    required this.aboutMe,
    required this.services,
    required this.serviceLanguage,
    required this.primaryLocation,
    required this.location,
    required this.serviceDistance,
    required this.pricePerHour,
    required this.serviceImages,
    required this.isRead,
    required this.isActive,
    required this.verified,
    required this.isOnline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProvidersData.fromJson(Map<String, dynamic> json) {
    return ProvidersData(
      id: json['_id'] ?? '',
      user: json['user'] is Map<String, dynamic>
          ? UserData.fromJson(json['user'])
          : UserData.fromString(json['user'] ?? ''),
      aboutMe: json['aboutMe'] ?? '',
      services: json['services'] != null
          ? List<Service>.from(
          json['services'].map((x) => Service.fromJson(x)))
          : [],
      serviceLanguage: json['serviceLanguage'] != null
          ? List<String>.from(json['serviceLanguage'])
          : [],
      primaryLocation: json['primaryLocation'] ?? '',
      location: LocationData.fromJson(json['location'] ?? {}),
      serviceDistance: json['serviceDistance'] ?? 0,
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      serviceImages: json['serviceImages'] != null
          ? List<String>.from(json['serviceImages'])
          : [],
      isRead: json['isRead'] ?? false,
      isActive: json['isActive'] ?? false,
      verified: json['verified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'aboutMe': aboutMe,
      'services': services.map((x) => x.toJson()).toList(),
      'serviceLanguage': serviceLanguage,
      'primaryLocation': primaryLocation,
      'location': location.toJson(),
      'serviceDistance': serviceDistance,
      'pricePerHour': pricePerHour,
      'serviceImages': serviceImages,
      'isRead': isRead,
      'isActive': isActive,
      'verified': verified,
      'isOnline': isOnline,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class UserData {
  final String id;
  final String name;
  final String? image;
  final String email;
  final String contact;

  UserData({
    required this.id,
    required this.name,
    this.image,
    required this.email,
    required this.contact,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
    );
  }

  // Factory for backward compatibility if user is a string
  factory UserData.fromString(String userId) {
    return UserData(
      id: userId,
      name: 'Service Provider',
      image: null,
      email: '',
      contact: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'email': email,
      'contact': contact,
    };
  }
}

class Service {
  final String id;
  final Category? category;
  final SubCategory? subCategory;
  final double price;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Service({
    required this.id,
    this.category,
    this.subCategory,
    required this.price,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? '',
      category:
      json['category'] != null ? Category.fromJson(json['category']) : null,
      subCategory: json['subCategory'] != null
          ? SubCategory.fromJson(json['subCategory'])
          : null,
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'category': category?.toJson(),
      'subCategory': subCategory?.toJson(),
      'price': price,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Category {
  final String id;
  final String name;
  final String? icon;

  Category({
    required this.id,
    required this.name,
    this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'icon': icon,
    };
  }
}

class SubCategory {
  final String id;
  final String name;

  SubCategory({
    required this.id,
    required this.name,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

class LocationData {
  final String type;
  final List<double> coordinates;

  LocationData({required this.type, required this.coordinates});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
          : [0.0, 0.0],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'coordinates': coordinates,
  };
}