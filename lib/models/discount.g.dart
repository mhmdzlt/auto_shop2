// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiscountAdapter extends TypeAdapter<Discount> {
  @override
  final int typeId = 4;

  @override
  Discount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Discount(
      id: fields[0] as String,
      code: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      type: fields[4] as DiscountType,
      value: fields[5] as double,
      minimumAmount: fields[6] as double?,
      maximumDiscount: fields[7] as double?,
      startDate: fields[8] as DateTime,
      endDate: fields[9] as DateTime,
      usageLimit: fields[10] as int?,
      usedCount: fields[11] as int,
      isActive: fields[12] as bool,
      applicableCategories: (fields[13] as List?)?.cast<String>(),
      applicableProducts: (fields[14] as List?)?.cast<String>(),
      isFirstTimeOnly: fields[15] as bool,
      createdAt: fields[16] as DateTime,
      updatedAt: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Discount obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.value)
      ..writeByte(6)
      ..write(obj.minimumAmount)
      ..writeByte(7)
      ..write(obj.maximumDiscount)
      ..writeByte(8)
      ..write(obj.startDate)
      ..writeByte(9)
      ..write(obj.endDate)
      ..writeByte(10)
      ..write(obj.usageLimit)
      ..writeByte(11)
      ..write(obj.usedCount)
      ..writeByte(12)
      ..write(obj.isActive)
      ..writeByte(13)
      ..write(obj.applicableCategories)
      ..writeByte(14)
      ..write(obj.applicableProducts)
      ..writeByte(15)
      ..write(obj.isFirstTimeOnly)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DiscountTypeAdapter extends TypeAdapter<DiscountType> {
  @override
  final int typeId = 5;

  @override
  DiscountType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DiscountType.percentage;
      case 1:
        return DiscountType.fixedAmount;
      case 2:
        return DiscountType.freeShipping;
      default:
        return DiscountType.percentage;
    }
  }

  @override
  void write(BinaryWriter writer, DiscountType obj) {
    switch (obj) {
      case DiscountType.percentage:
        writer.writeByte(0);
        break;
      case DiscountType.fixedAmount:
        writer.writeByte(1);
        break;
      case DiscountType.freeShipping:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscountTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
