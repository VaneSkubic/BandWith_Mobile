import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../Screens/empty_page.dart';
import '../Screens/instrument_settings.dart';
import '../Providers/auth.dart';
import '../Providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

bool _notifications;
bool _darkMode;
double _rangeValue;
String _base64Image;
//String _base64Audio;
Map settingsData = {
  'Name': null,
  'Surname': null,
  'Email': null,
  'ProfileImage': null,
  'UIColor': null,
  'Notifications': null,
  'Radius': null,
};

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future getSettings;
  dynamic settings;
  dynamic auth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      auth = Provider.of<Auth>(context, listen: false);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      settings = Provider.of<Settings>(context, listen: false);
      setState(() {
        getSettings = settings.getSettings(auth.token);
      });
      getSettings = settings.getSettings(auth.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    _darkMode = Provider.of<Settings>(context).theme;

    return Consumer2<Settings, Auth>(
      builder: (ctx, settings, auth, _) => FutureBuilder(
        future: getSettings,
        builder: (ctx, settingsResultSnapshot) =>
            (settingsResultSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    settingsData['Email'] == null)
                ? EmptyPage()
                : SettingsPage(),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  dynamic auth;
  dynamic settings;

  PickedFile _image;
  PickedFile _audio;

  bool playPause = false;

  Future pickAudio() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    setState(() {
      if (result != null) {
        _audio = PickedFile(result.paths.first);
      }
    });
  }

  final picker = ImagePicker();
  final audioPlayer = AudioPlayer();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = PickedFile(pickedFile.path);
      }
    });
  }

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      auth = Provider.of<Auth>(context, listen: false);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      settings = Provider.of<Settings>(context, listen: false);
      setState(() {
        settingsData = settings.fetchSettings();
        _notifications = settingsData['Notifications'] == '1';
        _darkMode = settingsData['UIColor'] == '1';
        _rangeValue = double.parse(settingsData['Radius']);
        _base64Image = settingsData['ProfileImage'];
        //_base64Audio = settingsData['Audio'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    settings = Provider.of<Settings>(context, listen: false);
    auth = Provider.of<Auth>(context, listen: false);
    if (settings.isOpening) {
      settings.getSettings(auth.token);
      settingsData = settings.fetchSettings();
      _notifications = settingsData['Notifications'] == '1';
      _darkMode = settingsData['UIColor'] == '1';
      if (settingsData['Radius'] != null) {
        setState(() {
          settings.changeIsOpening();
          _rangeValue = double.parse(settingsData['Radius']);
        });
      } else {
        _rangeValue = null;
      }
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.save_outlined,
              ),
              onPressed: () {
                settings.postSettings(auth.token, _notifications, _darkMode,
                    _rangeValue, _image, _audio);
              },
            ),
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
                text: 'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                top: 40.0, left: 40, right: 40, bottom: 10),
            child: new Container(
              width: 190.0,
              height: 190.0,
              decoration: new BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: _darkMode
                        ? Colors.black.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: _darkMode ? 30 : 12,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                shape: BoxShape.circle,
                image: _image != null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(File(_image.path)),
                      )
                    : DecorationImage(
                        fit: BoxFit.cover,
                        image: settingsData['ProfileImage'] == null
                            ? AssetImage('Assets/Profile.png')
                            : MemoryImage(
                                Base64Decoder().convert(_base64Image)),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: TextButton(
              child: Text(
                'Change Photo',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              onPressed: () {
                getImage();
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 25),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  (settingsData['Name'] != null &&
                          settingsData['Surname'] != null)
                      ? settingsData['Name'] + ' ' + settingsData['Surname']
                      : '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  settingsData['Email'] == null ? '' : settingsData['Email'],
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          Divider(),
          Container(
            padding: const EdgeInsets.all(5),
            child: ListTile(
              trailing: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(Icons.music_note_rounded),
              ),
              title: Row(
                children: [
                  Text(
                    'SoundID',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: playPause
                        ? Icon(Icons.pause_rounded)
                        : Icon(Icons.play_arrow_rounded),
                    onPressed: () {
                      playAudio();
                    },
                  ),
                ],
              ),
              subtitle: _audio == null
                  ? Text(
                      settingsData['AudioTitle'] != null
                          ? settingsData['AudioTitle']
                          : '',
                    )
                  : Text(_audio.path.split("/").last),
              onTap: () {
                pickAudio();
              },
            ),
          ),
          Divider(),
          Container(
            padding: const EdgeInsets.all(5),
            child: ListTile(
              trailing: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(Icons.arrow_forward_ios_rounded),
              ),
              title: Text(
                "Instruments",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text("Add or remove instruments"),
              onTap: () {
                Navigator.of(context).pushNamed(InstrumentSettings.routeName);
              },
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.all(5),
          //   child: ListTile(
          //     trailing: Padding(
          //       padding: const EdgeInsets.all(12.0),
          //       child: Icon(Icons.arrow_forward_ios_rounded),
          //     ),
          //     title: Text(
          //       "Favorite Artists",
          //       style: TextStyle(
          //         fontSize: 18,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //     subtitle: Text("Change your favorite artists"),
          //     onTap: () {
          //       Navigator.of(context).pushNamed(ArtistSettings.routeName);
          //     },
          //   ),
          // ),
          Container(
            padding: const EdgeInsets.all(5),
            child: SwitchListTile(
              value: _notifications == null ? false : _notifications,
              title: Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text("Toggle notification status"),
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                });
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child: SwitchListTile(
              value: _darkMode == null ? false : _darkMode,
              title: Text(
                "Dark Theme",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text("Toggle dark theme"),
              onChanged: (value) {
                Provider.of<Settings>(context, listen: false).switchTheme();
                setState(() {
                  _darkMode = value;
                });
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(5.0),
          //   child: ListTile(
          //     title: Row(
          //       children: [
          //         Text(
          //           'Range:  ',
          //           style: TextStyle(
          //             fontSize: 18,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //         Text(
          //           _rangeValue == null
          //               ? ''
          //               : _rangeValue.toInt().toString() + ' km',
          //           style: TextStyle(
          //             fontSize: 18,
          //             fontWeight: FontWeight.w300,
          //           ),
          //         ),
          //       ],
          //     ),
          //     subtitle: Text("How many km around do you want us to search?"),
          //   ),
          // ),
          // Padding(
          //   padding: EdgeInsets.only(bottom: 15),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Expanded(
          //         child: SliderTheme(
          //           data: SliderTheme.of(context).copyWith(
          //             trackHeight: 2.0,
          //           ),
          //           child: Slider(
          //             min: 0,
          //             max: 100,
          //             value: _rangeValue == null ? 0 : _rangeValue,
          //             onChanged: (value) {
          //               setState(() {
          //                 _rangeValue = value;
          //               });
          //             },
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(5),
              child: ListTile(
                trailing: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(Icons.logout),
                ),
                title: Text(
                  "Log out",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/');
                  Provider.of<Auth>(context, listen: false).logout();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
