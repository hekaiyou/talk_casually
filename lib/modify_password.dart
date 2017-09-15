import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'prompt_wait.dart';
import 'dart:async';

class ModifyPassword extends StatefulWidget {
  ModifyPassword(this.myPhone);
  final String myPhone;

  @override
  State createState() => new _ModifyPasswordState();
}

class _ModifyPasswordState extends State<ModifyPassword> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
  new GlobalKey<ScaffoldState>();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmController = new TextEditingController();
  bool _correctPassword = true;
  bool _correctConfirm = true;
  final reference = FirebaseDatabase.instance.reference().child('users');

  void _handleSubmitted() {
    FocusScope.of(context).requestFocus(new FocusNode());
    _checkInput();
    if (_confirmController.text == '' || _passwordController.text == '') {
      showMessage(context, "修改密码所需信息不完整！");
      return;
    } else if (!_correctConfirm || !_correctPassword) {
      showMessage(context, "修改密码输入格式不正确！");
      return;
    }
    showDialog<int>(
        context: context,
        barrierDismissible: false,
        child: new ShowAwait(_saveModify())).then((int onValue) {
      if (onValue == 1) {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text("密码修改成功！"),
        ));
      } else {
        print("暂时没有处理！");
      }
    });
  }

  Future<int> _saveModify() async {
    await reference
        .child('${widget.myPhone}/password')
        .set(_passwordController.text.trim());
    return 1;
  }

  void _checkInput() {
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text.trim().length < 6) {
      _correctPassword = false;
    } else {
      _correctPassword = true;
    }
    if (_confirmController.text.isNotEmpty &&
        _confirmController.text.trim() != _passwordController.text.trim()) {
      _correctConfirm = false;
    } else {
      _correctConfirm = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text("修改密码"),
          centerTitle: true,
          elevation: 0.0,
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.save),
                onPressed: () {
                  _handleSubmitted();
                })
          ],
        ),
        body: new Stack(children: <Widget>[
          new GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                _checkInput();
              },
              child: new Container(
                decoration: new BoxDecoration(),
              )),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Column(
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: new TextField(
                      controller: _passwordController,
                      keyboardType: TextInputType.number,
                      decoration: new InputDecoration(
                        hintText: "新密码",
                        errorText: _correctPassword ? null : '密码的长度应该大于6位',
                      ),
                      onSubmitted: (value) {
                        _checkInput();
                      },
                    ),
                  ),
                  new Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: new TextField(
                      controller: _confirmController,
                      keyboardType: TextInputType.number,
                      decoration: new InputDecoration(
                        hintText: "确认密码",
                        errorText: _correctConfirm ? null : '确认密码与新密码不一致',
                      ),
                      onSubmitted: (value) {
                        _checkInput();
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ]));
  }
}
