// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

InputDecoration getTextFieldDecoration(BuildContext context) {
  return InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: Colors.grey.shade400,
        width: 1,
      ),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: Colors.red.shade400,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 2,
      ),
    ),
  );
}
