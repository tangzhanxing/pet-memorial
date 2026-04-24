import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

/// 声音克隆服务 - 克隆宠物生前的叫声
/// 支持服务：ElevenLabs, Coqui TTS, MockingBird 等
class SoundCloneService {
  // API密钥配置
  static const String _elevenLabsApiKey = 'YOUR_ELEVENLABS_API_KEY';

  /// 从音频文件克隆声音
  /// [audioPath] - 原始音频文件路径（宠物叫声）
  /// 返回生成的克隆声音文件路径
  static Future<SoundCloneResult> cloneFromAudio(String audioPath) async {
    if (_elevenLabsApiKey == 'YOUR_ELEVENLABS_API_KEY') {
      // 没有API密钥，返回原始音频（演示模式）
      return SoundCloneResult(
        success: true,
        soundPath: audioPath,
        isDemo: true,
      );
    }

    try {
      // 使用 ElevenLabs 声音克隆
      return await _cloneWithElevenLabs(audioPath);
    } catch (e) {
      return SoundCloneResult(
        success: false,
        errorMessage: 'Sound cloning failed: $e',
      );
    }
  }

  /// 从视频提取音频并克隆
  /// [videoPath] - 包含宠物叫声的视频路径
  static Future<SoundCloneResult> cloneFromVideo(String videoPath) async {
    // 在实际实现中，需要先从视频提取音频
    // 可以使用 ffmpeg 或调用视频处理API
    // 这里简化处理，直接复制原文件
    final appDir = await getApplicationDocumentsDirectory();
    final soundDir = Directory('${appDir.path}/PetMemorial/sounds');
    if (!await soundDir.exists()) {
      await soundDir.create(recursive: true);
    }

    final fileName = 'extracted_${DateTime.now().millisecondsSinceEpoch}.wav';
    final targetPath = '${soundDir.path}/$fileName';
    await File(videoPath).copy(targetPath);

    return SoundCloneResult(
      success: true,
      soundPath: targetPath,
      isDemo: true,
      message: 'Video audio extracted (demo mode)',
    );
  }

  /// 使用 ElevenLabs 进行声音克隆
  static Future<SoundCloneResult> _cloneWithElevenLabs(String audioPath) async {
    // 1. 上传音频创建声音克隆
    final uploadUrl = Uri.parse('https://api.elevenlabs.io/v1/voices/add');

    final request = http.MultipartRequest('POST', uploadUrl)
      ..headers['xi-api-key'] = _elevenLabsApiKey
      ..files.add(await http.MultipartFile.fromPath('audio', audioPath))
      ..fields['name'] = 'pet_voice'
      ..fields['description'] = 'Cloned pet voice';

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception('ElevenLabs clone failed: ${response.body}');
    }

    final result = jsonDecode(response.body);
    final voiceId = result['voice_id'];

    // 2. 使用克隆的声音生成示例音频
    // 这里可以生成宠物的"叫"声
    return SoundCloneResult(
      success: true,
      soundPath: null, // 使用 voiceId 通过TTS生成
      voiceId: voiceId,
      isDemo: false,
    );
  }

  /// 生成宠物的叫声（基于克隆的声音）
  /// [voiceId] - 克隆的声音ID
  /// [text] - 要说的话（可以是宠物的名字或叫声）
  static Future<String?> generateBark(String voiceId, String text) async {
    if (_elevenLabsApiKey == 'YOUR_ELEVENLABS_API_KEY') {
      return null; // 演示模式返回null
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId'),
        headers: {
          'xi-api-key': _elevenLabsApiKey,
          'Content-Type': 'application/json',
        ],
        body: jsonEncode({
          'text': text,
          'voice_settings': {
            'stability': 0.3,
            'similarity_boost': 0.8,
          },
        }),
      );

      if (response.statusCode == 200) {
        final appDir = await getApplicationDocumentsDirectory();
        final soundDir = Directory('${appDir.path}/PetMemorial/sounds');
        if (!await soundDir.exists()) {
          await soundDir.create(recursive: true);
        }
        final fileName = 'bark_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final filePath = '${soundDir.path}/$fileName';
        await File(filePath).writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (e) {
      // 忽略错误
    }
    return null;
  }
}

/// 声音克隆结果
class SoundCloneResult {
  final bool success;
  final String? soundPath;   // 本地音频文件路径
  final String? voiceId;     // ElevenLabs声音ID
  final String? errorMessage;
  final bool isDemo;         // 是否演示模式
  final String? message;

  SoundCloneResult({
    required this.success,
    this.soundPath,
    this.voiceId,
    this.errorMessage,
    this.isDemo = false,
    this.message,
  });
}