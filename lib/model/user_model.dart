import 'package:hive/hive.dart';

part 'user_model.g.dart'; // ✅ required for code generation

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final String name;
  @HiveField(2) 
  final String role;
  @HiveField(3)
  final String userImage;
  @HiveField(4)
  final String userEmail;
  @HiveField(5)
  final String userPhone;
  @HiveField(6)
  final String startShift;
  @HiveField(7)
  final String endShift;
  @HiveField(8)
  final String isPresent;
  @HiveField(9)
  final bool isMobileDeviceRegister;
  @HiveField(10)
  final bool isAvailableForMobile;
  @HiveField(11)
  final String email;
  @HiveField(12)
  final String password;

  UserModel({
    required this.userId,
    required this.name,
    required this.role,
    required this.userImage,
    required this.userEmail,
    required this.userPhone,
    required this.startShift,
    required this.endShift,
    required this.isPresent,
    required this.isMobileDeviceRegister,
    required this.isAvailableForMobile,
    required this.email,
    required this.password,
  });
}
