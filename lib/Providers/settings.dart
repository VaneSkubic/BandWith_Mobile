import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/http_exception.dart';
import '../consts.dart' as constants;
//import 'package:shared_preferences/shared_preferences.dart';

const urlStart = constants.url;

class Settings with ChangeNotifier {
  dynamic _theme = false;
  dynamic _userSettings;
  dynamic _userInstruments;

  bool _isOpening = true;

  bool get isOpening {
    return _isOpening;
  }

  dynamic get userInstruments {
    return _userInstruments;
  }

  dynamic get userSettings {
    return _userSettings;
  }

  void changeIsOpening() {
    _isOpening = !_isOpening;
  }

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

      _userSettings = responseData['data'];

      notifyListeners();
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
            'UIColor': theme.toString() == null ? 'false' : 'true',
            'Notifications':
                notifications.toString() == null ? 'false' : 'true',
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
    } catch (error) {
      throw error;
    }
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
    // if (uiColor != null && uiColor == 'true') {
    //   _theme = true;
    // }
    // return _theme;
    return false;
  }

  Future<void> switchTheme() async {
    _theme = !_theme;
    notifyListeners();
  }
}
