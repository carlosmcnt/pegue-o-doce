import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pegue_o_doce/utils/roteador.dart';
import 'package:pegue_o_doce/utils/tema.dart';
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var carrinho = FlutterCart();
  carrinho.initializeCart(isPersistenceSupportEnabled: true);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  if (!kIsWeb) {
    OneSignal.initialize(
      dotenv.env['ONESIGNAL_APP_ID']!,
    );
    await OneSignal.Notifications.requestPermission(true);
  }

  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'App Pegue o Doce',
        debugShowCheckedModeBanner: false,
        home: Roteador(),
        theme: Tema.lightTheme,
        darkTheme: Tema.darkTheme,
        themeMode: ThemeMode.light,
        locale: const Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
      ),
    ),
  );
}
