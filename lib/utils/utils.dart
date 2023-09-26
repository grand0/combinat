import 'package:flutter/material.dart';

void showSnackBar({
  required BuildContext context,
  Widget? icon,
  required Widget text,
}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: (icon != null)
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  icon,
                  const SizedBox(width: 8.0),
                  Expanded(child: text),
                ],
              )
            : text,
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(
          side: const BorderSide(),
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: const EdgeInsets.all(8.0),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
