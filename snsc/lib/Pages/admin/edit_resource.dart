// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:snsc/Functions_and_Vars/api_services.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/models/organization.dart';
import 'package:snsc/Pages/all_pages.dart';
import 'package:snsc/widgets/all_widgets.dart';

final bucketGlobal3 = PageStorageBucket();

class EditResource extends StatefulWidget {
  const EditResource({
    Key? key,
    this.searchText,
  }) : super(key: key);

  final String? searchText;

  @override
  _EditResourceState createState() => _EditResourceState();
}

class _EditResourceState extends State<EditResource> {
  late int numResults = 0;
  TextEditingController searchText = TextEditingController();
  late Future<List<Organization>?> entries;

  Future<List<Organization>?> searchByText() async {
    return await APIService.searchByText(searchText.text);
  }

  refresh() {
    if (searchText.text.isNotEmpty) {
      setState(() {
        entries = searchByText();
      });
    } else {
      setState(() {
        entries = APIService.getAllOrganizations();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    entries = APIService.getAllOrganizations();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    var futureBuilder = FutureBuilder(
      future: entries,
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
            numResults = snapshot.data.length;
            if (numResults == 0) {
              child = Center(child: Image.asset("Assets/no_results_found.png"));
            } else {
              child = SizedBox(
                width: 550,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, bottom: 5),
                        child: Text("$numResults results found ",
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 550),
                        child: ListView.builder(
                            shrinkWrap: true,
                            key: const PageStorageKey<String>(
                                'edit_resource_page'),
                            padding: const EdgeInsets.all(8),
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ResourceCard(
                                org: snapshot.data[index],
                                reloadAllPages: refresh,
                                adminButton: true,
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              );
            }
          } else {
            child = const Center(
                child: Text('Please check your internet connection'));
          }
        }
        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500), child: child);
      },
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("Assets/background_1.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(children: [
              const AppBarAdmin(returnPage: AdminLandingPage()),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: const [
                  Text("Manage Resources",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Pallete.buttonGreen,
                          fontSize: 30,
                          fontWeight: FontWeight.bold))
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 5.0),
                child: SizedBox(
                  width: 500,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          width: 300,
                          decoration: const BoxDecoration(),
                          child: TextFormField(
                            controller: searchText,
                            maxLines: 2,
                            minLines: 1,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Search Organization Name',
                            ),
                            onChanged: (input) {
                              refresh();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      CircleButton(
                        icon: Icons.search,
                        iconSize: 30,
                        onPressed: () {
                          setState(() {
                            refresh();
                          });
                        },
                        color: Pallete.buttonGreen,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              PageStorage(
                  bucket: bucketGlobal3,
                  child: SizedBox(
                      height: screenHeight * 0.9, child: futureBuilder)),
            ]),
          ),
        ),
      ),
    );
  }
}
