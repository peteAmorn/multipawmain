import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:multipawmain/support/constants.dart';
import 'authCheck.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> backgroundHandler(RemoteMessage message) async{}

bool isAuth = false;

Future<Null> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'th';
  initializeDateFormatting();

  await Firebase.initializeApp().then((value) async{
    await FirebaseAuth.instance.authStateChanges().listen((event) async{
      if(event != null){
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
        ).then((value) => runApp(MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                fontFamily: 'EkkamaiNew'
            ),
            home: home(currentUserId: event.uid,isAuth: true)
        )));

      }
    });
  });
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseMessaging.onBackgroundMessage((backgroundHandler));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return Sizer(
        builder: (context, orientation, deviceType){
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  fontFamily: 'EkkamaiNew',
                  tabBarTheme: TabBarTheme(
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(color: themeColour)
                      )
                  )
              ),
              home:
              home()
          );
        }
    );
  }
}
