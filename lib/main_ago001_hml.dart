import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_locale_bootstrap.dart';
import 'core/config/ago001_hml_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Ago001HmlConfig.validate(debug: kDebugMode, web: kIsWeb, origin: Uri.base);
  await AppLocaleBootstrap.initialize();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'ago001-local-only',
      appId: '1:1:web:ago001hml',
      messagingSenderId: '1',
      projectId: Ago001HmlConfig.projectId,
    ),
  );
  await FirebaseAuth.instance.useAuthEmulator(
    Ago001HmlConfig.host,
    Ago001HmlConfig.authPort,
  );
  await FirebaseAuth.instance.setPersistence(Persistence.NONE);
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: false);
  FirebaseFirestore.instance.useFirestoreEmulator(
    Ago001HmlConfig.host,
    Ago001HmlConfig.firestorePort,
  );
  // Emuladores não exigem App Check. A entrada normal permanece independente.
  runApp(const Banner(
    message: 'AGO-001 HML LOCAL',
    location: BannerLocation.topEnd,
    textDirection: TextDirection.ltr,
    layoutDirection: TextDirection.ltr,
    child: GeducRaeApp(),
  ));
}
