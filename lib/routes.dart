import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/first.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> unauthenticatedRoutes =
<String, WidgetBuilder>{
  '/': (BuildContext context) => const FirstPage(),
};

final Map<String, WidgetBuilder> authenticatedRoutes =
<String, WidgetBuilder>{
};
