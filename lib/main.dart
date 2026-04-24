import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/pet_model.dart';
import 'screens/home_screen.dart';
import 'screens/create_pet_screen.dart';
import 'screens/pet_detail_screen.dart';
import 'services/pet_storage_service.dart';
import 'services/speech_service.dart';

void main() {
  runApp(const PetMemorialApp());
}

class PetMemorialApp extends StatelessWidget {
  const PetMemorialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PetStorageService()),
        ChangeNotifierProvider(create: (_) => SpeechService()),
      ],
      child: MaterialApp(
        title: 'Pet Memorial',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B5CF6), // 紫色系，温暖治愈
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
        routes: {
          '/create': (context) => const CreatePetScreen(),
          '/pet': (context) {
            final pet = ModalRoute.of(context)!.settings.arguments as PetModel;
            return PetDetailScreen(pet: pet);
          },
        },
      ),
    );
  }
}