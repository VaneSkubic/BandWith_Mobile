import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Screens/chat_page.dart';
import '../Providers/chat.dart';
import '../Providers/auth.dart';
import 'package:provider/provider.dart';

class ChatOverviewScreen extends StatefulWidget {
  static const routeName = '/chat';

  @override
  _ChatOverviewScreenState createState() => _ChatOverviewScreenState();
}

class _ChatOverviewScreenState extends State<ChatOverviewScreen> {
  Future getFavorites;
  Future getConversations;
  dynamic auth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final chat = Provider.of<Chat>(context, listen: false);
      auth = Provider.of<Auth>(context, listen: false);
      setState(() {
        getFavorites = chat.getFavorites(auth.token);
        getConversations = chat.getConversations(auth.token);
      });
    });
  }

  Future<void> _refreshFavorites(BuildContext context) async {
    await Provider.of<Chat>(context, listen: false).getFavorites(auth.token);
  }

  Future<void> _refreshChat(BuildContext context) async {
    await Provider.of<Chat>(context, listen: false)
        .getConversations(auth.token);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Montserrat',
                fontSize: 20,
                letterSpacing: 4,
              ),
              children: [
                TextSpan(
                  text: 'Band',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: 'With',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          bottom: TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3.0),
            ),
            unselectedLabelColor: Colors.grey,
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Montserrat',
            ),
            labelColor: Colors.black,
            labelStyle: TextStyle(
              fontFamily: 'Montserrat',
            ),
            tabs: [
              Tab(
                text: 'Favorites',
              ),
              Tab(
                text: 'Chat',
              ),
            ],
          ),
        ),
        body: Consumer<Chat>(
          builder: (ctx, explore, _) => TabBarView(
            children: [
              FutureBuilder(
                future: getFavorites,
                builder: (ctx, usersResultSnapshot) =>
                    (usersResultSnapshot.connectionState ==
                            ConnectionState.waiting)
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : RefreshIndicator(
                            color: Colors.black,
                            onRefresh: () => _refreshFavorites(context),
                            child: Favorites(),
                          ),
              ),
              FutureBuilder(
                future: getConversations,
                builder: (ctx, usersResultSnapshot) =>
                    (usersResultSnapshot.connectionState ==
                            ConnectionState.waiting)
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : RefreshIndicator(
                            color: Colors.black,
                            onRefresh: () => _refreshChat(context),
                            child: ChatOverview(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatOverview extends StatefulWidget {
  @override
  _ChatOverviewState createState() => _ChatOverviewState();
}

class _ChatOverviewState extends State<ChatOverview> {
  @override
  Widget build(BuildContext context) {
    dynamic userConversations = Provider.of<Chat>(context).userConversations;
    return ListView.builder(
      itemCount: userConversations.length,
      itemBuilder: (ctx, index) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(ChatPage.routeName, arguments: {
                  'name': userConversations[index]['name'],
                  'surname': userConversations[index]['surname'],
                  'image': userConversations[index]['image'],
                  'first': false,
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: userConversations[index]["image"] != null
                        ? MemoryImage(
                            Base64Decoder().convert(
                                userConversations[index]["image"].toString()),
                          )
                        : AssetImage('Assets/Profile.png'),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      userConversations[index]['name'] +
                          ' ' +
                          userConversations[index]['surname'],
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      userConversations[index]['sender'] == true
                          ? 'You: ' + userConversations[index]['content']
                          : userConversations[index]['name'] +
                              userConversations[index]['content'],
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  trailing: Text(
                    userConversations[index]['sendtime'],
                  ),
                ),
              ),
            ),
            Divider(),
          ],
        );
      },
    );
  }
}

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<Chat>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    dynamic userFavorites = Provider.of<Chat>(context).userFavorites;
    return ListView.builder(
      itemCount: userFavorites.length,
      itemBuilder: (ctx, index) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: userFavorites[index]["image"] != null
                      ? MemoryImage(
                          Base64Decoder().convert(
                              userFavorites[index]["image"].toString()),
                        )
                      : AssetImage('Assets/Profile.png'),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.messenger_outline_rounded),
                  onPressed: () {
                    // chat.newConversation(
                    //     auth.token,
                    //     userFavorites[index]['name'],
                    //     userFavorites[index]['surname']);
                    Navigator.of(context)
                        .pushNamed(ChatPage.routeName, arguments: {
                      'name': userFavorites[index]['name'],
                      'surname': userFavorites[index]['surname'],
                      'image': userFavorites[index]['image'],
                      'first': true,
                    });
                  },
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    userFavorites[index]['name'] +
                        ' ' +
                        userFavorites[index]['surname'],
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat'),
                  ),
                ),
              ),
            ),
            Divider(),
          ],
        );
      },
    );
  }
}
