// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:math';
import 'dart:typed_data';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:snsc/Functions_and_Vars/api_services.dart';
import 'package:snsc/Pages/admin/edit_resource_fields.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/models/organization.dart';
import 'package:like_button/like_button.dart';
import 'package:snsc/widgets/action_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../config/accesibility_config.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'loader.dart';

class DetailedResourceCard extends StatefulWidget {
  final Organization org;
  final bool admin;
  final Function()? reloadAllPages;
  const DetailedResourceCard(
      {Key? key, required this.org, required this.admin, this.reloadAllPages})
      : super(key: key);

  @override
  _DetailedResourceCardState createState() => _DetailedResourceCardState();
}

class _DetailedResourceCardState extends State<DetailedResourceCard> {
  late Future<User?> user;
  late Future<ImageProvider> orgImage;
  static var server = http.Client();
  bool isLoading = false;

  Future<User?> getUser() async {
    return await APIService.getUserInfo(context);
  }

  Future<ImageProvider> getOrgImage() async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    if (widget.org.imageURL != "None") {
      var url =
          Uri.https(ApiConfig.rootURL, '/api/images/${widget.org.imageURL}');
      var response = await server.get(url, headers: requestHeaders);
      return Image.memory(Uint8List.fromList(response.bodyBytes)).image;
    }

    return Image.asset('Assets/stock_resource_image.jpeg').image;
  }

  // action button functions
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }

  static _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launch(launchUri.toString());
  }

  static Future<void> _launchInBrowser(String url) async {
    if (!await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $url';
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

  refreshPage() {
    setState(() {});
  }

  loading(load) {
    setState(() {
      isLoading = load;
    });
  }

  @override
  void initState() {
    super.initState();
    user = getUser();
    orgImage = getOrgImage();
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = FutureBuilder(
      future: user,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.none) {
          child = const Center(child: Text('No Connection'));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          child = const Center(
              child: SpinKitRing(
            color: Pallete.buttondarkBlue,
            size: 50.0,
          ));
        } else {
          if (snapshot.hasData) {
            bool isLiked = snapshot.data.favoriteIds.contains(widget.org.id);
            child = Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: LikeButton(
                isLiked: isLiked,
                onTap: (isLiked) async {
                  bool noInternet = await noInternetConnection();

                  if (!noInternet) {
                    if (isLiked) {
                      await APIService.removeToFavorites(
                          widget.org.id!, context);
                    } else {
                      await APIService.saveToFavorites(widget.org.id!, context);
                    }
                    return !isLiked;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: Colors.red[400],
                          content: const Text('No Internet Connection')),
                    );
                  }
                  return null;
                },
              ),
            );
          } else {
            child = Container();
          }
        }

        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500), child: child);
      },
    );

    var imagefutureBuilder = FutureBuilder(
      future: orgImage,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.none) {
          child = const Center(child: Text('No Connection'));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          child = const Center(
              child: SpinKitRing(
            color: Pallete.buttondarkBlue,
            size: 50.0,
          ));
        } else {
          if (snapshot.hasData) {
            ImageProvider image = snapshot.data;
            child = CircleAvatar(
              maxRadius: min(MediaQuery.of(context).size.width / 7.5, 60),
              backgroundImage: image,
            );
          } else {
            child = Container();
          }
        }
        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500), child: child);
      },
    );
    return Card(
        color: Preferences.usingDarkMode()
            ? Pallete.cardBackground.withOpacity(0.2)
            : Pallete.cardBackground,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          splashColor: Colors.green.withAlpha(30),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Align(child: imagefutureBuilder),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: AutoSizeText('${widget.org.name}',
                                  maxLines: 3,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Pallete.buttonGreen,
                                    fontSize: 22,
                                    fontFamily: Preferences.currentFont(),
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                if (widget.org.primaryEmail != "")
                                  ActionButton(
                                      icon: Icons.email,
                                      labelText: "Email",
                                      onPressed: () => setState(() {
                                            _sendEmail(widget.org.primaryEmail
                                                as String);
                                          })),
                                if (widget.org.primaryWebsite != "")
                                  ActionButton(
                                      icon: Icons.web_outlined,
                                      labelText: "Website",
                                      onPressed: () => setState(() {
                                            _launchInBrowser(widget
                                                .org.primaryWebsite as String);
                                          })),
                                if (widget.org.primaryPhoneNumber != "" &&
                                    widget.org.primaryPhoneNumber != "Multiple")
                                  ActionButton(
                                      icon: Icons.phone,
                                      labelText: "Phone",
                                      onPressed: () => setState(() {
                                            _makePhoneCall(widget.org
                                                .primaryPhoneNumber as String);
                                          })),
                                if (widget.admin)
                                  Align(
                                    child: SizedBox(
                                        width: 120,
                                        child: Row(children: [
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            alignment: Alignment.center,
                                            color: Colors.black,
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                        "Do you want to delete this resource?",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: Preferences
                                                                .currentFont(),
                                                            fontSize: 18.0),
                                                      ),
                                                      actions: [
                                                        Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Wrap(
                                                                alignment:
                                                                    WrapAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: ElevatedButton(
                                                                        onPressed: () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        style: ElevatedButton.styleFrom(
                                                                          primary:
                                                                              Pallete.buttonGreen,
                                                                        ),
                                                                        child: Text(
                                                                          "Cancel",
                                                                          style: TextStyle(
                                                                              fontFamily: Preferences.currentFont(),
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white),
                                                                        )),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: ElevatedButton(
                                                                        onPressed: () async {
                                                                          loading(
                                                                              true);
                                                                          bool
                                                                              noInternet =
                                                                              await noInternetConnection();
                                                                          if (!noInternet) {
                                                                            await APIService.deleteOrganization(widget.org.id!,
                                                                                context);
                                                                            Navigator.of(context).pop();
                                                                          } else {
                                                                            Navigator.of(context).pop();
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(backgroundColor: Colors.red[400], content: const Text('No Internet Connection')),
                                                                            );
                                                                          }
                                                                          loading(
                                                                              false);
                                                                        },
                                                                        style: ElevatedButton.styleFrom(
                                                                          primary: const Color.fromARGB(
                                                                              255,
                                                                              247,
                                                                              69,
                                                                              46),
                                                                        ),
                                                                        child: Text(
                                                                          "Delete",
                                                                          style: TextStyle(
                                                                              fontFamily: Preferences.currentFont(),
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white),
                                                                        )),
                                                                  ),
                                                                ]))
                                                      ],
                                                    );
                                                  });
                                            },
                                            iconSize: 24,
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            iconSize: 24,
                                            alignment: Alignment.center,
                                            color: Colors.black,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditResourceFields(
                                                          resource: widget.org,
                                                        )),
                                              ).then((value) {
                                                Navigator.of(context).pop();
                                              });
                                            },
                                          ),
                                        ])),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: IgnorePointer(
                            child: ListView(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8),
                                children: [
                                  AutoSizeText.rich(
                                    TextSpan(
                                        style: const TextStyle(fontSize: 16),
                                        children: [
                                          TextSpan(
                                              text:
                                                  "\nResource Description: \n",
                                              style: TextStyle(
                                                  color: Pallete.buttonGreen,
                                                  fontFamily:
                                                      Preferences.currentFont(),
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text:
                                                  '${widget.org.descriptions}',
                                              style: TextStyle(
                                                  color: Preferences
                                                          .usingDarkMode()
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontFamily:
                                                      Preferences.currentFont(),
                                                  fontWeight: FontWeight.bold)),
                                          const TextSpan(text: '\n'),
                                          if (widget.org.agesServed!.allAges ==
                                              true)
                                            TextSpan(
                                              text:
                                                  '\nServes all ages in ${widget.org.statesServed?.join(', ')}',
                                              style: TextStyle(
                                                  fontFamily:
                                                      Preferences.currentFont(),
                                                  color: Preferences
                                                          .usingDarkMode()
                                                      ? Colors.white
                                                      : Pallete.buttondarkBlue,
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          else if (widget
                                                  .org.agesServed!.upperRange! >
                                              90)
                                            TextSpan(
                                              text:
                                                  '\nServes ages ${widget.org.agesServed?.lowerRange}+ in ${widget.org.statesServed?.join(', ')}',
                                              style: TextStyle(
                                                  fontFamily:
                                                      Preferences.currentFont(),
                                                  color: Pallete.buttondarkBlue,
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          else
                                            TextSpan(
                                              text:
                                                  '\nServes ages ${widget.org.agesServed?.lowerRange}-${widget.org.agesServed?.upperRange} in ${widget.org.statesServed?.join(', ')}',
                                              style: TextStyle(
                                                  fontFamily:
                                                      Preferences.currentFont(),
                                                  color: Pallete.buttondarkBlue,
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          const TextSpan(
                                              text: '\n',
                                              style: TextStyle(fontSize: 1)),
                                          if (widget.org.fee != "")
                                            TextSpan(
                                                text: "\nService Fee? ",
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    color: Pallete.buttonGreen,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          if (widget.org.fee == "true")
                                            TextSpan(
                                                text: 'Yes',
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    color: Preferences
                                                            .usingDarkMode()
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          if (widget.org.fee == "false")
                                            TextSpan(
                                                text: 'No',
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    color: Preferences
                                                            .usingDarkMode()
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          TextSpan(
                                              text: "\nInsurance accepted? ",
                                              style: TextStyle(
                                                  fontFamily:
                                                      Preferences.currentFont(),
                                                  color: Pallete.buttonGreen,
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text:
                                                  '${widget.org.insurancesAccepted?.join(', ')}',
                                              style: TextStyle(
                                                  fontFamily:
                                                      Preferences.currentFont(),
                                                  color: Preferences
                                                          .usingDarkMode()
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          if (widget.org.disabilitiesServed!
                                                  .first !=
                                              'None')
                                            TextSpan(
                                                text: "\nArea of Disability: ",
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    color: Pallete.buttonGreen,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          if (widget.org.disabilitiesServed!
                                                  .first !=
                                              'None')
                                            TextSpan(
                                                text:
                                                    '${widget.org.disabilitiesServed?.join(', ')}',
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    color: Preferences
                                                            .usingDarkMode()
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          if (widget.org.servicesProvided!
                                                  .first !=
                                              'None')
                                            TextSpan(
                                                text: "\nServices Provided: ",
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    color: Pallete.buttonGreen,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          if (widget.org.servicesProvided!
                                                  .first !=
                                              'None')
                                            TextSpan(
                                                text:
                                                    '${widget.org.servicesProvided?.join(', ')}',
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    color: Preferences
                                                            .usingDarkMode()
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          TextSpan(
                                            text: "\n\n",
                                            style: TextStyle(
                                                fontFamily:
                                                    Preferences.currentFont(),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                              text: "Contact us: ",
                                              style: TextStyle(
                                                  fontFamily:
                                                      Preferences.currentFont(),
                                                  color: Pallete.buttonGreen,
                                                  fontWeight: FontWeight.bold)),
                                          const TextSpan(
                                            text: "\n",
                                          ),
                                          if (widget.org.primaryContactName !=
                                              "")
                                            TextSpan(
                                                text: "\nPoint of Contact: ",
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    color: Pallete.buttonGreen,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          TextSpan(
                                              text:
                                                  '${widget.org.primaryContactName}',
                                              style: TextStyle(
                                                  fontFamily:
                                                      Preferences.currentFont(),
                                                  color: Preferences
                                                          .usingDarkMode()
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          if (widget.org.fullPhoneNumber != "")
                                            TextSpan(
                                                text: "\nBy Phone: ",
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    color: Pallete.buttonGreen,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          TextSpan(
                                              text:
                                                  '${widget.org.fullPhoneNumber}',
                                              style: TextStyle(
                                                  fontFamily:
                                                      Preferences.currentFont(),
                                                  color: Preferences
                                                          .usingDarkMode()
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          if (widget.org.fullEmail != "")
                                            TextSpan(
                                                text: "\nBy Email: ",
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    color: Pallete.buttonGreen,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          TextSpan(
                                              text: '${widget.org.fullEmail}',
                                              style: TextStyle(
                                                  fontFamily:
                                                      Preferences.currentFont(),
                                                  color: Preferences
                                                          .usingDarkMode()
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          if (widget.org.fullWebsite != "")
                                            TextSpan(
                                                text: "\nWebsite: ",
                                                style: TextStyle(
                                                    fontFamily: Preferences
                                                        .currentFont(),
                                                    color: Pallete.buttonGreen,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          TextSpan(
                                              text: '${widget.org.fullWebsite}',
                                              style: TextStyle(
                                                  fontFamily:
                                                      Preferences.currentFont(),
                                                  color: Preferences
                                                          .usingDarkMode()
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(child: isLoading ? const Loader() : null),
                ]),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      if (!widget.admin) Column(children: [futureBuilder]),
                      if (!widget.admin) const Spacer(),
                      if (!widget.admin)
                        Column(
                          children: [
                            IconButton(
                              color: Pallete.cardBackground,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    action: SnackBarAction(
                                      onPressed: () {},
                                      label: '',
                                    ),
                                    content: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "Information not up to date?\nVisit the Feedback page and leave us a message",
                                          style: TextStyle(
                                              fontFamily:
                                                  Preferences.currentFont(),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center),
                                    ),
                                    duration: const Duration(seconds: 4),
                                    width: 290, // Width of the SnackBar.
                                    padding: const EdgeInsets.fromLTRB(
                                        45.0, 8.0, 0.0, 8.0),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.info,
                                color: Colors.grey,
                              ),
                              iconSize: 30,
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
