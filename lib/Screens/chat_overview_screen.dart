import 'package:flutter/material.dart';
import 'package:flutter_music_app/Providers/explore.dart';
import '../Screens/chat_page.dart';
import '../Providers/chat.dart';
import '../Providers/auth.dart';
import 'package:provider/provider.dart';
import '../consts.dart' as constants;

const urlStart = constants.url;

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
    return userConversations.length == 0
        ? Center(
            child: Text(
              "Start a new conversation!",
            ),
          )
        : ListView.builder(
            itemCount: userConversations.length,
            itemBuilder: (ctx, index) {
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(ChatPage.routeName, arguments: {
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
                          backgroundImage:
                              userConversations[index]["image"] != null
                                  ? NetworkImage(
                                      urlStart +
                                          "Assets/Images/" +
                                          userConversations[index]["image"]
                                              .toString(),
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
    final auth = Provider.of<Auth>(context, listen: false);
    final explore = Provider.of<Explore>(context, listen: false);
    final chat = Provider.of<Chat>(context, listen: false);
    dynamic userFavorites = Provider.of<Chat>(context).userFavorites;
    return userFavorites.length == 0
        ? Center(
            child: Text(
              "You don't have any favorites yet!",
            ),
          )
        : ListView.builder(
            itemCount: userFavorites.length,
            itemBuilder: (ctx, index) {
              return Column(
                children: [
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: userFavorites[index]["image"] != null
                              ? NetworkImage(
                                  urlStart +
                                      "Assets/Images/" +
                                      userFavorites[index]["image"].toString(),
                                )
                              : AssetImage('Assets/Profile.png'),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.messenger_outline_rounded),
                          onPressed: () {
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
                    onLongPress: () {
                      showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(10.0),
                            topRight: const Radius.circular(10.0),
                          ),
                        ),
                        context: context,
                        builder: (context) {
                          return Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.horizontal_rule_rounded,
                                  size: 30,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, top: 15.0, bottom: 30),
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      userFavorites[index]['name'] +
                                          ' ' +
                                          userFavorites[index]['surname'],
                                      style: TextStyle(
                                        fontSize: 25,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, bottom: 25),
                                    child: Icon(Icons.favorite_border_rounded),
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, bottom: 20),
                                    child: Text(
                                      'Unlike',
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      explore.updateLikes(
                                        auth.token,
                                        userFavorites[index]['name'],
                                        userFavorites[index]['surname'],
                                        false,
                                      );
                                      explore.toggleFavorite(index);
                                      userFavorites.removeAt(index);
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 35),
                                    child: Icon(
                                        Icons.report_gmailerrorred_rounded),
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, bottom: 35),
                                    child: Text(
                                      'Report',
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            contentPadding: EdgeInsets.zero,
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  decoration: BoxDecoration(
                                                    color: Colors.red[300],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    child: Text(
                                                      "Report",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        letterSpacing: 2,
                                                        fontSize: 25,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Text(
                                                    "Are you sure you want to report this user?",
                                                    style: TextStyle(
                                                      letterSpacing: 2,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              OutlinedButton(
                                                child: Text(
                                                  "No",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: OutlinedButton(
                                                  child: Text(
                                                    "Yes",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red[300],
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      chat.reportUser(
                                                        auth.token,
                                                        userFavorites[index]
                                                            ['name'],
                                                      );
                                                      explore.updateLikes(
                                                        auth.token,
                                                        userFavorites[index]
                                                            ['name'],
                                                        userFavorites[index]
                                                            ['surname'],
                                                        false,
                                                      );
                                                      explore.toggleFavorite(
                                                          index);
                                                      explore.removeUser(index);
                                                      userFavorites
                                                          .removeAt(index);
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Divider(),
                ],
              );
            },
          );
  }
}
