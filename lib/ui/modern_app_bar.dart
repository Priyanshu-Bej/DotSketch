import 'package:flutter/material.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const ModernAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12, right: 4),
        child: Image.asset(
          'assets/images/app_logo.jpg',
          fit: BoxFit.contain,
          height: 32,
          width: 32,
        ),
      ),
      title: Text(title),
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.deepPurple,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            showAboutDialog(
              context: context,
              applicationName: 'DotSketch',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2025 Priyanshu-Bej',
              applicationIcon: const Icon(
                Icons.palette,
                size: 48,
                color: Colors.deepPurple,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
