// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:snsc/Pages/all_pages.dart';
import '../Functions_and_Vars/api_services.dart';
import '../Functions_and_Vars/functions.dart';
import '../config/accesibility_config.dart';
import '../config/pallete.dart';
import '../widgets/all_widgets.dart';
import '../widgets/loader.dart';

class PasswordResetNew extends StatefulWidget {
  final String token;
  const PasswordResetNew({Key? key, required this.token}) : super(key: key);

  @override
  State<PasswordResetNew> createState() => _PasswordResetNewState();
}

class _PasswordResetNewState extends State<PasswordResetNew> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController newPasswordController1 = TextEditingController();
  TextEditingController newPasswordController2 = TextEditingController();

  bool validPasword = false;
  bool isLoading = false;

  updatePassword() async {
    if (_formKey.currentState!.validate() && validPasword) {
      loading(true);
      if (newPasswordController1.text != newPasswordController2.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match')),
        );
      } else {
        bool noInternet = await noInternetConnection();

        if (!noInternet) {
          await APIService.resetPassword(
              newPasswordController2.text, widget.token, context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.red[400],
                content: const Text('No Internet Connection')),
          );
        }
      }
      loading(false);
    }
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
      child: Scaffold(
        backgroundColor:
            Preferences.usingDarkMode() ? Colors.black : Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              children: [
                AppBarReturn(
                    returnPage: const LandingPage(),
                    popContext: false,
                    callBack: refreshPage),
                const Padding(
                  padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                  child: Image(
                    image: AssetImage('Assets/high_res_SNSC_logo.png'),
                    width: 200,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "PASSWORD RESET",
                        style: TextStyle(
                            fontFamily: Preferences.currentFont(),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Pallete.buttonGreen),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 8.0),
                      child: Text(
                        "Enter new password. You will be required to log in once you set the new password",
                        style: TextStyle(
                          fontFamily: Preferences.currentFont(),
                          fontSize: (MediaQuery.of(context).size.height * 0.02),
                          color: Preferences.usingDarkMode()
                              ? Colors.white
                              : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RoundedInputField(
                              hintText: "New Password",
                              icon: Icons.lock,
                              onChanged: (value) {},
                              controller: newPasswordController1,
                              obscure: true,
                              inputType: TextInputType.visiblePassword,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: FlutterPwValidator(
                                  width: 300,
                                  height: 80,
                                  minLength: 8,
                                  numericCharCount: 1,
                                  uppercaseCharCount: 1,
                                  onSuccess: () {
                                    setState(() {
                                      validPasword = true;
                                    });
                                  },
                                  onFail: () {
                                    setState(() {
                                      validPasword = false;
                                    });
                                  },
                                  controller: newPasswordController1),
                            ),
                            RoundedInputField(
                              hintText: "Enter Password Again",
                              icon: Icons.lock,
                              onChanged: (value) {},
                              controller: newPasswordController2,
                              validator: Validators.passwordValidator,
                              obscure: true,
                              inputType: TextInputType.visiblePassword,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(child: isLoading ? const Loader() : null),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: RoundedRectangleButton(
                                width: 400,
                                onPressed: () {
                                  updatePassword();
                                },
                                text: "RESET PASSWORD",
                                buttoncolor: Pallete.buttonBlue,
                                height: 50,
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
