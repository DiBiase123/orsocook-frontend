import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/auth_service.dart';
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
          ),
        ),
      ],
      child: Consumer<CreateRecipeViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: RecipeAppBar(
              isLoading: viewModel.isLoading || viewModel.isUploading,
              onSave: () => _saveRecipe(context, viewModel),
              onBack: () => Navigator.pop(context),
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

    // Salva le reference del contesto PRIMA delle chiamate async
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final createdRecipe = await viewModel.saveRecipe();

      if (!mounted) return;

      if (createdRecipe != null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Ricetta creata con successo!'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop(true);
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
