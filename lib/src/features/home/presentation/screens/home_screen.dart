import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Bienvenue !',
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Que souhaitez-vous faire ?',
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () {
                  context.push('/meetings');
                },
                icon: const Icon(Icons.group),
                label: const Text('Gérer les réunions'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Naviguer vers l'écran des paramètres
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Écran des paramètres à implémenter.')),
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('Paramètres'),
                 style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
