import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';

String api = "https://api.hgbrasil.com/finance?format=json&key=75200980";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double euro;
  double dolar;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  _clearFields() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsPrecision(2);
    euroController.text = (real / euro).toStringAsPrecision(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsPrecision(4);
    euroController.text = (dolar * this.dolar / euro).toStringAsPrecision(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsPrecision(4);
    dolarController.text = (euro * this.euro / dolar).toStringAsPrecision(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Currecy"),
        backgroundColor: Colors.amber,
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return FutureBuilder<Map>(
      future: getData(),
      builder: (context, snapshot) {
        Widget children;
        if (snapshot.hasData) {
          euro = snapshot.data["currencies"]["EUR"]["buy"];
          dolar = snapshot.data["currencies"]["USD"]["buy"];
          children = SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.monetization_on,
                  size: 150.0,
                  color: Colors.amber,
                ),
                buildTextField("Real", "R\$", realController, _realChanged),
                Divider(),
                buildTextField("Dolar", "\$", dolarController, _dolarChanged),
                Divider(),
                buildTextField("Euro", "€", euroController, _euroChanged),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          children = Text(
            "Ops...",
            style: TextStyle(color: Colors.white),
          );
        } else {
          children = SizedBox(
            child: CircularProgressIndicator(),
            width: 60,
            height: 60,
          );
        }

        return Center(
          child: children,
        );
      },
    );
  }

  Future<Map> getData() async {
    Response response = await get(api);
    return json.decode(response.body)["results"];
  }

  Widget buildTextField(
      String label, String prefix, TextEditingController c, Function f) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefix: Text(prefix),
        prefixStyle: TextStyle(color: Colors.amber),
        labelStyle: TextStyle(
          color: Colors.amber,
          fontSize: 20,
        ),
      ),
      onChanged: (value) {
        if (value.isEmpty) {
          return _clearFields();
        }
        f(value);
      },
      style: TextStyle(color: Colors.amber),
    );
  }
}
