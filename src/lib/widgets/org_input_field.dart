import 'package:flutter/material.dart';
import 'package:snsc/widgets/rounded_rectangle_button.dart';

import '../config/pallete.dart';

class OrgInputField extends StatefulWidget {
  const OrgInputField(
      {Key? key,
      required this.hintText,
      required this.labelText,
      required this.minLines,
      this.textInput,
      this.setText})
      : super(key: key);

  final String hintText;
  final String labelText;
  final int minLines;
  final String? textInput;
  final Function(String)? setText;

  @override
  State<OrgInputField> createState() => _OrgInputFieldState();
}

class _OrgInputFieldState extends State<OrgInputField> {
  TextEditingController inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    inputController.text = widget.textInput!;

    return AlertDialog(
      title: Text(widget.labelText),
      content: Container(
        width: screenWidth * 0.9,
        decoration: const BoxDecoration(),
        child: TextFormField(
          controller: inputController,
          maxLines: null,
          minLines: widget.minLines,
          decoration: InputDecoration(
              hintText: widget.hintText,
              hintMaxLines: 5,
              border: const OutlineInputBorder(),
              labelText: widget.labelText),
        ),
      ),
      actions: [
        RoundedRectangleButton(
            width: 70,
            onPressed: () {
              widget.setText!(inputController.text);
              Navigator.of(context).pop();
            },
            text: "Save",
            buttoncolor: Pallete.buttonGreen,
            height: 40),
      ],
    );
  }
}
