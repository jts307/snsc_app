import 'package:flutter/material.dart';
import 'package:snsc/config/accesibility_config.dart';
import 'package:snsc/config/pallete.dart';

class AccessibilityButon extends StatefulWidget {
  final List<String> texts;
  final List<Icon> iconList;
  const AccessibilityButon({
    Key? key,
    required this.texts,
    required this.iconList,
  }) : super(key: key);

  @override
  State<AccessibilityButon> createState() => _AccessibilityButonState();
}

class _AccessibilityButonState extends State<AccessibilityButon> {
  late int index;

  changeSetting() {
    if (index == widget.texts.length - 1) {
      setState(() {
        index = 0;
      });
    } else {
      setState(() {
        index = index += 1;
      });
    }

    if (index == 0) {
      Preferences.setRegularFont();
    }
    if (index == 1) {
      Preferences.setDyslexicFont();
    }
  }

  @override
  void initState() {
    super.initState();

    if (Preferences.useFont() == "regular") {
      index = 0;
    }
    if (Preferences.useFont() == "dyslexic") {
      index = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        changeSetting();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1.5),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: widget.iconList[index],
              ),
              SizedBox(
                height: 30,
                child: Text(
                  widget.texts[index],
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Wrap(
                spacing: 3,
                children: [
                  Container(
                    width: 20,
                    height: 5,
                    decoration: BoxDecoration(
                        color: index == 0 ? Pallete.buttonGreen : Colors.grey,
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  Container(
                    width: 20,
                    height: 5,
                    decoration: BoxDecoration(
                        color: index == 1 ? Pallete.buttonGreen : Colors.grey,
                        borderRadius: BorderRadius.circular(24)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
