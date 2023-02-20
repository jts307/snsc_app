bool darkMode = false;
bool fontRegular = true;
bool fontDyslexic = false;

class Preferences {
  // dark mode
  static bool usingDarkMode() {
    return darkMode;
  }

  static setDarkMode() {
    darkMode = true;
  }

  static setLightMode() {
    darkMode = false;
  }

  // fonts
  static String useFont() {
    if (fontRegular) {
      return "regular";
    }
    if (fontDyslexic) {
      return "dyslexic";
    }
    return "";
  }

  static setRegularFont() {
    fontRegular = true;
    fontDyslexic = false;
  }

  static setDyslexicFont() {
    fontRegular = false;
    fontDyslexic = true;
  }

  static String currentFont() {
    if (Preferences.useFont() == "regular") {
      return "Regular";
    }
    if (Preferences.useFont() == "dyslexic") {
      return "DyslexicFont";
    } else {
      return "";
    }
  }

}
