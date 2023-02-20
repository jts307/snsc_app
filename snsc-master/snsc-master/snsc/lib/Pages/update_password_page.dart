// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:snsc/Functions_and_Vars/api_services.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/widgets/all_widgets.dart';
import 'package:snsc/Pages/all_pages.dart';
import '../Functions_and_Vars/all_fvc.dart';
import '../config/accesibility_config.dart';
import '../widgets/loader.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({Key? key}) : super(key: key);

  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
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
          const SnackBar(content: Text('New passwords do not match')),
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
            resizeToAvoidBottomInset: false,
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
                        width: 200,
                      ),
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RoundedInputField(
                              hintText: "Old Password",
                              icon: Icons.password,
                              onChanged: (value) {},
                              controller: oldPasswordController,
                              validator: Validators.passwordValidator,
                              obscure: true,
                              inputType: TextInputType.visiblePassword,
                            ),
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
                              padding: const EdgeInsets.all(8.0),
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
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
