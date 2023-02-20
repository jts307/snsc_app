import 'package:flutter/material.dart';

import '../config/accesibility_config.dart';

class FilterButtonDropdown extends StatefulWidget {
  final List items;
  final String querryText;
  final Function(String)? setFilter;
  final String? prevSelected;
  const FilterButtonDropdown(
      {Key? key,
      required this.items,
      required this.querryText,
      this.setFilter,
      required this.prevSelected})
      : super(key: key);

  @override
  State<FilterButtonDropdown> createState() => _FilterButtonDropdownState();
}

class _FilterButtonDropdownState extends State<FilterButtonDropdown> {
  @override
  Widget build(BuildContext context) {
    String shownValue = widget.prevSelected!;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: Colors.green,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.querryText,
                    style: TextStyle(
                      color: Preferences.usingDarkMode()
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18,
                      fontFamily: Preferences.currentFont(),
                    ),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButton(
                    dropdownColor: Preferences.usingDarkMode()
                        ? Colors.black
                        : Colors.white,
                    value: shownValue,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 25,
                    iconEnabledColor: Preferences.usingDarkMode()
                        ? Colors.white
                        : Colors.black,
                    elevation: 8,
                    style: TextStyle(
                        color: Preferences.usingDarkMode()
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold),
                    underline: Container(
                      height: 2,
                      color: Colors.green,
                    ),
                    onChanged: (String? newValue) {
                      widget.setFilter!(newValue!);
                      setState(() {
                        shownValue = newValue;
                      });
                    },
                    items: ['----', 'YES', 'NO'].map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: Preferences.usingDarkMode()
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: Preferences.currentFont(),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
