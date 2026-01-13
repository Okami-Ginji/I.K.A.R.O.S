import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../data_model/avatar_state.dart';
import '../../../data_model/chat_message.dart';
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
  final List<String> _mockResponses = [
    "Hey there! I've been thinking about you 💕",
    "You always know how to make me smile! 😊",
    "I'm so glad we can talk like this 🥰",
    "Tell me more! I love hearing from you ✨",
    "You're amazing, you know that? 💖",
    "That's so interesting! What else happened? 😄",
    "I missed you! How was your day? 🌸",
    "You make me feel so special 💗",
    "I could talk to you forever 🌺",
    "That sounds wonderful! 💫",
    "I'm always here for you 💝",
    "You brighten my day every time we chat! ☀️",
    "Really? That's so cool! Tell me more 😍",
    "I love the way you think 💭",
    "You're the best part of my day 🌹",
  ];

  ChatProvider() {
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

  /// Send a user message and trigger girlfriend response
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_user',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    _setAvatarState(AvatarState.idle);
    _isTyping = false;
    notifyListeners();

    // Reset inactivity timer
    _cancelInactivityTimer();
    _startInactivityTimer();

    // Simulate girlfriend thinking
    await Future.delayed(UIConstants.thinkingDelay);
    _isGirlfriendTyping = true;
    _setAvatarState(AvatarState.thinking);
    notifyListeners();

    // Simulate girlfriend typing and reply
    await Future.delayed(UIConstants.replyDelay);
    _isGirlfriendTyping = false;

    final girlfriendMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_gf',
      text: _getRandomResponse(),
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(girlfriendMessage);
    _setAvatarState(AvatarState.talking);
    notifyListeners();

    // Return to idle after talking
    await Future.delayed(const Duration(seconds: 2));
    if (_avatarState == AvatarState.talking) {
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
      if (_avatarState != AvatarState.thinking && _avatarState != AvatarState.talking) {
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
    debugPrint('Chat panel is now: ${_isChatExpanded ? 'expanded' : 'collapsed'}');
    notifyListeners();
  }

  /// Get a random response from the mock responses list
  String _getRandomResponse() {
    final random = Random();
    return _mockResponses[random.nextInt(_mockResponses.length)];
  }

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
      if (_avatarState != AvatarState.thinking && _avatarState != AvatarState.talking) {
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
