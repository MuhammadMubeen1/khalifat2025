// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_tagging_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopTaggingModelAdapter extends TypeAdapter<ShopTaggingModel> {
  @override
  final int typeId = 4;

  @override
  ShopTaggingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopTaggingModel(
      userId: fields[0] as String,
      TerritoryId: fields[1] as int?,
      shopName: fields[2] as String,
      phoneNo: fields[3] as String,
      ownerName: fields[4] as String,
      address: fields[5] as String,
      openingTime: fields[6] as String,
      closingTime: fields[7] as String,
      imageExtension: fields[8] as String,
      lat: fields[9] as double,
      lng: fields[10] as double,
      imageFileSource: fields[11] as String,
      shopTypeId: fields[12] as int?,
      pepsiFridge: fields[13] as String,
      cokeFridge: fields[14] as String,
      nestleFridge: fields[15] as String,
      nesfrutaFridge: fields[16] as String,
      othersFridge: fields[17] as String,
      appDateTime: fields[18] as String,
      landmark: fields[19] as String,
      secondaryPhoneNo: fields[20] as String,
      isSynced: fields[21] as bool,
      createdAt: fields[22] as DateTime,
      id: fields[23] as int,
      isDuplicate: fields[24] as bool, // Add this field
    );
  }

  @override
  void write(BinaryWriter writer, ShopTaggingModel obj) {
    writer
      ..writeByte(25) // Changed from 24 to 25
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.TerritoryId)
      ..writeByte(2)
      ..write(obj.shopName)
      ..writeByte(3)
      ..write(obj.phoneNo)
      ..writeByte(4)
      ..write(obj.ownerName)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.openingTime)
      ..writeByte(7)
      ..write(obj.closingTime)
      ..writeByte(8)
      ..write(obj.imageExtension)
      ..writeByte(9)
      ..write(obj.lat)
      ..writeByte(10)
      ..write(obj.lng)
      ..writeByte(11)
      ..write(obj.imageFileSource)
      ..writeByte(12)
      ..write(obj.shopTypeId)
      ..writeByte(13)
      ..write(obj.pepsiFridge)
      ..writeByte(14)
      ..write(obj.cokeFridge)
      ..writeByte(15)
      ..write(obj.nestleFridge)
      ..writeByte(16)
      ..write(obj.nesfrutaFridge)
      ..writeByte(17)
      ..write(obj.othersFridge)
      ..writeByte(18)
      ..write(obj.appDateTime)
      ..writeByte(19)
      ..write(obj.landmark)
      ..writeByte(20)
      ..write(obj.secondaryPhoneNo)
      ..writeByte(21)
      ..write(obj.isSynced)
      ..writeByte(22)
      ..write(obj.createdAt)
      ..writeByte(23)
      ..write(obj.id)
      ..writeByte(24)
      ..write(obj.isDuplicate); // Add this field
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopTaggingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
