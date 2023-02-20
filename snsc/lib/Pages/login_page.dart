// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:snsc/Functions_and_Vars/api_services.dart';
import 'package:snsc/Functions_and_Vars/functions.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/widgets/all_widgets.dart';
import 'package:snsc/Pages/all_pages.dart';
import '../config/accesibility_config.dart';
import '../widgets/loader.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool wantsBiometrics = false;
  bool userEnrolledBiometrics = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getSecureStorage();
  }

  void getSecureStorage() async {
    final isUsingBio = await storage.read(key: 'usingBiometric');
    if (isUsingBio == "true") {
      setState(() {
        userEnrolledBiometrics = true;
      });
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

  void authenticate() async {
    final canCheck = await auth.canCheckBiometrics;

    if (canCheck) {
      List availableBiometrics = await auth.getAvailableBiometrics();

      if (Platform.isIOS) {
        if (availableBiometrics.contains(BiometricType.face)) {
          // Face ID.
          final authenticated = await auth.authenticate(
              localizedReason: 'Enable Face ID to sign in more easily');
          if (authenticated) {
            final userStoredEmail = await storage.read(key: 'email');
            final userStoredPassword = await storage.read(key: 'password');
            loading(true);
            await APIService.login(
                userStoredEmail!, userStoredPassword!, context, false);
            loading(false);
          }
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          // Touch ID.
          final authenticated = await auth.authenticate(
              localizedReason: 'Enable Touch ID to sign in more easily');
          if (authenticated) {
            final userStoredEmail = await storage.read(key: 'email');
            final userStoredPassword = await storage.read(key: 'password');

            loading(true);
            await APIService.login(
                userStoredEmail!, userStoredPassword!, context, false);
            loading(false);
          }
        }
      }
    } else {
      if (kDebugMode) {
        print('cant check for biometrics ');
      }
    }
  }

  validateLogin() async {
    if (_formKey.currentState!.validate()) {
      loading(true);

      bool noInternet = await noInternetConnection();

      if (!noInternet) {
        await APIService.login(emailController.text.toLowerCase(),
            passwordController.text, context, wantsBiometrics);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red[400],
              content: const Text('No Internet Connection')),
        );
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
            child: Column(
              children: [
                AppBarReturn(
                  returnPage: const LandingPage(),
                  popContext: false,
                  callBack: refreshPage,
                ),
                SizedBox(
                  height: 150,
                  width: 550,
                  child: Image.asset('Assets/high_res_SNSC_logo.png'),
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RoundedInputField(
                          hintText: "Email Address",
                          icon: Icons.email,
                          onChanged: (value) {},
                          controller: emailController,
                          validator: Validators.emailValidator,
                          obscure: false,
                          inputType: TextInputType.emailAddress,
                        ),
                        RoundedInputField(
                          hintText: "Password",
                          icon: Icons.lock,
                          onChanged: (value) {},
                          controller: passwordController,
                          validator: Validators.passwordValidator,
                          obscure: true,
                          inputType: TextInputType.visiblePassword,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        userEnrolledBiometrics && !kIsWeb
                            ? InkWell(
                                onTap: () => authenticate(),
                                child: Image.asset(
                                  "Assets/faceID.png",
                                  width: 40,
                                  height: 40,
                                  color: Preferences.usingDarkMode()
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                      value: wantsBiometrics,
                                      activeColor: Pallete.buttonGreen,
                                      side: BorderSide(
                                        color: Preferences.usingDarkMode()
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      onChanged: (newValue) {
                                        setState(() {
                                          wantsBiometrics = newValue!;
                                        });
                                      }),
                                  Text(
                                    "Sign in with Face Id / Touch Id?",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Preferences.currentFont(),
                                      color: Preferences.usingDarkMode()
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(child: isLoading ? const Loader() : null),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: RoundedRectangleButton(
                            width: 400,
                            onPressed: () {
                              validateLogin();
                            },
                            text: "Login",
                            buttoncolor: Pallete.buttonBlue,
                            height: 50,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const TextAndLink(
                            text1: "Forgot Password?",
                            text2: "Reset it here",
                            navigateTo: PasswordResetPage()),
                        const SizedBox(
                          height: 15,
                        ),
                        const TextAndLink(
                            text1: "Don't have an account?",
                            text2: "Sign Up",
                            navigateTo: SignupPage()),
                      ],
                    )),
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
