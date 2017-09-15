import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'sign_in.dart';
import 'modify_password.dart';

class AppSettings extends StatefulWidget {
  AppSettings(this.myPhone);
  final String myPhone;

  @override
  State createState() => new _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  Future<Null> _logOut() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    await new File('$dir/LandingInformation').delete();
    Navigator.of(context).push(new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new SignIn();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("设置"),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: new Column(
          children: <Widget>[
            new GestureDetector(
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute<Null>(
                  builder: (BuildContext context) {
                    return new ModifyPassword(widget.myPhone);
                  },
                ));
              },
              child: new Container(
                height: 40.0,
                decoration: new BoxDecoration(),
                alignment: FractionalOffset.centerLeft,
                width: MediaQuery.of(context).size.width * 0.9,
                child: new Text("修改密码", textScaleFactor: 1.1),
              ),
            ),
            new Divider(height: 0.0),
            new GestureDetector(
              onTap: () {
                _logOut();
              },
              child: new Container(
                height: 40.0,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: new BoxDecoration(),
                alignment: FractionalOffset.centerLeft,
                width: MediaQuery.of(context).size.width * 0.9,
                child: new Text("退出登录", textScaleFactor: 1.1),
              ),
            ),
            new Divider(height: 0.0),
          ],
        ));
  }
}
