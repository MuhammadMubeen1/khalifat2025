import 'package:hive/hive.dart';

part 'offline_order_model.g.dart';

@HiveType(typeId: 1)
class OfflineOrder {
  @HiveField(0)
  final int dealershipId;

  @HiveField(1)
  final String dealershipName;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final String userId;

  @HiveField(4)
  final String appDateTime;

  @HiveField(5)
  final String? imageBase64;

  @HiveField(6)
  final List<OfflineOrderSelectedProduct> products;

  @HiveField(7)
  final bool isSynced;

  @HiveField(8)
  final DateTime createdAt;

  OfflineOrder({
    required this.dealershipId,
    required this.dealershipName,
    required this.address,
    required this.userId,
    required this.appDateTime,
    this.imageBase64,
    required this.products,
    required this.isSynced,
    required this.createdAt,
  });

  OfflineOrder copyWith({
    int? dealershipId,
    String? dealershipName,
    String? address,
    String? userId,
    String? appDateTime,
    String? imageBase64,
    List<OfflineOrderSelectedProduct>? products,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return OfflineOrder(
      dealershipId: dealershipId ?? this.dealershipId,
      dealershipName: dealershipName ?? this.dealershipName,
      address: address ?? this.address,
      userId: userId ?? this.userId,
      appDateTime: appDateTime ?? this.appDateTime,
      imageBase64: imageBase64 ?? this.imageBase64,
      products: products ?? this.products,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@HiveType(typeId: 2)
class OfflineOrderSelectedProduct {
  @HiveField(0)
  final int productId;

  @HiveField(1)
  final double distributorPrice;

  @HiveField(2)
  final int orderQuantity;

  @HiveField(3)
  final String productName;

  @HiveField(4)
  final int productVolume;

  OfflineOrderSelectedProduct({
    required this.productId,
    required this.distributorPrice,
    required this.orderQuantity,
    required this.productName,
    required this.productVolume,
  });
}
