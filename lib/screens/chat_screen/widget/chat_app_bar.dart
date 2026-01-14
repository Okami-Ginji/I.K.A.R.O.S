import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBackPressed;
  final String? avatarAsset;
  final String? nameText;
  final String? statusText;

  const ChatAppBar({
    super.key,
    this.onMenuPressed,
    this.onBackPressed,
    this.avatarAsset,
    this.statusText,
    this.nameText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 4),

          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: onBackPressed ?? () => Navigator.maybePop(context),
            splashRadius: 20,
          ),

          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(
              avatarAsset ?? 'assets/images/avatar.png',
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nameText ?? dotenv.env['APP_NAME'] ?? 'Chat Bot',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                statusText ?? 'Đang hoạt động',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onMenuPressed,
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
