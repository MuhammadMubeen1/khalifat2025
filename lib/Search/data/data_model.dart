class User {
  final int shopId;
  final String shopName;
  final String ownerName;
  final String shopAddress;
  final String pinLocation;
  final String openingTime;
  final String closingTime;
  final String phoneNo;
  final double shopLat;
  final double shopLng;
  final double distanceInMeters;
  final String formattedDistance;
  final String formattedDistanceUnit;
  final String isOrder;
  final int totalOrder;

  User({
    required this.shopId,
    required this.shopName,
    required this.ownerName,
    required this.shopAddress,
    required this.pinLocation,
    required this.openingTime,
    required this.closingTime,
    required this.phoneNo,
    required this.shopLat,
    required this.shopLng,
    required this.distanceInMeters,
    required this.formattedDistance,
    required this.formattedDistanceUnit,
    required this.isOrder,
    required this.totalOrder,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      shopId: json['ShopId'],
      shopName: json['ShopName'],
      ownerName: json['OwnerName'],
      shopAddress: json['ShopAddress'],
      pinLocation: json['PinLocation'],
      openingTime: json['OpeningTime'],
      closingTime: json['ClosingTime'],
      phoneNo: json['PhoneNo'],
      shopLat: json['ShopLat'],
      shopLng: json['ShopLng'],
      distanceInMeters: json['DistanceInMeters'],
      formattedDistance: json['FormattedDistance'],
      formattedDistanceUnit: json['FormattedDistanceUnit'],
      isOrder: json['IsOrder'],
      totalOrder: json['TotalOrder'],
    );
  }
}
