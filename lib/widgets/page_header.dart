import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.titleKey,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Key? titleKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (onBack != null)
            Positioned(
              left: 4,
              child: IconButton(
                key: const Key('page-back'),
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
            ),
          Text(
            title,
            key: titleKey,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
          ),
          if (trailing != null) Positioned(right: 4, child: trailing!),
        ],
      ),
    );
  }
}
