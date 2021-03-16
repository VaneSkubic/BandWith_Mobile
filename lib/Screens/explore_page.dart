import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_music_app/Screens/chat_overview_screen.dart';
import 'package:flutter_music_app/Screens/settings_screen.dart';
import '../Providers/auth.dart';
import 'package:provider/provider.dart';
import '../Providers/explore.dart';

dynamic explore;

class ExploreScreen extends StatefulWidget {
  static const routeName = '/explore';

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  Future getUsers;
  dynamic auth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      explore = Provider.of<Explore>(context, listen: false);
      auth = Provider.of<Auth>(context, listen: false);
      setState(() {
        getUsers = explore.getUsers(auth.token);
      });
    });
  }

  Future<void> _refreshExplore(BuildContext context) async {
    await Provider.of<Explore>(context, listen: false).getUsers(auth.token);
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

  playAudio() async {
    if (playPause) {
      audioPlayer.pause();
    } else {
      await audioPlayer.play('http://192.168.1.101/Server/API/Rosanna.wav');
    }

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
      audioPlayer.stop();
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
                                        image: MemoryImage(Base64Decoder()
                                            .convert(data[index]["image"]
                                                .toString())),
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
                                    HSLColor.fromAHSL(0, 0, 0, 1).toColor(),
                                    HSLColor.fromAHSL(0.081, 0, 0, 0.9942)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.155, 0, 0, 0.9776)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.225, 0, 0, 0.9515)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.29, 0, 0, 0.9167)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.353, 0, 0, 0.8741)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.412, 0, 0, 0.8244)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.471, 0, 0, 0.7684)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.529, 0, 0, 0.7068)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.588, 0, 0, 0.6406)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.647, 0, 0, 0.5709)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.71, 0, 0, 0.4996)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.775, 0, 0, 0.4297)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.845, 0, 0, 0.3664)
                                        .toColor(),
                                    HSLColor.fromAHSL(0.919, 0, 0, 0.3187)
                                        .toColor(),
                                    HSLColor.fromAHSL(1, 0, 0, 0.3).toColor(),
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
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Row(
                                          children: [
                                            Text(
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
                                            // Text(
                                            //   ', 18', //', ' + data[index]['age'],
                                            //   style: TextStyle(
                                            //     fontSize: 30,
                                            //     fontWeight: FontWeight.w400,
                                            //     color: Colors.white,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          children: [
                                            // Text(
                                            //   'Instruments:',
                                            //   style: TextStyle(
                                            //     fontSize: 18,
                                            //     fontWeight: FontWeight.w400,
                                            //     color: Colors.white,
                                            //   ),
                                            // ),
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
                                  icon: playPause
                                      ? Icon(Icons.pause_rounded)
                                      : Icon(Icons.play_arrow_rounded),
                                  onPressed: () {
                                    playAudio();
                                  },
                                ),
                              ),
                              VerticalDivider(
                                thickness: 2,
                                color: Colors.black54,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
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
                child: Icon(
                  Icons.favorite_rounded,
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
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: ImageIcon(
          AssetImage('Assets/' +
              data[index]['instruments'][i].toString().replaceAll('/', '') +
              '.png'),
          color: Colors.white,
        ),
      ),
    );
    widgets.add(
      Text(
        ' | ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
        ),
      ),
    );
  }
  widgets.removeLast();
  return Row(
    children: widgets,
  );
}
