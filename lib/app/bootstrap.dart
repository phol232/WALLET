import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_wallet/app/app.dart';

void bootstrapMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  await bootstrap();

  runApp(const ProviderScope(child: App()));
}

Future<void> bootstrap() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  runZonedGuarded(() async {}, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stack');
  });
}
