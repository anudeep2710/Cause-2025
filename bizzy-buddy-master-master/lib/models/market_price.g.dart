// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_price.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarketPriceAdapter extends TypeAdapter<MarketPrice> {
  @override
  final int typeId = 4;

  @override
  MarketPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarketPrice(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      prices: (fields[2] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, MarketPrice obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.prices);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
