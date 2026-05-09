import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/injection.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const PosSystemApp());
}
