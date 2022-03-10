import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/home.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/first.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';

class OptiShop extends StatelessWidget {
  const OptiShop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (_) => AuthenticationProvider(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthenticationProvider>().authState, initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'OptiShop',
        theme: OptiShopAppTheme.theme,
        routes: <String, WidgetBuilder>{
          '/signin': (BuildContext context) => const SignInPage(),
        },
        home: const RootPage(),
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const HomeScreen();
    }
    return const FirstPage();
  }
}

/*class OptiShop extends StatefulWidget {
  const OptiShop({Key? key}) : super(key: key);

  @override
  _OptiShopState createState() => _OptiShopState();
}

class _OptiShopState extends State<OptiShop> with WidgetsBindingObserver {
  final Logger _logger = Logger('OptiShop');

  Future<void> initServices(BuildContext context) async {
    var authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    await authProvider.initialize();

    if(authProvider.isAuthenticated){
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }else{
      Navigator.pushReplacementNamed(context, '/start');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (context) => AuthenticationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'OptiShop',
        theme: OptiShopAppTheme.theme,
        routes: <String, WidgetBuilder>{
          '/start': (BuildContext context) => const FirstPage(),
          '/loading': (BuildContext context) => LoadingPage(
                function: initServices,
              ),
          '/signin': (BuildContext context) => const SignInPage(),
          '/': (BuildContext context) => const HomeScreen(),
        },
        initialRoute: '/loading',
      ),
    );
  }
}*/
