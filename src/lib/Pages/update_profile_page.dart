// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:snsc/Functions_and_Vars/api_services.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/models/user.dart';
import 'package:snsc/widgets/all_widgets.dart';
import 'package:snsc/Pages/all_pages.dart';
import '../Functions_and_Vars/all_fvc.dart';
import '../config/accesibility_config.dart';
import '../widgets/loader.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key}) : super(key: key);

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late Future<User?> user;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  bool isLoading = false;
  bool loadUserData = true;

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

  updateProfile() async {
    if (_formKey.currentState!.validate()) {
      loading(true);

      bool noInternet = await noInternetConnection();

      if (!noInternet) {
        await APIService.updateUser(
            User(
                name: nameController.text,
                email: emailController.text,
                location: locationController.text,
                dateOfBirth: dateOfBirthController.text),
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
    user = getUser();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    var futureBuilder = FutureBuilder(
      future: user,
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
            if (loadUserData) {
              nameController.text = snapshot.data.name;
              emailController.text = snapshot.data.email;
              locationController.text = snapshot.data.location;
              dateOfBirthController.text = snapshot.data.dateOfBirth;
              loadUserData = false;
            }

            child = Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: RoundedInputField(
                          hintText: "Name",
                          icon: Icons.account_circle_outlined,
                          onChanged: (value) {},
                          controller: nameController,
                          validator: Validators.otherValidator,
                          obscure: false,
                          inputType: TextInputType.name,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: RoundedInputField(
                          hintText: "Email Address",
                          icon: Icons.email,
                          onChanged: (value) {},
                          controller: emailController,
                          validator: Validators.emailValidator,
                          obscure: false,
                          inputType: TextInputType.emailAddress,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: RoundedInputField(
                          hintText: "City/Town, State ",
                          icon: Icons.location_city,
                          onChanged: (value) {},
                          controller: locationController,
                          validator: Validators.otherValidator,
                          obscure: false,
                          inputType: TextInputType.streetAddress,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: RoundedInputField(
                          hintText: "Age",
                          icon: Icons.numbers,
                          onChanged: (value) {},
                          controller: dateOfBirthController,
                          validator: Validators.ageValidator,
                          obscure: false,
                          inputType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  Container(child: isLoading ? const Loader() : null),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 5.0, bottom: 5.0),
                    child: RoundedRectangleButton(
                      width: 400,
                      onPressed: () async {
                        await updateProfile();
                      },
                      text: "Update Profile",
                      buttoncolor: Pallete.buttonBlue,
                      height: 50,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            );
          } else {
            // use snapshot.error to see the error
            child = const Center(
                child: Text('Please check your internet connection'));
          }
        }
        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500), child: child);
      },
    );

    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(screenWidth < 700
                ? "Assets/background_1.jpg"
                : "Assets/web_background_1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor:
              Preferences.usingDarkMode() ? Colors.black : Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppBarReturn(
                    returnPage: const AccountPage(),
                    popContext: true,
                    callBack: refreshPage,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                    child: Image(
                      image: AssetImage('Assets/high_res_SNSC_logo.png'),
                      width: 150,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Update Profile",
                          style: TextStyle(
                              color: Pallete.buttonGreen,
                              fontSize: 30,
                              fontFamily: Preferences.currentFont(),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "Please make sure the new email address is capable of receiving emails\n(this is just in case you need to send feedback or reset your password)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.red,
                            fontFamily: Preferences.currentFont(),
                            fontSize: 12,
                            fontWeight: FontWeight.normal)),
                  ),
                  futureBuilder,
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
