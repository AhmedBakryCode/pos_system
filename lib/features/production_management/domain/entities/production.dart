import 'package:equatable/equatable.dart';
import '../../../recipes/domain/entities/recipe.dart';

class Production extends Equatable {
  final int id;
  final int recipeId;
  final String quantity;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final Recipe? recipe;

  const Production({
    required this.id,
    required this.recipeId,
    required this.quantity,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.recipe,
  });

  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      id: int.parse(json['id'].toString()),
      recipeId: int.parse(json['recipe_id'].toString()),
      quantity: json['quantity'].toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      recipe: json['recipe'] != null ? Recipe.fromJson(json['recipe']) : null,
    );
  }

  @override
  List<Object?> get props => [id, recipeId, quantity, status, recipe];
}
