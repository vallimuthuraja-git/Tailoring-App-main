import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../screens/avatar/avatar_customization_screen.dart';

class UserAvatar extends StatefulWidget {
  final String displayName;
  final String? imageUrl;
  final double radius;
  final bool showCustomization;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.displayName,
    this.imageUrl,
    this.radius = 20.0,
    this.showCustomization = false,
    this.onTap,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  AvatarCustomization? _customization;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.showCustomization) {
      _loadCustomization();
    }
  }

  Future<void> _loadCustomization() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userProfile?.id;

    if (userId != null) {
      setState(() => _isLoading = true);
      try {
        // Use FirebaseFirestore directly
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('avatar')
            .doc('customization')
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _customization = AvatarCustomization.fromJson(data);
        }
      } catch (e) {
        debugPrint('Error loading avatar customization: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String _extractLetters(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words[0].length >= 2) {
      return words[0].substring(0, 2).toUpperCase();
    } else {
      return words[0][0].toUpperCase();
    }
  }

  Color _generateColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while loading customization
    if (_isLoading && widget.showCustomization) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.grey[300],
        child: const CircularProgressIndicator(),
      );
    }

    // If we have customization and showCustomization is enabled, render custom avatar
    if (widget.showCustomization && _customization != null) {
      return GestureDetector(
        onTap: widget.onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AvatarCustomizationScreen(),
                ),
              );
            },
        child: Container(
          width: widget.radius * 2,
          height: widget.radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _customization!.skinTone.withValues(alpha: 0.8),
                _customization!.skinTone,
              ],
            ),
            border: Border.all(
              color: _customization!.skinTone.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: widget.radius * 0.6,
              height: widget.radius * 0.6,
              decoration: BoxDecoration(
                color: _customization!.eyeColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    }

    // Default fallback: profile image or initials
    if (widget.imageUrl != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: CircleAvatar(
          radius: widget.radius,
          backgroundImage: NetworkImage(widget.imageUrl!),
          backgroundColor: Colors.grey[300],
        ),
      );
    }

    final letters = _extractLetters(widget.displayName);
    final backgroundColor = _generateColor(widget.displayName);

    return GestureDetector(
      onTap: widget.onTap,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: backgroundColor,
        child: Text(
          letters,
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.radius * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
