// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:snsc/Pages/all_pages.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/widgets/all_widgets.dart';
import 'dart:io';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

import '../Functions_and_Vars/api_services.dart';
import '../Functions_and_Vars/functions.dart';
import '../config/accesibility_config.dart';
import '../models/user.dart';
import '../widgets/loader.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({
    Key? key,
    required this.userLoggedIn,
  }) : super(key: key);

  final bool userLoggedIn;
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int value = 0;
  bool positive = false;
  bool account = false;
  bool suggestion = false;
  bool app = false;
  bool resource = false;
  bool contact = false;
  bool other = false;
  File? image;
  late User? user;
  bool isLoading = false;

  TextEditingController feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  getUser() async {
    bool noInternet = await noInternetConnection();

    if (!noInternet) {
      if (widget.userLoggedIn) {
        user = await APIService.getUserInfo(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
    }
  }

  sendFeedback() async {
    loading(true);
    bool noInternet = await noInternetConnection();
    if (!noInternet) {
      List feedbackTypes = [];
      String senderEmail = "";

      if (account) {
        feedbackTypes.add("Account");
      }
      if (suggestion) {
        feedbackTypes.add("Suggestion");
      }
      if (app) {
        feedbackTypes.add("App");
      }
      if (resource) {
        feedbackTypes.add("Resource");
      }
      if (contact) {
        feedbackTypes.add("Contact");
      }
      if (other) {
        feedbackTypes.add("Other");
      }
      if (widget.userLoggedIn && positive == false) {
        if (user != null) {
          senderEmail = user!.email;
        } else {
          senderEmail = "Anonymous";
        }
      }
      if (widget.userLoggedIn == false || positive == true) {
        senderEmail = "Anonymous";
      }

      await APIService.sendFeedback(senderEmail, feedbackController.text,
          feedbackTypes.join(", "), context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
    }
    loading(false);
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

  loading(load) {
    setState(() {
      isLoading = load;
    });
  }

  void refreshPage() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(screenWidth < 700
              ? "Assets/background_2.jpg"
              : "Assets/web_background_2.jpg"),
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
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                                          builder: (context) => FeedbackPage(
                                                userLoggedIn:
                                                    widget.userLoggedIn,
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
                                )),
                            const SizedBox(width: 70),
                            TextButton(
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
                            ),
                          ]),
                    ),
                    Text("Please select the type of feedback",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Preferences.usingDarkMode()
                                ? Colors.white
                                : Colors.black,
                            fontSize: 20,
                            fontFamily: Preferences.currentFont(),
                            fontWeight: FontWeight.bold)),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 700,
                            child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 40,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            primary: Colors.white,
                                            backgroundColor: account
                                                ? Pallete.buttonGreen
                                                : Pallete.buttonGrey),
                                        onPressed: () => {
                                          setState(() {
                                            account = !account;
                                          })
                                        },
                                        child: Text(
                                          'Account',
                                          style: TextStyle(
                                            fontFamily:
                                                Preferences.currentFont(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 40,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            primary: Colors.white,
                                            backgroundColor: suggestion
                                                ? Pallete.buttonGreen
                                                : Pallete.buttonGrey),
                                        onPressed: () => {
                                          setState(() {
                                            suggestion = !suggestion;
                                          })
                                        },
                                        child: Text(
                                          'Suggestion',
                                          style: TextStyle(
                                            fontFamily:
                                                Preferences.currentFont(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 40,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            primary: Colors.white,
                                            backgroundColor: app
                                                ? Pallete.buttonGreen
                                                : Pallete.buttonGrey),
                                        onPressed: () => {
                                          setState(() {
                                            app = !app;
                                          })
                                        },
                                        child: Text(
                                          'App',
                                          style: TextStyle(
                                            fontFamily:
                                                Preferences.currentFont(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 40,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            primary: Colors.white,
                                            backgroundColor: resource
                                                ? Pallete.buttonGreen
                                                : Pallete.buttonGrey),
                                        onPressed: () => {
                                          setState(() {
                                            resource = !resource;
                                          })
                                        },
                                        child: Text(
                                          'Resource',
                                          style: TextStyle(
                                            fontFamily:
                                                Preferences.currentFont(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 40,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            primary: Colors.white,
                                            backgroundColor: contact
                                                ? Pallete.buttonGreen
                                                : Pallete.buttonGrey),
                                        onPressed: () => {
                                          setState(() {
                                            contact = !contact;
                                          })
                                        },
                                        child: Text(
                                          'Contact',
                                          style: TextStyle(
                                            fontFamily:
                                                Preferences.currentFont(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 40,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            primary: Colors.white,
                                            backgroundColor: other
                                                ? Pallete.buttonGreen
                                                : Pallete.buttonGrey),
                                        onPressed: () => {
                                          setState(() {
                                            other = !other;
                                          })
                                        },
                                        child: Text(
                                          'Other',
                                          style: TextStyle(
                                            fontFamily:
                                                Preferences.currentFont(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        ]),
                    const SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 1.0, left: 16, right: 16),
                        child: SizedBox(
                            width: 800,
                            height: 150,
                            child: TextFormField(
                              validator: Validators.otherValidator,
                              controller: feedbackController,
                              keyboardType: TextInputType.multiline,
                              minLines: 10,
                              maxLines: 50,
                              decoration: InputDecoration(
                                  hintText:
                                      'Enter your feedback and suggestions here. This includes any potential resources we should add to the database and ideas you want to recommend. We look forward to what you have to say, thanks!',
                                  hintStyle: TextStyle(
                                    fontFamily: Preferences.currentFont(),
                                    fontSize:
                                        Preferences.useFont() == "dyslexic"
                                            ? 12
                                            : 14,
                                    color: Preferences.usingDarkMode()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 3, color: Pallete.buttonGreen),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 3,
                                          color: Pallete.buttonGreen))),
                              style: TextStyle(
                                fontSize: 14,
                                height: 2,
                                color: Preferences.usingDarkMode()
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    widget.userLoggedIn
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Send Anonymously",
                                  style: TextStyle(
                                      fontFamily: Preferences.currentFont(),
                                      color: Preferences.usingDarkMode()
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 90,
                                child: AnimatedToggleSwitch<bool>.dual(
                                  current: positive,
                                  first: false,
                                  second: true,
                                  dif: 30.0,
                                  borderColor: Colors.transparent,
                                  borderWidth: 2.0,
                                  height: 25,
                                  animationOffset: const Offset(15.0, 0),
                                  clipAnimation: true,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 1.5),
                                    ),
                                  ],
                                  onChanged: (b) {
                                    setState(() => positive = b);
                                  },
                                  colorBuilder: (b) =>
                                      b ? Pallete.buttonGreen : Colors.red,
                                  iconBuilder: (value) => value
                                      ? const Icon(Icons.check)
                                      : const Icon(Icons.close),
                                  textBuilder: (value) => value
                                      ? const Center(child: Text('YES'))
                                      : const Center(child: Text('NO')),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(child: isLoading ? const Loader() : null),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RoundedRectangleButton(
                        width: 200,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            sendFeedback();
                          }
                        },
                        text: "Send Feedback",
                        buttoncolor: Pallete.buttonGreen,
                        height: 50,
                      ),
                    ),
                    const Center(
                      child: TextAndLink(
                          text1: "",
                          text2: "About",
                          navigateTo: AboutPage(prevPage: LandingPage(),)),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom))
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
