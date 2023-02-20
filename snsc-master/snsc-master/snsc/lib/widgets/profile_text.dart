import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:snsc/config/pallete.dart';

import '../config/accesibility_config.dart';

class ProfileText extends StatelessWidget {
  final String tittle;
  final String content;
  const ProfileText({Key? key, required this.tittle, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 8.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText.rich(
                      TextSpan(
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                                text: tittle,
                                style: TextStyle(
                                  fontFamily: Preferences.currentFont(),
                                  color: Preferences.usingDarkMode()
                                      ? Colors.white
                                      : Colors.black,
                                ))
                          ]),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText.rich(
                    TextSpan(
                        style: const TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                              text: content,
                              style: TextStyle(
                                fontFamily: Preferences.currentFont(),
                                color: Preferences.usingDarkMode()
                                    ? Pallete.buttonGreen
                                    : Colors.grey,
                              ))
                        ]),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
