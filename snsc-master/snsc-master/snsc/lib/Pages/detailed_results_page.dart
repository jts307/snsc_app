// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:snsc/Pages/admin/edit_resource.dart';
import 'package:snsc/Pages/all_pages.dart';
import 'package:snsc/models/organization.dart';
import 'package:snsc/widgets/all_widgets.dart';

import '../config/accesibility_config.dart';

class DetailedResultsPage extends StatefulWidget {
  final Organization org;
  final bool admin;
  const DetailedResultsPage({Key? key, required this.org, required this.admin})
      : super(key: key);

  @override
  _DetailedResultsPageState createState() => _DetailedResultsPageState();
}

class _DetailedResultsPageState extends State<DetailedResultsPage> {

  void refreshPage() {
    setState(() {
    });
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
            child: Column(children: [
              !widget.admin
                  ? AppBarReturn(
                      returnPage: const ResultsPage(userLoggedIn: false),
                      popContext: true, callBack: refreshPage,)
                  : const AppBarAdmin(returnPage: EditResource()),
              SizedBox(
                width: 550,
                child: Row(
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 550,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DetailedResourceCard(
                            org: widget.org,
                            admin: widget.admin,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
