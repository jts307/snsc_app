// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
// import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snsc/Pages/all_pages.dart';
import 'package:snsc/models/organization.dart';
import 'package:snsc/models/filter.dart';
import 'package:snsc/models/faq.dart';

import '../config/api_config.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;

class APIService {
  static var server = http.Client();

  // user functions

  static Future<String> signup(User user, BuildContext context) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    var url = Uri.https(ApiConfig.rootURL, ApiConfig.signupAPI);

    try {
      var response = await server.post(url,
          headers: requestHeaders, body: jsonEncode(user.toJson()));

      // if successful
      if (response.statusCode == 200) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        User apiUserInfo = User.fromJson(json.decode(response.body));
        String savedUserInfo = jsonEncode(apiUserInfo);
        localStorage.setString('user', savedUserInfo);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const HomePage(
                      email: '',
                      password: '',
                      wantsBiometrics: false,
                    )),
            (route) => false);
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'])),
        );
      }

      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  static Future<String> login(String email, String password,
      BuildContext context, bool wantsBiometrics) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    final data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;

    var url = Uri.https(ApiConfig.rootURL, ApiConfig.loginAPI);

    try {
      var response = await server.post(url,
          headers: requestHeaders, body: jsonEncode(data));

      if (kDebugMode) {
        print(response.body);
      }

      // if successful
      if (response.statusCode == 200) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        User apiUserInfo = User.fromJson(json.decode(response.body));
        String savedUserInfo = jsonEncode(apiUserInfo);
        localStorage.setString('user', savedUserInfo);

        if (apiUserInfo.isAdmin!) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AdminLandingPage()),
              (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        email: email,
                        password: password,
                        wantsBiometrics: wantsBiometrics,
                      )),
              (route) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Email or Password')),
        );
      }
      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  static Future<void> logout(BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove('user');
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (route) => false);
  }

  // can only use this function if the user is logged in
  // hence why there are no arguments
  static Future<User?> getUserInfo(BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userStringInfo = localStorage.getString('user')!;
    Map<String, dynamic> userMap = jsonDecode(userStringInfo);
    User user = User.fromJson(userMap);

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': '${user.token}',
      'Access-Control-Allow-Origin': '*'
    };

    var url = Uri.https(ApiConfig.rootURL, ApiConfig.userAPI);

    try {
      var response = await server.get(url, headers: requestHeaders);
      Map<String, dynamic> responseUserMap = jsonDecode(response.body);
      User responseUser = User.fromJson(responseUserMap);
      return responseUser;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      //print(exception.toString());
    }
    return null;
  }

  //Test
  // update user info
  static Future<String> updateUser(
      User updatedUser, BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userStringInfo = localStorage.getString('user')!;
    Map<String, dynamic> userMap = jsonDecode(userStringInfo);
    User user = User.fromJson(userMap);

    if (kDebugMode) {
      print(jsonEncode(user));
    }

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': '${user.token}',
      'Access-Control-Allow-Origin': '*'
    };

    try {
      final data = <String, dynamic>{};

      if (updatedUser.name != null) {
        data['name'] = updatedUser.name;
      }

      data['email'] = updatedUser.email;

      if (updatedUser.dateOfBirth != null) {
        data['dateOfBirth'] = updatedUser.dateOfBirth;
      }

      if (updatedUser.location != null) {
        data['location'] = updatedUser.location;
      }

      if (updatedUser.disability != null) {
        data['disability'] = updatedUser.disability;
      }

      if (updatedUser.insurance != null) {
        data['insurance'] = updatedUser.insurance;
      }

      var url = Uri.https(ApiConfig.rootURL, ApiConfig.userAPI);
      var response = await server.put(url,
          headers: requestHeaders, body: jsonEncode(data));

      // if successful
      if (response.statusCode == 200) {
        // update the user info in sharedpreferences
        // rethink this because the token will disappear
        // this also mean the user data saved in local storage will be out of date
        // that is okay because the only thing we need is the token which never changes

        // SharedPreferences localStorage = await SharedPreferences.getInstance();
        // User apiUserInfo = User.fromJson(json.decode(response.body));
        // String savedUserInfo = jsonEncode(apiUserInfo);
        // localStorage.setString('user', savedUserInfo);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile successfully updated')),
        );
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'])),
        );
      }

      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  // update user password
  static Future<String> updatePassword(
      String oldPassword, String newPassword, BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userStringInfo = localStorage.getString('user')!;
    Map<String, dynamic> userMap = jsonDecode(userStringInfo);
    User user = User.fromJson(userMap);

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': '${user.token}',
      'Access-Control-Allow-Origin': '*'
    };

    final data = <String, dynamic>{};
    data['old'] = oldPassword;
    data['new'] = newPassword;

    var url = Uri.https(ApiConfig.rootURL, ApiConfig.userpasswordAPI);

    try {
      var response = await server.put(url,
          headers: requestHeaders, body: jsonEncode(data));

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password successfully changed')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Old password is incorrect')),
        );
      }

      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  // todo: delete user (so that they can delete there account)
  static Future<String> deleteUser(BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userStringInfo = localStorage.getString('user')!;
    Map<String, dynamic> userMap = jsonDecode(userStringInfo);
    User user = User.fromJson(userMap);

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': '${user.token}',
      'Access-Control-Allow-Origin': '*'
    };

    var url = Uri.https(ApiConfig.rootURL, ApiConfig.userAPI);
    try {
      var response = await server.delete(url, headers: requestHeaders);

      if (response.statusCode == 200) {
        localStorage.remove('user');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully deleted your account')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete your account')),
        );
      }

      return response.body;
    } catch (exception) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  // organization functions

  static Future<List<Organization>?> getAllOrganizations() async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    try {
      var url = Uri.https(ApiConfig.rootURL, ApiConfig.organizationsAPI);
      var response = await server.get(url, headers: requestHeaders);

      List responseJson = jsonDecode(response.body);

      return responseJson.map((m) => Organization.fromJson(m)).toList();
    } catch (e) {
      //print(e);
    }
    return null;
  }

  static Future<Organization> getOrganization(String id) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userStringInfo = localStorage.getString('user')!;
    Map<String, dynamic> userMap = jsonDecode(userStringInfo);
    User user = User.fromJson(userMap);

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': '${user.token}',
      'Access-Control-Allow-Origin': '*'
    };

    var url = Uri.https(ApiConfig.rootURL, '${ApiConfig.organizationsAPI}/$id');
    var response = await server.get(url, headers: requestHeaders);

    Map<String, dynamic> responseJson = jsonDecode(response.body);
    return Organization.fromJson(responseJson);
  }

  static Future<String> saveOrganization(
      Organization organization, String token, BuildContext context) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': token,
      'Access-Control-Allow-Origin': '*'
    };

    try {
      var url = Uri.https(ApiConfig.rootURL, ApiConfig.organizationsAPI);
      var response = await server.post(url,
          headers: requestHeaders, body: jsonEncode(organization.toJson()));

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Successfully created a new organization')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create a new organization')),
        );
      }

      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  static Future<String> deleteOrganization(
      String id, BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userStringInfo = localStorage.getString('user')!;
    Map<String, dynamic> userMap = jsonDecode(userStringInfo);
    User user = User.fromJson(userMap);

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': '${user.token}',
      'Access-Control-Allow-Origin': '*'
    };

    try {
      var url =
          Uri.https(ApiConfig.rootURL, '${ApiConfig.organizationsAPI}/$id');
      var response = await server.delete(url, headers: requestHeaders);

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Successfully deleted the organization')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete the organization')),
        );
      }

      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  static Future<String> updateOrganization(String id, Organization organization,
      String token, String oldImageKey, BuildContext context) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': token,
      'Access-Control-Allow-Origin': '*'
    };

    try {
      var url =
          Uri.https(ApiConfig.rootURL, '${ApiConfig.organizationsAPI}/$id');
      var response = await server.put(url,
          headers: requestHeaders, body: jsonEncode(organization.toJson()));

      if (response.statusCode == 200) {
        if (oldImageKey != "None") {
          if (kDebugMode) {
            print("key being deleted");
            print(oldImageKey);
          }

          var url = Uri.https(ApiConfig.rootURL, '/api/images/$oldImageKey');
          await server.delete(url, headers: requestHeaders);
        }
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Successfully updated the organization')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update the organization')),
        );
      }

      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  static Future<String> saveToFavorites(
      String organizationId, BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userStringInfo = localStorage.getString('user')!;
    Map<String, dynamic> userMap = jsonDecode(userStringInfo);
    User user = User.fromJson(userMap);

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': '${user.token}',
      'Access-Control-Allow-Origin': '*'
    };

    try {
      var url = Uri.https(ApiConfig.rootURL,
          '${ApiConfig.userFavoritesAPI}/add/$organizationId');
      var response = await server.put(url, headers: requestHeaders);
      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  static Future<String> removeToFavorites(
      String organizationId, BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userStringInfo = localStorage.getString('user')!;
    Map<String, dynamic> userMap = jsonDecode(userStringInfo);
    User user = User.fromJson(userMap);

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': '${user.token}',
      'Access-Control-Allow-Origin': '*'
    };

    try {
      var url = Uri.https(ApiConfig.rootURL,
          '${ApiConfig.userFavoritesAPI}/remove/$organizationId');
      var response = await server.put(url, headers: requestHeaders);

      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  static Future<List<Organization>?> getAllFavorites() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userStringInfo = localStorage.getString('user')!;
    Map<String, dynamic> userMap = jsonDecode(userStringInfo);
    User user = User.fromJson(userMap);

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': '${user.token}',
      'Access-Control-Allow-Origin': '*'
    };

    try {
      var url = Uri.https(ApiConfig.rootURL, ApiConfig.userFavoritesAPI);
      var response = await server.get(url, headers: requestHeaders);

      List responseJson = jsonDecode(response.body);

      return responseJson.map((m) => Organization.fromJson(m)).toList();
    } catch (e) {
      //print(e);
    }
    return null;
  }

  static Future<List<Organization>?> searchByText(
      String organizationName) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    try {
      final data = <String, String>{};
      data['name'] = organizationName;

      var url = Uri.https(ApiConfig.rootURL, ApiConfig.textSearch);

      var response = await server.post(url,
          headers: requestHeaders, body: json.encode(data));

      List responseJson = jsonDecode(response.body);

      return responseJson.map((m) => Organization.fromJson(m)).toList();
    } catch (e) {
      //print(e);
    }
    return null;
  }

  static Future<List<Organization>?> searchByFilter(
      {List<String>? disabilities,
      List<String>? services,
      List<String>? states,
      List<String>? insurances,
      String? fee,
      String? age}) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    try {
      final data = <String, dynamic>{};

      if (disabilities!.isNotEmpty) {
        data['disabilities'] = disabilities;
      }
      if (services!.isNotEmpty) {
        data['services'] = services;
      }
      if (states!.isNotEmpty) {
        data['states'] = states;
      }
      if (insurances!.isNotEmpty) {
        data['insurances'] = insurances;
      }
      if (fee != "----") {
        data['fee'] = fee;
      }
      if (age != "") {
        data['age'] = int.parse(age!);
      }

      var url = Uri.https(ApiConfig.rootURL, ApiConfig.filterSearch);
      var response = await server.post(url,
          headers: requestHeaders, body: jsonEncode(data));

      List responseJson = jsonDecode(response.body);

      return responseJson.map((m) => Organization.fromJson(m)).toList();
    } catch (exception) {
      //print(exception)
    }
    return null;
  }

  // filter functions
  static Future<List<Filter>> getDisabilityFilters() async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    var url =
        Uri.https(ApiConfig.rootURL, "${ApiConfig.filterAPI}/disabilities");
    var response = await server.get(url, headers: requestHeaders);

    List responseJson = jsonDecode(response.body);

    return responseJson.map((m) => Filter.fromJson(m)).toList();
  }

  static Future<List<Filter>> getServiceFilters() async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    var url = Uri.https(ApiConfig.rootURL, "${ApiConfig.filterAPI}/services");
    var response = await server.get(url, headers: requestHeaders);

    List responseJson = jsonDecode(response.body);

    return responseJson.map((m) => Filter.fromJson(m)).toList();
  }

  static Future<List<Filter>> getStateFilters() async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    var url = Uri.https(ApiConfig.rootURL, "${ApiConfig.filterAPI}/states");
    var response = await server.get(url, headers: requestHeaders);

    List responseJson = jsonDecode(response.body);

    return responseJson.map((m) => Filter.fromJson(m)).toList();
  }

  static Future<List<Filter>> getInsuranceFilters() async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    var url = Uri.https(ApiConfig.rootURL, "${ApiConfig.filterAPI}/insurances");
    var response = await server.get(url, headers: requestHeaders);

    List responseJson = jsonDecode(response.body);

    return responseJson.map((m) => Filter.fromJson(m)).toList();
  }

  // faq functions
  static Future<List<Faq>?> getFaqs(BuildContext context) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    var url = Uri.https(ApiConfig.rootURL, ApiConfig.faqAPI);

    try {
      var response = await server.get(url, headers: requestHeaders);

      List responseJson = jsonDecode(response.body);

      return responseJson.map((m) => Faq.fromJson(m)).toList();
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      //print(exception.toString());
    }
    return null;
  }

  static Future<String> saveFaq(Faq faq, BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userStringInfo = localStorage.getString('user')!;
    Map<String, dynamic> userMap = jsonDecode(userStringInfo);
    User user = User.fromJson(userMap);

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': '${user.token}',
      'Access-Control-Allow-Origin': '*'
    };

    try {
      var url = Uri.https(ApiConfig.rootURL, ApiConfig.faqAPI);
      var response = await server.post(url,
          headers: requestHeaders, body: jsonEncode(faq.toJson()));

      return response.body;
    } catch (exception) {
      return exception.toString();
    }
  }

  static Future<String> deleteFaq(String id, BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userStringInfo = localStorage.getString('user')!;
    Map<String, dynamic> userMap = jsonDecode(userStringInfo);
    User user = User.fromJson(userMap);

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': '${user.token}',
      'Access-Control-Allow-Origin': '*'
    };

    try {
      var url = Uri.https(ApiConfig.rootURL, '${ApiConfig.faqAPI}/$id');
      var response = await server.delete(url, headers: requestHeaders);

      return response.body;
    } catch (exception) {
      return exception.toString();
    }
  }

  static Future<String> updateFaq(
      String id, Faq faq, BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userStringInfo = localStorage.getString('user')!;
    Map<String, dynamic> userMap = jsonDecode(userStringInfo);
    User user = User.fromJson(userMap);

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': '${user.token}',
      'Access-Control-Allow-Origin': '*'
    };

    try {
      var url = Uri.https(ApiConfig.rootURL, '${ApiConfig.faqAPI}/$id');
      var response = await server.put(url,
          headers: requestHeaders, body: jsonEncode(faq.toJson()));

      return response.body;
    } catch (exception) {
      return exception.toString();
    }
  }

  static Future<String> sendOTP(String userEmail, BuildContext context) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    final data = <String, String>{};
    data['userEmail'] = userEmail;

    var url = Uri.https(ApiConfig.rootURL, ApiConfig.otpAPI);

    try {
      var response = await server.post(url,
          headers: requestHeaders, body: jsonEncode(data));

      // if successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> res = jsonDecode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PasswordResetOTP(
                  email: userEmail, fullHash: res['fullHash'])),
        );
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'])),
        );
      }
      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  static Future<String> resendOTP(
      String userEmail, BuildContext context) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    try {
      final data = <String, String>{};
      data['userEmail'] = userEmail;
      var url = Uri.https(ApiConfig.rootURL, ApiConfig.otpAPI);

      var response = await server.post(url,
          headers: requestHeaders, body: jsonEncode(data));

      // if successful
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('A new code has been sent to $userEmail')),
        );
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'])),
        );
      }
      final Map<String, dynamic> res = jsonDecode(response.body);
      return res['fullHash'];
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      //print(exception.toString());
      return "error";
    }
  }

  static Future<String> verifyOTP(String userEmail, String otp, String fullHash,
      BuildContext context) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };

    final data = <String, String>{};
    data['userEmail'] = userEmail;
    data['otp'] = otp;
    data['hash'] = fullHash;

    var url = Uri.https(ApiConfig.rootURL, ApiConfig.verifyOTPApi);
    try {
      var response = await server.post(url,
          headers: requestHeaders, body: json.encode(data));

      // if successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> res = jsonDecode(response.body);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => PasswordResetNew(token: res['token'])),
            (route) => false);
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'])),
        );
      }
      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  static Future<String> resetPassword(
      String newPassword, String token, BuildContext context) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'authorization': token,
      'Access-Control-Allow-Origin': '*'
    };

    try {
      final data = <String, dynamic>{};
      data['newPassword'] = newPassword;

      var url = Uri.https(ApiConfig.rootURL, ApiConfig.userResetPasswordAPI);
      var response = await server.put(url,
          headers: requestHeaders, body: jsonEncode(data));

      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password successfully reset')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error resetting your password')),
        );
      }

      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }

  static Future<String> sendFeedback(String senderEmail, String feedback,
      String feedbackTypes, BuildContext context) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    };
    try {
      final data = <String, String>{};
      data['senderEmail'] = senderEmail;
      data['feedback'] = feedback;
      data['feedbackTypes'] = feedbackTypes;

      var url = Uri.https(ApiConfig.rootURL, ApiConfig.feedbackAPI);

      var response = await server.post(url,
          headers: requestHeaders, body: jsonEncode(data));

      // if successful
      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your Feedback has been sent')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("There was an error sending your feedback")),
        );
      }
      return response.body;
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[400],
            content: const Text('No Internet Connection')),
      );
      return exception.toString();
    }
  }
}
