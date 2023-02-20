// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:snsc/Functions_and_Vars/api_services.dart';
import 'package:snsc/Pages/all_pages.dart';
import 'package:snsc/Pages/profile_page.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/models/user.dart';
import '../config/accesibility_config.dart';
import '../widgets/all_widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key, this.callBack}) : super(key: key);

  final Function? callBack;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  late Future<User?> user;
  late Future<String?> bioInfo;

  Future<User?> getUser() async {
    bool noInternet = await noInternetConnection();

    if (!noInternet) {
      return await APIService.getUserInfo(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
    }
    return null;
  }

  Future<String?> getBioInfo() async {
    return await storage.read(key: 'usingBiometric');
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

  refreshPage() {
    setState(() {
      user = getUser();
    });
    widget.callBack;
  }

  @override
  void initState() {
    super.initState();
    user = getUser();
    bioInfo = getBioInfo();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(children: [
                AppBarLogo(
                  callBack: refreshPage,
                ),
                FutureBuilder(
                  future: user,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    Widget child;
                    if (snapshot.hasData) {
                      child = Column(
                        children: [
                          Text("Hi, ${snapshot.data.name}",
                              style: TextStyle(
                                  color: Pallete.buttonGreen,
                                  fontFamily: Preferences.currentFont(),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold)),
                          Text('${snapshot.data.email}',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  fontFamily: Preferences.currentFont(),
                                  fontWeight: FontWeight.bold)),
                        ],
                      );
                    } else {
                      child = Container();
                    }
                    return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: child);
                  },
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    ProfileButton(
                      text: "My Profile",
                      icon: const Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfilePage()),
                        ).then((value) => refreshPage());
                      },
                    ),
                    ProfileButton(
                      text: "Update Profile",
                      icon: const Icon(
                        Icons.account_circle_outlined,
                        color: Colors.white,
                      ),
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UpdateProfilePage()),
                        ).then((value) => refreshPage());
                      },
                    ),
                    ProfileButton(
                      text: "Update Password",
                      icon: const Icon(
                        Icons.lock,
                        color: Colors.white,
                      ),
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UpdatePasswordPage()),
                        ).then((value) => refreshPage());
                      },
                    ),
                    ProfileButton(
                      text: "Feedback and FAQ",
                      icon: const Icon(
                        Icons.feedback_outlined,
                        color: Colors.white,
                      ),
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FeedbackPage(
                                    userLoggedIn: true,
                                  )),
                        ).then((value) => refreshPage());
                      },
                    ),
                    FutureBuilder(
                      future: bioInfo,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        Widget child;
                        if (snapshot.hasData) {
                          child = ProfileButton(
                              text: "Disable Face Id/ Touch Id",
                              icon: const Icon(
                                Icons.fingerprint,
                                color: Colors.white,
                              ),
                              press: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Disable Face/Touch ID? ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    Preferences.currentFont(),
                                                fontSize: 22.0)),
                                        content: Text(
                                            "You will be required to sign out to re-enable biometric Login ",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontFamily:
                                                  Preferences.currentFont(),
                                            )),
                                        actions: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                primary: Pallete.buttonGreen,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "No",
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              )),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                primary: Pallete.buttonGreen,
                                              ),
                                              onPressed: () {
                                                storage.deleteAll();
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Yes",
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              )),
                                        ],
                                      );
                                    });
                              });
                        } else {
                          child = Container();
                        }
                        return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: child);
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(11, 0, 11, 0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: DonateButton(
                          text: "DONATE",
                          icon: Icon(Icons.volunteer_activism_outlined),
                          url:
                              'https://pages.donately.com/specialneedssupportcenter/campaigns',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: DonateButton(
                          text: "SPONSOR",
                          icon: Icon(Icons.favorite),
                          url: 'https://snsc-uv.org/sponsor/',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: DonateButton(
                          text: "VOLUNTEER",
                          icon: Icon(Icons.group),
                          url: 'https://snsc-uv.org/volunteer/',
                        ),
                      )
                    ],
                  ),
                ),
                ProfileButton(
                  text: "Log Out",
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  press: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Log out of SNSC?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: Preferences.currentFont(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0)),
                            actions: [
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Pallete.buttonGreen,
                                          ),
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                                fontFamily:
                                                    Preferences.currentFont(),
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: Pallete.buttonGreen,
                                          ),
                                          onPressed: () async {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                });
                                            await APIService.logout(context);
                                          },
                                          child: Text(
                                            "Log Out",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    Preferences.currentFont(),
                                                color: Colors.white),
                                          )),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Divider(
                    thickness: 2,
                    color: Preferences.usingDarkMode()
                        ? Colors.white
                        : Colors.grey.withOpacity(0.4),
                  ),
                ),
                Center(
                  child: Text(
                    "Special Needs Support Center",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: Preferences.currentFont(),
                        color: Pallete.buttonBlue,
                        fontSize: 14.0),
                  ),
                ),
                Center(
                  child: Text(
                    "Version 1.0.0",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: Preferences.currentFont(),
                        color: Pallete.buttonBlue,
                        fontSize: 14.0),
                  ),
                ),
                const Center(
                  child: TextAndLink(
                      text1: "",
                      text2: "Learn More",
                      navigateTo: AboutPage(prevPage: HomePage(currIndex: 2,),)),
                ),
                const SizedBox(
                  height: 20,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
