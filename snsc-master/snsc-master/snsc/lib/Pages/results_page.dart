// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:snsc/Functions_and_Vars/api_services.dart';
import 'package:snsc/Pages/all_pages.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/models/organization.dart';
import 'package:snsc/widgets/all_widgets.dart';

import '../config/accesibility_config.dart';

final bucketGlobal = PageStorageBucket();

class ResultsPage extends StatefulWidget {
  const ResultsPage(
      {Key? key,
      this.searchText,
      this.disabilities,
      this.services,
      this.states,
      this.insurances,
      this.fee,
      this.age,
      required this.userLoggedIn})
      : super(key: key);

  final String? searchText;
  final List<String>? disabilities;
  final List<String>? services;
  final List<String>? states;
  final List<String>? insurances;
  final String? fee;
  final String? age;
  final bool userLoggedIn;

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late int numResults = 0;
  late Future<List<Organization>?> entries;

  Future<List<Organization>?> searchByText() async {
    if (widget.searchText == "") {
      return await APIService.getAllOrganizations();
    } else {
      return await APIService.searchByText(widget.searchText!);
    }
  }

  Future<List<Organization>?> searchByFilter() async {
    return await APIService.searchByFilter(
        disabilities: widget.disabilities,
        services: widget.services,
        states: widget.states,
        insurances: widget.insurances,
        fee: widget.fee,
        age: widget.age);
  }

  refresh() {
    if (widget.searchText != null) {
      setState(() {
        entries = searchByText();
      });
    } else {
      setState(() {
        entries = searchByFilter();
      });
    }
  }

  void refreshPage() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    if (widget.searchText != null) {
      entries = searchByText();
    } else {
      entries = searchByFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    var futureBuilder = FutureBuilder(
      future: entries,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.none) {
          child = const Center(child: Text('No Connection'));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          child = const Center(
              child: SpinKitFadingCube(
            color: Pallete.buttondarkBlue,
            size: 50.0,
          ));
        } else {
          if (snapshot.hasData) {
            numResults = snapshot.data.length;
            if (numResults == 0) {
              child = Center(
                  child: SizedBox(
                width: 250,
                child: Text(
                  "No Results Found\nTry a new search with a new search term or edit the filters.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                      fontFamily: Preferences.currentFont(),
                      fontWeight: FontWeight.bold,
                      color: Preferences.usingDarkMode()
                          ? Colors.white
                          : Colors.black),
                ),
              ));
            } else {
              child = SizedBox(
                width: 550,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, bottom: 5),
                        child: Text("$numResults results found ",
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: Preferences.currentFont(),
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 550,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          key: const PageStorageKey<String>('results_page'),
                          padding: const EdgeInsets.all(8),
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ResourceCard(
                              org: snapshot.data[index],
                              reloadAllPages: refresh,
                              adminButton: false,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          } else {
            // use snapshot.error to see the real problem
            child = const Center(
                child: Text('Please check your internet connection'));
          }
        }

        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500), child: child);
      },
    );

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(screenWidth < 700
              ? "Assets/background_1.jpg"
              : "Assets/web_background_1.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor:
            Preferences.usingDarkMode() ? Colors.black : Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            AppBarReturn(
              returnPage: SearchPage(
                userLoggedIn: widget.userLoggedIn,
              ),
              popContext: true,
              callBack: refreshPage,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Disability Resources",
                  style: TextStyle(
                      color: Pallete.buttonGreen,
                      fontSize: 30,
                      fontFamily: Preferences.currentFont(),
                      fontWeight: FontWeight.bold)),
            ),
            Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RoundedRectangleButton(
                    width: 120,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: "Edit Search",
                    buttoncolor: Pallete.buttonGreen,
                    height: 40),
              ),
            ]),
            const SizedBox(
              height: 5,
            ),
            Expanded(
                child: PageStorage(bucket: bucketGlobal, child: futureBuilder)),
          ]),
        ),
      ),
    );
  }
}
