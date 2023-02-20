import 'package:flutter/material.dart';
import 'package:snsc/config/pallete.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Pallete.buttondarkBlue,
        width: 70,
        height: 70,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Pallete.lightGrey),
          ),
        ));
  }
}
