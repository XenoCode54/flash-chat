import 'package:flutter/material.dart';

class LogButton extends StatelessWidget {
  final Color logColor;
  final String label;
  final Function pressed;

  LogButton({this.logColor, this.label, @required this.pressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: logColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: pressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
