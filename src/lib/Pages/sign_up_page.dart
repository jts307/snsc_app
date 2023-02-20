// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:snsc/Functions_and_Vars/api_services.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/models/user.dart';
import 'package:snsc/widgets/all_widgets.dart';
import 'package:snsc/Pages/all_pages.dart';
import '../Functions_and_Vars/all_fvc.dart';
import '../config/accesibility_config.dart';
import '../widgets/loader.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  bool validPasword = false;
  bool isLoading = false;

  loading(load) {
    setState(() {
      isLoading = load;
    });
  }

  void refreshPage() {
    setState(() {});
  }

  validateSignup() async {
    if (_formKey.currentState!.validate() && validPasword) {
      loading(true);

      bool noInternet = await noInternetConnection();

      if (!noInternet) {
        await APIService.signup(
            User(
                email: emailController.text,
                password: passwordController.text,
                name: nameController.text),
            context);
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
            reverse: true,
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
                const SizedBox(
                  height: 20,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RoundedInputField(
                          hintText: "Name",
                          icon: Icons.account_circle_outlined,
                          onChanged: (value) {},
                          controller: nameController,
                          validator: Validators.otherValidator,
                          obscure: false,
                          inputType: TextInputType.name,
                        ),
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
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
                              controller: passwordController),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(child: isLoading ? const Loader() : null),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: RoundedRectangleButton(
                            width: 400,
                            onPressed: () {
                              validateSignup();
                            },
                            text: "Sign up",
                            buttoncolor: Pallete.buttonBlue,
                            height: 50,
                          ),
                        ),
                        const TextAndLink(
                            text1: "Already have an account?",
                            text2: "Log In",
                            navigateTo: LoginPage()),
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
