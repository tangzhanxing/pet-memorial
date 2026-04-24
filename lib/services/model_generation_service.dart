import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// 3D模型生成服务 - 调用云端API
/// 目前支持: Meshy API (https://meshy.ai)
class ModelGenerationService {
  static const String _meshyBaseUrl = 'https://api.meshy.ai/v1';

  // ⚠️ 实际使用时替换为你的API Key
  // 申请地址: https://meshy.ai/
  static const String _apiKey = 'YOUR_MESHY_API_KEY';

  /// 上传照片生成3D模型
  /// [imagePaths] 本地图片路径列表（建议5-20张）
  /// 返回生成进度查询ID
  Future<String?> generateModel(List<String> imagePaths) async {
    try {
      // Step 1: 创建任务
      final createResponse = await http.post(
        Uri.parse('$_meshyBaseUrl/image-to-3d'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image_urls': imagePaths, // 或上传本地图片
          'preset': 'medium', // 'low' | 'medium' | 'high'
          '梗优化': true,
        }),
      );

      if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
        final data = jsonDecode(createResponse.body);
        return data['result']['task_id'];
      } else {
        debugPrint('Model generation failed: ${createResponse.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error generating model: $e');
      return null;
    }
  }

  /// 查询生成状态
  /// 返回状态: 'IN_QUEUE' | 'PROCESSING' | 'COMPLETED' | 'FAILED'
  Future<Map<String, dynamic>?> checkStatus(String taskId) async {
    try {
      final response = await http.get(
        Uri.parse('$_meshyBaseUrl/image-to-3d/$taskId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error checking status: $e');
      return null;
    }
  }

  /// 下载生成的GLB模型到本地
  Future<String?> downloadModel(String modelUrl, String petId) async {
    try {
      final response = await http.get(Uri.parse(modelUrl));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final modelDir = Directory('${dir.path}/models');
        if (!await modelDir.exists()) {
          await modelDir.create(recursive: true);
        }
        final file = File('${modelDir.path}/$petId.glb');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading model: $e');
      return null;
    }
  }

  /// 完整的生成流程（轮询直到完成）
  Future<String?> generateAndDownload(List<String> imagePaths, String petId, {
    Function(double progress)? onProgress,
  }) async {
    final taskId = await generateModel(imagePaths);
    if (taskId == null) return null;

    // 轮询进度（最多等待5分钟）
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 5));

      final status = await checkStatus(taskId);
      if (status == null) continue;

      final state = status['status'] as String;
      final progress = (status['progress'] as num?)?.toDouble() ?? 0.0;
      onProgress?.call(progress);

      if (state == 'COMPLETED') {
        final modelUrl = status['model_urls']?['glb'];
        if (modelUrl != null) {
          return await downloadModel(modelUrl, petId);
        }
      } else if (state == 'FAILED') {
        debugPrint('Model generation failed');
        return null;
      }
    }
    return null;
  }
}