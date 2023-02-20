// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:snsc/Functions_and_Vars/api_services.dart';
import 'package:snsc/Pages/admin/edit_resource_fields.dart';
import 'package:snsc/Pages/detailed_results_page.dart';
import 'package:snsc/config/api_config.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/models/organization.dart';
import 'package:snsc/models/user.dart';
import 'package:snsc/widgets/action_button.dart';
import 'package:snsc/widgets/all_widgets.dart';
import 'package:like_button/like_button.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../config/accesibility_config.dart';

class ResourceCard extends StatefulWidget {
  final Organization org;
  final bool adminButton;
  final Function()? reloadFavoritesPage;
  final Function()? reloadAllPages;
  const ResourceCard(
      {Key? key,
      required this.org,
      required this.adminButton,
      this.reloadFavoritesPage,
      this.reloadAllPages})
      : super(key: key);

  @override
  _ResourceCardState createState() => _ResourceCardState();
}

class _ResourceCardState extends State<ResourceCard> {
  late Future<User?> user;
  late Future<Image> orgImage;
  static var server = http.Client();
  bool isLoading = false;

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

  Future<Image> getOrgImage() async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    if (widget.org.imageURL != "None") {
      var url =
          Uri.https(ApiConfig.rootURL, '/api/images/${widget.org.imageURL}');
      var response = await server.get(url, headers: requestHeaders);
      return Image.memory(Uint8List.fromList(response.bodyBytes));
    }

    return Image.asset('Assets/stock_resource_image.jpeg');
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

  Future<bool> noInternetConnection() async {
    if (kIsWeb) {
      var result = await Connectivity().checkConnectivity();
      return result == ConnectivityResult.none;
    } else {
      var result = await InternetConnectionChecker().hasConnection;
      return !result;
    }
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
            child = LikeButton(
              isLiked: isLiked,
              onTap: (isLiked) async {
                bool noInternet = await noInternetConnection();

                if (!noInternet) {
                  if (isLiked) {
                    await APIService.removeToFavorites(widget.org.id!, context);
                  } else {
                    await APIService.saveToFavorites(widget.org.id!, context);
                  }

                  if (widget.reloadFavoritesPage == null) {
                    return !isLiked;
                  } else {
                    widget.reloadFavoritesPage!();
                  }
                  return null;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        backgroundColor: Colors.red[400],
                        content: const Text('No Internet Connection')),
                  );
                }
                return null;
              },
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
            Image image = snapshot.data;
            child = SizedBox(
              height: 100,
              width: 100,
              child: image,
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailedResultsPage(
                        org: widget.org,
                        admin: widget.adminButton,
                      )),
            ).then((value) {
              widget.reloadAllPages!();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        imagefutureBuilder,
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                RoundedRectangleButton(
                                    width: 60,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DetailedResultsPage(
                                                  org: widget.org,
                                                  admin: widget.adminButton,
                                                )),
                                      ).then((value) {
                                        widget.reloadAllPages!();
                                      });
                                    },
                                    text: "More",
                                    buttoncolor: Pallete.buttonGrey,
                                    height: 25),
                                const SizedBox(width: 10),
                                if (!widget.adminButton) futureBuilder,
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
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
                                fontFamily: Preferences.currentFont(),
                                fontSize: 22,
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
                                        _sendEmail(
                                            widget.org.primaryEmail as String);
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
                                        _makePhoneCall(widget
                                            .org.primaryPhoneNumber as String);
                                      })),
                            if (widget.adminButton)
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
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    "Do you want to delete this resource?",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          primary:
                                                                              Pallete.buttonGreen,
                                                                        ),
                                                                        child:
                                                                            const Text(
                                                                          "Cancel",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white),
                                                                        )),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () async {
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
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          primary: const Color.fromARGB(
                                                                              255,
                                                                              247,
                                                                              69,
                                                                              46),
                                                                        ),
                                                                        child:
                                                                            const Text(
                                                                          "Delete",
                                                                          style: TextStyle(
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
                                            widget.reloadAllPages!();
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
                )
              ],
            ),
          ),
        ));
  }
}
