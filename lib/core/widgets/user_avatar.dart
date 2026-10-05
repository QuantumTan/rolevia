import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../design/colors.dart';
import 'pressable.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.initial,
    this.size = 32,
    this.onTap,
    this.showEditBadge = false,
  });

  final String? avatarUrl;
  final String initial;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final letter = initial.trim().isNotEmpty ? initial.trim()[0].toUpperCase() : 'U';

    Widget content;
    final url = avatarUrl?.trim();
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        content = ClipOval(
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _fallbackLetter(colors, letter),
          ),
        );
      } else if (!kIsWeb && File(url).existsSync()) {
        content = ClipOval(
          child: Image.file(
            File(url),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _fallbackLetter(colors, letter),
          ),
        );
      } else {
        content = _fallbackLetter(colors, letter);
      }
    } else {
      content = _fallbackLetter(colors, letter);
    }

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: content,
    );

    if (showEditBadge) {
      final badgeSize = (size * 0.36).clamp(20.0, 28.0);
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.surface,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: badgeSize * 0.55,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return PressableScale(
        onPressed: onTap,
        semanticLabel: 'Profile picture',
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _fallbackLetter(AppColors colors, String letter) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: (size * 0.44).clamp(12.0, 32.0),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
