import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A prompt dialog around a single [TextField], returning the entered text on
/// confirm and null on cancel/dismiss.
///
/// The controller lives in the dialog's own State so it is disposed with the
/// route. The previous pattern — caller-owned controller disposed in a
/// `finally` right after `showDialog` resolves — killed the controller while
/// the dialog was still animating out, and the IME teardown could then touch
/// the disposed notifier (throws in debug/profile builds).
Future<String?> showTextPromptDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required String cancelLabel,
  String? initial,
  String? hintText,
  String? helperText,
  String? suffixText,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  int minLines = 1,
  int maxLines = 1,
  bool outlined = false,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextPromptDialog(
      title: title,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      initial: initial,
      hintText: hintText,
      helperText: helperText,
      suffixText: suffixText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      outlined: outlined,
    ),
  );
}

class _TextPromptDialog extends StatefulWidget {
  final String title, confirmLabel, cancelLabel;
  final String? initial, hintText, helperText, suffixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int minLines, maxLines;
  final bool outlined;

  const _TextPromptDialog({
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.initial,
    required this.hintText,
    required this.helperText,
    required this.suffixText,
    required this.keyboardType,
    required this.inputFormatters,
    required this.minLines,
    required this.maxLines,
    required this.outlined,
  });

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          hintText: widget.hintText,
          helperText: widget.helperText,
          suffixText: widget.suffixText,
          border: widget.outlined ? const OutlineInputBorder() : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
