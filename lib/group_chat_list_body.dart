import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'chat_screen.dart';
import 'prompt_wait.dart';

class GroupChatListBodyItem extends StatelessWidget {
  GroupChatListBodyItem({
    this.name,
    this.lastMessage,
    this.timestamp,
    this.messages,
    this.myName,
    this.myPhone,
    this.shePhone,
    this.shePortrait,
    this.myPortrait,
  });
  final String name;
  final String lastMessage;
  final String timestamp;
  final String messages;
  final String myName;
  final String myPhone;
  final String shePhone;
  final String shePortrait;
  final String myPortrait;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return new ChatScreen(
                messages: messages,
                myName: myName,
                sheName: name,
                myPhone: myPhone,
                shePhone: shePhone,
                shePortrait: shePortrait,
                myPortrait: myPortrait,
              );
            },
          ));
        },
        child: new Container(
            decoration: new BoxDecoration(),
            padding: new EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: new Row(
              children: <Widget>[
                new CircleAvatar(
                    backgroundImage: new NetworkImage(shePortrait)),
                new Flexible(
                    child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text("  " + name, textScaleFactor: 1.2),
                          new Text(readableTime(timestamp),
                              textAlign: TextAlign.right,
                              style: new TextStyle(
                                  color: Theme.of(context).hintColor)),
                        ]),
                    new Container(
                        padding: new EdgeInsets.only(top: 2.0),
                        child: new Text("  " + lastMessage,
                            overflow: TextOverflow.ellipsis,
                            style: new TextStyle(
                                color: Theme.of(context).hintColor))),
                  ],
                ))
              ],
            )));
  }
}

class GroupChatListBody extends StatefulWidget {
  GroupChatListBody({
    this.phone,
    this.myName,
    this.portrait,
    Key key,
  })
      : super(key: key);
  final String phone;
  final String myName;
  final String portrait;
  @override
  _GroupChatListBodyState createState() => new _GroupChatListBodyState(phone);
}

class _GroupChatListBodyState extends State<GroupChatListBody> {
  _GroupChatListBodyState(this._phone);
  final String _phone;

  DatabaseReference _chatsReference;

  @override
  void initState() {
    super.initState();
    _chatsReference =
        FirebaseDatabase.instance.reference().child('chats/$_phone');
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    _chatsReference.keepSynced(true);
  }

  @override
  Widget build(BuildContext context) {
    return new FirebaseAnimatedList(
      query: _chatsReference,
      sort: (DataSnapshot a, DataSnapshot b) =>
          b.value["timestamp"].compareTo(a.value["timestamp"]),
      defaultChild: new CircularProgressIndicator(),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation,int i) {
        return new SizeTransition(
          sizeFactor: animation,
          child: snapshot.value["activate"] == "false"
              ? null
              : new GroupChatListBodyItem(
                  name: snapshot.value["name"],
                  lastMessage: snapshot.value["lastMessage"],
                  timestamp: snapshot.value["timestamp"],
                  messages: snapshot.value["messages"],
                  myName: widget.myName,
                  myPhone: _phone,
                  shePhone: snapshot.value["phone"],
                  shePortrait: snapshot.value["portrait"],
                  myPortrait: widget.portrait,
                ),
        );
      },
    );
  }
}
