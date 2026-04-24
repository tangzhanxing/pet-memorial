import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_data.dart';

class StorageService {
  static const String _petsKey = 'pets_data';
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 保存宠物列表到本地
  static Future<void> savePets(List<PetData> pets) async {
    final jsonList = pets.map((p) => p.toJson()).toList();
    await _prefs.setString(_petsKey, jsonEncode(jsonList));
  }

  /// 加载宠物列表
  static Future<List<PetData>> loadPets() async {
    final jsonStr = _prefs.getString(_petsKey);
    if (jsonStr == null) return [];
    try {
      final jsonList = jsonDecode(jsonStr) as List;
      return jsonList.map((j) => PetData.fromJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取应用文档目录（用于存储模型文件）
  static Future<String> getAppDocPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// 保存文件到应用目录
  static Future<String> saveFile(String sourcePath, String fileName) async {
    final appDir = await getAppDocPath();
    final targetDir = Directory('$appDir/PetMemorial');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    final targetPath = '${targetDir.path}/$fileName';
    await File(sourcePath).copy(targetPath);
    return targetPath;
  }

  /// 删除宠物相关文件
  static Future<void> deletePetFiles(String petId) async {
    final appDir = await getAppDocPath();
    final petDir = Directory('$appDir/PetMemorial/$petId');
    if (await petDir.exists()) {
      await petDir.delete(recursive: true);
    }
  }
}