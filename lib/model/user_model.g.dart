// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      userId: fields[0] as String,
      name: fields[1] as String,
      role: fields[2] as String,
      userImage: fields[3] as String,
      userEmail: fields[4] as String,
      userPhone: fields[5] as String,
      startShift: fields[6] as String,
      endShift: fields[7] as String,
      isPresent: fields[8] as String,
      isMobileDeviceRegister: fields[9] as bool,
      isAvailableForMobile: fields[10] as bool,
      email: fields[11] as String,
      password: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.userImage)
      ..writeByte(4)
      ..write(obj.userEmail)
      ..writeByte(5)
      ..write(obj.userPhone)
      ..writeByte(6)
      ..write(obj.startShift)
      ..writeByte(7)
      ..write(obj.endShift)
      ..writeByte(8)
      ..write(obj.isPresent)
      ..writeByte(9)
      ..write(obj.isMobileDeviceRegister)
      ..writeByte(10)
      ..write(obj.isAvailableForMobile)
      ..writeByte(11)
      ..write(obj.email)
      ..writeByte(12)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
