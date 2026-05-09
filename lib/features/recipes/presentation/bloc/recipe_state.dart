import 'package:equatable/equatable.dart';
import '../../domain/entities/recipe.dart';

enum RecipeStatus { initial, loading, loaded, error }

class RecipeState extends Equatable {
  final RecipeStatus status;
  final List<Recipe> recipes;
  final String? errorMessage;
  final int currentPage;

  const RecipeState({
    this.status = RecipeStatus.initial,
    this.recipes = const [],
    this.errorMessage,
    this.currentPage = 1,
  });

  RecipeState copyWith({
    RecipeStatus? status,
    List<Recipe>? recipes,
    String? errorMessage,
    int? currentPage,
  }) {
    return RecipeState(
      status: status ?? this.status,
      recipes: recipes ?? this.recipes,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, recipes, errorMessage, currentPage];
}
