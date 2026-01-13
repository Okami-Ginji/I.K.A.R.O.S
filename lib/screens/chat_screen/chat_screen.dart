import 'package:flutter/material.dart';
import 'package:ikaros/screens/chat_screen/widget/avatar_view.dart';
import 'package:ikaros/screens/chat_screen/widget/chat_input_bar.dart';
import 'package:ikaros/screens/chat_screen/widget/chat_provider.dart';
import 'package:ikaros/screens/chat_screen/widget/chat_section.dart';
import 'package:provider/provider.dart';

/// Main chat screen with three sections: Avatar, Chat, and Input
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💕'),
            const SizedBox(width: 8),
            Text(
              'My Girlfriend',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showOptionsMenu(context),
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'Options',
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          final isExpanded = chatProvider.isChatExpanded;
          return Column(
            children: [
              // Avatar Area: grows when chat is collapsed
              Expanded(
                flex: isExpanded ? 45 : 85,
                child: AvatarView(state: chatProvider.avatarState),
              ),

              // Chat Area: expanded section or collapsed bar
              if (isExpanded)
                const Expanded(flex: 55, child: ChatSection())
              else
                const ChatCollapsedBar(),

              // Input Area (fixed at bottom)
              const ChatInputBar(),
            ],
          );
        },
      ),
    );
  }

  /// Show options menu
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Menu items
              ListTile(
                leading: Icon(
                  Icons.refresh_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Reset Chat'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatProvider>().resetChat();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chat has been reset'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.settings_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings coming soon!'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.info_outline_rounded,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Virtual Girlfriend'),
        content: const Text(
          'A beautiful chat interface with animated avatar states. '
          'The avatar is designed to be replaceable with Live2D, 3D models, or WebView content in the future.\n\n'
          'Built with Flutter & Provider.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
