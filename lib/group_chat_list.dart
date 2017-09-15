import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'group_chat_list_body.dart';
import 'add_session.dart';
import 'chat_screen.dart';
import 'personal_data.dart';
import 'app_settings.dart';

class GroupChatList extends StatefulWidget {
  @override
  State createState() => new _GroupChatListState();
}

class _GroupChatListState extends State<GroupChatList> {
  String name = "null";
  String phone = "null";
  String email = "null";
  String portrait = "null";

  @override
  void initState() {
    super.initState();
    _readLoginData().then((Map onValue) {
      setState(() {
        name = onValue["name"];
        phone = onValue["phone"];
        email = onValue["email"];
        portrait = onValue["portrait"];
      });
    });
  }

  Future<Map> _readLoginData() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/LandingInformation');
    String data = await file.readAsString();
    Map json = new JsonDecoder().convert(data);
    return json;
  }

  Widget _drawerOption(Icon icon, String name) {
    return new Container(
      padding: const EdgeInsets.only(top: 19.0),
      child: new Row(
        children: <Widget>[
          new Container(
              padding: const EdgeInsets.only(right: 28.0), child: icon),
          new Text(name, textScaleFactor: 1.1)
        ],
      ),
    );
  }

  void _openModify() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new PersonalData(
          name: name,
          email: email,
          portrait: portrait,
          phone: phone,
        );
      },
    )).then((onValue) {
      _readLoginData().then((Map onValue) {
        setState(() {
          name = onValue["name"];
          phone = onValue["phone"];
          email = onValue["email"];
          portrait = onValue["portrait"];
        });
      });
    });
  }

  void _floatingButtonCallback() {
    showDialog<List<String>>(
            context: context,
            barrierDismissible: false,
            child: new AddSession(phone, name, portrait))
        .then((List<String> onValue) {
      if (onValue != null) {
        Navigator.of(context).push(new MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return new ChatScreen(
              messages: onValue[2],
              myName: name,
              sheName: onValue[0],
              myPhone: phone,
              shePhone: onValue[1],
              myPortrait: portrait,
              shePortrait: onValue[3],
            );
          },
        ));
      }
    });
  }

  Widget build(BuildContext context) {
    Drawer drawer = new Drawer(
        child: new ListView(
      children: <Widget>[
        new DrawerHeader(
            child: new Column(
          children: <Widget>[
            new GestureDetector(
              onTap: _openModify,
              child: new Row(
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: new CircleAvatar(
                      backgroundImage: new NetworkImage(portrait),
                      radius: 22.0,
                    ),
                  ),
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        name,
                        textScaleFactor: 1.4,
                      ),
                      new Text(
                        phone,
                        textScaleFactor: 1.1,
                      )
                    ],
                  )
                ],
              ),
            ),
            new GestureDetector(
                onTap: _openModify,
                child: new Container(
                  decoration: new BoxDecoration(),
                  child: _drawerOption(new Icon(Icons.account_circle), "个人资料"),
                )),
            new GestureDetector(
                onTap: () {
                  Navigator.of(context).push(new MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return new AppSettings(phone);
                    },
                  ));
                },
                child: new Container(
                  decoration: new BoxDecoration(),
                  child: _drawerOption(new Icon(Icons.settings), "设置"),
                )),
          ],
        ))
      ],
    ));

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("纸聊"),
          centerTitle: true,
          elevation: 0.0,
        ),
        drawer: drawer,
        body: new Center(
          child: phone == "null"
              ? null
              : new GroupChatListBody(
                  phone: phone, myName: name, portrait: portrait),
        ),
        floatingActionButton: new FloatingActionButton(
            backgroundColor: Theme.of(context).buttonColor,
            elevation: 0.0,
            onPressed: _floatingButtonCallback,
            child: new Icon(Icons.person_add)));
  }
}
