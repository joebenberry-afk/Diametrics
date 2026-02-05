import 'package:flutter/material.dart';
import '../theme.dart';

/// BigButton - Accessibility-first button meeting Engineering Guidelines for touch targets.
///
/// Engineering Guidelines Compliance:
/// - Height: 60px (exceeds Material Design 48dp minimum touch target)
/// - Text Size: 20sp (exceeds 18sp minimum from ARCHITECTURE.md)
/// - Touch Target: 60x60dp minimum (WCAG 2.1 AAA / Material 3 compliant)
/// - Semantics: Full screen reader support via Semantics wrapper
/// - Contrast: 4.5:1 minimum ratio (WCAG AA compliant)
///
/// Usage:
/// ```dart
/// BigButton(
///   label: 'Log Blood Glucose',
///   onPressed: () => navigateToLogging(),
///   icon: Icons.add,
/// )
/// ```
class BigButton extends StatelessWidget {
  /// The text label displayed on the button.
  final String label;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Optional icon displayed before the label.
  final IconData? icon;

  /// Whether to use the secondary/accent color scheme.
  final bool isSecondary;

  /// Optional semantic label for screen readers (defaults to [label]).
  final String? semanticLabel;

  /// Optional semantic hint for screen readers.
  final String? semanticHint;

  /// Minimum height for the button (default: 60px per Engineering Guidelines).
  static const double minHeight = 60.0;

  /// Text size for the button label (default: 20sp per ARCHITECTURE.md).
  static const double textSize = 20.0;

  const BigButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on primary/secondary variant
    final backgroundColor = isSecondary
        ? colorScheme.secondary
        : colorScheme.primary;
    final foregroundColor = isSecondary
        ? colorScheme.onSecondary
        : colorScheme.onPrimary;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel ?? label,
      hint: semanticHint,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: minHeight,
          minWidth: minHeight, // Ensure square minimum touch target
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
            disabledForegroundColor: foregroundColor.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 28, // Larger icon for visibility
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Text(
                  label,
                  style: SeniorTheme.buttonTextStyle.copyWith(
                    color: foregroundColor,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// BigButtonIcon - Icon-only variant of BigButton for compact touch targets.
///
/// Maintains the same 60x60dp minimum touch target as BigButton.
class BigButtonIcon extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Semantic label for screen readers (required for accessibility).
  final String semanticLabel;

  /// Whether to use the secondary/accent color scheme.
  final bool isSecondary;

  const BigButtonIcon({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = isSecondary
        ? colorScheme.secondary
        : colorScheme.primary;
    final foregroundColor = isSecondary
        ? colorScheme.onSecondary
        : colorScheme.onPrimary;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: SizedBox(
        width: BigButton.minHeight,
        height: BigButton.minHeight,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Icon(icon, size: 32, color: foregroundColor),
        ),
      ),
    );
  }
}
