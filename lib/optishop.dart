import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/home.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/first.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/signin.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';

Logger _logger = Logger('OptiShop');

class OptiShop extends StatelessWidget {
  const OptiShop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (_) => AuthenticationProvider(FirebaseAuth.instance),
        ),
      ],
      child: MaterialApp(
        title: 'OptiShop',
        theme: OptiShopAppTheme.theme,
        routes: <String, WidgetBuilder>{
          '/signin': (BuildContext context) => const SignInPage(),
          '/signup': (BuildContext context) => const SignUpPage(),
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
    return StreamBuilder<User?>(
        stream: Provider.of<AuthenticationProvider>(context)
            .firebaseAuth
            .idTokenChanges(),
        builder: (context, snapshot) {
          return snapshot.data != null ? const HomeScreen() : const FirstPage();
        });
  }
}
