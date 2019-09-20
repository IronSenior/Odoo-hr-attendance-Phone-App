import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:odoo_api/odoo_api.dart';
import 'package:shared_preferences/shared_preferences.dart';




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
    _client = new OdooClient(
        (prefs.getString("Odoo_URL") ?? "http://82.223.32.157:8071"));
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
    // It checks the connection with the odoo server
    _checkConnectionState();
  }

  @override
  Widget build(BuildContext context) {
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
                      decoration: InputDecoration(hintText: 'Odoo URL'),
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
                      decoration: InputDecoration(hintText: 'Database'),
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
                      decoration: InputDecoration(hintText: 'Login'),
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
                      decoration: InputDecoration(hintText: 'Password'),
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
                          prefs.setString(
                              "Odoo_Database", _databaseController.text);
                          prefs.setString(
                              "User_Name", _userNameController.text);
                          prefs.setString("Password", _passwordController.text);
                        }
                      },
                      child: Text('Save'),
                    ),
                    Container(
                      color: (_connected) ? Colors.green : Colors.red,
                      child: Icon(FontAwesomeIcons.plug),
                      width: MediaQuery.of(context).size.width,
                      height: 30,
                    ),
                  ],
                ),
              ]),
        ));
  }
}
