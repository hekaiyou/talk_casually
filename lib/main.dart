import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'sign_in.dart';
import 'group_chat_list.dart';

void main() {
  _getLandingFile().then((onValue) {
    runApp(new TalkcasuallyApp(onValue.existsSync()));
  });
}

Future<File> _getLandingFile() async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  return new File('$dir/LandingInformation');
}

class TalkcasuallyApp extends StatelessWidget {
  TalkcasuallyApp(this.landing);

  final bool landing;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: new ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.grey[50],
          scaffoldBackgroundColor: Colors.grey[50],
          dialogBackgroundColor: Colors.grey[50],
          primaryColorBrightness: Brightness.light,
          buttonColor: Colors.blue,
          iconTheme: new IconThemeData(
            color: Colors.grey[700],
          ),
          hintColor: Colors.grey[400],
        ),
        title: '纸聊',
        home: landing ? new GroupChatList() : new SignIn());
  }
}
