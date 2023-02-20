// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:snsc/Pages/all_pages.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/widgets/all_widgets.dart';
import 'package:snsc/widgets/filter_button_dropdown.dart';
import 'package:snsc/widgets/filter_button_number.dart';

import '../Functions_and_Vars/api_services.dart';
import '../config/accesibility_config.dart';
import '../models/filter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, required this.userLoggedIn, this.callBack})
      : super(key: key);

  final bool userLoggedIn;
  final Function? callBack;

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchText = TextEditingController();
  late Future<List<Filter>> disabilityFilters;
  late Future<List<Filter>> serviceFilters;
  late Future<List<Filter>> stateFilters;
  late Future<List<Filter>> insuranceFilters;

  late List<String> disabilitesChosen;
  late List<String> servicesChosen;
  late List<String> statesChosen;
  late List<String> insurancesChosen;

  late List<Filter> previousDisChosen;
  late List<Filter> previousServChosen;
  late List<Filter> previousStateChosen;
  late List<Filter> previousInsurChosen;

  late String? fee;
  late String? age;

  late String? prevFee;
  late String? prevAge;

  Future<List<Filter>> getDisabilityFilters() async {
    return await APIService.getDisabilityFilters();
  }

  Future<List<Filter>> getServiceFilters() async {
    return await APIService.getServiceFilters();
  }

  Future<List<Filter>> getStateFilters() async {
    return await APIService.getStateFilters();
  }

  Future<List<Filter>> getInsuranceFilters() async {
    return await APIService.getInsuranceFilters();
  }

  void refreshPage() {
    setState(() {});
  }

  setDisabilties(List<String> data, List<Filter> prev) {
    setState(() {
      disabilitesChosen = data;
      previousDisChosen = prev;
    });
  }

  setServices(List<String> data, List<Filter> prev) {
    setState(() {
      servicesChosen = data;
      previousServChosen = prev;
    });
  }

  setStates(List<String> data, List<Filter> prev) {
    setState(() {
      statesChosen = data;
      previousStateChosen = prev;
    });
  }

  setInsurance(List<String> data, List<Filter> prev) {
    setState(() {
      insurancesChosen = data;
      previousInsurChosen = prev;
    });
  }

  setFee(String data) {
    setState(() {
      fee = data;
      prevFee = data;
    });
  }

  setAge(String data) {
    setState(() {
      age = data;
      prevAge = data;
    });
  }

  @override
  void initState() {
    super.initState();
    disabilitesChosen = [];
    servicesChosen = [];
    statesChosen = [];
    insurancesChosen = [];

    previousDisChosen = [];
    previousServChosen = [];
    previousStateChosen = [];
    previousInsurChosen = [];

    fee = "----";
    age = "";

    prevFee = "----";
    prevAge = "0";

    disabilityFilters = getDisabilityFilters();
    serviceFilters = getServiceFilters();
    stateFilters = getStateFilters();
    insuranceFilters = getInsuranceFilters();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    var futureBuilder = FutureBuilder(
      future: Future.wait(
          [disabilityFilters, serviceFilters, stateFilters, insuranceFilters]),
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
            child = Column(
              children: [
                Wrap(
                  runSpacing: 15,
                  alignment: WrapAlignment.center,
                  children: [
                    FilterButtonBottomSheet(
                        name: "Area Of Disability",
                        objects: snapshot.data[0],
                        setFilter: setDisabilties,
                        previouslySelected: previousDisChosen),
                    FilterButtonBottomSheet(
                        name: "Service Provided",
                        objects: snapshot.data[1],
                        setFilter: setServices,
                        previouslySelected: previousServChosen),
                    FilterButtonBottomSheet(
                        name: "State Served",
                        objects: snapshot.data[2],
                        setFilter: setStates,
                        previouslySelected: previousStateChosen),
                    FilterButtonBottomSheet(
                        name: "Insurance",
                        objects: snapshot.data[3],
                        setFilter: setInsurance,
                        previouslySelected: previousInsurChosen),
                    FilterButtonDropdown(
                        items: const [],
                        querryText: "Service Fee",
                        setFilter: setFee,
                        prevSelected: prevFee),
                    FilterButtonNumber(
                        querryText: "Age",
                        setFilter: setAge,
                        prevSelected: prevAge),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RoundedRectangleButton(
                        width: 120,
                        onPressed: () {
                          setState(() {
                            disabilitesChosen = [];
                            servicesChosen = [];
                            statesChosen = [];
                            insurancesChosen = [];

                            previousDisChosen = [];
                            previousServChosen = [];
                            previousStateChosen = [];
                            previousInsurChosen = [];

                            fee = "----";
                            age = "";

                            prevFee = "----";
                            prevAge = "0";
                          });
                        },
                        text: "Clear Filters",
                        buttoncolor: Pallete.buttonGreen,
                        height: 40,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RoundedRectangleButton(
                        width: 200,
                        onPressed: () {
                          if (age == "0") {
                            age = "-1";
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResultsPage(
                                      disabilities: disabilitesChosen,
                                      services: servicesChosen,
                                      states: statesChosen,
                                      insurances: insurancesChosen,
                                      fee: fee,
                                      age: age,
                                      userLoggedIn: widget.userLoggedIn,
                                    )),
                          );
                        },
                        text: "SEARCH",
                        buttoncolor: Pallete.buttonGreen,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ],
            );
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
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor:
              Preferences.usingDarkMode() ? Colors.black : Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(children: [
                widget.userLoggedIn
                    ? AppBarLogo(
                        callBack: refreshPage,
                      )
                    : AppBarReturn(
                        returnPage: const LandingPage(),
                        popContext: true,
                        callBack: refreshPage,
                      ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 5.0),
                  child: SizedBox(
                    width: 500,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Preferences.usingDarkMode()
                                  ? Pallete.cardBackground.withOpacity(0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                width: 2.0,
                                color: Preferences.usingDarkMode()
                                    ? Colors.blue
                                    : Colors.transparent,
                              ),
                            ),
                            child: TextField(
                              controller: searchText,
                              maxLines: 2,
                              minLines: 1,
                              onSubmitted: (input) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ResultsPage(
                                            searchText: searchText.text.isEmpty
                                                ? ""
                                                : searchText.text,
                                            userLoggedIn: widget.userLoggedIn,
                                          )),
                                );
                              },
                              textInputAction: TextInputAction.search,
                              style: TextStyle(
                                fontFamily: Preferences.currentFont(),
                                color: Preferences.usingDarkMode()
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: Preferences.usingDarkMode()
                                      ? 'Search Organization Name'
                                      : '',
                                  hintStyle: TextStyle(
                                    fontFamily: Preferences.currentFont(),
                                    color: Preferences.usingDarkMode()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  labelText: Preferences.usingDarkMode()
                                      ? ''
                                      : 'Search Organization Name'),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        CircleButton(
                          icon: Icons.search,
                          iconSize: 30,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResultsPage(
                                        searchText: searchText.text.isEmpty
                                            ? ""
                                            : searchText.text,
                                        userLoggedIn: widget.userLoggedIn,
                                      )),
                            );
                          },
                          color: Pallete.buttonGreen,
                        )
                      ],
                    ),
                  ),
                ),
                const DividerText(
                  text: "   or   ",
                ),
                Text(
                  "Search Using Filters",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: Preferences.currentFont(),
                      color: Preferences.usingDarkMode()
                          ? Colors.white
                          : Colors.grey),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: widget.userLoggedIn ? 650 : 800,
                  child: SingleChildScrollView(child: futureBuilder),
                ),
                const SizedBox(
                  height: 10,
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
