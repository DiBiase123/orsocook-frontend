import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/screens/recipe/detail_recipe/viewmodels/detail_recipe_viewmodel.dart';
import 'package:orsocook/screens/recipe/detail_recipe/widgets/detail_app_bar.dart';
import 'package:orsocook/screens/recipe/detail_recipe/widgets/detail_body.dart';
import 'package:orsocook/screens/recipe/detail_recipe/widgets/detail_loading_error.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/like_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';

class DetailRecipeScreen extends StatefulWidget {
  final String? recipeId;
  final Recipe? recipe;

  const DetailRecipeScreen({
    super.key,
    this.recipeId,
    this.recipe,
  }) : assert(recipeId != null || recipe != null,
            'Deve essere fornito recipeId o recipe');

  @override
  State<DetailRecipeScreen> createState() => _DetailRecipeScreenState();
}

class _DetailRecipeScreenState extends State<DetailRecipeScreen> {
  late DetailRecipeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _initializeViewModel();
  }

  void _initializeViewModel() {
    final recipeService = Provider.of<RecipeService>(context, listen: false);
    final likeService = Provider.of<LikeService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    _viewModel = DetailRecipeViewModel(
      recipeService: recipeService,
      likeService: likeService,
      authService: authService,
      recipeId: widget.recipeId,
      initialRecipe: widget.recipe,
    );

    _viewModel.addListener(_onViewModelUpdate);
  }

  void _onViewModelUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleBackPressed() {
    AppLogger.debug('⬅️ Torna indietro da DetailRecipeScreen');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleEditPressed() {
    if (_viewModel.recipe != null) {
      _viewModel.navigateToEditScreen(context);
    }
  }

  void _handleDeletePressed() {
    if (_viewModel.recipe != null) {
      _viewModel.showDeleteConfirmationDialog(context);
    }
  }

  void _handleRetry() {
    if (widget.recipeId != null) {
      _viewModel.loadRecipeById(widget.recipeId!);
    } else if (_viewModel.recipe != null) {
      _viewModel.refreshRecipe();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('🏗️ Building DetailRecipeScreen (rifattorizzato)');

    return Scaffold(
      appBar: DetailAppBar(
        recipe: _viewModel.recipe,
        isOwner: _viewModel.isOwner,
        onBackPressed: _handleBackPressed,
        onEditPressed: _viewModel.isOwner ? _handleEditPressed : null,
        onDeletePressed: _viewModel.isOwner ? _handleDeletePressed : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const DetailLoadingWidget();
    }

    if (_viewModel.error != null) {
      return DetailErrorWidget(
        error: _viewModel.error,
        onRetry: _handleRetry,
      );
    }

    if (_viewModel.recipe != null) {
      return DetailBody(
        recipe: _viewModel.recipe!,
        likeCount: _viewModel.likeCount,
        isFavorite: _viewModel.isFavorite,
      );
    }

    return DetailErrorWidget(
      error: 'Ricetta non trovata',
      onRetry: _handleRetry,
    );
  }
}
