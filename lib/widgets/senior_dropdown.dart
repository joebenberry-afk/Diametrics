import 'package:flutter/material.dart';
import '../theme.dart';

/// SeniorDropdown - Accessibility-first dropdown matching prototype styling.
///
/// Features:
/// - Minimum 48dp touch target per Engineering Guidelines
/// - Large 18sp+ font for readability
/// - Gray/white background with rounded corners (matches prototypes)
/// - Full Semantics support for screen readers
class SeniorDropdown<T> extends StatelessWidget {
  /// List of items to display in the dropdown.
  final List<DropdownMenuItem<T>> items;

  /// Currently selected value.
  final T? value;

  /// Callback when selection changes.
  final ValueChanged<T?>? onChanged;

  /// Hint text when no value is selected.
  final String hint;

  /// Semantic label for screen readers.
  final String? semanticLabel;

  const SeniorDropdown({
    super.key,
    required this.items,
    required this.hint,
    this.value,
    this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? hint,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            hint: Text(
              hint,
              style: SeniorTheme.bodyStyle.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            style: SeniorTheme.bodyStyle,
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
