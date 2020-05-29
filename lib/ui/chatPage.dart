import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/show_message.dart';
class chatPage extends StatefulWidget{
  final FirebaseUser user;
  chatPage(this.user);
  @override
  _chatPageState createState()=> _chatPageState();
}

class _chatPageState extends State<chatPage>{
  final Firestore _firestore=Firestore.instance;
  var _currentUser;
  TextEditingController messageController=TextEditingController();
  ScrollController scrollController=ScrollController();
  String imagelink;
  String name;
  @override
  void getImageLink() async{
      await _firestore.collection('Vehicle').document(widget.user.uid).get().then((snapshot){
        _currentUser=snapshot.data;
        setState(() {
          imagelink= _currentUser['image'].toString();
          name= _currentUser['name'].toString();
        });
      });
  }

  Future<void> callback() async{
    if(messageController.text.length>0){
      await _firestore.collection('messages').add({
      'text':messageController.text,
      'from':widget.user.email,
      'imagelink': imagelink,
        'name':name,
        "timestamp": DateTime.now().millisecondsSinceEpoch
      });
      messageController.clear();
      scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    getImageLink();
    TextStyle textStyle = TextStyle(
        fontFamily: "ChelseaMarket", color: Color(0xFF303960), fontSize: 15.0, fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: new AppBar(
        title: Center(child: Text(
          'Chat           ',
        )),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        minimum: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('messages').orderBy('timestamp', descending: false).snapshots(),
                builder: (context,snapshot){
                  if(!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  List<DocumentSnapshot> docs=snapshot.data.documents;

                  List<Widget> messages= docs
                      .map((doc)=> Message(
                    from: doc.data['from'],
                    text: doc.data['text'],
                    me: widget.user.email==doc.data['from'],
                    imagelink: doc.data['imagelink'],
                    name: doc.data['name'],
                  ))
                      .toList();
                  return ListView(
                    controller: scrollController,
                    children: <Widget>[
                      ...messages,
                    ],
                  );
                },
              )
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                  color: Colors.blueGrey.shade50,
                  offset: Offset(0.0,0.1),
                  blurRadius: 6.0,
                )
                ]
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onSubmitted: (value)=>callback,
                      controller: messageController,
                      decoration: new InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue,width: 2.0),
                        ),
                        contentPadding: EdgeInsets.all(10.0),
                        hintText: 'Enter message',
                      ),
                    ),
                  ),
                  SendButton(
                    callback: callback,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget{
  final VoidCallback callback;
  const SendButton({Key key,this.callback});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
      icon: Icon(Icons.send),
      onPressed: callback,
    );
  }
}
