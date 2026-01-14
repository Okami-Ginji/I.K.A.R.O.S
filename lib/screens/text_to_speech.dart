import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechPage extends StatefulWidget {
  const TextToSpeechPage({super.key});

  @override
  State<TextToSpeechPage> createState() => _TextToSpeechPageState();
}

class _TextToSpeechPageState extends State<TextToSpeechPage> {
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  String _selectedLanguage = 'ja-JP';
  String _selectedGender = 'female';
  double _speechRate = 0.45;

  List<dynamic> _voices = [];

  final Map<String, String> _languages = {
    'ja-JP': 'Tiếng Nhật',
    'en-US': 'Tiếng Anh',
    'vi-VN': 'Tiếng Việt',
  };

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setSpeechRate(_speechRate);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _voices = await _tts.getVoices;
    await _applyVoice();
  }

  Future<void> _applyVoice() async {
    await _tts.setLanguage(_selectedLanguage);

    final candidates = _voices.where((voice) {
      final locale = voice['locale'];
      final gender = voice['gender']?.toString().toLowerCase();
      return locale == _selectedLanguage &&
          (gender == null || gender == _selectedGender);
    }).toList();

    if (candidates.isNotEmpty) {
      await _tts.setVoice({
        'name': candidates.first['name'],
        'locale': candidates.first['locale'],
      });
    }
  }

  Future<void> _speak() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Text To Speech'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextInput(theme),
            const SizedBox(height: 16),
            _buildLanguageSelector(),
            const SizedBox(height: 12),
            _buildGenderSelector(),
            const SizedBox(height: 12),
            _buildSpeedSelector(),
            const Spacer(),
            _buildSpeakButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(ThemeData theme) {
    return TextField(
      controller: _textController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'Nhập nội dung cần đọc...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: theme.textTheme.bodyLarge,
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      children: [
        const Text('Ngôn ngữ'),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButton<String>(
            value: _selectedLanguage,
            isExpanded: true,
            items: _languages.entries
                .map(
                  (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                )
                .toList(),
            onChanged: (value) async {
              if (value == null) return;
              _selectedLanguage = value;
              await _applyVoice();
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        const Text('Giọng'),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: _selectedGender,
          items: const [
            DropdownMenuItem(value: 'female', child: Text('Nữ')),
            DropdownMenuItem(value: 'male', child: Text('Nam')),
          ],
          onChanged: (value) async {
            if (value == null) return;
            _selectedGender = value;
            await _applyVoice();
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildSpeedSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tốc độ nói'),
        Slider(
          value: _speechRate,
          min: 0.2,
          max: 0.8,
          divisions: 6,
          label: _speechRate.toStringAsFixed(2),
          onChanged: (value) async {
            _speechRate = value;
            await _tts.setSpeechRate(value);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildSpeakButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _speak,
        child: const Text('Phát giọng nói'),
      ),
    );
  }
}
