import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';
import 'package:sandy_cay/globals.dart' as globals;

// class HomePage extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//         // This makes the visual density adapt to the platform that you run
//         // the app on. For desktop platforms, the controls will be smaller and
//         // closer together (more dense) than on mobile platforms.
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'Sandy Cay'),
//     );
//   }
// }

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
  String scanResult = "";

  @override
  void initState() {
    super.initState();

    globals.makeprogressObject();
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

      Map<String,String> postparam = Map();
      postparam["barcode"] = scanResult;
      postparam["name"] = "";
      postparam["price"] = "";
      postparam["image"] = "";
      postparam["color"] = "";
      postparam["description"] = "";
      var jsondata = await globals.callPostAPI("store", postparam);

      if(jsondata == null) {
        globals.dismissDialog(context);
        globals.showDialog1('Please check your internet connectivity', context);
        return;
      }

      globals.dismissDialog(context);

      var msg = "";
      if(jsondata['message'] != null) {
        if(jsondata['message'] == "Success") {
            msg = "Submitted successfully!";
            globals.showDialog1('Submitted successfully!', context);
          // Navigator.of(context).push(
          //     new MaterialPageRoute(builder: (BuildContext context) => HomePage())
          // );
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
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
            image: AssetImage("img/bg_app.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new ButtonTheme(
              minWidth: 200,
              height: 44,
              child: new FlatButton(
                child: new Text("Scan", style: TextStyle(fontWeight: FontWeight.bold)),
                color: Colors.orange,
                textColor: Colors.white,
                onPressed: () {
                  _scan();
                },
              ),
            ),
            new Padding(padding: new EdgeInsets.only(top: 10.0,),),
            Text(
              'result:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              scanResult,
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            new Padding(padding: new EdgeInsets.only(top: 50.0,),),
            new ButtonTheme(
              minWidth: 100,
              height: 44,
              child: new FlatButton(
                child: new Text("Submit", style: TextStyle(fontWeight: FontWeight.bold)),
                color: Colors.blue.withOpacity(scanResult.isEmpty ? 0.5 : 1),
                textColor: Colors.white,
                onPressed: () {
                  if (scanResult.isEmpty) {
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
