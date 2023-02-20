import 'package:flutter/material.dart';
import 'package:snsc/config/accesibility_config.dart';

class RoundedRectangleButton extends StatelessWidget {
  final double width;
  final double height;
  final String text;
  final Color buttoncolor;
  final void Function() onPressed;

  const RoundedRectangleButton(
      {Key? key,
      required this.width,
      required this.onPressed,
      required this.text,
      required this.buttoncolor,
      required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(29),
          child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                primary: buttoncolor,
                elevation: 15,
                shadowColor: Colors.black,
              ),
              child: FittedBox(
                child: Text(
                  text,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontFamily: Preferences.currentFont()),
                ),
              ))),
    );
  }
}
