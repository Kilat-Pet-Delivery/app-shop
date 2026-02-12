class ShopModel {
  final String id;
  final String? ownerId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String category;
  final List<String> services;
  final double rating;
  final String? imageUrl;
  final String openingHours;
  final String description;
  final DateTime createdAt;

  const ShopModel({
    required this.id,
    this.ownerId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.category,
    required this.services,
    required this.rating,
    this.imageUrl,
    required this.openingHours,
    required this.description,
    required this.createdAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] ?? '',
      ownerId: json['owner_id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      category: json['category'] ?? '',
      services: List<String>.from(json['services'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      openingHours: json['opening_hours'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'email': email,
        'category': category,
        'services': services,
        'image_url': imageUrl ?? '',
        'opening_hours': openingHours,
        'description': description,
      };

  Map<String, dynamic> toUpdateJson() {
    final map = <String, dynamic>{};
    if (name.isNotEmpty) map['name'] = name;
    if (address.isNotEmpty) map['address'] = address;
    if (latitude != 0) map['latitude'] = latitude;
    if (longitude != 0) map['longitude'] = longitude;
    if (phone.isNotEmpty) map['phone'] = phone;
    if (email.isNotEmpty) map['email'] = email;
    if (category.isNotEmpty) map['category'] = category;
    if (services.isNotEmpty) map['services'] = services;
    if (openingHours.isNotEmpty) map['opening_hours'] = openingHours;
    if (description.isNotEmpty) map['description'] = description;
    return map;
  }

  ShopModel copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? category,
    List<String>? services,
    String? imageUrl,
    String? openingHours,
    String? description,
  }) {
    return ShopModel(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      category: category ?? this.category,
      services: services ?? this.services,
      rating: rating,
      imageUrl: imageUrl ?? this.imageUrl,
      openingHours: openingHours ?? this.openingHours,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }
}
