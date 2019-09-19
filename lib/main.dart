import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:odoo_api/odoo_api.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odoo Assistance',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Odoo Assistance'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _employeeIn = false;
  var _client;
  var _user;

  void _sign() async {
    final prefs = await SharedPreferences.getInstance();
    _client = new OdooClient((prefs.getString("Odoo_URL") ?? ""));

    _client.authenticate(prefs.getString("User_Name"), prefs.getString("Password"), prefs.getString("Odoo_Database")).then((auth) {
        if(auth.isSuccess) {
          // The hr_employee Object is the one who register the attendance
          _client.searchRead("hr.employee", [["user_id", "=", auth.getUser().uid]], ["id"]).then((employeeResult) {
            if(! employeeResult.hasError()){
              var _employee = employeeResult.getResult()["records"][0]["id"];
              // Call the attendance_manual method that will do the rest in server side
              _client.callKW("hr.employee", "attendance_manual", [_employee, "hr_attendance.hr_attendance_action_my_attendances"]).then((kwResult) {
                if(! kwResult.hasError()){
                  setState(() {
                    _employeeIn = ! _employeeIn;
                  });
                }
              });
            }
          });
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              (_employeeIn) ? 'Press here to sign out'
                                : 'Press here to sign in'
            ),
            Center( 
              child: Container(
                color: Theme.of(context).accentColor,
                child: IconButton(
                            icon: (_employeeIn) ? Icon( FontAwesomeIcons.signOutAlt, color: Colors.white, size: 100)
                                                    : Icon(FontAwesomeIcons.signInAlt, color: Colors.white, size: 100),
                            onPressed: _sign
                          ),
                width: 200,
                height: 200,
              )
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){Navigator.push(
                         context, 
                         MaterialPageRoute(builder: (context) => SettingsPage(title: "Settings")));},
        tooltip: 'Settings',
        child: Icon(FontAwesomeIcons.tools),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsState createState() => _SettingsState();

}


class _SettingsState extends State<SettingsPage> {

  
  bool _connected = false;
  var _client;
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _databaseController = TextEditingController();
  
  void _checkConnectionState() async {
    final prefs = await SharedPreferences.getInstance();
    _client = new OdooClient((prefs.getString("Odoo_URL") ?? "http://82.223.32.157:8071"));
    _client.connect().then((version) {
      setState(() {
        _connected = true;
      });
    });
  }

  @protected
  @mustCallSuper
  void initState() {
    // This method will be called every time the screen is started
    // It checks the connection with the user data
    _checkConnectionState();
  }
  
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'Odoo URL'
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter odoo URL';
                    }
                    return null;
                  },
                  controller: _urlController,
                ),
                TextFormField(
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'Database'
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter Odoo database name';
                    }
                    return null;
                  },
                  controller: _databaseController,
                ),
                TextFormField(
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'Login'
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your login';
                    }
                    return null;
                  },
                  controller: _userNameController,
                ),
                TextFormField(
                  autocorrect: false,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password'
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  controller: _passwordController,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    if (_formKey.currentState.validate()) {
                      prefs.setString("Odoo_URL", _urlController.text);
                      prefs.setString("Odoo_Database", _databaseController.text);
                      prefs.setString("User_Name", _userNameController.text);
                      prefs.setString("Password", _passwordController.text);
                    }
                  },
                  child: Text('Save'),
                ),
                Container(
                  color: (_connected) ? Colors.green
                                        :Colors.red,
                  child: Icon(FontAwesomeIcons.plug),
                  width: MediaQuery.of(context).size.width,
                  height: 30,
                ),
              ],
            ),
          ]
        ),
      )
    );
  }
  

}