import 'package:flutter/material.dart';

class ArtistSettings extends StatefulWidget {
  static const routeName = '/artistSettings';

  @override
  _ArtistSettingsState createState() => _ArtistSettingsState();
}

class _ArtistSettingsState extends State<ArtistSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Artist'),
        backgroundColor: Color.fromRGBO(52, 174, 255, 1).withOpacity(1),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Back'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
