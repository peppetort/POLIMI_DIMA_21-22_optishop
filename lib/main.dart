import 'package:dima21_migliore_tortorelli/optishop.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'firebase_options.dart';


Logger _logger = Logger('flutterMain');

Future<void> main() async{
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: [${record.loggerName}] ${record.message}');
    }
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const OptiShop());
}
