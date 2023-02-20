import 'package:flutter/material.dart';

import '../config/accesibility_config.dart';

class TextAndLink extends StatefulWidget {
  const TextAndLink(
      {Key? key,
      required this.text1,
      required this.text2,
      required this.navigateTo})
      : super(key: key);
  final String text1;
  final String text2;
  final Widget navigateTo;

  @override
  State<TextAndLink> createState() => _TextAndLinkState();
}

class _TextAndLinkState extends State<TextAndLink> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.text1 != ""
            ? Text(
                widget.text1,
                style: TextStyle(
                  fontFamily: Preferences.currentFont(),
                  color:
                      Preferences.usingDarkMode() ? Colors.white : Colors.black,
                ),
              )
            : Container(),
        widget.text1 != "" ? const Text("   ") : Container(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => widget.navigateTo),
            );
          },
          child: Text(
            widget.text2,
            style: TextStyle(
              fontFamily: Preferences.currentFont(),
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
    );
  }
}
