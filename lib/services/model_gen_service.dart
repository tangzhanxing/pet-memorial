import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:math';

/// 生成状态
enum GenerationStatus { pending, processing, completed, failed }

/// 3D模型生成服务 - 连接云端AI API
/// 支持多种后端：Meshy, Luma AI, Tripo3D 等
class ModelGenService {
  // ===== 可配置的API密钥 =====
  // 请替换为你申请的API密钥
  static const String _meshyApiKey = 'YOUR_MESHY_API_KEY';
static const String _tripoApiKey = 'YOUR_TRIPO_API_KEY';

 /// 生成结果
  static Future<ModelGenResult> generateFromImages(List<String> imagePaths) async {
    // 检查是否有可用的API密钥
    if (_meshyApiKey == 'YOUR_MESHY_API_KEY' && _tripoApiKey == 'YOUR_TRIPO_API_KEY') {
      // 没有API密钥，返回示例模型用于开发测试
      return _getDemoModel();
    }

    // 实际调用API的逻辑（等你有密钥后启用）
    try {
      return await _generateWithMeshy(imagePaths);
    } catch (e) {
      // 如果Meshy失败，尝试其他服务
      try {
        return await _generateWithTripo(imagePaths);
      } catch (e2) {
        return ModelGenResult(
          success: false,
          errorMessage: 'All 3D generation services failed: $e2',
        );
      }
    }
  }

  /// 使用 Meshy AI 生成3D模型
  /// 文档: https://docs.meshy.ai/api-reference
  static Future<ModelGenResult> _generateWithMeshy(List<String> imagePaths) async {
    // 1. 上传图片
    final uploadUrl = Uri.parse('https://api.meshy.ai/v1/image-to-3d');

    for (final imagePath in imagePaths) {
      final request = http.MultipartRequest('POST', uploadUrl)
        ..headers['Authorization'] = 'Bearer $_meshyApiKey'
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Upload failed: ${response.body}');
      }

      final result = jsonDecode(response.body);
      final taskId = result['result']['task_id'];

      // 2. 轮询任务状态
      final modelUrl = await _pollMeshyTask(taskId);

      // 3. 下载模型
      final localPath = await _downloadModel(modelUrl, 'mesh_$imagePath.glb');
      return ModelGenResult(success: true, modelPath: localPath);
    }

    throw Exception('No images processed');
  }

  /// 轮询 Meshy 任务直到完成
  static Future<String> _pollMeshyTask(String taskId, {int maxAttempts = 60}) async {
    final statusUrl = Uri.parse('https://api.meshy.ai/v1/image-to-3d/$taskId');

    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 5));

      final response = await http.get(
        statusUrl,
        headers: {'Authorization': 'Bearer $_meshyApiKey'},
      );

      final result = jsonDecode(response.body);
      final status = result['status'];

      if (status == 'completed') {
        return result['result']['model_urls']['glb'];
      } else if (status == 'failed') {
        throw Exception('Model generation failed: ${result['error']}');
      }
    }

    throw Exception('Timeout waiting for model generation');
  }

  /// 使用 Tripo3D 生成3D模型
  /// 文档: https://www.tripo3d.ai/docs
  static Future<ModelGenResult> _generateWithTripo(List<String> imagePaths) async {
    final uploadUrl = Uri.parse('https://api.tripo3d.ai/v1/openapi/形象重建');

    final request = http.MultipartRequest('POST', uploadUrl)
      ..headers['Authorization'] = $_tripoApiKey
      ..files.add(await http.MultipartFile.fromPath('image', imagePaths.first));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Tripo upload failed: ${response.body}');
    }

    final result = jsonDecode(response.body);
    final taskId = result['data']['task_id'];

    // 轮询直到完成
    String? modelUrl;
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 5));

      final statusResponse = await http.get(
        Uri.parse('https://api.tripo3d.ai/v1/openapi/形象重建/$taskId'),
        headers: {'Authorization': 'Bearer $_tripoApiKey'},
      );

      final statusResult = jsonDecode(statusResponse.body);
      if (statusResult['status'] == 'completed') {
        modelUrl = statusResult['data']['model_url'];
        break;
      }
    }

    if (modelUrl == null) throw Exception('Tripo generation timeout');

    final localPath = await _downloadModel(modelUrl, 'tripo_model.glb');
    return ModelGenResult(success: true, modelPath: localPath);
  }

  /// 下载模型文件到本地
  static Future<String> _downloadModel(String url, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${appDir.path}/PetMemorial/models');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }

    final localPath = '${modelDir.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    await File(localPath).writeAsBytes(response.bodyBytes);

    return localPath;
  }

  /// 获取演示模型（无API密钥时使用）
  static ModelGenResult _getDemoModel() {
    // 返回null表示使用内置的示例模型
    return ModelGenResult(success: true, modelPath: null, isDemo: true);
  }
}

/// 3D模型生成结果
class ModelGenResult {
  final bool success;
  final String? modelPath;
  final String? errorMessage;
  final bool isDemo;  // 是否是演示模型

  ModelGenResult({
    required this.success,
    this.modelPath,
    this.errorMessage,
    this.isDemo = false,
  });
}