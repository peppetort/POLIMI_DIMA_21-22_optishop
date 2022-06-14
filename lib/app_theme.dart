import 'package:flutter/material.dart';

class OptiShopAppTheme {
  static const Color primaryColor = Color(0xFFFFC61E);
  static const Color primaryColorDark = Color(0xFFC79600);
  static const Color primaryColorLight = Color(0xFFFFDB70);
  static const Color secondaryColor = Color(0xFF364652);
  static const Color secondaryColorDark = Color(0xFF0F1F2A);
  static const Color secondaryColorLight = Color(0xFF61717E);

  static const Color backgroundColor = Color(0xFFFAFAFA);

  static const Color accentColor = Color.fromARGB(255, 246, 186, 53);

  static const Color headingText = Color.fromARGB(255, 71, 123, 114);
  static const Color primaryText = Color.fromARGB(255, 155, 158, 166);
  static const Color secondaryText = Color.fromARGB(255, 0, 0, 0);

  static const Color errorTextColor = Color.fromARGB(255, 212, 52, 52);
  static TextStyle errorTextStyle =
  t.textTheme.bodyText1!.copyWith(color: errorTextColor);

  static const Color darkGray = Color.fromARGB(255, 90, 90, 90);
  static const Color dividerLine = Color.fromARGB(50, 111, 111, 110);
  static const Color grey = Color.fromARGB(255, 235, 235, 235);

  static const fontFamily = 'Roboto';

  static const defaultPagePadding =
  EdgeInsets.symmetric(vertical: 8.0, horizontal: 28.0);

  // Shadows
  static const Shadow defaultShadow =
  Shadow(color: Colors.black26, offset: Offset(5, 5), blurRadius: 8);

  static ThemeData t = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // Define the default font family.
    fontFamily: fontFamily,

    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: const TextTheme(
      headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      headline4: TextStyle(
        fontSize: 34.0,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        color: secondaryColor,
      ),
      headline5: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        color: secondaryColor,
      ),
      headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      bodyText1: TextStyle(fontSize: 14.0, color: secondaryColor),
      bodyText2: TextStyle(fontSize: 16.0, color: secondaryColor),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: secondaryColor,
        splashFactory: InkSplash.splashFactory,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        primary: secondaryColor,
        onSurface: Colors.white,
        splashFactory: InkSplash.splashFactory,
        side: const BorderSide(width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        splashFactory: InkSplash.splashFactory,
        primary: secondaryColor,
        onSurface: secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
    ),
    iconTheme: const IconThemeData(
      color: Colors.black45,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(fontSize: 16.0, color: Colors.black45),
    ),
    appBarTheme: const AppBarTheme(
      color: primaryColor,
      foregroundColor: secondaryColor,
      iconTheme: IconThemeData(
        color: secondaryColor,
      ),
      actionsIconTheme: IconThemeData(
        color: secondaryColor,
      ),
      titleTextStyle: TextStyle(
        color: secondaryColor,
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      toolbarTextStyle: TextStyle(
        color: secondaryColor,
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      actionTextColor: Colors.black87,
      disabledActionTextColor: Colors.grey,
      contentTextStyle: TextStyle(fontSize: 16, color: Colors.black54),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
    ),
    colorScheme: const ColorScheme(
      primary: primaryColor,
      onPrimary: Colors.white,
      background: Colors.red,
      onBackground: Colors.black,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: Colors.black,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: secondaryColor,
      brightness: Brightness.light,
    ),
  );

  static ThemeData get theme => t;
}
