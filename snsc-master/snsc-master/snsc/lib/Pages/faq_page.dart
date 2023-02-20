// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:snsc/Pages/all_pages.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/widgets/all_widgets.dart';

import '../Functions_and_Vars/api_services.dart';
import '../config/accesibility_config.dart';
import '../models/faq.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({Key? key, required this.userLoggedIn}) : super(key: key);

  final bool userLoggedIn;

  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
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

  void expandList(int length) {
    _isExpanded ??= List.filled(length, false);
  }

  void refreshPage() {
    setState(() {});
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

            child = ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ExpansionPanelList(
                    animationDuration: const Duration(milliseconds: 500),
                    expandedHeaderPadding: const EdgeInsets.only(bottom: 0.0),
                    elevation: 1,
                    children: [
                      ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              snapshot.data[index].question,
                              style: TextStyle(
                                fontFamily: Preferences.currentFont(),
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: Preferences.currentFont(),
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
            );
          } else {
            // use snapshot.error to see the actual error
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
        backgroundColor:
            Preferences.usingDarkMode() ? Colors.black : Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                height: screenHeight, width: screenWidth),
            child: Column(children: [
              AppBarReturn(
                returnPage: const LandingPage(),
                popContext: true,
                callBack: refreshPage,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                child: Image(
                  image: AssetImage('Assets/high_res_SNSC_logo.png'),
                  width: 250,
                ),
              ),
              SizedBox(
                width: 400,
                height: 60,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FeedbackPage(
                                      userLoggedIn: widget.userLoggedIn,
                                    )),
                          );
                        },
                        child: Text(
                          "Feedback",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: Preferences.currentFont(),
                              color: Preferences.usingDarkMode()
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 70),
                      Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                            color: Colors.green,
                            width: 4,
                          ))),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FaqPage(
                                          userLoggedIn: widget.userLoggedIn,
                                        )),
                              );
                            },
                            child: Text(
                              "FAQ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Preferences.currentFont(),
                                  color: Preferences.usingDarkMode()
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 24),
                            ),
                          ))
                    ]),
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
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
