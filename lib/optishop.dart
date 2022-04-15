import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/providers/result.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/allow_location.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/cart.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/favorites.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/home.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/results.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/settings.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/update_password.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/update_profile.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/first.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/recover_password.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/signin.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';

Logger _logger = Logger('OptiShop');

class OptiShop extends StatelessWidget {
  final FirebaseFirestore fireStoreInstance = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuthInstance = FirebaseAuth.instance;
  final Location location = Location();

  OptiShop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (_) =>
              AuthenticationProvider(firebaseAuthInstance, fireStoreInstance),
        ),
        ChangeNotifierProxyProvider<AuthenticationProvider, CartProvider>(
          create: (_) => CartProvider(),
          lazy: false,
          update: (_, authenticationProvider, cartProvider) => cartProvider!
            ..update(authenticationProvider: authenticationProvider),
        ),
        ChangeNotifierProxyProvider<AuthenticationProvider, DataProvider>(
          create: (_) => DataProvider(fireStoreInstance),
          lazy: false,
          update: (_, authenticationProvider, dataProvider) => dataProvider!
            ..update(authenticationProvider: authenticationProvider),
        ),
        ChangeNotifierProxyProvider<AuthenticationProvider, UserDataProvider>(
          create: (_) => UserDataProvider(location, fireStoreInstance),
          update: (_, authenticationProvider, userDataProvider) =>
              userDataProvider!
                ..update(authenticationProvider: authenticationProvider),
        ),
        ChangeNotifierProxyProvider2<UserDataProvider, CartProvider,
            ResultProvider>(
          create: (_) => ResultProvider(),
          update: (_, userDataProvider, cartProvider, resultProvider) =>
              resultProvider!
                ..update(
                    userDataProvider: userDataProvider,
                    cartProvider: cartProvider),
        ),
      ],
      child: MaterialApp(
        title: 'OptiShop',
        theme: OptiShopAppTheme.theme,
        routes: <String, WidgetBuilder>{
          '/signin': (BuildContext context) => const SignInPage(),
          '/signup': (BuildContext context) => const SignUpPage(),
          '/recover': (BuildContext context) => const RecoverPasswordPage(),
          '/settings': (BuildContext context) => const SettingsPage(),
          '/cart': (BuildContext context) => const CartPage(),
          '/favorites': (BuildContext context) => const FavoritesPage(),
          '/results': (BuildContext context) => const ResultsPage(),
          '/updateprofile': (BuildContext context) => const UpdateProfilePage(),
          '/updatepassword': (BuildContext context) =>
              const UpdatePasswordPage(),
        },
        home: const Root(),
      ),
    );
  }
}

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Future<PermissionStatus> locationPermissionsFuture =
        Provider.of<UserDataProvider>(context, listen: false).getPermissions();

    return StreamBuilder<User?>(
        stream: Provider.of<AuthenticationProvider>(context)
            .firebaseAuth
            .idTokenChanges(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const FirstPage();
          } else {
            return FutureBuilder(
                future: locationPermissionsFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<PermissionStatus> snapshot) {
                  _logger.info('Future build');
                  if (snapshot.hasData) {
                    PermissionStatus locationPermission = snapshot.data!;

                    if (locationPermission != PermissionStatus.denied &&
                        locationPermission != PermissionStatus.deniedForever) {
                      return const HomePage();
                    } else {
                      return AllowLocationPage();
                    }
                  } else {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                });
          }
        });
  }
}
