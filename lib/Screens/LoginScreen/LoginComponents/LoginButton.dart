import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final double width;
  final double height;
  final Color backgroundColor; // New color parameter
  final Color textColor;
  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.label,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor, // Use the passed color
        borderRadius: BorderRadius.circular(12),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
