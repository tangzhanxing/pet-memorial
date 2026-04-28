import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/create_pet_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/pet_detail_screen.dart';
import 'providers/pet_provider.dart';
import 'models/pet_model.dart';

void main() {
  runApp(const PetMemorialApp());
}

class PetMemorialApp extends StatelessWidget {
  const PetMemorialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PetProvider(),
      child: MaterialApp(
        title: 'Pet Memorial',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B5CF6),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          '/create': (context) => const CreatePetScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/pet-detail': (context) {
            final pet = ModalRoute.of(context)!.settings.arguments as PetModel;
            return PetDetailScreen(petModel: pet);
          },
        },
      ),
    );
  }
}