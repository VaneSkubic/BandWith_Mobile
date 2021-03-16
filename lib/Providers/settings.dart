import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';

const urlStart = 'http://192.168.1.101/Server/API/';

class Settings with ChangeNotifier {
  dynamic _theme = false;
  dynamic userSettings;
  dynamic _userInstruments;

  bool _isOpening = true;

  bool get isOpening {
    return _isOpening;
  }

  dynamic get userInstruments {
    return _userInstruments;
  }

  void changeIsOpening() {
    _isOpening = !_isOpening;
  }

  String name;
  String surname;
  String email;
  String profileImage;
  String audio;
  String uiColor;
  String notifications;
  String radius;
  String audioTitle;

  Future<void> getSettings(String token) async {
    final url = urlStart + 'GetSettings.php';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: token,
        },
      );
      final responseData = jsonDecode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']);
      }

      final userSettings = json.encode(
        {
          'Name': responseData['data']['Name'],
          'Surname': responseData['data']['Surname'],
          'Email': responseData['data']['Email'],
          'ProfileImage': responseData['data']['ProfileImage'],
          'UIColor': responseData['data']['UIColor'],
          'Notifications': responseData['data']['Notifications'],
          'Radius': responseData['data']['Radius'],
          'AudioTitle': responseData['data']['AudioTitle'],
          //'Audio': responseData['data']['Audio'],
        },
      );

      name = responseData['data']['Name'];
      surname = responseData['data']['Surname'];
      email = responseData['data']['Email'];
      profileImage = responseData['data']['ProfileImage'];
      uiColor = responseData['data']['UIColor'];
      notifications = responseData['data']['Notifications'];
      radius = responseData['data']['Radius'];
      audioTitle = responseData['data']['AudioTitle'];
      audio = responseData['data']['Audio'];

      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userSettings', userSettings);
    } catch (error) {
      throw error;
    }
  }

  Future<void> getInstruments(String token) async {
    final url = urlStart + 'GetInstruments.php/';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: token,
        },
      );
      final responseData = jsonDecode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']);
      }

      _userInstruments = responseData['data'];

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateInstruments(String token, dynamic data) async {
    final url = urlStart + 'UpdateInstruments.php/';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(data),
        headers: {
          HttpHeaders.authorizationHeader: token,
        },
      );
      final responseData = jsonDecode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']);
      }

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> postSettings(String token, bool notifications, bool theme,
      double range, PickedFile image, PickedFile audio) async {
    final url = urlStart + 'UpdateSettings.php/';

    final encodedImage =
        image != null ? base64Encode(File(image.path).readAsBytesSync()) : null;
    final encodedAudio =
        audio != null ? base64Encode(File(audio.path).readAsBytesSync()) : null;
    final audioTitle = audio != null ? audio.path.split('/').last : null;

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'Radius': range,
            'UIColor': theme.toString(),
            'Notifications': notifications.toString(),
            'Image': encodedImage,
            'Audio': encodedAudio,
            'AudioTitle': audioTitle,
          },
        ),
        headers: {
          'authorization': token,
        },
      );
      final responseData = jsonDecode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']);
      }

      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userSettings', userSettings);
    } catch (error) {
      throw error;
    }
  }

  dynamic fetchSettings() {
    Map result = {
      'Name': name,
      'Surname': surname,
      'Email': email,
      'ProfileImage': profileImage,
      'UIColor': uiColor,
      'Notifications': notifications,
      'Radius': radius,
      'AudioTitle': audioTitle,
      //'Audio': audio,
    };
    return result;
  }

  // Future<void> getThemeValue() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (!prefs.containsKey('userSettings')) {
  //     return false;
  //   } else {
  //     final extractedUserSettings =
  //         json.decode(prefs.getString('userSettings')) as Map<String, Object>;
  //     _theme = extractedUserSettings['UIColor'];
  //     return _theme;
  //   }
  // }

  bool get theme {
    if (uiColor != null && uiColor == 'true') {
      _theme = true;
    }
    return _theme;
  }

  Future<void> switchTheme() async {
    _theme = !_theme;
    notifyListeners();
  }
}
