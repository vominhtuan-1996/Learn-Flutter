// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_pin_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MapPinModelAdapter extends TypeAdapter<MapPinModel> {
  @override
  final int typeId = 2;

  @override
  MapPinModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MapPinModel(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      title: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MapPinModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapPinModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
