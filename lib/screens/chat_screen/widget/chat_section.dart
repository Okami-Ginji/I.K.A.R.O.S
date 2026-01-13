import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_list_view.dart';
import 'chat_provider.dart';

/// Chat Section (expanded) with header and collapse action
class ChatSection extends StatelessWidget {
  const ChatSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Header area: now tappable and draggable to collapse
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: chatProvider.toggleChatExpanded,
                onVerticalDragUpdate: (details) {
                  // Swipe down to collapse
                  if (details.primaryDelta != null &&
                      details.primaryDelta! > 6) {
                    if (chatProvider.isChatExpanded)
                      chatProvider.toggleChatExpanded();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Chat',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Thu gọn',
                        onPressed: () => chatProvider.toggleChatExpanded(),
                        icon: const Icon(Icons.expand_more_rounded),
                        color: theme.colorScheme.primary,
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(child: ChatListView()),
            ],
          ),
        );
      },
    );
  }
}

/// Collapsed bar shown when chat is collapsed
class ChatCollapsedBar extends StatelessWidget {
  const ChatCollapsedBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: chatProvider.toggleChatExpanded,
          onVerticalDragUpdate: (details) {
            // Swipe up to expand
            if (details.primaryDelta != null && details.primaryDelta! < -6) {
              if (!chatProvider.isChatExpanded)
                chatProvider.toggleChatExpanded();
            }
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Chat đã thu gọn',
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Mở rộng',
                  onPressed: () => chatProvider.toggleChatExpanded(),
                  icon: const Icon(Icons.expand_less_rounded),
                  color: theme.colorScheme.primary,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
