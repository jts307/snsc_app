// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:snsc/Pages/all_pages.dart';
import 'package:snsc/Pages/favorites_page.dart';
import 'package:snsc/config/pallete.dart';

import '../config/accesibility_config.dart';

class HomePage extends StatefulWidget {
  final bool? wantsBiometrics;
  final String? email;
  final String? password;
  final int? currIndex;
  const HomePage(
      {Key? key,
      this.wantsBiometrics,
      this.email,
      this.password,
      this.currIndex})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocalAuthentication auth = LocalAuthentication();
  final storage = const FlutterSecureStorage();
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    if (widget.wantsBiometrics != null) {
      if (widget.wantsBiometrics!) {
        authenticate();
      }
    }

    if (widget.currIndex != null){
        _selectedIndex = widget.currIndex!;
    }
    else{
        _selectedIndex = 0;
    }
  }

  void authenticate() async {
    final canCheck = await auth.canCheckBiometrics;

    if (canCheck) {
      List availableBiometrics = await auth.getAvailableBiometrics();

      if (Platform.isIOS) {
        if (availableBiometrics.contains(BiometricType.face)) {
          // Face ID.
          final authenticated = await auth.authenticate(
              localizedReason: 'Enable Face ID to sign in more easily');
          if (authenticated) {
            storage.write(key: 'email', value: widget.email);
            storage.write(key: 'password', value: widget.password);
            storage.write(key: 'usingBiometric', value: 'true');
          }
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          // Touch ID.
          final authenticated = await auth.authenticate(
              localizedReason: 'Enable Touch ID to sign in more easily');
          if (authenticated) {
            storage.write(key: 'email', value: widget.email);
            storage.write(key: 'password', value: widget.password);
            storage.write(key: 'usingBiometric', value: 'true');
          }
        }
      }
    } else {
      if (kDebugMode) {
        print('cant check for biometrics');
      }
    }
  }

  void refreshPage() {
    setState(() {});
  }

  static const List<Widget> _widgetOptions = <Widget>[
    SearchPage(
      userLoggedIn: true,
    ),
    FavoritesPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: TextStyle(
          fontFamily: Preferences.currentFont(),
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: Preferences.currentFont(),
        ),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Pallete.buttonGreen,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        iconSize: 36,
        backgroundColor:
            Preferences.usingDarkMode() ? Colors.white : Colors.white,
      ),
    );
  }
}
