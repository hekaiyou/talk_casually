import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'image_zoomable.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({
    this.messages,
    this.myName,
    this.sheName,
    this.myPhone,
    this.shePhone,
    this.shePortrait,
    this.myPortrait,
  });
  final String messages;
  final String myName;
  final String sheName;
  final String myPhone;
  final String shePhone;
  final String shePortrait;
  final String myPortrait;

  @override
  State createState() => new ChatScreenState(messages);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState(this._messages);
  final String _messages;

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>();
  final TextEditingController _textController = new TextEditingController();
  final chatsReference = FirebaseDatabase.instance.reference().child('chats');
  final messagesReference =
      FirebaseDatabase.instance.reference().child('messages');
  bool _isComposing = false;

  Future _handleSubmitted(String text) async {
    chatsReference
        .child('${widget.myPhone}/${widget.shePhone}/activate')
        .onValue
        .listen((Event event) {
      if (event.snapshot.value == "false") {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text("会话已经被删除了哦！"),
        ));
      } else {
        if (text.trim() == "") return;
        _textController.clear();
        _isComposing = false;
        _sendMessage(text: text);
      }
    });
  }

  void _sendMessage({String text, String imageUrl}) {
    String time = new DateTime.now().toString();
    messagesReference.child(_messages).push().set({
      'text': text,
      'imageUrl': imageUrl,
      'senderName': widget.myName,
      'timestamp': time
    });
    chatsReference
        .child('${widget.shePhone}/${widget.myPhone}/lastMessage')
        .set(text);
    chatsReference
        .child('${widget.shePhone}/${widget.myPhone}/timestamp')
        .set(time);
    chatsReference
        .child('${widget.myPhone}/${widget.shePhone}/lastMessage')
        .set(text);
    chatsReference
        .child('${widget.myPhone}/${widget.shePhone}/timestamp')
        .set(time);
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: new Row(children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(Icons.photo_camera),
                    onPressed: () async {
                      File imageFile = await ImagePicker.pickImage();
                      int random = new Random().nextInt(100000);
                      _scaffoldKey.currentState.showSnackBar(new SnackBar(
                        content: new Text("上传原图中〜请稍候！"),
                      ));
                      StorageReference ref = FirebaseStorage.instance
                          .ref()
                          .child("sessions/$_messages/image_$random.jpg");
                      StorageUploadTask uploadTask = ref.put(imageFile);
                      Uri downloadUrl = (await uploadTask.future).downloadUrl;
                      _sendMessage(
                          text: "[图片]", imageUrl: downloadUrl.toString());
                    }),
              ),
              new Flexible(
                  child: new TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration: new InputDecoration.collapsed(hintText: '发送消息'),
              )),
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: _isComposing
                        ? () => _handleSubmitted(_textController.text)
                        : null),
              )
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          title: new Text(widget.sheName),
          centerTitle: true,
          elevation: 1.0,
          actions: <Widget>[
            new PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == "delete") {
                    chatsReference
                        .child('${widget.shePhone}/${widget.myPhone}/activate')
                        .set("false");
                    chatsReference
                        .child('${widget.myPhone}/${widget.shePhone}/activate')
                        .set("false");
                    _scaffoldKey.currentState.showSnackBar(new SnackBar(
                      content: new Text("删除成功！"),
                    ));
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                      new PopupMenuItem<String>(
                          value: "delete", child: new Text('删除会话')),
                    ])
          ]),
      body: new Stack(children: <Widget>[
        new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: new Container(
              decoration: new BoxDecoration(),
            )),
        new Column(
          children: <Widget>[
            new Flexible(
                child: new FirebaseAnimatedList(
                    query: messagesReference.child(_messages),
                    sort: (a, b) => b.key.compareTo(a.key),
                    padding: new EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, DataSnapshot snapshot,
                        Animation<double> animation) {
                      return new ChatMessage(
                        snapshot: snapshot,
                        animation: animation,
                        myName: widget.myName,
                        shePortrait: widget.shePortrait,
                        myPortrait: widget.myPortrait,
                      );
                    })),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: _buildTextComposer(),
            )
          ],
        )
      ]),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage(
      {this.snapshot,
      this.animation,
      this.myName,
      this.shePortrait,
      this.myPortrait});
  final DataSnapshot snapshot;
  final Animation animation;
  final String myName;
  final String shePortrait;
  final String myPortrait;

  @override
  Widget build(BuildContext context) {
    Widget _sheSessionStyle() {
      return new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(
                  backgroundImage: new NetworkImage(shePortrait)),
            ),
            new Flexible(
                child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  new Text(snapshot.value['senderName'],
                      style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: snapshot.value['imageUrl'] != null
                        ? new GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                  new MaterialPageRoute<Null>(
                                      builder: (BuildContext context) {
                                return new ImageZoomable(
                                  new NetworkImage(snapshot.value['imageUrl']),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              }));
                            },
                            child: new Image.network(
                              snapshot.value['imageUrl'],
                              width: 150.0,
                            ),
                          )
                        : new Text(snapshot.value['text']),
                  )
                ])),
          ]);
    }

    Widget _mySessionStyle() {
      return new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Flexible(
                child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                  new Text(snapshot.value['senderName'],
                      style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: snapshot.value['imageUrl'] != null
                        ? new GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                  new MaterialPageRoute<Null>(
                                      builder: (BuildContext context) {
                                return new ImageZoomable(
                                  new NetworkImage(snapshot.value['imageUrl']),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              }));
                            },
                            child: new Image.network(
                              snapshot.value['imageUrl'],
                              width: 150.0,
                            ),
                          )
                        : new Text(snapshot.value['text']),
                  )
                ])),
            new Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: new CircleAvatar(
                  backgroundImage: new NetworkImage(myPortrait)),
            ),
          ]);
    }

    return new SizeTransition(
        sizeFactor:
            new CurvedAnimation(parent: animation, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: myName == snapshot.value['senderName']
              ? _mySessionStyle()
              : _sheSessionStyle(),
        ));
  }
}
