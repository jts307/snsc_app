// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snsc/Functions_and_Vars/api_services.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/models/filter.dart';
import 'package:snsc/models/organization.dart';
import 'package:snsc/widgets/all_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:snsc/config/api_config.dart';
import '../../Functions_and_Vars/functions.dart';
import '../../models/user.dart';
import '../../widgets/filter_button_dropdown.dart';
import '../../widgets/loader.dart';
import '../all_pages.dart';

class AddResource extends StatefulWidget {
  const AddResource({Key? key}) : super(key: key);

  @override
  State<AddResource> createState() => _AddResourceState();
}

class _AddResourceState extends State<AddResource> {
  File? image;
  String? imagePath;
  Uint8List? webImage;

  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController allPhone = TextEditingController();
  TextEditingController allEmail = TextEditingController();
  TextEditingController website = TextEditingController();
  TextEditingController allWebsite = TextEditingController();
  TextEditingController contactPersonName = TextEditingController();
  TextEditingController contactPersonRole = TextEditingController();
  TextEditingController newDisabilityController = TextEditingController();
  TextEditingController newServicesController = TextEditingController();
  TextEditingController newStateController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController feeDescriptionController = TextEditingController();
  TextEditingController newInsuranceController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future pickImage(ImageSource source) async {
    try {
      final img = await ImagePicker().pickImage(source: source);
      if (img == null) return;

      var f = await img.readAsBytes();
      setState(() {
        image = File(img.path);
        imagePath = img.path;
        webImage = f;
      });
    } on Exception catch (e) {
      if (kDebugMode) {
        print("failed to pick image: $e");
      }
    }
  }

  dynamic getAgeObject(String? input) {
    if (input != "") {
      String lowerCaseInput = input!.toLowerCase();

      if (lowerCaseInput == "all") {
        return Age(lowerRange: 0, upperRange: 100, allAges: true);
      } else {
        var arr = lowerCaseInput.split("-");
        int lower = int.parse(arr[0]);
        int upper = int.parse(arr[1]);
        return Age(lowerRange: lower, upperRange: upper, allAges: false);
      }
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

  List<String> getFilterOptions(
      List<String> exisitngOptions, String newOptions) {
    if (exisitngOptions.isEmpty && newOptions == "") {
      return ["None"];
    } else {
      if (newOptions != "") {
        var newOptionsList = newOptions.split(",");
        var newList = exisitngOptions + newOptionsList;
        var newListWithoutDuplicates = newList.toSet().toList();
        return newListWithoutDuplicates;
      } else {
        return exisitngOptions;
      }
    }
  }

  createOrganization() async {
    loading(true);
    bool noInternet = await noInternetConnection();

    if (!noInternet) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String userStringInfo = localStorage.getString('user')!;
      Map<String, dynamic> userMap = jsonDecode(userStringInfo);
      User user = User.fromJson(userMap);

      if (image != null) {
        Map<String, dynamic> imageMap;

        try {
          if (kIsWeb) {
            var request = http.MultipartRequest(
                'POST', Uri.parse(ApiConfig.herokuUploads));
            request.headers['authorization'] = user.token!;
            List<int> listData = webImage!.cast();
            request.files.add(http.MultipartFile.fromBytes('image', listData,
                filename: "image.png"));
            var streamResponse = await request.send();
            var response = await http.Response.fromStream(streamResponse);
            imageMap = jsonDecode(response.body);
          } else {
            var request = http.MultipartRequest(
                'POST', Uri.parse(ApiConfig.herokuUploads));
            request.headers['authorization'] = user.token!;
            request.files
                .add(await http.MultipartFile.fromPath('image', imagePath!));
            var streamResponse = await request.send();
            var response = await http.Response.fromStream(streamResponse);
            imageMap = jsonDecode(response.body);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.red[400],
                content: const Text('No Internet Connection')),
          );
          loading(false);
          return e.toString();
        }

        Organization newOrg = Organization(
            name: name.text,
            descriptions: description.text,
            primaryContactName: contactPersonName.text,
            primaryContactRole: contactPersonRole.text,
            primaryEmail: email.text,
            fullEmail: allEmail.text,
            primaryPhoneNumber: phone.text,
            fullPhoneNumber: allPhone.text,
            primaryWebsite: website.text,
            fullWebsite: allWebsite.text,
            disabilitiesServed: getFilterOptions(
                disabilitesChosen, newDisabilityController.text),
            servicesProvided:
                getFilterOptions(servicesChosen, newServicesController.text),
            statesServed:
                getFilterOptions(statesChosen, newStateController.text),
            agesServed: getAgeObject(ageController.text),
            fee: reconvertFee(fee),
            feeDescription: feeDescriptionController.text,
            insurancesAccepted:
                getFilterOptions(insurancesChosen, newInsuranceController.text),
            imageURL: imageMap['imageKey']);
        //print(jsonEncode(newOrg));
        await APIService.saveOrganization(newOrg, user.token!, context);
      } else {
        Organization newOrg = Organization(
            name: name.text,
            descriptions: description.text,
            primaryContactName: contactPersonName.text,
            primaryContactRole: contactPersonRole.text,
            primaryEmail: email.text,
            fullEmail: allEmail.text,
            primaryPhoneNumber: phone.text,
            fullPhoneNumber: allPhone.text,
            primaryWebsite: website.text,
            fullWebsite: allWebsite.text,
            disabilitiesServed: getFilterOptions(
                disabilitesChosen, newDisabilityController.text),
            servicesProvided:
                getFilterOptions(servicesChosen, newServicesController.text),
            statesServed:
                getFilterOptions(statesChosen, newStateController.text),
            agesServed: getAgeObject(ageController.text),
            fee: reconvertFee(fee),
            feeDescription: feeDescriptionController.text,
            insurancesAccepted:
                getFilterOptions(insurancesChosen, newInsuranceController.text),
            imageURL: 'None');

        //print(jsonEncode(newOrg));
        await APIService.saveOrganization(newOrg, user.token!, context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
    }

    loading(false);
  }

  String reconvertFee(String? fee) {
    if (fee == "YES") {
      return "true";
    } else {
      return "false";
    }
  }

  // for the  search filters
  late Future<List<Filter>> disabilityFilters;
  late Future<List<Filter>> serviceFilters;
  late Future<List<Filter>> stateFilters;
  late Future<List<Filter>> insuranceFilters;

  late List<String> disabilitesChosen;
  late List<String> servicesChosen;
  late List<String> statesChosen;
  late List<String> insurancesChosen;

  late List<Filter> previousDisChosen;
  late List<Filter> previousServChosen;
  late List<Filter> previousStateChosen;
  late List<Filter> previousInsurChosen;

  late String? fee;

  late String? prevFee;

  Future<List<Filter>> getDisabilityFilters() async {
    return await APIService.getDisabilityFilters();
  }

  Future<List<Filter>> getServiceFilters() async {
    return await APIService.getServiceFilters();
  }

  Future<List<Filter>> getStateFilters() async {
    return await APIService.getStateFilters();
  }

  Future<List<Filter>> getInsuranceFilters() async {
    return await APIService.getInsuranceFilters();
  }

  setDisabilties(List<String> data, List<Filter> prev) {
    setState(() {
      disabilitesChosen = data;
      previousDisChosen = prev;
    });
  }

  setServices(List<String> data, List<Filter> prev) {
    setState(() {
      servicesChosen = data;
      previousServChosen = prev;
    });
  }

  setStates(List<String> data, List<Filter> prev) {
    setState(() {
      statesChosen = data;
      previousStateChosen = prev;
    });
  }

  setInsurance(List<String> data, List<Filter> prev) {
    setState(() {
      insurancesChosen = data;
      previousInsurChosen = prev;
    });
  }

  setFee(String data) {
    setState(() {
      fee = data;
      prevFee = data;
    });
  }

  setOrganizationName(String data) {
    setState(() {
      name.text = data;
    });
  }

  setDescription(String data) {
    setState(() {
      description.text = data;
    });
  }

  setPrimaryContactName(String data) {
    setState(() {
      contactPersonName.text = data;
    });
  }

  setPrimaryContactRole(String data) {
    setState(() {
      contactPersonRole.text = data;
    });
  }

  setPrimaryEmail(String data) {
    setState(() {
      email.text = data;
    });
  }

  setFullEmail(String data) {
    setState(() {
      allEmail.text = data;
    });
  }

  setPrimaryPhone(String data) {
    setState(() {
      phone.text = data;
    });
  }

  setFullPhone(String data) {
    setState(() {
      allPhone.text = data;
    });
  }

  setPrimaryWebsite(String data) {
    setState(() {
      website.text = data;
    });
  }

  setFullWebsite(String data) {
    setState(() {
      allWebsite.text = data;
    });
  }

  setNewDisabilities(String data) {
    setState(() {
      newDisabilityController.text = data;
    });
  }

  setNewServicesProvided(String data) {
    setState(() {
      newServicesController.text = data;
    });
  }

  setNewState(String data) {
    setState(() {
      newStateController.text = data;
    });
  }

  setAgesServed(String data) {
    setState(() {
      ageController.text = data;
    });
  }

  setFeeDescription(String data) {
    setState(() {
      feeDescriptionController.text = data;
    });
  }

  setNewInsurance(String data) {
    setState(() {
      newInsuranceController.text = data;
    });
  }

  loading(load) {
    setState(() {
      isLoading = load;
    });
  }

  @override
  void initState() {
    super.initState();

    disabilitesChosen = [];
    servicesChosen = [];
    statesChosen = [];
    insurancesChosen = [];

    previousDisChosen = [];
    previousServChosen = [];
    previousStateChosen = [];
    previousInsurChosen = [];

    fee = "NO";

    prevFee = "NO";

    disabilityFilters = getDisabilityFilters();
    serviceFilters = getServiceFilters();
    stateFilters = getStateFilters();
    insuranceFilters = getInsuranceFilters();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    var futureBuilder = FutureBuilder(
      future: Future.wait(
          [disabilityFilters, serviceFilters, stateFilters, insuranceFilters]),
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
            child = Column(
              children: [
                Wrap(
                  runSpacing: 15,
                  alignment: WrapAlignment.center,
                  children: [
                    FilterButtonBottomSheet(
                        name: "Area Of Disability",
                        objects: snapshot.data[0],
                        setFilter: setDisabilties,
                        previouslySelected: previousDisChosen),
                    FilterButtonBottomSheet(
                        name: "Service Provided",
                        objects: snapshot.data[1],
                        setFilter: setServices,
                        previouslySelected: previousServChosen),
                    FilterButtonBottomSheet(
                        name: "State Served",
                        objects: snapshot.data[2],
                        setFilter: setStates,
                        previouslySelected: previousStateChosen),
                    FilterButtonBottomSheet(
                        name: "Insurance",
                        objects: snapshot.data[3],
                        setFilter: setInsurance,
                        previouslySelected: previousInsurChosen),
                    FilterButtonDropdown(
                        items: const [],
                        querryText: "Service Fee",
                        setFilter: setFee,
                        prevSelected: prevFee),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RoundedRectangleButton(
                        width: 120,
                        onPressed: () {
                          setState(() {
                            disabilitesChosen = [];
                            servicesChosen = [];
                            statesChosen = [];
                            insurancesChosen = [];

                            previousDisChosen = [];
                            previousServChosen = [];
                            previousStateChosen = [];
                            previousInsurChosen = [];

                            fee = "NO";

                            prevFee = "NO";
                          });
                        },
                        text: "Clear Filters",
                        buttoncolor: Pallete.buttonGreen,
                        height: 40,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            child = const Center(child: Text('No internet connection'));
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
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const AppBarAdmin(returnPage: AdminLandingPage()),
                  const Focus(
                    child: Text(
                      "Add New Resource",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Pallete.buttonGreen,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Pallete.buttonGreen, width: 2),
                              ),
                              child: webImage == null
                                  ? Image.asset(
                                      'Assets/stock_org_picture.jpeg',
                                      fit: BoxFit.fill,
                                    )
                                  : (kIsWeb)
                                      ? Image.memory(
                                          webImage!,
                                          fit: BoxFit.fill,
                                        )
                                      : Image.file(image!, fit: BoxFit.fill)),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            children: [
                              RoundedRectangleButton(
                                text: "Change Image",
                                buttoncolor: Pallete.buttonGreen,
                                width: 200,
                                height: 50,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                            "Change Resource Image",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0)),
                                        actions: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context,
                                                      pickImage(
                                                          ImageSource.gallery));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: Pallete.buttonGreen,
                                                ),
                                                child: const Text(
                                                  "Choose From Gallery",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                )),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                primary: Pallete.buttonGreen,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(
                                                    context,
                                                    pickImage(
                                                        ImageSource.camera));
                                              },
                                              child: const Text(
                                                "Take Photo",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              RoundedRectangleButton(
                                width: 150,
                                height: 30,
                                onPressed: () {
                                  setState(() {
                                    webImage = null;
                                  });
                                },
                                text: "Delete Image",
                                buttoncolor: Pallete.buttonGreen,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Form(
                    key: _formKey,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: DividerText(
                                text: "   General Organization Information   "),
                          ),
                          SizedBox(
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "Enter the organization name.",
                                          labelText: "Organization Name",
                                          minLines: 2,
                                          textInput: name.text,
                                          setText: setOrganizationName,
                                        ));
                              },
                              child: TextFormField(
                                enabled: false,
                                maxLines: null,
                                minLines: 1,
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: "Organization Name",
                                    errorStyle: TextStyle(
                                        color: Theme.of(context).errorColor)),
                                controller: name,
                                validator: Validators.otherValidator,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "Enter the organization description.",
                                          labelText: "Description",
                                          minLines: 3,
                                          textInput: description.text,
                                          setText: setDescription,
                                        ));
                              },
                              child: TextFormField(
                                enabled: false,
                                maxLines: null,
                                minLines: 1,
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: "Description",
                                    errorStyle: TextStyle(
                                        color: Theme.of(context).errorColor)),
                                controller: description,
                                validator: Validators.otherValidator,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: DividerText(
                                text: "   Organization Contact Details   "),
                          ),
                          SizedBox(
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText: "For example +16031234567.",
                                          labelText: "Primary Phone Number",
                                          minLines: 1,
                                          textInput: phone.text,
                                          setText: setPrimaryPhone,
                                        ));
                              },
                              child: TextFormField(
                                enabled: false,
                                maxLines: null,
                                minLines: 1,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Primary Phone Number"),
                                controller: phone,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "Enter all phone numbers separated by a comma.\nFor example +16031234567 - New Hampshire,+16031234567 - Vermont",
                                          labelText: "All Phone Numbers",
                                          minLines: 2,
                                          textInput: allPhone.text,
                                          setText: setFullPhone,
                                        ));
                              },
                              child: TextFormField(
                                enabled: false,
                                maxLines: null,
                                minLines: 1,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "All Phone Numbers"),
                                controller: allPhone,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "For example SNSC@gmail.com",
                                          labelText: "Primary Email Address",
                                          minLines: 1,
                                          textInput: email.text,
                                          setText: setPrimaryEmail,
                                        ));
                              },
                              child: TextFormField(
                                enabled: false,
                                maxLines: null,
                                minLines: 1,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Primary Email Address"),
                                controller: email,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "List all email addresses separated by a comma.\nFor example SNSC@info.com - Inquiries,SNSC@gmail.com - General Contact",
                                          labelText: "All Email Address",
                                          minLines: 2,
                                          textInput: allEmail.text,
                                          setText: setFullEmail,
                                        ));
                              },
                              child: TextFormField(
                                enabled: false,
                                maxLines: null,
                                minLines: 1,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "All Email Address"),
                                controller: allEmail,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText: "For example SNSC.org",
                                          labelText: "Primary Website",
                                          minLines: 1,
                                          textInput: website.text,
                                          setText: setPrimaryWebsite,
                                        ));
                              },
                              child: TextFormField(
                                enabled: false,
                                maxLines: null,
                                minLines: 1,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Primary Website"),
                                controller: website,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "List all websites separated by a comma.\nFor example SNSC.org.nh - NH,SNSC.org.vt - Vermont",
                                          labelText: "All Websites",
                                          minLines: 2,
                                          textInput: allWebsite.text,
                                          setText: setFullWebsite,
                                        ));
                              },
                              child: TextFormField(
                                enabled: false,
                                maxLines: null,
                                minLines: 1,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "All Websites",
                                ),
                                controller: allWebsite,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "The name of the primary contact person for the organization",
                                          labelText: "Primary Contact Name",
                                          minLines: 1,
                                          textInput: contactPersonName.text,
                                          setText: setPrimaryContactName,
                                        ));
                              },
                              child: TextFormField(
                                enabled: false,
                                maxLines: null,
                                minLines: 1,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Primary Contact Name",
                                ),
                                controller: contactPersonName,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "The role of the primary contact person for the organization",
                                          labelText: "Primary Contact role",
                                          minLines: 1,
                                          textInput: contactPersonRole.text,
                                          setText: setPrimaryContactRole,
                                        ));
                              },
                              child: TextFormField(
                                enabled: false,
                                maxLines: null,
                                minLines: 1,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Primary Contact role",
                                ),
                                controller: contactPersonRole,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: DividerText(
                                text: "   Organization Filter Details   "),
                          ),
                          SingleChildScrollView(child: futureBuilder),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: DividerText(
                                text:
                                    "   Organization Filter Details (new)   "),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "Example: Depends on service (psychotherapy ranges from \$95-\$189)",
                                          labelText: "Fee description",
                                          minLines: 2,
                                          textInput:
                                              feeDescriptionController.text,
                                          setText: setFeeDescription,
                                        ));
                              },
                              child: TextFormField(
                                enabled: false,
                                maxLines: null,
                                minLines: 1,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Fee description",
                                ),
                                controller: feeDescriptionController,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "Enter the age From-To for example 1-21.\n If all ages are served enter ALL",
                                          labelText: "Age Served",
                                          minLines: 1,
                                          textInput: ageController.text,
                                          setText: setAgesServed,
                                        ));
                              },
                              child: TextFormField(
                                enabled: false,
                                maxLines: null,
                                minLines: 1,
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: "Age Served",
                                    errorStyle: TextStyle(
                                        color: Theme.of(context).errorColor)),
                                controller: ageController,
                                validator: Validators.ageInputValidator,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "List all disabilities separated by a comma.\nFor example Autism,Cognitive Diabilities",
                                          labelText: "Areas of disability",
                                          minLines: 2,
                                          textInput:
                                              newDisabilityController.text,
                                          setText: setNewDisabilities,
                                        ));
                              },
                              child: TextFormField(
                                  enabled: false,
                                  maxLines: null,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: "Areas of disability",
                                      errorStyle: TextStyle(
                                          color: Theme.of(context).errorColor)),
                                  controller: newDisabilityController,
                                  validator: Validators.inputValidator),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "List all services separated by a comma.\n For example Child Care,Counselling services",
                                          labelText: "Service Provided",
                                          minLines: 2,
                                          textInput: newServicesController.text,
                                          setText: setNewServicesProvided,
                                        ));
                              },
                              child: TextFormField(
                                  enabled: false,
                                  maxLines: null,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: "Service Provided",
                                      errorStyle: TextStyle(
                                          color: Theme.of(context).errorColor)),
                                  controller: newServicesController,
                                  validator: Validators.inputValidator),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "List all states served separated by a comma.\nFor example NH,VT,CA,NY",
                                          labelText: "States Served",
                                          minLines: 2,
                                          textInput: newStateController.text,
                                          setText: setNewState,
                                        ));
                              },
                              child: TextFormField(
                                  enabled: false,
                                  maxLines: null,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: "States Served",
                                      errorStyle: TextStyle(
                                          color: Theme.of(context).errorColor)),
                                  controller: newStateController,
                                  validator: Validators.inputValidator),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth * 0.9,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        OrgInputField(
                                          hintText:
                                              "List all insurances accepted separated by a comma.\nFor example Medicaid,Private",
                                          labelText: "Insurances Accepted",
                                          minLines: 2,
                                          textInput:
                                              newInsuranceController.text,
                                          setText: setNewInsurance,
                                        ));
                              },
                              child: TextFormField(
                                  enabled: false,
                                  maxLines: null,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: "Insurances Accepted",
                                      errorStyle: TextStyle(
                                          color: Theme.of(context).errorColor)),
                                  controller: newInsuranceController,
                                  validator: Validators.inputValidator),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(child: isLoading ? const Loader() : null),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: RoundedRectangleButton(
                        width: 400,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            createOrganization();
                          }
                        },
                        text: "Create Resource",
                        buttoncolor: Pallete.buttondarkBlue,
                        height: 50),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom))
                ],
              ),
            )),
      ),
    );
  }
}
