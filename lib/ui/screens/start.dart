import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:odoo_api/odoo_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _employeeIn = false;
  var _client;

  void _sign() async {
    final prefs = await SharedPreferences.getInstance();
    _client = new OdooClient((prefs.getString("Odoo_URL") ?? ""));

    _client
        .authenticate(prefs.getString("User_Name"), prefs.getString("Password"),
            prefs.getString("Odoo_Database"))
        .then((auth) {
      if (auth.isSuccess) {
        // The hr_employee Object is the one who register the attendance
        _client.searchRead("hr.employee", [
          ["user_id", "=", auth.getUser().uid]
        ], [
          "id"
        ]).then((employeeResult) {
          if (!employeeResult.hasError()) {
            var _employee = employeeResult.getResult()["records"][0]["id"];
            // Call the attendance_manual method that will do the rest in server side
            _client.callKW("hr.employee", "attendance_manual", [
              _employee,
              "hr_attendance.hr_attendance_action_my_attendances"
            ]).then((kwResult) {
              if (!kwResult.hasError()) {
                setState(() {
                  _employeeIn = !_employeeIn;
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
            Text((_employeeIn)
                ? 'Press here to sign out'
                : 'Press here to sign in'),
            Center(
                child: Container(
              color: Theme.of(context).accentColor,
              child: IconButton(
                  icon: (_employeeIn)
                      ? Icon(FontAwesomeIcons.signOutAlt,
                          color: Colors.white, size: 100)
                      : Icon(FontAwesomeIcons.signInAlt,
                          color: Colors.white, size: 100),
                  onPressed: _sign),
              width: 200,
              height: 200,
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SettingsPage(title: "Settings")));
        },
        tooltip: 'Settings',
        child: Icon(FontAwesomeIcons.tools),
      ),
    );
  }
}
