import 'package:flutter/material.dart';

class PersonAvatar extends StatelessWidget {
  final String photoUrl;
  final String fullName;
  final double radius;
  final String? heroTag;

  const PersonAvatar({
    super.key,
    required this.photoUrl,
    required this.fullName,
    this.radius = 24,
    this.heroTag,
  });

  String get _initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final diameter = radius * 2;

    Widget avatar = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.12),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: photoUrl.trim().isNotEmpty
            ? Image.network(
                photoUrl,
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallback(colorScheme),
              )
            : _buildFallback(colorScheme),
      ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: avatar,
      );
    }
    return avatar;
  }

  Widget _buildFallback(ColorScheme colorScheme) {
    return Center(
      child: Text(
        _initials,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.64,
          height: 1.0,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}
