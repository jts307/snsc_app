import 'package:flutter/material.dart';
import 'package:snsc/widgets/all_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/accesibility_config.dart';
import '../config/pallete.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key, required this.prevPage}) : super(key: key);

  final Widget prevPage;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  void refreshPage() {
    setState(() {});
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
        body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(children: [
                AppBarReturn(
                  returnPage: widget.prevPage,
                  popContext: false,
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
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text("Special Needs Support Center (SNSC) App",
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            style: TextStyle(
                                color: Pallete.buttonGreen,
                                fontFamily: Preferences.currentFont(),
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const DividerText(text: "   CONTACT US   "),
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 5.0, bottom: 5.0),
                        child: Text(
                            "129 South Main Street, Suite 103, White River Junction, VT 00501 \nStop by our offices Tuesday-Friday between 10am and 4pm",
                            maxLines: 6,
                            style: TextStyle(
                                color: Pallete.buttonBlue,
                                fontFamily: Preferences.currentFont(),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 5.0, bottom: 5.0),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _launchInBrowser("https://snsc-uv.org/");
                          }),
                          child: Text(
                              "Visit our website at https://snsc-uv.org/",
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: Preferences.currentFont(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 5.0, bottom: 5.0),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _launchInBrowser("https://snsc-uv.org/contact/");
                          }),
                          child: Text("Send us an email",
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: Preferences.currentFont(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 2.0, bottom: 2.0),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _makePhoneCall("603-448-6311");
                          }),
                          child: Text("Give us a call at 603-448-6311",
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: Preferences.currentFont(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const DividerText(text: "   DEVELOPERS   "),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 2.0, bottom: 6.0),
                        child: Text(
                            "The app was developed as part of the COSC98 Senior Design and Implementation Course at Dartmouth College Winter-Spring 2022",
                            maxLines: 4,
                            style: TextStyle(
                                color: Pallete.buttonBlue,
                                fontFamily: Preferences.currentFont(),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 2.0, bottom: 2.0),
                        child: Text("Faculty Advisor: ",
                            maxLines: 4,
                            style: TextStyle(
                                color: Pallete.buttonBlue,
                                fontFamily: Preferences.currentFont(),
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 16.0, top: 2.0, bottom: 2.0),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _sendEmail("sebastiaan.joosten@dartmouth.edu");
                          }),
                          child: Text("Sebastiaan Joosten",
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: Preferences.currentFont(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 2.0, bottom: 2.0),
                        child: Text("Developer: ",
                            maxLines: 4,
                            style: TextStyle(
                                color: Pallete.buttonBlue,
                                fontFamily: Preferences.currentFont(),
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 16.0, top: 2.0, bottom: 2.0),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _launchInBrowser(
                                "https://www.linkedin.com/in/jeffmaina");
                          }),
                          child: Text("Jeff Maina Gitahi",
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: Preferences.currentFont(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 2.0, bottom: 2.0),
                        child: Text("Developer: ",
                            maxLines: 4,
                            style: TextStyle(
                                color: Pallete.buttonBlue,
                                fontFamily: Preferences.currentFont(),
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 16.0, top: 2.0, bottom: 2.0),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _launchInBrowser(
                                "https://www.linkedin.com/in/johnbkariuki");
                          }),
                          child: Text("John Kariuki",
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: Preferences.currentFont(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 2.0, bottom: 2.0),
                        child: Text("Developer: ",
                            maxLines: 4,
                            style: TextStyle(
                                color: Pallete.buttonBlue,
                                fontFamily: Preferences.currentFont(),
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 16.0, top: 2.0, bottom: 2.0),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _launchInBrowser(
                                "https://www.linkedin.com/in/jfwagner22");
                          }),
                          child: Text("Jack Wagner",
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: Preferences.currentFont(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 2.0, bottom: 2.0),
                        child: Text("Developer: ",
                            maxLines: 4,
                            style: TextStyle(
                                color: Pallete.buttonBlue,
                                fontFamily: Preferences.currentFont(),
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 16.0, top: 2.0, bottom: 2.0),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _launchInBrowser(
                                "https://www.linkedin.com/in/daniel-akili-57788a132");
                          }),
                          child: Text("Daniel Akili",
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: Preferences.currentFont(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30,),
              ]),
            )),
      ),
    );
  }
}
