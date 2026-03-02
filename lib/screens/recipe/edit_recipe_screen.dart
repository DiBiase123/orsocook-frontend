import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/screens/recipe/edit_recipe/viewmodels/edit_recipe_viewmodel.dart';
import 'package:orsocook/screens/recipe/edit_recipe/widgets/edit_app_bar.dart';
import 'package:orsocook/screens/recipe/edit_recipe/widgets/edit_form.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EditRecipeViewModel(
            authService: Provider.of<AuthService>(context, listen: false),
            recipeService: Provider.of<RecipeService>(context, listen: false),
            categoryService:
                Provider.of<CategoryService>(context, listen: false),
            originalRecipe: widget.recipe,
          ),
        ),
      ],
      child: Consumer<EditRecipeViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: EditAppBar(
              isLoading: viewModel.isLoading || viewModel.isUploading,
              onSave: () => _saveRecipe(context, viewModel),
              onBack: () => context.pop(), // <-- MODIFICATO
            ),
            body: viewModel.isUploading
                ? const _UploadingIndicator()
                : EditForm(formKey: _formKey),
          );
        },
      ),
    );
  }

  Future<void> _saveRecipe(
      BuildContext context, EditRecipeViewModel viewModel) async {
    if (!viewModel.validate(_formKey)) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final updatedRecipe = await viewModel.saveRecipe();

      if (!mounted) return;

      if (updatedRecipe != null) {
        // 👈 FORZA REFRESH DELLE CATEGORIE PRIMA DI TORNARE INDIETRO
        final categoryService =
            Provider.of<CategoryService>(context, listen: false);
        await categoryService.fetchCategories(forceRefresh: true);

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Ricetta aggiornata con successo!'),
            backgroundColor: Colors.green,
          ),
        );

        // MODIFICATO: usa context.pop() invece di navigator.pop(true)
        if (mounted) {
          context.pop();
        }
      } else {
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
