import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sandy_cay/my_app.dart';
//import 'package:testresapp/globals.dart' as globals;

class ScopedWrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModel<LangModel>(model: LangModel(), child: MyApp());
  }
}

class LangModel extends Model {

  Locale _appLocale = Locale("en");
  Locale get appLocal => _appLocale ?? Locale("en");

  void changeDirection(String lng) {
      print(lng);
      //globals.localelanguage = lng;
    _appLocale = Locale(lng);

    notifyListeners();
  }

}