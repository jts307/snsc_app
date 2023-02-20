import 'package:flutter/material.dart';
import 'package:snsc/config/pallete.dart';
import 'all_widgets.dart';

class AppBarLogo extends StatefulWidget {
  const AppBarLogo({Key? key, required this.callBack}) : super(key: key);

  final Function callBack;

  @override
  State<AppBarLogo> createState() => _AppBarLogoState();
}

class _AppBarLogoState extends State<AppBarLogo> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 70,
              child: Image.asset('Assets/high_res_SNSC_logo.png'),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: CircleButton(
                icon: Icons.settings_accessibility,
                iconSize: 40,
                color: Pallete.buttondarkBlue,
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AccesibilityWidget();
                      });
                  widget.callBack();
                }),
          ),
        ],
      ),
    );
  }
}
