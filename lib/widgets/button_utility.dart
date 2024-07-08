import 'package:flutter/material.dart';

Widget myButton(String text, VoidCallback Func) {
  return InkWell(
    onTap: Func,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}
