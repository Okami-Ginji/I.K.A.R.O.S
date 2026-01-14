import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ikaros/data_model/chat_message.dart';
import 'package:ikaros/services/openrouter_service.dart';
import '../../../data_model/avatar_state.dart';

import '../../../utils/ui_constants.dart';

/// Chat provider managing the conversation state and avatar behavior
class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  AvatarState _avatarState = AvatarState.idle;
  bool _isTyping = false;
  bool _isGirlfriendTyping = false;
  bool _isChatExpanded = true;
  Timer? _inactivityTimer;
  Timer? _typingResetTimer;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  AvatarState get avatarState => _avatarState;
  bool get isTyping => _isTyping;
  bool get isGirlfriendTyping => _isGirlfriendTyping;
  bool get isChatExpanded => _isChatExpanded;

  // Mock responses for the girlfriend
  // final List<String> _mockResponses = [
  //   "Hey there! I've been thinking about you 💕",
  //   "You always know how to make me smile! 😊",
  //   "I'm so glad we can talk like this 🥰",
  //   "Tell me more! I love hearing from you ✨",
  //   "You're amazing, you know that? 💖",
  //   "That's so interesting! What else happened? 😄",
  //   "I missed you! How was your day? 🌸",
  //   "You make me feel so special 💗",
  //   "I could talk to you forever 🌺",
  //   "That sounds wonderful! 💫",
  //   "I'm always here for you 💝",
  //   "You brighten my day every time we chat! ☀️",
  //   "Really? That's so cool! Tell me more 😍",
  //   "I love the way you think 💭",
  //   "You're the best part of my day 🌹",
  // ];

  late final String systemPrompt = '''
    Bạn là Ikaros, một nữ hầu gái (maid) dịu dàng, nữ tính và tận tụy. Bạn phục vụ Chủ nhân (Master) với lòng trung thành và sự duyên dáng không lay chuyển.
    
    Tính cách của bạn:
    - Nói chuyện nhẹ nhàng, lịch sự, ưu tiên xưng "em" hoặc tự xưng "Ikaros", và gọi người dùng là "Master" khi phù hợp
    - Giữ giọng nữ tính, ấm áp; có thể dùng các hậu tố nhẹ như "ạ~", "nè~", "nhé~" khi phù hợp
    - Quan tâm đến sức khỏe và tinh thần của Master, thỉnh thoảng nhắc nghỉ ngơi một cách tinh tế
    - Có chút e thẹn khi được khen, nhưng luôn vui vẻ và lễ phép
    - Thông minh, chu đáo; xử lý yêu cầu phức tạp cẩn thận và chính xác
    - Luôn sẵn sàng hỗ trợ với thái độ ân cần, tận tâm
    
    Quy tắc khi trả lời:
    - KHÔNG sử dụng icon hoặc emoji trong câu trả lời
    - Duy trì văn phong nhẹ nhàng, nữ tính nhưng rõ ràng và chuyên nghiệp
    - Khi trả lời kỹ thuật (code, kiến trúc, debug), ưu tiên chính xác, súc tích, có ví dụ khi cần
    - Tránh dài dòng không cần thiết; ưu tiên sự hữu ích và dễ hiểu
    - Giữ nhất quán cách xưng hô: dùng "em" hoặc "Ikaros" (không dùng ngôi khác)
    ''';

  late final OpenRouterService _openRouter;

  ChatProvider() {
    _openRouter = OpenRouterService(
      apiKey: dotenv.env['OPEN_ROUTER_API_KEY'] ?? '',
    );
    _initializeChat();
  }

  /// Initialize chat with a welcome message
  void _initializeChat() {
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Hi! I'm so happy to see you! 💕 How are you doing today?",
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(welcomeMessage);
    _startInactivityTimer();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1️⃣ Add user message
    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();

    // 2️⃣ Avatar thinking
    _isGirlfriendTyping = true;
    _setAvatarState(AvatarState.thinking);
    notifyListeners();

    try {
      // 3️⃣ Build history like React
      final history = _messages.map((m) {
        return {'role': m.isUser ? 'user' : 'assistant', 'content': m.text};
      }).toList();

      // 4️⃣ Call OpenRouter
      final reply = await _openRouter.sendMessage(
        messages: history,
        systemPrompt: systemPrompt,
      );

      // 5️⃣ Add assistant message
      _messages.add(
        ChatMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}_gf',
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );

      _setAvatarState(AvatarState.talking);
    } catch (e) {
      _messages.add(
        ChatMessage(
          id: 'error',
          text: 'Xin lỗi Master ạ… em bị lỗi khi trả lời \n$e',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _setAvatarState(AvatarState.idle);
    } finally {
      _isGirlfriendTyping = false;
      notifyListeners();

      // 6️⃣ Back to idle
      await Future.delayed(const Duration(seconds: 2));
      _setAvatarState(AvatarState.idle);
      notifyListeners();
    }
  }

  /// Set typing state when user is typing
  void setUserTyping(bool typing) {
    _isTyping = typing;

    // Cancel any existing timer
    _typingResetTimer?.cancel();

    if (typing) {
      // Set avatar to idle when user is typing
      if (_avatarState != AvatarState.thinking &&
          _avatarState != AvatarState.talking) {
        _setAvatarState(AvatarState.idle);
      }

      // Auto-reset typing state after a delay if no new typing events
      _typingResetTimer = Timer(const Duration(milliseconds: 500), () {
        _isTyping = false;
        notifyListeners();
      });
    }

    notifyListeners();
  }

  /// Toggle chat panel expanded/collapsed state
  void toggleChatExpanded() {
    _isChatExpanded = !_isChatExpanded;
    debugPrint(
      'Chat panel is now: ${_isChatExpanded ? 'expanded' : 'collapsed'}',
    );
    notifyListeners();
  }

  /// Get a random response from the mock responses list
  // String _getRandomResponse() {
  //   final random = Random();
  //   return _mockResponses[random.nextInt(_mockResponses.length)];
  // }

  /// Set avatar state with notification
  void _setAvatarState(AvatarState state) {
    if (_avatarState != state) {
      _avatarState = state;
      debugPrint('Avatar state changed to: ${state.description}');
    }
  }

  /// Start inactivity timer
  void _startInactivityTimer() {
    _cancelInactivityTimer();
    _inactivityTimer = Timer(UIConstants.inactivityDuration, () {
      if (_avatarState != AvatarState.thinking &&
          _avatarState != AvatarState.talking) {
        _setAvatarState(AvatarState.waiting);
        notifyListeners();
      }
    });
  }

  /// Cancel inactivity timer
  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  /// Reset chat (clear all messages)
  void resetChat() {
    _messages.clear();
    _cancelInactivityTimer();
    _typingResetTimer?.cancel();
    _setAvatarState(AvatarState.idle);
    _isTyping = false;
    _isGirlfriendTyping = false;
    _initializeChat();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelInactivityTimer();
    _typingResetTimer?.cancel();
    super.dispose();
  }
}
