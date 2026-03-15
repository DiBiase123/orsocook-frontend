import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/screens/recipe/create_recipe/viewmodels/create_recipe_viewmodel.dart';
import 'package:orsocook/screens/recipe/create_recipe/widgets/recipe_app_bar.dart';
import 'package:orsocook/screens/recipe/create_recipe/widgets/recipe_form.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CreateRecipeViewModel(
            authService: Provider.of<AuthService>(context, listen: false),
            recipeService: Provider.of<RecipeService>(context, listen: false),
            categoryService:
                Provider.of<CategoryService>(context, listen: false),
          ),
        ),
      ],
      child: Consumer<CreateRecipeViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: RecipeAppBar(
              isLoading: viewModel.isLoading || viewModel.isUploading,
              onSave: () => _saveRecipe(context, viewModel),
              onBack: () => context.pop(),
            ),
            body: viewModel.isUploading
                ? const _UploadingIndicator()
                : RecipeForm(formKey: _formKey),
          );
        },
      ),
    );
  }

  Future<void> _saveRecipe(
      BuildContext context, CreateRecipeViewModel viewModel) async {
    if (!viewModel.validate(_formKey)) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    // Ottieni il service PRIMA dell'async gap
    final categoryService =
        Provider.of<CategoryService>(context, listen: false);
    // Ottieni il router PRIMA dell'async gap
    final goRouter = GoRouter.of(context);

    try {
      final createdRecipe = await viewModel.saveRecipe();

      if (!mounted) return;

      if (createdRecipe != null) {
        // Mostra snackbar (usa context salvato in scaffoldMessenger)
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Ricetta creata con successo!'),
            backgroundColor: Colors.green,
          ),
        );

        // Esegui fetch (non richiede context dopo)
        await categoryService.fetchCategories(forceRefresh: true);

        if (!mounted) return;

        // Naviga alla home invece di fare pop()
        goRouter.go('/');
      } else {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Errore: Risposta vuota dal server'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Errore: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _UploadingIndicator extends StatelessWidget {
  const _UploadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Caricamento immagine in corso...'),
        ],
      ),
    );
  }
}
