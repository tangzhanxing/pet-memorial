import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 语音服务：语音识别 + 语音合成
class SpeechService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  String? _errorMessage;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  String? get errorMessage => _errorMessage;

  /// 初始化语音引擎
  Future<bool> init() async {
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          _errorMessage = error.errorMsg;
          notifyListeners();
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );

      if (_isInitialized) {
        await _flutterTts.setLanguage('en-US');
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setPitch(1.0);
      }

      notifyListeners();
      return _isInitialized;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 开始监听语音
  Future<void> startListening({required Function(String) onResult}) async {
    if (!_isInitialized) {
      final ok = await init();
      if (!ok) return;
    }

    if (_isListening) return;

    _isListening = true;
    _lastWords = '';
    _errorMessage = null;
    notifyListeners();

    await _speechToText.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        onResult(_lastWords);
        notifyListeners();
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
    );
  }

  /// 停止监听
  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  /// 文字转语音（让宠物"说话"）
  Future<void> speak(String text) async {
    if (!_isInitialized) await init();
    await _flutterTts.speak(text);
  }

  /// 停止说话
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}