import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/pet_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 宠物数据持久化服务
class PetStorageService extends ChangeNotifier {
  static const String _storageKey = 'pets_data';

  List<PetModel> _pets = [];
  bool _isLoading = true;

  List<PetModel> get pets => _pets;
  bool get isLoading => _isLoading;

  PetStorageService() {
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        _pets = jsonList.map((j) => PetModel.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load pets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _savePets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _pets.map((p) => p.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Failed to save pets: $e');
    }
  }

  Future<void> addPet(PetModel pet) async {
    _pets.add(pet);
    await _savePets();
    notifyListeners();
  }

  Future<void> updatePet(PetModel updatedPet) async {
    final index = _pets.indexWhere((p) => p.id == updatedPet.id);
    if (index != -1) {
      _pets[index] = updatedPet;
      await _savePets();
      notifyListeners();
    }
  }

  Future<void> deletePet(String petId) async {
    _pets.removeWhere((p) => p.id == petId);
    await _savePets();
    notifyListeners();
  }

  PetModel? getPetById(String id) {
    try {
      return _pets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}