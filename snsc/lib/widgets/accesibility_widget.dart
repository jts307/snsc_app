import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:snsc/config/accesibility_config.dart';
import 'package:snsc/widgets/all_widgets.dart';

import '../config/pallete.dart';

class AccesibilityWidget extends StatefulWidget {
  const AccesibilityWidget({Key? key}) : super(key: key);

  @override
  State<AccesibilityWidget> createState() => _AccesibilityWidgetState();
}

class _AccesibilityWidgetState extends State<AccesibilityWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("ACCESSIBILITY SETTINGS",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0)),
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color.fromARGB(255, 239, 241, 245),
      content: SizedBox(
        width: 170,
        height: 200,
        // height: 200,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  AccessibilityButon(texts: [
                    "Default Font",
                    "Dyslexia Friendly",
                  ], iconList: [
                    Icon(Icons.abc, size: 50),
                    Icon(Icons.abc, size: 50),
                  ]),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 150,
                height: 40,
                child: AnimatedToggleSwitch<bool>.dual(
                  current: Preferences.usingDarkMode(),
                  first: false,
                  second: true,
                  innerColor: Pallete.buttonGreen,
                  dif: 50.0,
                  borderColor: Colors.transparent,
                  borderWidth: 2.0,
                  height: 40,
                  animationOffset: const Offset(15.0, 0),
                  clipAnimation: true,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => Preferences.usingDarkMode()
                        ? Preferences.setLightMode()
                        : Preferences.setDarkMode());
                  },
                  colorBuilder: (value) => value ? Colors.black : Colors.white,
                  iconBuilder: (value) => value
                      ? const Icon(
                          Icons.dark_mode,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.light_mode,
                          color: Colors.black,
                        ),
                  textBuilder: (value) => value
                      ? const Center(
                          child: Text(
                          'Dark Mode',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14),
                        ))
                      : const Center(
                          child: Text(
                          'Light Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        )),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Pallete.buttonGreen,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Update Settings",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20),
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
