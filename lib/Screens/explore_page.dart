import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_music_app/Screens/chat_overview_screen.dart';
import 'package:flutter_music_app/Screens/settings_screen.dart';
import '../Providers/auth.dart';
import 'package:provider/provider.dart';
import '../Providers/explore.dart';
import '../consts.dart' as constants;

const urlStart = constants.url;

dynamic explore;
int count = 0;

AnimationController _iconController;

class ExploreScreen extends StatefulWidget {
  static const routeName = '/explore';

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  Future getUsers;
  dynamic auth;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      explore = Provider.of<Explore>(context, listen: false);
      auth = Provider.of<Auth>(context, listen: false);
      setState(() {
        getUsers = explore.getUsers(auth.token, count);
      });
    });
  }

  Future<void> _refreshExplore(BuildContext context) async {
    await Provider.of<Explore>(context, listen: false)
        .getUsers(auth.token, count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.person_outline_rounded),
          onPressed: () {
            Navigator.of(context).pushNamed(SettingsScreen.routeName);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () {
              Navigator.of(context).pushNamed(ChatOverviewScreen.routeName);
            },
          ),
        ],
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
      ),
      body: Consumer<Explore>(
        builder: (ctx, explore, _) => FutureBuilder(
          future: getUsers,
          builder: (ctx, usersResultSnapshot) =>
              (usersResultSnapshot.connectionState == ConnectionState.waiting)
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _refreshExplore(context),
                      child: ExplorePage(),
                    ),
        ),
      ),
    );
  }
}

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final PageController verticalController = PageController();
  final PageController horizontalController = PageController();

  final audioPlayer = AudioPlayer();
  bool playPause = false;

  playAudio(index) async {
    if (playPause) {
      audioPlayer.pause();
      _iconController.reverse();
    } else {
      _iconController.forward();
      await audioPlayer.play(urlStart + 'Assets/Audio/' + index);
    }

    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        playPause = !playPause;
        _iconController.reverse();
      });
    });

    setState(() {
      playPause = !playPause;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final explore = Provider.of<Explore>(context, listen: false);
    final data = Provider.of<Explore>(context, listen: false).usersData;
    horizontalController.addListener(() {
      _iconController.reverse();
      audioPlayer.stop();
      audioPlayer.release();
      if (playPause) {
        playPause = !playPause;
      }
    });
    return Center(
      child: PageView.builder(
        controller: horizontalController,
        physics: BouncingScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (_, index) {
          if (index == data.length - 3) {
            count++;
            explore.getUsers(auth.token, count);
          }
          return PageView(
            controller: verticalController,
            onPageChanged: (value) {
              if (value == 1) {
                explore.updateLikes(auth.token, data[index]['name'],
                    data[index]['surname'], !data[index]['favorite']);
                explore.toggleFavorite(index);
                Timer(Duration(seconds: 1), () {
                  horizontalController.nextPage(
                    curve: Curves.ease,
                    duration: Duration(milliseconds: 300),
                  );
                });
              }
            },
            scrollDirection: Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 15.0,
                        spreadRadius: 4.0,
                        offset: Offset(
                          0.0,
                          2.0,
                        ),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Flexible(
                        flex: 5,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                image: data[index]["image"] != null
                                    ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          urlStart +
                                              "Assets/Images/" +
                                              data[index]["image"].toString(),
                                        ),
                                        // MemoryImage(Base64Decoder()
                                        //     .convert(data[index]["image"]
                                        //         .toString())),
                                      )
                                    : DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage('Assets/Profile.png'),
                                      ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xffffff).withOpacity(0.0),
                                    Color(0xadadad).withOpacity(0.2),
                                    Color(0x7a7a7a).withOpacity(0.4),
                                    Color(0x737373).withOpacity(0.5),
                                    Color(0x363636).withOpacity(.6),
                                    Color(0x303030).withOpacity(.8),
                                    Color(0x000000).withOpacity(.8),
                                  ],
                                  end: Alignment.bottomCenter,
                                  begin: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topRight,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                ),
                                child: IconButton(
                                  iconSize: 30,
                                  icon: data[index]['favorite']
                                      ? Icon(Icons.favorite_rounded)
                                      : Icon(Icons.favorite_border_rounded),
                                  color: Colors.red,
                                  onPressed: () {
                                    setState(() {
                                      explore.updateLikes(
                                          auth.token,
                                          data[index]['name'],
                                          data[index]['surname'],
                                          !data[index]['favorite']);
                                      explore.toggleFavorite(index);
                                    });
                                  },
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.all(20),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.end,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  80,
                                              child: Text(
                                                data[index]['name'][0]
                                                        .toString()
                                                        .toUpperCase() +
                                                    data[index]['name']
                                                        .toString()
                                                        .substring(1) +
                                                    ' ' +
                                                    data[index]['surname'][0]
                                                        .toString()
                                                        .toUpperCase() +
                                                    data[index]['surname']
                                                        .toString()
                                                        .substring(1),
                                                style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  letterSpacing: 1.7,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: data[index]['instruments']
                                                          .toString() !=
                                                      '[]'
                                                  ? iconList(data, index)
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 4.0),
                                                      child: Text(
                                                        '/',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, left: 17, right: 10, bottom: 10),
                                child: IconButton(
                                  iconSize: 50,
                                  icon: AnimatedIcon(
                                    icon: AnimatedIcons.play_pause,
                                    progress: _iconController,
                                  ),
                                  onPressed: () {
                                    playAudio(data[index]['audio']);
                                  },
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    right: 5,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(20),
                                      ),
                                      image: DecorationImage(
                                        fit: BoxFit.fitWidth,
                                        image:
                                            AssetImage('Assets/Waveform.png'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: data[index]['favorite']
                    ? Icon(
                        Icons.favorite_rounded,
                        size: 100,
                        color: Colors.red,
                      )
                    : Icon(
                        Icons.favorite_border_rounded,
                        size: 100,
                        color: Colors.red,
                      ),
              )
            ],
          );
        },
      ),
    );
  }
}

Widget iconList(dynamic data, int index) {
  List<Widget> widgets = [];
  for (int i = 0; i < data[index]['instruments'].length; i++) {
    data[index]['instruments'][i].toString();
    widgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10),
        child: ImageIcon(
          AssetImage('Assets/' +
              data[index]['instruments'][i].toString().replaceAll('/', '') +
              '.png'),
          color: Colors.white,
          size: 25,
        ),
      ),
    );
    widgets.add(
      RotatedBox(
        quarterTurns: 1,
        child: Icon(
          Icons.horizontal_rule_rounded,
          color: Colors.white,
          size: 45,
        ),
      ),
    );
  }
  widgets.removeLast();
  return Row(
    children: widgets,
  );
}
