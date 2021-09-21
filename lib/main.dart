import 'package:ecg/util/common_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'MyApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (kDebugMode) {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(false);
  }
  // Map<String, String> env = await loadEnvFile("assets/env/.env_production");
  Map<String, String> env = await loadEnvFile("assets/env/.env_testing");
  // Map<String, String> env = await loadEnvFile("assets/env/.env_dev");
  print('maib---${env}');
  runApp(MyApp(env));
}

