// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:snsc/Pages/all_pages.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/widgets/all_widgets.dart';

import '../../Functions_and_Vars/api_services.dart';
import '../../models/faq.dart';

class EditFAQ extends StatefulWidget {
  const EditFAQ({Key? key}) : super(key: key);

  @override
  State<EditFAQ> createState() => _EditFAQState();
}

class _EditFAQState extends State<EditFAQ> {
  late Future<List<Faq>?> faqs;
  List<bool>? _isExpanded;

  Future<List<Faq>?> getFaqs() async {
    bool noInternet = await noInternetConnection();

    if (!noInternet) {
      return await APIService.getFaqs(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
    }
    return null;
  }

  Future<bool> noInternetConnection() async {
    if (kIsWeb) {
      var result = await Connectivity().checkConnectivity();
      return result == ConnectivityResult.none;
    } else {
      var result = await InternetConnectionChecker().hasConnection;
      return !result;
    }
  }

  deleteFaq(String id) async {
    bool noInternet = await noInternetConnection();
    if (!noInternet) {
      await APIService.deleteFaq(id, context);
    }
    setState(() {
      faqs = getFaqs();
    });
  }

  addFaq(Faq faq) async {
    if (_isExpanded != null) {
      _isExpanded!.add(false);
    }
    bool noInternet = await noInternetConnection();
    if (!noInternet) {
      await APIService.saveFaq(faq, context);
    }
    setState(() {
      faqs = getFaqs();
    });
  }

  // update function
  updateFaq(String id, Faq faq) async {
    bool noInternet = await noInternetConnection();
    if (!noInternet) {
      await APIService.updateFaq(id, faq, context);
    }
    setState(() {
      faqs = getFaqs();
    });
  }

  void expandList(int length) {
    // check if _isExpanded is initialized
    _isExpanded ??= List.filled(length, false, growable: true);
  }

  @override
  void initState() {
    super.initState();
    faqs = getFaqs();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    var futureBuilder = FutureBuilder(
      future: faqs,
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
            expandList(snapshot.data.length);

            child = SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: ExpansionPanelList(
                      animationDuration: const Duration(milliseconds: 500),
                      dividerColor: Colors.red,
                      expandedHeaderPadding: const EdgeInsets.only(bottom: 0.0),
                      elevation: 1,
                      children: [
                        ExpansionPanel(
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              child: Wrap(
                                children: [
                                  Text(
                                    snapshot.data[index].question,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  "Do you want to delete this FAQ?",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0),
                                                ),
                                                actions: [
                                                  Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Wrap(
                                                          alignment:
                                                              WrapAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        primary:
                                                                            Pallete.buttonGreen,
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        "Cancel",
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.white),
                                                                      )),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        if (_isExpanded !=
                                                                            null) {
                                                                          _isExpanded!
                                                                              .removeAt(index);
                                                                        }

                                                                        deleteFaq(snapshot
                                                                            .data[index]
                                                                            .id);

                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        primary: const Color.fromARGB(
                                                                            255,
                                                                            247,
                                                                            69,
                                                                            46),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        "Delete",
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.white),
                                                                      )),
                                                            ),
                                                          ]))
                                                ],
                                              );
                                            });
                                      },
                                      alignment: Alignment.center,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              FaqPopUp(
                                            question:
                                                snapshot.data[index].question,
                                            answer: snapshot.data[index].answer,
                                            tittle: "EDIT FAQ",
                                            faqId: snapshot.data[index].id,
                                            updateFaq: updateFaq,
                                          ),
                                        );
                                      },
                                      alignment: Alignment.center,
                                    ),
                                  ]),
                                ],
                              ),
                            );
                          },
                          body: Container(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data[index].answer,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isExpanded: _isExpanded![index],
                          canTapOnHeader: true,
                        )
                      ],
                      expansionCallback: (int item, bool status) {
                        setState(() {
                          _isExpanded![index] = !status;
                        });
                      },
                    ),
                  );
                },
              ),
            );
          } else {
            // use the error details with snapshot.error
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
              ? "Assets/background_2.jpg"
              : "Assets/web_background_2.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          minimum: const EdgeInsets.all(10.0),
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                height: screenHeight, width: screenWidth),
            child: Column(children: [
              const AppBarAdmin(returnPage: AdminLandingPage()),
              const Text(
                "Manage FAQs",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    color: Colors.black),
              ),
              // const Spacer(),
              const SizedBox(
                height: 20,
              ),
              RoundedRectangleButton(
                width: 130,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => FaqPopUp(
                      question: "",
                      answer: "",
                      tittle: "ADD FAQ",
                      addFaq: addFaq,
                    ),
                  );
                },
                text: " + Add FAQ",
                buttoncolor: Pallete.buttonGreen,
                height: 35,
              ),
              // const Spacer(),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Align(
                    alignment: Alignment.center,
                    child: futureBuilder,
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
