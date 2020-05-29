import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Message extends StatelessWidget{
  final String from;
  final String text;
  final bool me;
  final String imagelink;
  final String name;
  const Message({Key key,this.from,this.text,this.me,this.imagelink,this.name});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    TextStyle textStyle = TextStyle(
        fontFamily: "ChelseaMarket", color: Color(0xFF303960), fontSize: 15.0, fontWeight: FontWeight.bold);
    return Container(
      child: Row(
        mainAxisAlignment: me? MainAxisAlignment.end :MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          me? Container():CircleAvatar(
            child: Image.network(
              imagelink,
              fit: BoxFit.contain,
            ),
            radius: 18.0,
          ),
          Column(
            children: <Widget>[
              Text(me? "":name),
              Material(
                color: me? Colors.teal:Colors.red,
                borderRadius: BorderRadius.circular(10.0),
                elevation: 6.0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                  child: Text(
                    text,
                    style: textStyle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}