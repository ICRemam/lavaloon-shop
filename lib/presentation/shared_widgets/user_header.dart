import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavaloon_assessment/data/models/auth_user.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_state.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  static const String _logoutValue = 'logout';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => previous.user != current.user || previous.isOfflineSession != current.isOfflineSession,
      builder: (context, state) {
        final user = state.user;
        if (user == null) return const SizedBox.shrink();

        final nameWidth = MediaQuery.sizeOf(context).width < 420 ? 88.0 : 160.0;

        return PopupMenuButton<String>(
          tooltip: user.fullName,
          offset: const Offset(0, kToolbarHeight - 8),
          onSelected: (value) {
            if (value == _logoutValue) unawaited(context.read<AuthCubit>().logout());
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                user.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ),
            if (user.email != null)
              PopupMenuItem<String>(
                enabled: false,
                child: Text(user.email!, style: const TextStyle(fontSize: 12)),
              ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: _logoutValue,
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: nameWidth < 100 ? 4 : 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserAvatar(user: user, reloadOnline: !state.isOfflineSession),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: nameWidth),
                  child: Text(user.fullName, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class UserAvatar extends StatefulWidget {
  final AuthUser user;
  final double radius;
  final bool reloadOnline;

  const UserAvatar({super.key, required this.user, this.radius = 18, this.reloadOnline = true});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  var _recoveredFromOffline = false;

  @override
  void didUpdateWidget(UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.reloadOnline && widget.reloadOnline) _recoveredFromOffline = true;
  }

  String get _initials {
    final name = widget.user.fullName.trim();
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final image = widget.user.image;
    final hasImage = image != null && image.isNotEmpty;

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: colorScheme.primaryContainer,
      foregroundImage: !hasImage
          ? null
          : NetworkImage(image, headers: _recoveredFromOffline ? const {'Cache-Control': 'no-cache'} : null),
      onForegroundImageError: hasImage ? (_, _) {} : null,
      child: Text(
        _initials,
        style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600),
      ),
    );
  }
}
