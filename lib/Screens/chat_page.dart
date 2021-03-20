import 'package:flutter/material.dart';
import '../Providers/auth.dart';
import '../Providers/chat.dart';
import 'package:provider/provider.dart';
import '../consts.dart' as constants;

const urlStart = constants.url;

class ChatPage extends StatefulWidget {
  static const routeName = '/chatRoom';

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  dynamic messages = [];

  Future getMessages;

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<Chat>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    final Map userData = ModalRoute.of(context).settings.arguments;
    final controller = TextEditingController();

    chat.resetUserMessages();

    getMessages =
        chat.getMessages(auth.token, userData['name'], userData['surname']);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    urlStart + "Assets/Images/" + userData["image"].toString(),
                  ),
                  maxRadius: 20,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        userData['name'] + ' ' + userData['surname'],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Consumer<Chat>(
            builder: (ctx, explore, _) => FutureBuilder(
              future: getMessages,
              builder: (ctx, usersResultSnapshot) => (usersResultSnapshot
                          .connectionState ==
                      ConnectionState.done)
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 60.0),
                      child: ListView.builder(
                        itemCount: chat.userMessages.length,
                        itemBuilder: (ctx, index) {
                          return Container(
                            padding: EdgeInsets.only(
                                left: 14, right: 14, top: 10, bottom: 10),
                            child: Align(
                              alignment:
                                  (chat.userMessages[index]['Sender'] != true
                                      ? Alignment.bottomLeft
                                      : Alignment.bottomRight),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: (chat.userMessages[index]['Sender'] !=
                                          true
                                      ? Colors.grey.shade200
                                      : Colors.white),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 0.1,
                                  ),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  chat.userMessages[index]['Content'],
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        if (userData['first'] =
                            true && chat.userMessages.length == 0) {
                          chat.newConversation(auth.token, userData['name'],
                              userData['surname']);
                        }
                        chat.newMessage(auth.token, controller.text,
                            userData['name'], userData['surname']);
                      });
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.grey,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
