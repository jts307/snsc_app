// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:snsc/Functions_and_Vars/api_services.dart';
import 'package:snsc/config/pallete.dart';
import 'package:snsc/models/organization.dart';
import 'package:snsc/widgets/all_widgets.dart';

import '../config/accesibility_config.dart';

final bucketGlobal = PageStorageBucket();

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key, this.callBack}) : super(key: key);
  final Function? callBack;

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Organization>?> entries;

  Future<List<Organization>?> getOrganizations() async {
    return await APIService.getAllFavorites();
  }

  refresh() {
    setState(() {
      entries = getOrganizations();
    });
    widget.callBack;
  }

  @override
  void initState() {
    super.initState();
    entries = getOrganizations();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
            if (snapshot.data.length == 0) {
              child = Center(
                  child: Column(
                children: [
                  Image.asset("Assets/no_favorites.png", color: Pallete.buttonGreen,),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 250,
                    child: Text(
                      "Favorite resources and have them appear here for easier access!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: Preferences.currentFont(),
                          fontWeight: FontWeight.bold,
                          color: Preferences.usingDarkMode() ? Colors.white : Colors.black),
                    ),
                  )
                ],
              ));
            } else {
              child = Column(
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 550,
                      ),
                      child: ListView.builder(
                          key: const PageStorageKey<String>('favorites_page'),
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.all(8),
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ResourceCard(
                              adminButton: false,
                              org: snapshot.data[index],
                              reloadFavoritesPage: refresh,
                              reloadAllPages: refresh,
                            );
                          }),
                    ),
                  ),
                ],
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
          child: Column(children: [
            AppBarLogo(
              callBack: refresh,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("FAVORITES",
                    style: TextStyle(
                        color: Pallete.buttonGreen,
                        fontFamily: Preferences.currentFont(),
                        fontSize: 25,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: PageStorage(bucket: bucketGlobal, child: futureBuilder),
            )
          ]),
        ),
      ),
    );
  }
}
