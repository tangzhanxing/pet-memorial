import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_model.dart';

/// 宠物管理状态管理
class PetProvider extends ChangeNotifier {
  List<PetModel> _pets = [];
  PetModel? _currentPet;
  bool _isLoading = false;
  String? _error;
  String? _generationStatus;

  List<PetModel> get pets => _pets;
  PetModel? get currentPet => _currentPet;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get generationStatus => _generationStatus;

  PetProvider() {
    _loadPets();
  }

  /// 从本地存储加载宠物列表
  Future<void> _loadPets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('pets_data');
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        _pets = jsonList.map((j) => PetModel.fromJson(j)).toList();
      }
    } catch (e) {
      _error = 'Failed to load: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 保存宠物列表到本地
  Future<void> _savePets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _pets.map((p) => p.toJson()).toList();
      await prefs.setString('pets_data', jsonEncode(jsonList));
    } catch (e) {
      _error = 'Failed to save: $e';
    }
  }

  /// 添加新宠物
  Future<void> addPet(PetModel pet) async {
    _pets.add(pet);
    await _savePets();
    notifyListeners();
  }

  /// 更新宠物信息
  Future<void> updatePet(PetModel updatedPet) async {
    final index = _pets.indexWhere((p) => p.id == updatedPet.id);
    if (index != -1) {
      _pets[index] = updatedPet;
      if (_currentPet?.id == updatedPet.id) {
        _currentPet = updatedPet;
      }
      await _savePets();
      notifyListeners();
    }
  }

  /// 添加纪念照片
  Future<void> addMemorialPhoto(String petId, String photoPath) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      final pet = _pets[index];
      final updatedPhotos = List<String>.from(pet.memorialPhotos)..add(photoPath);
      _pets[index] = pet.copyWith(memorialPhotos: updatedPhotos);
      if (_currentPet?.id == petId) {
        _currentPet = _pets[index];
      }
      await _savePets();
      notifyListeners();
    }
  }

  /// 更新纪念备忘录
  Future<void> updateMemorialNotes(String petId, String notes) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      final pet = _pets[index];
      _pets[index] = pet.copyWith(memorialNotes: notes);
      if (_currentPet?.id == petId) {
        _currentPet = _pets[index];
      }
      await _savePets();
      notifyListeners();
    }
  }

  /// 删除宠物
  Future<void> deletePet(String id) async {
    _pets.removeWhere((p) => p.id == id);
    if (_currentPet?.id == id) _currentPet = null;
    await _savePets();
    notifyListeners();
  }

  /// 选择当前宠物
  void selectPet(PetModel pet) {
    _currentPet = pet;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}