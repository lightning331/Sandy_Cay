library gopizzago.globals;

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_hud/progress_hud.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';
import 'dart:async';
import 'package:sandy_cay/main.dart';

String APIURL = "http://portal.sandycay.com/api/";
//String APIURL = "http://demos1.strategic-alliance.in/";
//String APIType = "iphoneAPI/";
//String APIType = "goapi/"; //"iPhoneAPI/";
//String APIURL = "https://www.gopizzago.de/goapi/";

String localelanguage;
Widget page1;
bool IsiOS = false;
Map<String,dynamic> cartDict = new Map<String,dynamic>();
bool IsLogin;
//LoginUserClass loginUserObj;

var latlngDict;
String UserType = '0';
int countdown = 300;
int sessionduration = 300;
Timer timer1;

//AppThemeClass themeObj = AppThemeClass("#DF2B26", "#BD2019", "#ffffff", "#000000", "#000000", "#ffffff", "#000000", "#F3EBE4", "#EDD282", "#ffffff", "#ffffff");

ProgressClass progressobj = ProgressClass();
ProgressHUD _progressHUD;

void makeprogressObject() async {

  _progressHUD = new ProgressHUD(
    backgroundColor: Colors.black12,
    color: Colors.white, //Color(0xFFB30012),//
    containerColor: const Color(0x00000000),
    borderRadius: 5.0,
    text: 'Loading',
  );

  progressobj.myprogressHUD = _progressHUD;
}

void showProgressDialog(BuildContext context1) {
  showDialog(
    context: context1,
    builder: (BuildContext context2) => _progressHUD,
  );
}

void dismissDialog(BuildContext context1) {
  Navigator.pop(context1);
}

Future checkInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
    else {
      return false;
    }
  }
  on SocketException catch (_) {
    print('not connected');
    return false;
  }
}

void showDialog1(String value, BuildContext context1, {String title = ''}) {

  showDialog(
    context: context1,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text(title == '' ? "" : title),
        titlePadding: new EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
        content: new Text(value),
        contentPadding: new EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Ok"),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future callAPI(String method,String param) async {

  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      String url = APIURL + method;
      if(param != '') {
        url = url + '?' + param;
      }
      // print('connected12 : ' + url);

      final response = await http.get(url);

      if(response != null) {
        if(response.statusCode == 200) {
          String res1 = response.body.toString().trim();
          if(res1.length > 0) {
            var unescape = new HtmlUnescape();
            res1 = unescape.convert(response.body.toString());
            res1 = res1.replaceAll('\\u0080', '€');
            final result1 = json.decode(res1.trim());
            return result1;
          }
          else {
            return null;
          }
        }
        else {
          return null;
        }
      }
      else {
        return null;
      }
    }
  }
  on SocketException catch (_) {
    print('not connected');
    return null;
  }
}

Future callPostAPI(String method,Map<String,String> param) async {

  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      String url = APIURL + method;
     // print('connected : : : ' + url);
     // print(param);
      final response = await http.post(url,body: param);
//          .timeout(Duration(seconds: 180), onTimeout: (){
//        return null;
//      });
      if(response != null) {
        String res1 = response.body.toString().trim();
        if(res1.length > 0) {
          // print("res1 : " + res1);
          var unescape = new HtmlUnescape();
          String res2 = unescape.convert(res1);
          // print("res2 : " + res2);
          //String res3 = convertUTF(res2);
          // print("res3 : " + res3);
          //String res4 = res3.replaceAll('\\u0080', '€');
          // print(res4);
          final result1 = json.decode(res2.trim());
          return result1;
        }
        else {
          return null;
        }
      }
      else {
        return null;
      }
    }
  }
  on SocketException catch (_) {
    print('not connected');
    return null;
  }
}

class ProgressClass {

  ProgressHUD _myprogressHUD;

  ProgressHUD get myprogressHUD => _myprogressHUD;
  set myprogressHUD(ProgressHUD myprogressHUD) {
    _myprogressHUD = myprogressHUD;
  }
}
