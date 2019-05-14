import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'prompt_wait.dart';
import 'image_zoomable.dart';

class PersonalData extends StatefulWidget {
  PersonalData({this.name, this.email, this.portrait, this.phone});

  final String name;
  final String email;
  final String portrait;
  final String phone;

  @override
  State createState() => new _PersonalDataState(name, email, portrait);
}

class _PersonalDataState extends State<PersonalData> {
  _PersonalDataState(this._name, this._email, this._portrait);

  String _name;
  String _email;
  String _portrait;
  String _newPortrait;

  final usersReference = FirebaseDatabase.instance.reference().child('users');
  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  bool _editableState = false;
  bool _correctUsername = true;
  bool _correctEmail = true;

  void _handleSubmitted() {
    FocusScope.of(context).requestFocus(new FocusNode());
    _checkInput();
    if (_usernameController.text == '' ||
        !_correctUsername ||
        _emailController.text == '' ||
        !_correctEmail) {
      showMessage(context, "资料信息填写不完整！");
      return;
    }
    _editableState = false;
    showDialog<int>(
            context: context,
            barrierDismissible: false,
            child: new ShowAwait(_saveModify()))
        .then((int onValue) {
      if (onValue == 1) {
        _editableState = false;
        setState(() {});
      } else {
        print("暂时没有处理！");
      }
    });
    setState(() {});
  }

  Future<int> _saveModify() async {
    if (_usernameController.text.trim() != _name) {
      _name = _usernameController.text.trim();
      await usersReference
          .child('${widget.phone}/name')
          .set(_usernameController.text.trim());
    }
    if (_emailController.text.trim() != _email) {
      _email = _emailController.text.trim();
      await usersReference
          .child('${widget.phone}/email')
          .set(_emailController.text.trim());
    }
    if (_newPortrait != _portrait) {
      _portrait = _newPortrait;
      await usersReference.child('${widget.phone}/portrait').set(_newPortrait);
    }
    _saveLogin(widget.phone, _name, _email, _newPortrait);
    return 1;
  }

  Future<Null> _saveLogin(
      String phone, String name, String email, String portrait) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    await new File('$dir/LandingInformation').writeAsString(
        '{"phone":"$phone","name":"$name","email":"$email","portrait":"$portrait"}');
  }

  void _checkInput() {
    if (_usernameController.text.isNotEmpty &&
        _usernameController.text.trim().length < 2) {
      _correctUsername = false;
    } else {
      _correctUsername = true;
    }
    if (_emailController.text.isNotEmpty &&
        _emailController.text.trim().length < 3) {
      _correctEmail = false;
    } else {
      _correctEmail = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("个人资料"),
        centerTitle: true,
        elevation: 0.0,
        leading: _editableState
            ? new IconButton(
                icon: new Icon(Icons.undo),
                onPressed: () {
                  _editableState = false;
                  setState(() {});
                })
            : null,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(_editableState ? Icons.save : Icons.create),
              onPressed: () {
                if (!_editableState) {
                  _editableState = true;
                  _usernameController.text = _name;
                  _emailController.text = _email;
                  _newPortrait = _portrait;
                  _correctUsername = true;
                  _correctEmail = true;
                  setState(() {});
                } else {
                  _handleSubmitted();
                }
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
                  margin: const EdgeInsets.only(top: 30.0),
                  child: _editableState
                      ? new Stack(children: <Widget>[
                          new Opacity(
                              opacity: 0.4,
                              child: new CircleAvatar(
                                backgroundImage: new NetworkImage(_newPortrait),
                                radius: 50.0,
                              )),
                          new GestureDetector(
                            onTap: () async {
                              File imageFile = await ImagePicker.pickImage(
                                  source: ImageSource.gallery);
                              int random = new Random().nextInt(100000);
                              StorageReference ref = FirebaseStorage.instance
                                  .ref()
                                  .child(
                                      "custom-portraits/portrait_$random.jpg");
                              StorageUploadTask uploadTask =
                                  ref.putFile(imageFile);
                              String url = await uploadTask.lastSnapshot.ref
                                  .getDownloadURL();
                              setState(() {
                                _newPortrait = url;
                              });
                            },
                            child: new Container(
                                padding: const EdgeInsets.only(
                                    top: 30.0, left: 30.0),
                                child: new Icon(
                                  Icons.add_a_photo,
                                  size: 40.0,
                                )),
                          )
                        ])
                      : new GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                                new MaterialPageRoute<Null>(
                                    builder: (BuildContext context) {
                              return new ImageZoomable(
                                new NetworkImage(_portrait),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              );
                            }));
                          },
                          child: new CircleAvatar(
                            backgroundImage: new NetworkImage(_portrait),
                            radius: 50.0,
                          )),
                ),
                _editableState
                    ? new Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: new TextField(
                          controller: _usernameController,
                          decoration: new InputDecoration(
                            hintText: "用户名称",
                            errorText: _correctUsername ? null : '名称的长度应该大于2位',
                          ),
                          onSubmitted: (value) {
                            _checkInput();
                          },
                        ),
                      )
                    : new Container(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                        child: new Text(_name, textScaleFactor: 1.4),
                      ),
                _editableState
                    ? new Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: new TextField(
                          controller: _emailController,
                          decoration: new InputDecoration(
                            hintText: "电子邮箱",
                            errorText: _correctEmail ? null : '邮箱格式不正确',
                          ),
                          onSubmitted: (value) {
                            _checkInput();
                          },
                        ),
                      )
                    : new Text(_email, textScaleFactor: 1.1),
              ],
            ),
          ],
        )
      ]),
    );
  }
}
