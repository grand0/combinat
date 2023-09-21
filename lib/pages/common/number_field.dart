import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberField extends StatefulWidget {
  const NumberField({
    super.key,
    this.controller,
    this.decoration,
    this.validator,
  });

  final TextEditingController? controller;
  final InputDecoration? decoration;
  final FormFieldValidator<String>? validator;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      width: expanded ? 200 : 86,
      child: TextFormField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: widget.decoration,
        validator: widget.validator,
        style: const TextStyle(
          fontFamily: "Times New Roman",
          fontSize: 24,
        ),
        onChanged: (text) {
          if (text.length > 2 && !expanded) {
            setState(() {
              expanded = true;
            });
          } else if (text.length <= 2 && expanded) {
            setState(() {
              expanded = false;
            });
          }
        },
      ),
    );
  }
}
