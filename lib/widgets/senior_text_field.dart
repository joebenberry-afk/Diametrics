import 'package:flutter/material.dart';
import '../theme.dart';

/// SeniorTextField - Accessibility-first text field matching prototype styling.
///
/// Features:
/// - Minimum 18sp font per ARCHITECTURE.md
/// - Gray background with rounded corners (matches prototypes)
/// - Large touch target for elderly users
/// - Full Semantics support for screen readers
class SeniorTextField extends StatelessWidget {
  /// Controller for the text field.
  final TextEditingController? controller;

  /// Hint text displayed when empty.
  final String hint;

  /// Label text displayed above the field.
  final String? label;

  /// Keyboard type for input.
  final TextInputType? keyboardType;

  /// Whether to obscure text (for passwords).
  final bool obscureText;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Semantic label for screen readers.
  final String? semanticLabel;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Callback when tapped (useful for date pickers).
  final VoidCallback? onTap;

  const SeniorTextField({
    super.key,
    this.controller,
    required this.hint,
    this.label,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.semanticLabel,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: SeniorTheme.labelStyle),
          const SizedBox(height: 8),
        ],
        Semantics(
          label: semanticLabel ?? label ?? hint,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            readOnly: readOnly,
            onTap: onTap,
            style: SeniorTheme.bodyStyle,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: SeniorTheme.bodyStyle.copyWith(
                color: Colors.grey.shade500,
              ),
              filled: true,
              fillColor: SeniorTheme.surfaceWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
