import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_app/src/core/navigation/app_router.dart';
import 'package:meeting_app/src/core/theme/app_theme.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Décommentez pour charger les variables d'environnement
  // await dotenv.load(fileName: ".env");

  // TODO: Initialiser les services d'arrière-plan (AudioService, Workmanager) ici
  // await setupAudioHandler();
  // await setupWorkManager();

  runApp(
    // ProviderScope stocke l'état de tous nos providers Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Récupère la configuration du routeur depuis Riverpod
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Plateforme de Réunions',
      theme: AppTheme.lightTheme,
      // Utilise MaterialApp.router pour GoRouter
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
