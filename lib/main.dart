import 'dart:io';



import 'package:taxi_schedule_user/new_utils/Demo_Localization.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/routes.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';



import 'package:wakelock_plus/wakelock_plus.dart';


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Common.debugPrintApp('Handling a background message ${message.messageId}');
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // navigation bar color
    statusBarColor: MyColorName.mainColor, // status bar color
  ));
  runApp(TaxiSchedule());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class TaxiSchedule extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    _TaxiScheduleState state = context.findAncestorStateOfType<_TaxiScheduleState>()!;
    state.setLocale(newLocale);
  }

  @override
  State<TaxiSchedule> createState() => _TaxiScheduleState();
}

class _TaxiScheduleState extends State<TaxiSchedule> {
  bool _isKeptOn = true;
  double _brightness = 1.0;
  @override
  initState() {
    super.initState();
  //  initPlatformState();
  }

  Locale? _locale;

  setLocale(Locale locale) {
    if (mounted)
      setState(() {
        _locale = locale;
      });
  }
  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      if (mounted)
        setState(() {
          this._locale = locale;
        });
    });
    super.didChangeDependencies();
  }
  /*initPlatformState() async {
    await App.init();
    bool keptOn = await WakelockPlus.enabled;
    if (App.localStorage.getBool("lock") != null) {
      doLock = App.localStorage.getBool("lock")!;
      WakelockPlus.toggle(enable: App.localStorage.getBool("lock")!);
    }
    if (App.localStorage.getBool("notification") != null) {
      notification = App.localStorage.getBool("notification")!;
    }
  }*/

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      locale: _locale,
      supportedLocales: [
        Locale("en", "US"),
        Locale("ne", "NPL"),
      ],
      localizationsDelegates: [
        DemoLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode ==
              locale!.languageCode &&
              supportedLocale.countryCode ==
                  locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      title: Constants.appName,
      navigatorKey: NavigationService.navigatorKey,
      theme: UI.getLightTheme(),
      onGenerateRoute: generateRoute,
      debugShowCheckedModeBanner: false,
      initialRoute: Constants.splashRoute,
    );
  }
}
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
}