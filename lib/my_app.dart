import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sandy_cay/scoped_wrapper.dart';
import 'package:sandy_cay/login.dart';
import 'package:sandy_cay/globals.dart' as globals;

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<LangModel>(builder: (context, child, model) {
      return MaterialApp(
        builder: (context, child) =>
            MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child),
        locale: model.appLocal,
        // localizationsDelegates: [
        //   const TranslationsDelegate(),
        //   GlobalMaterialLocalizations.delegate,
        //   GlobalWidgetsLocalizations.delegate,
        // ],
        supportedLocales: [
          const Locale('de', ''), // German
          const Locale('en', ''), // English
        ],
//        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          platform: TargetPlatform.android,
          // primaryColor: const Color(0xFFB30012),
          // backgroundColor: const Color(0xFFECECEC),
          // buttonColor: const Color(0xFF67AD2C),
//          dividerColor: const Color(0xFF6A6A6A),
        ),
        routes: <String, WidgetBuilder>{
          '/search': (BuildContext context) => new LoginPage(),
          //'/cart': (BuildContext context) => new CartPage(),
        },
        home: globals.page1,
      );
    });
  }
}