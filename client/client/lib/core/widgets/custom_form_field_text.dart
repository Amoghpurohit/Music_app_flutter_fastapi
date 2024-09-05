import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      required this.text,
      required this.controller,
      this.isObscured = false,
      this.readOnly = false,
      this.onTap,
      });        //this field is not required and
      // thus we have initialized it as false and we override it with true for password

  final String text;
  final TextEditingController? controller;
  final bool isObscured;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      onTap: onTap,
      controller: controller,
      decoration: InputDecoration(
        //labelText: text,
        hintText: text,
      ),
      obscureText: isObscured,
      validator: (value) {
        if (value!.trim().isEmpty) {
          return '$text is empty';
        } else {
          return null;
        }
      },
    );
  }
}
