import 'package:equatable/equatable.dart';

class RecipeIngredient extends Equatable {
  final int id;
  final int recipeId;
  final int itemId;
  final String quantity;
  final String? createdAt;
  final String? updatedAt;

  const RecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.itemId,
    required this.quantity,
    this.createdAt,
    this.updatedAt,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: int.parse(json['id'].toString()),
      recipeId: int.parse(json['recipe_id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      quantity: json['quantity'].toString(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, recipeId, itemId, quantity];
}

class Recipe extends Equatable {
  final int id;
  final int outputItemId;
  final String outputQuantity;
  final String? createdAt;
  final String? updatedAt;
  final List<RecipeIngredient> items;

  const Recipe({
    required this.id,
    required this.outputItemId,
    required this.outputQuantity,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: int.parse(json['id'].toString()),
      outputItemId: int.parse(json['output_item_id'].toString()),
      outputQuantity: json['output_quantity'].toString(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => RecipeIngredient.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, outputItemId, outputQuantity, items];
}

class RecipeIngredientInput {
  final int itemId;
  final double quantity;

  const RecipeIngredientInput({
    required this.itemId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'quantity': quantity,
      };
}
