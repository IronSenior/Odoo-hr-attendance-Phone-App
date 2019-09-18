import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:odoo_api/odoo_api.dart';

void main() => runApp(MyApp());

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

  void _incrementCounter() {
    setState(() {
      _employeeIn = ! _employeeIn;
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
                            onPressed: _incrementCounter
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
                         MaterialPageRoute(builder: (context) => SettingsPage()));},
        tooltip: 'Settings',
        child: Icon(FontAwesomeIcons.toolbox),
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

  String _odooUrl = "";
  var _client;
  
  void _checkConnectionState() {
    _client = new OdooClient(_odooUrl);
    _client.connect().then((version) {
      print("Connected $version");
    });
  }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title)
      ),
    );
  }
  

}