import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class ResultWidget extends StatelessWidget {
  const ResultWidget({
    super.key,
    required this.result,
    this.resultToCopy,
    this.copyCallback,
    this.prefix,
    this.fontSize,
    this.prefixStyle,
    this.style,
    this.isTex = false,
    this.alignment,
  });

  final String result;
  final String? resultToCopy;
  final void Function(String copied)? copyCallback;
  final String? prefix;
  final double? fontSize;
  final TextStyle? prefixStyle;
  final TextStyle? style;
  final bool isTex;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: resultToCopy ?? result));
        copyCallback?.call(resultToCopy ?? result);
      },
      child: Stack(
        alignment: alignment ?? Alignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 24.0,
            ),
            child: isTex ? _buildTex(context) : _buildRichText(context),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 24,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  stops: const [0.2, 1.0],
                  colors: [
                    Theme.of(context).colorScheme.background,
                    Theme.of(context).colorScheme.background.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 24,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  stops: const [0.0, 0.8],
                  colors: [
                    Theme.of(context).colorScheme.background.withAlpha(0),
                    Theme.of(context).colorScheme.background,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTex(BuildContext context) {
    return Math.tex(
      "${prefix ?? ""}$result",
      textStyle: style?.copyWith(fontSize: fontSize ?? 28) ??
          TextStyle(
            fontSize: fontSize ?? 28,
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }

  Widget _buildRichText(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: fontSize ?? 28),
        children: <TextSpan>[
          TextSpan(
            text: prefix ?? "= ",
            style: prefixStyle ??
                const TextStyle(
                  color: Colors.grey,
                ),
          ),
          TextSpan(
            text: result,
            style: style ??
                TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
