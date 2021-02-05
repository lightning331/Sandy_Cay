import 'package:flutter/material.dart';
import 'dart:io';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';
import 'package:sandy_cay/globals.dart' as globals;
import 'package:image_picker/image_picker.dart';
import 'package:sandy_cay/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() {

    return new _MyHomePageState();
  }
}

class _MyHomePageState extends State<HomePage> {
  final TextEditingController _priceTextController = new TextEditingController();
  final TextEditingController _amountTextController = new TextEditingController();
  String scanResult = "";
  String filePath = "";

  @override
  void initState() {
    super.initState();

    globals.makeprogressObject();

    // _priceTextController.text = "1";
    _amountTextController.text = "1";
  }

  chooseImage() async {
    await Permission.camera.request();
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(
      source: ImageSource.camera,
        imageQuality: 50, // <- Reduce Image quality
        maxHeight: 500,  // <- reduce the image size
        maxWidth: 500
    );
    if (pickedFile != null) {
      setState(() {
        filePath = pickedFile.path;
      });
    }

    //setStatus('');
  }

  Future _scan() async {
    await Permission.camera.request();
    await Permission.storage.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      setState(() {
        scanResult = barcode;
      });
    }
  }

  onSubmit() async {

      globals.showProgressDialog(context);

      String fileName = filePath.split('/').last;

      FormData data = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        "barcode": scanResult,
        "price": _priceTextController.text,
        "amount": _amountTextController.text,
      });

      Dio dio = new Dio();

      var response = await dio.post("http://portal.sandycay.com/api/store", data: data);

      print(response);
      globals.dismissDialog(context);
      if(response == null) {
        globals.showDialog1('Please check your internet connectivity', context);
        return;
      }

      if(response.data['message'] != null) {
        if(response.data['message'] == "Success") {
            globals.showDialog1('Submitted successfully!', context);
        }
        else {
          globals.showDialog1('Failed to submit. Please try again!', context);
        }
      }
      else {
        globals.showDialog1('Failed to submit. Please try again!', context);
      }
    }

  onLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('IsLogin', false);
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (BuildContext context) => LoginPage())
    );

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    TextFormField pricetxt = new TextFormField(
      decoration: new InputDecoration(
        labelText: 'Price',
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.only(left: 14.0, bottom: 5.0, top: 5.0),
      ),
      controller: _priceTextController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value.trim().isEmpty)
          return 'Price is required.';
        return null;
      },
    );

    TextFormField amounttxt = new TextFormField(
      decoration: new InputDecoration(
        labelText: 'Amount',
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.only(left: 14.0, bottom: 5.0, top: 5.0),
      ),
      controller: _amountTextController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value.trim().isEmpty)
          return 'Amount is required.';
        return null;
      },
    );

    isFormValid() {
      if (filePath.isNotEmpty && scanResult.isNotEmpty && _priceTextController.text.isNotEmpty && _amountTextController.text.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text("Sandy Cay"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
            image: AssetImage("img/bg_app.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(padding: new EdgeInsets.only(top: 50.0)),
            new ButtonTheme(
              minWidth: 150,
              height: 50,
              child: new FlatButton(
                child: new Text(filePath.isEmpty ? "Choose Image" : "Picked", style: TextStyle(fontWeight: FontWeight.bold)),
                color: Colors.orange,
                textColor: Colors.white,
                onPressed: () {
                  //_scan();
                  chooseImage();
                },
              ),
            ),
            new Padding(padding: new EdgeInsets.only(top: 10.0)),
            new ButtonTheme(
              minWidth: 150,
              height: 50,
              child: new FlatButton(
                child: new Text(scanResult.isEmpty ? "Barcode Scan" : scanResult, style: TextStyle(fontWeight: FontWeight.bold)),
                color: Colors.orange,
                textColor: Colors.white,
                onPressed: () {
                  _scan();
                },
              ),
            ),
            new Container(
                padding: new EdgeInsets.only(top: 10.0),
                width: 150,
                child: pricetxt,
              ),
            new Container(
                padding: new EdgeInsets.only(top: 10.0),
                width: 150,
                child: amounttxt,
              ),
            new Padding(padding: new EdgeInsets.only(top: 10.0,),),
            new Padding(padding: new EdgeInsets.only(top: 30.0,),),
            new ButtonTheme(
              minWidth: 120,
              height: 44,
              child: new FlatButton(
                child: new Text("Submit", style: TextStyle(fontWeight: FontWeight.bold)),
                color: Colors.blue.withOpacity(isFormValid() ? 1 : 0.5),
                textColor: Colors.white,
                onPressed: () {
                  if (!isFormValid()) {
                    return;
                  }
                  onSubmit();
                },
              ),
            ),
            new Expanded(
              child: GestureDetector(
                onTap: () {
                  onLogout();
                },
                child: new Align(
                    // alignment: Alignment.bottomCenter,
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Icon(Icons.logout, color: Colors.white),
                        new Padding(padding: new EdgeInsets.only(left: 5.0,),),
                        new Text("LogOut", style: TextStyle(color: Colors.white))
                      ],
                    ),
                ),
              ),
            ),
            // new Padding(padding: new EdgeInsets.only(top: 20.0,),),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
