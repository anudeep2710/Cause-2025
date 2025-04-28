import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyCwZi1vhN8C-80PpH4SUWKR092_Q6UjZSw';
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: _apiKey,
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(
        Content.text(message),
      );
      return response.text ?? 'Sorry, I could not process your request.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  void resetChat() {
    _chat = _model.startChat();
  }
}
