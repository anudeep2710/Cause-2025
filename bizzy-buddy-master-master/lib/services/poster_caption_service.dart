import 'package:google_generative_ai/google_generative_ai.dart';

class PosterCaptionService {
  static const String _apiKey = 'AIzaSyCwZi1vhN8C-80PpH4SUWKR092_Q6UjZSw';
  late final GenerativeModel _model;

  PosterCaptionService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: _apiKey,
    );
  }

  Future<String> generateCaption({
    required String productName,
    required String productDescription,
    required String targetAudience,
    required String style,
  }) async {
    try {
      final prompt = '''
Generate a creative and engaging caption for a product poster with the following details:
Product: $productName
Description: $productDescription
Target Audience: $targetAudience
Style: $style

The caption should be:
- Catchy and memorable
- Relevant to the product and target audience
- Match the specified style
- Be between 5-15 words
- Include relevant hashtags if appropriate
''';

      final response = await _model.generateContent(
        [Content.text(prompt)],
      );

      return response.text ?? 'Unable to generate caption';
    } catch (e) {
      return 'Error generating caption: ${e.toString()}';
    }
  }

  // Test function to demonstrate caption generation
  static Future<void> testCaptionGeneration() async {
    final service = PosterCaptionService();
    final caption = await service.generateCaption(
      productName: 'Eco-Friendly Water Bottle',
      productDescription:
          'A sustainable water bottle made from recycled materials, keeping your drinks cold for 24 hours',
      targetAudience: 'Environmentally conscious young adults',
      style: 'Modern and Minimalist',
    );
    print('Generated Caption: $caption');
  }
}
