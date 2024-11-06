import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveDialogTextField extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  const AdaptiveDialogTextField({
    super.key,
    this.placeholder,
    this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoTextField(
          controller: controller,
          obscureText: obscureText,
          placeholder: placeholder,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      default:
        return TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: placeholder,
          ),
        );
    }
  }
}
