// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_order.dart';

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
      order: fields[0] as Order,
      synced: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineOrder obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.order)
      ..writeByte(1)
      ..write(obj.synced);
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
