import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
part 'employee.g.dart';

@HiveType(typeId: 9)
class Employee extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String role;

  @HiveField(5)
  double hourlyRate;

  @HiveField(6)
  List<String> workingDays;

  @HiveField(7)
  @HiveField(8)
  TimeOfDay startTime;

  @HiveField(9)
  @HiveField(10)
  TimeOfDay endTime;

  @HiveField(11)
  bool isActive;

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  DateTime? lastModified;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.hourlyRate,
    required this.workingDays,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
    required this.createdAt,
    this.lastModified,
  });

  factory Employee.create({
    required String name,
    required String email,
    required String phone,
    required String role,
    required double hourlyRate,
    required List<String> workingDays,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) {
    return Employee(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      role: role,
      hourlyRate: hourlyRate,
      workingDays: workingDays,
      startTime: startTime,
      endTime: endTime,
      createdAt: DateTime.now(),
    );
  }

  Employee copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    double? hourlyRate,
    List<String>? workingDays,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isActive,
  }) {
    return Employee(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      workingDays: workingDays ?? this.workingDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastModified: DateTime.now(),
    );
  }
}

// TimeOfDay adapter for Hive
class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 20;

  @override
  TimeOfDay read(BinaryReader reader) {
    final hour = reader.readInt();
    final minute = reader.readInt();
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeInt(obj.hour);
    writer.writeInt(obj.minute);
  }
}
