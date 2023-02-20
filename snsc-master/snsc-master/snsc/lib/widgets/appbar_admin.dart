import 'package:flutter/material.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/widgets/all_widgets.dart';

class AppBarAdmin extends StatelessWidget {
  const AppBarAdmin({Key? key, required this.returnPage}) : super(key: key);

  final Widget returnPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'Assets/high_res_SNSC_logo.png',
              width: 100,
              height: 80,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: CircleButton(
                icon: Icons.home,
                iconSize: 40,
                color: Pallete.buttonGreen,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => returnPage),
                      (route) => false);
                }),
          )
        ],
      ),
    );
  }
}
