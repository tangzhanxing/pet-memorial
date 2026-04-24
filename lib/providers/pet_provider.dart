import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/pet_model.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/ai_3d_service.dart';

/// 宠物管理状态管理
class PetProvider extends ChangeNotifier {
  final StorageService storage;
  final AudioService audio;
  final AI3DService ai3d;

  List<PetModel> _pets = [];
  PetModel? _currentPet;
  bool _isLoading = false;
  String? _error;
  // 生成状态：null=未开始, 'uploading'=上传中, 'generating'=生成中, 'done'=完成
  String? _generationStatus;

  PetProvider({
    required this.storage,
    required this.audio,
    required this.ai3d,
  }) {
    _loadPets();
  }

  List<PetModel> get pets => _pets;
  PetModel? get currentPet => _currentPet;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get generationStatus => _generationStatus;

  /// 从本地存储加载宠物列表
  Future<void> _loadPets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = storage.get('pets');
      if (data != null) {
        final list = jsonDecode(data) as List;
        _pets = list.map((e) => PetModel.fromJson(e)).toList();
      }
    } catch (e) {
      _error = '加载失败: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 保存宠物列表到本地
  Future<void> _savePets() async {
    final data = jsonEncode(_pets.map((e) => e.toJson()).toList());
    storage.set('pets', data);
  }

  /// 添加新宠物（仅基本信息，3D模型后续生成）
  Future<void> addPet(String name, String species, List<String> photosPaths) async {
    final pet = PetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      species: species,
      photosPaths: photosPaths,
      createdAt: DateTime.now(),
    );

    _pets.add(pet);
    await _savePets();
    notifyListeners();
  }

  /// 开始AI生成3D模型
  Future<void> generate3DModel(PetModel pet) async {
    _generationStatus = 'uploading';
    _error = null;
    _currentPet = pet;
    notifyListeners();

    try {
      // 阶段1：上传照片到云端
      _generationStatus = 'uploading';
      notifyListeners();

      final uploadedUrls = await ai3d.uploadPhotos(pet.photosPaths);

      // 阶段2：调用AI生成3D模型
      _generationStatus = 'generating';
      notifyListeners();

      final modelUrl = await ai3d.generateModel(uploadedUrls);

      // 阶段3：更新宠物模型URL
      _generationStatus = 'done';
      final updatedPet = pet.copyWith(modelUrl: modelUrl);
      final idx = _pets.indexWhere((p) => p.id == pet.id);
      if (idx != -1) {
        _pets[idx] = updatedPet;
        await _savePets();
      }
      _currentPet = updatedPet;

    } catch (e) {
      _error = '生成失败: $e';
      _generationStatus = null;
    }

    notifyListeners();
  }

  /// 播放宠物叫声
  Future<void> playPetSound(PetModel pet) async {
    if (pet.hasVoice) {
      await audio.play(pet.voicePath!);
    } else {
      // 没有克隆声音时，播放默认叫声
      await audio.playDefault(pet.species);
    }
  }

  /// 叫名字触发反馈（声音+动画信号）
  Future<void> onNameCalled(PetModel pet) async {
    await playPetSound(pet);
    // 动画信号通过 CurrentPet 的 getter 触发 UI 响应
    // 模型层发出事件，UI 层监听
    notifyListeners();
  }

  /// 删除宠物
  Future<void> removePet(String id) async {
    _pets.removeWhere((p) => p.id == id);
    await _savePets();
    if (_currentPet?.id == id) _currentPet = null;
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