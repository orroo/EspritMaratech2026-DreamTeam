import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:flutter/foundation.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isAvailable = false;

  bool get isAvailable => _isAvailable;
  bool get isListening => _speechToText.isListening;

  Function(String)? _onStatus;
  Function(SpeechRecognitionError)? _onError;
  Function(double)? _onSoundLevelChange;

  Future<bool> initialize() async {
    try {
      _isAvailable = await _speechToText.initialize(
        onStatus: (status) {
          if (kDebugMode) print('Speech status: $status');
          _onStatus?.call(status);
        },
        onError: (error) {
          if (kDebugMode) print('Speech error: $error');
          _onError?.call(error);
        },
      );
      return _isAvailable;
    } catch (e) {
      if (kDebugMode) print('Speech initialization error: $e');
      return false;
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onStatus,
    Function(SpeechRecognitionError)? onError,
    Function(double)? onSoundLevelChange,
  }) async {
    _onStatus = onStatus;
    _onError = onError;
    _onSoundLevelChange = onSoundLevelChange;

    if (!_isAvailable) {
      bool available = await initialize();
      if (!available) return;
    }

    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      onSoundLevelChange: (level) {
        _onSoundLevelChange?.call(level);
      },
      localeId: "fr_FR",
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      cancelOnError: true,
      partialResults: false,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }
}
