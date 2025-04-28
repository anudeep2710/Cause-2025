// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sustainability.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GreenBadgeAdapter extends TypeAdapter<GreenBadge> {
  @override
  final int typeId = 10;

  @override
  GreenBadge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GreenBadge(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      iconPath: fields[3] as String,
      points: fields[4] as int,
      earnedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GreenBadge obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconPath)
      ..writeByte(4)
      ..write(obj.points)
      ..writeByte(5)
      ..write(obj.earnedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GreenBadgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CarbonFootprintAdapter extends TypeAdapter<CarbonFootprint> {
  @override
  final int typeId = 6;

  @override
  CarbonFootprint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CarbonFootprint(
      id: fields[0] as String,
      totalCarbonSaved: fields[1] as double,
      categorySavings: (fields[2] as Map).cast<String, double>(),
      lastUpdated: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CarbonFootprint obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.totalCarbonSaved)
      ..writeByte(2)
      ..write(obj.categorySavings)
      ..writeByte(3)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarbonFootprintAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocalSupplierAdapter extends TypeAdapter<LocalSupplier> {
  @override
  final int typeId = 7;

  @override
  LocalSupplier read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalSupplier(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      sustainabilityCertifications: (fields[5] as List).cast<String>(),
      description: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalSupplier obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.sustainabilityCertifications)
      ..writeByte(6)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalSupplierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
