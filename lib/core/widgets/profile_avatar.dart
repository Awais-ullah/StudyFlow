import 'dart:io';
import 'package:flutter/material.dart';

/// A profile avatar that renders a LOCAL file with guaranteed correct
/// framing — no stretching, no distortion, regardless of the source
/// file's exact pixel dimensions.
///
/// Why not just use CircleAvatar(backgroundImage: ...)? CircleAvatar
/// gives no control over the image's BoxFit — if the file isn't EXACTLY
/// square, it can appear stretched. Building the circle manually with
/// ClipOval + Image.file(fit: BoxFit.cover) makes the fitting behavior
/// explicit and correct.
class ProfileAvatar extends StatelessWidget {
  final String? imagePath;
  final String fallbackInitial;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.imagePath,
    required this.fallbackInitial,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final file = (imagePath != null && imagePath!.isNotEmpty && !imagePath!.startsWith('http'))
        ? File(imagePath!)
        : null;
    final hasValidLocalFile = file != null && file.existsSync();
    final isNetworkUrl = imagePath != null && imagePath!.startsWith('http');

    return ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: hasValidLocalFile
            ? Image.file(
          file,
          fit: BoxFit.cover,
          width: diameter,
          height: diameter,
          errorBuilder: (context, error, stackTrace) => _fallback(context, diameter),
        )
            : isNetworkUrl
            ? Image.network(
          imagePath!,
          fit: BoxFit.cover,
          width: diameter,
          height: diameter,
          errorBuilder: (context, error, stackTrace) => _fallback(context, diameter),
        )
            : _fallback(context, diameter),
      ),
    );
  }

  Widget _fallback(BuildContext context, double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      color: Theme.of(context).colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        fallbackInitial.isNotEmpty ? fallbackInitial.toUpperCase() : '?',
        style: TextStyle(fontSize: diameter * 0.35),
      ),
    );
  }
}