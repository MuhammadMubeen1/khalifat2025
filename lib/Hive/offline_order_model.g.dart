// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineOrderAdapter extends TypeAdapter<OfflineOrder> {
  @override
  final int typeId = 1;

  @override
  OfflineOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineOrder(
      dealershipId: fields[0] as int,
      dealershipName: fields[1] as String,
      address: fields[2] as String,
      userId: fields[3] as String,
      appDateTime: fields[4] as String,
      imageBase64: fields[5] as String?,
      products: (fields[6] as List).cast<OfflineOrderSelectedProduct>(),
      isSynced: fields[7] as bool,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineOrder obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.dealershipId)
      ..writeByte(1)
      ..write(obj.dealershipName)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.userId)
      ..writeByte(4)
      ..write(obj.appDateTime)
      ..writeByte(5)
      ..write(obj.imageBase64)
      ..writeByte(6)
      ..write(obj.products)
      ..writeByte(7)
      ..write(obj.isSynced)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OfflineOrderSelectedProductAdapter
    extends TypeAdapter<OfflineOrderSelectedProduct> {
  @override
  final int typeId = 2;

  @override
  OfflineOrderSelectedProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineOrderSelectedProduct(
      productId: fields[0] as int,
      distributorPrice: fields[1] as double,
      orderQuantity: fields[2] as int,
      productName: fields[3] as String,
      productVolume: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineOrderSelectedProduct obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.distributorPrice)
      ..writeByte(2)
      ..write(obj.orderQuantity)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.productVolume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineOrderSelectedProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
