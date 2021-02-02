import 'package:flutter/material.dart';
import 'package:sandy_cay/globals.dart' as globals;
import 'package:sandy_cay/home.dart';

class LoginPage extends StatefulWidget {

  LoginPage({Key key, this.isCheckout}) : super(key: key);

  bool isCheckout;

  @override
  LoginPageState createState() {

    return new LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {

  final TextEditingController _unametextController = new TextEditingController();
  final TextEditingController _passtextController = new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = new GlobalKey<FormState>();

  //LoginUserClass _userObj;

  @override
  void initState() {
    super.initState();

    globals.makeprogressObject();
    // _unametextController.text = "joe@joec.com";
    // _passtextController.text = "admin123";
  }

  @override
  Widget build(BuildContext context) {

    BoxDecoration shadow = new BoxDecoration(
      color: Colors.white,
      borderRadius: new BorderRadius.circular(3.0),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          offset: Offset(0.0, 3.0),
          blurRadius: 5.0,
          spreadRadius: -1.0,
          color: Color(0x33000000),
        ),
        BoxShadow(
          offset: Offset(0.0, 6.0),
          blurRadius: 10.0,
          spreadRadius: 0.0,
          color: Color(0x24000000),
        ),
        BoxShadow(
          offset: Offset(0.0, 1.0),
          blurRadius: 18.0,
          spreadRadius: 0.0,
          color: Color(0x1F000000),
        ),
      ],
    );

    callSignIn() async {

      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        globals.showProgressDialog(context);

        Map<String,String> postparam = Map();
        postparam["email"] = _unametextController.text;
        postparam["password"] = _passtextController.text;
        var jsondata = await globals.callPostAPI("auth/login", postparam);

        if(jsondata == null) {
          globals.dismissDialog(context);
          globals.showDialog1('Please check your internet connectivity', context);
          return;
        }

        globals.dismissDialog(context);

        if(jsondata['message'] != null) {
          if(jsondata['message'] == "Authourized") {
            // _userObj = LoginUserClass.fromJson(jsondata['user']);
            // Iterable l = _userObj.addresses;
            // SharedPreferences prefs = await SharedPreferences.getInstance();
            // prefs.setString("CustomerId", _userObj.CustomerId);
            // prefs.setString("Company", _userObj.company);
            // globals.IsLogin = true;
            // globals.loginUserObj = LoginUserClass(_userObj.CustomerId, _userObj.company,_userObj.CustomerFirstName,_userObj.CustomerLastName, _userObj.CustomerEmail, _userObj.StreetAddress, _userObj.City, _userObj.Phonecode, _userObj.CustomerPhone, _userObj.ZipCode, _userObj.CCode, _userObj.NLETTER);

            Navigator.of(context).pushReplacement(
                new MaterialPageRoute(builder: (BuildContext context) => HomePage())
            );
          }
          else {
            globals.showDialog1("Invalid username or password.", context);
          }
        }
        else {
            globals.showDialog1("Invalid username or password.", context);
        }
      }
    }


    String validateEmail(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value))
        return 'Invalid Email';
      else
        return null;
    }

    TextFormField unametxt = new TextFormField(
      decoration: new InputDecoration(
        labelText: 'Email' + ' ' + 'or' + ' ' +  ('Username') + '*',
      ),
      controller: _unametextController,
      keyboardType: TextInputType.emailAddress,
      onSaved: (String value) {
        print("username");
      },
      validator: (value) {
        if (value.trim().isEmpty)
          return 'Email or Username is required.';
        else
          return validateEmail(value.trim());
      },
    );

    TextFormField passwordtxt = new TextFormField(
      decoration: new InputDecoration(
        labelText: 'Password' + '*',
      ),
      controller: _passtextController,
      obscureText: true,
      keyboardType: TextInputType.text,
      onSaved: (String value) {
        print("password");
      },
      validator: (value) {
        if (value.trim().isEmpty)
          return 'Password is required.';
        return null;
      },
    );

    return new WillPopScope(
      onWillPop: () async => false,
      child: new Scaffold(
        //backgroundColor: globals.hexToColor(globals.themeObj.content_center_bgcolor),
        appBar: new AppBar(
          centerTitle: false,
          //backgroundColor: globals.hexToColor(globals.themeObj.navigation_bgcolor),
          title: new Text("Sandy Cay"),
          actions: <Widget>[
            new SizedBox(
              width: 55.0,
              height: 30.0,
              child: new FlatButton(
                onPressed: () {
                  if(widget.isCheckout == true) {
                    Navigator.of(context).pop();
                  }
                  else {
                    Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
                  }
                },
              ),
            ),
          ],
        ),
        body: new Container(
          child: new Column(
            children: <Widget>[
              new Container(
                child: new Text('Login', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                padding: new EdgeInsets.only(top: 5.0, left: 5.0),
                decoration: shadow,
                height: 44,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment(-1.0, 0.0),
              ),
              new Expanded(
                child: new ListView(
                  children: <Widget>[
                    new Padding(padding: new EdgeInsets.only(top: 16.0)),
                    new Form(
                      key: _formKey,
                      child: new Card(
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        child: new Column(
                          children: <Widget>[
                            new Container(
                              padding: new EdgeInsets.only(left: 8.0, right: 8.0),
                              child: unametxt,
                            ),
                            new Container(
                              padding: new EdgeInsets.only(left: 8.0, right: 8.0),
                              child: passwordtxt,
                            ),
                            new Padding(padding: new EdgeInsets.only(bottom: 20.0)),
                            new ButtonTheme(
                              minWidth: MediaQuery.of(context).size.width - 48.0,
                              height: 44.0,
                              child: new RaisedButton(
                                child: new Text('Login'),
                                //color: globals.hexToColor(globals.themeObj.active_bg),
                                //textColor: globals.hexToColor(globals.themeObj.active_color),
                                onPressed: () async {
                                  print("login clicked");
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  callSignIn();

                                },
                              ),
                            ),
                            new Padding(padding: new EdgeInsets.only(bottom: 20.0)),
                          ],
                        ),
                      ),
                    ),
                    // new Padding(padding: new EdgeInsets.only(bottom: 8.0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}