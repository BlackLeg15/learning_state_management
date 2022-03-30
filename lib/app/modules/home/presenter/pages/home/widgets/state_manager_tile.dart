import 'package:flutter/material.dart';

class StateManagerTile extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  const StateManagerTile({Key? key, required this.onPressed, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(label, style: const TextStyle(color: Colors.white)),
      onPressed: onPressed,
    );
  }
}
