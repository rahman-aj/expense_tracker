// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthlyBudgetAdapter extends TypeAdapter<MonthlyBudget> {
  @override
  final int typeId = 1;

  @override
  MonthlyBudget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyBudget(
      amount: fields[0] as double,
      month: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyBudget obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.month);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyBudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
