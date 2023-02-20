import 'package:flutter/material.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/widgets/all_widgets.dart';

class AppBarReturn extends StatefulWidget {
  const AppBarReturn(
      {Key? key,
      required this.returnPage,
      required this.popContext,
      required this.callBack})
      : super(key: key);

  final Widget returnPage;
  final bool popContext;
  final Function callBack;

  @override
  State<AppBarReturn> createState() => _AppBarReturnState();
}

class _AppBarReturnState extends State<AppBarReturn> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CircleButton(
                icon: Icons.arrow_back,
                iconSize: 40,
                color: Pallete.buttondarkBlue,
                onPressed: widget.popContext
                    ? () {
                        Navigator.pop(context);
                      }
                    : () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => widget.returnPage),
                            (route) => false);
                      }),
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
