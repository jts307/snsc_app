// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:snsc/Functions_and_Vars/api_services.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/widgets/all_widgets.dart';
import 'package:snsc/Pages/all_pages.dart';
import '../../widgets/loader.dart';
import '/Functions_and_Vars/all_fvc.dart';

class ChangeCredentials extends StatefulWidget {
  const ChangeCredentials({Key? key}) : super(key: key);

  @override
  State<ChangeCredentials> createState() => _ChangeCredentialsState();
}

class _ChangeCredentialsState extends State<ChangeCredentials> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController1 = TextEditingController();
  TextEditingController newPasswordController2 = TextEditingController();

  bool validPasword = false;
  bool isLoading = false;

  updatePassword() async {
    if (_formKey.currentState!.validate() && validPasword) {
      loading(true);
      if (newPasswordController1.text != newPasswordController2.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New admin passwords do not match')),
        );
      } else {
        bool noInternet = await noInternetConnection();

        if (!noInternet) {
          await APIService.updatePassword(
              oldPasswordController.text, newPasswordController2.text, context);
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
              // const Spacer(),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "ADMIN CREDENTIALS",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26.0,
                    color: Pallete.buttonGreen),
              ),
              // const Spacer(),
              const SizedBox(
                height: 50,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: RoundedInputField(
                          hintText: "Current Admin Password",
                          icon: Icons.password,
                          onChanged: (value) {},
                          controller: oldPasswordController,
                          validator: Validators.passwordValidator,
                          obscure: true,
                          inputType: TextInputType.visiblePassword,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: RoundedInputField(
                          hintText: "New Admin Password",
                          icon: Icons.lock,
                          onChanged: (value) {},
                          controller: newPasswordController1,
                          obscure: true,
                          inputType: TextInputType.visiblePassword,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
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
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: RoundedInputField(
                          hintText: "New Admin Password Again",
                          icon: Icons.lock,
                          onChanged: (value) {},
                          controller: newPasswordController2,
                          validator: Validators.passwordValidator,
                          obscure: true,
                          inputType: TextInputType.visiblePassword,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(child: isLoading ? const Loader() : null),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: RoundedRectangleButton(
                          width: 400,
                          onPressed: () {
                            updatePassword();
                          },
                          text: "Update Password",
                          buttoncolor: Pallete.buttonBlue,
                          height: 50,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ))
            ]),
          ),
        ),
      ),
    );
  }
}
