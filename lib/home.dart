import 'package:flutter/material.dart';
import 'dart:io';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';
import 'package:sandy_cay/globals.dart' as globals;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse("http://portal.sandycay.com/api/store"));
      request.fields["barcode"] = scanResult;
      request.fields["price"] = _priceTextController.text;
      request.fields["amount"] = _amountTextController.text;
      //create multipart using filepath, string or bytes
      var pic = await http.MultipartFile.fromPath("image", filePath);
      //add multipart to request
      request.files.add(pic);
      var response = await request.send();

      //Get the response from the server
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      print(responseString);
      final jsondata = json.decode(responseString.trim());

      globals.dismissDialog(context);
      if(jsondata == null) {
        globals.showDialog1('Please check your internet connectivity', context);
        return;
      }

      if(jsondata['message'] != null) {
        if(jsondata['message'] == "Success") {
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
            // Text(
            //   'result:',
            //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            // ),
            // Text(
            //   scanResult,
            //   style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            // ),
            new Padding(padding: new EdgeInsets.only(top: 50.0,),),
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
