import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../../routes.dart';

final Logger _logger = Logger('RootPage');

class RootPage extends StatefulWidget {
  static Route<void> rootPageBuiled(BuildContext context, Object? arguments) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => const RootPage(),
    );
  }

  const RootPage({Key? key}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final GlobalKey<NavigatorState> unauthenticatedNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'unauthenticated key');

  final GlobalKey<NavigatorState> authenticatedNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'authenticated key');

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthenticationProvider>(context);
    //TODO: rivedere

    return Container(
      color: Theme.of(context).primaryColor,
      child: authProvider.isAuthenticated
          ? Navigator(key: authenticatedNavigatorKey)
          : Navigator(key: unauthenticatedNavigatorKey),
    );
  }
}
