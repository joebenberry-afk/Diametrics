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

  /// Whether the dropdown should have a cyan background
  final bool isCyan;

  const SeniorDropdown({
    super.key,
    required this.items,
    required this.hint,
    this.value,
    this.onChanged,
    this.semanticLabel,
    this.isCyan = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? hint,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          color: isCyan ? SeniorTheme.primaryCyan : SeniorTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            hint: Text(
              hint,
              style: SeniorTheme.bodyStyle.copyWith(
                color: isCyan ? SeniorTheme.surfaceBlack : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            style: SeniorTheme.bodyStyle.copyWith(
              color: SeniorTheme.surfaceBlack,
              fontSize: 16,
            ),
            dropdownColor: SeniorTheme.surfaceWhite,
            icon: Icon(
              Icons.arrow_downward,
              color: isCyan ? SeniorTheme.surfaceBlack : Colors.grey.shade600,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
