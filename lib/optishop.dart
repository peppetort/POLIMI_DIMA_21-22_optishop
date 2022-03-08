import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/routes.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';

class OptiShop extends StatefulWidget {
  const OptiShop({Key? key}) : super(key: key);

  @override
  _OptiShopState createState() => _OptiShopState();
}

class _OptiShopState extends State<OptiShop> with WidgetsBindingObserver {
  final Logger _logger = Logger('OptiShop');

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
        initialRoute: '/',
        routes: unauthenticatedRoutes,
      ),
    );
  }
}
