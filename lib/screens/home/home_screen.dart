import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/screens/home/viewmodels/home_viewmodel.dart';
import 'package:orsocook/screens/home/widgets/home_app_bar.dart';
import 'package:orsocook/screens/home/widgets/home_body.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/like_service.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeViewModel();
  }

  void _initializeViewModel() {
    _viewModel = HomeViewModel(
      recipeService: context.read<RecipeService>(),
      likeService: context.read<LikeService>(),
      categoryService: context.read<CategoryService>(),
    );

    _viewModel.addListener(_onViewModelUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadInitialRecipes().catchError((e) {
        AppLogger.error('Errore nel caricamento iniziale', e);
      });
    });
  }

  void _onViewModelUpdate() {
    AppLogger.debug('🏠 [HOME] ViewModel aggiornato');

    if (mounted) setState(() {});
  }

  void _navigateToCreateRecipe() {
    final authService = context.read<AuthService>();
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog(
        title: 'Accesso richiesto',
        content: 'Devi effettuare il login per creare una ricetta.',
      );
      return;
    }
    context.go('/create-recipe');
  }

  void _navigateToProfile() {
    final authService = context.read<AuthService>();
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog(
        title: 'Accesso richiesto',
        content: 'Devi effettuare il login per accedere al profilo.',
      );
      return;
    }
    context.go('/profile');
  }

  void _navigateToRecipeDetail(Recipe recipe) {
    if (recipe.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore: ID ricetta non valido')),
      );
      return;
    }
    context.push('/recipe/detail/${recipe.id}', extra: recipe);
  }

  void _showLoginRequiredDialog({
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text('LOGIN'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen(AuthService authService) {
    return Scaffold(
      appBar: HomeAppBar(
        onProfileTap: _navigateToProfile,
        onCreateRecipeTap: _navigateToCreateRecipe,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Caricamento ricette...'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.disposeViewModel();
    _viewModel.removeListener(_onViewModelUpdate);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>.value(
      value: _viewModel,
      child: Consumer2<HomeViewModel, AuthService>(
        builder: (context, viewModel, authService, child) {
          if (viewModel.shouldShowLoading(viewModel.recipes.isEmpty)) {
            return _buildLoadingScreen(authService);
          }

          return Scaffold(
            appBar: HomeAppBar(
              onProfileTap: _navigateToProfile,
              onCreateRecipeTap: _navigateToCreateRecipe,
            ),
            body: HomeBody(
              onCreateRecipeTap: _navigateToCreateRecipe,
              searchController: _searchController,
              onRecipeTap: _navigateToRecipeDetail,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _navigateToCreateRecipe,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: const Icon(Icons.add, size: 28),
            ),
          );
        },
      ),
    );
  }
}
