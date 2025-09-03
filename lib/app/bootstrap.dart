import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_wallet/app/app.dart';

void bootstrapMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar bootstrap
  await bootstrap();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

Future<void> bootstrap() async {
  // Configurar flavor (puedes pasarlo desde argumentos o env)
  // const flavor = Flavor.dev; // Cambia según necesidad

  // Inicializar dependencias globales
  // Aquí puedes inicializar Dio, SecureStorage, etc.
  // Ejemplo:
  // await configureDependencies(flavor);

  // Configurar manejo de errores globales
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Log error o enviar a servicio de reportes
  };

  // Configurar zona para errores no capturados
  runZonedGuarded(
    () async {
      // Inicializaciones adicionales si es necesario
    },
    (error, stack) {
      // Manejar errores no capturados
      debugPrint('Uncaught error: $error');
      debugPrint('Stack trace: $stack');
    },
  );
}
