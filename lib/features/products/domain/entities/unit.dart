import 'package:equatable/equatable.dart';

class Unit extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  const Unit({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: int.parse(json['id'].toString()),
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [id, name, description, createdAt, updatedAt];
}
