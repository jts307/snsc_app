import 'package:flutter/material.dart';

import '../config/accesibility_config.dart';

class DividerText extends StatelessWidget {
  const DividerText({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              thickness: 2,
              color: Colors.grey,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontFamily: Preferences.currentFont(),
            ),
          ),
          const Expanded(
            child: Divider(
              thickness: 2,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
