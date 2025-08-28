import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'shop_tagging_model.g.dart';

@HiveType(typeId: 4)
class ShopTaggingModel {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final int? TerritoryId;

  @HiveField(2)
  final String shopName;

  @HiveField(3)
  final String phoneNo;

  @HiveField(4)
  final String ownerName;

  @HiveField(5)
  final String address;

  @HiveField(6)
  final String openingTime;

  @HiveField(7)
  final String closingTime;

  @HiveField(8)
  final String imageExtension;

  @HiveField(9)
  final double lat;

  @HiveField(10)
  final double lng;

  @HiveField(11)
  final String imageFileSource;

  @HiveField(12)
  final int? shopTypeId;

  @HiveField(13)
  final String pepsiFridge;

  @HiveField(14)
  final String cokeFridge;

  @HiveField(15)
  final String nestleFridge;

  @HiveField(16)
  final String nesfrutaFridge;

  @HiveField(17)
  final String othersFridge;

  @HiveField(18)
  final String appDateTime;

  @HiveField(19)
  final String landmark;

  @HiveField(20)
  final String secondaryPhoneNo;

  @HiveField(21)
  bool isSynced;

  @HiveField(22)
  final DateTime createdAt;

  @HiveField(23)
  final int id; // Added id field

  ShopTaggingModel({
    required this.userId,
    required this.TerritoryId,
    required this.shopName,
    required this.phoneNo,
    required this.ownerName,
    required this.address,
    required this.openingTime,
    required this.closingTime,
    required this.imageExtension,
    required this.lat,
    required this.lng,
    required this.imageFileSource,
    required this.shopTypeId,
    required this.pepsiFridge,
    required this.cokeFridge,
    required this.nestleFridge,
    required this.nesfrutaFridge,
    required this.othersFridge,
    required this.appDateTime,
    required this.landmark,
    required this.secondaryPhoneNo,
    this.isSynced = false,
    required this.createdAt,
    this.id = 0, // Default value for id
  });

  Map<String, dynamic> toJson() {
    return {
      "command": "SaveShopTagging", // Added the required command field
      "id": id,
      "userId": userId,
      "TerritoryId": TerritoryId,
      "shopName": shopName,
      "phoneNo": phoneNo,
      "ownerName": ownerName,
      "address": address,
      "openingTime": openingTime,
      "closingTime": closingTime,
      "imageExtension": imageExtension,
      "lat": lat,
      "lng": lng,
      "imageFileSource": imageFileSource.split('|||'), // Convert to array
      "shopTypeId": shopTypeId,
      "pepsiFridge": pepsiFridge,
      "cokeFridge": cokeFridge,
      "nestleFridge": nestleFridge,
      "nesfrutaFridge": nesfrutaFridge,
      "othersFridge": othersFridge,
      "appDateTime": appDateTime,
      "landmark": landmark,
      "secondaryPhoneNo": secondaryPhoneNo,
    };
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  }
}
