import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/http_exception.dart';
import '../consts.dart' as constants;

const urlStart = constants.url;

class Auth with ChangeNotifier {
  String _token;
  String _expiration;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return _token != null ? true : false;
  }

  String get token {
    return _token;
  }

  String get userId {
    return _userId;
  }

  Future<void> signup(
      String name, String surname, String email, String password) async {
    final url = urlStart + 'UserRegistration.php/';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-type': 'application/json'},
        body: json.encode(
          {
            'Name': name,
            'Surname': surname,
            'Email': email,
            'Password': password,
            'returnSecureToken': true,
          },
        ),
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

  Future<void> login(String email, String password) async {
    final url = urlStart + 'UserLogin.php/';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'Email': email,
            'Password': password,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']);
      }
      _token = responseData['token'];
      _expiration = responseData['expiration'];

      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'expiration': _expiration,
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    //await prefs.remove('userData');
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiration']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _expiration = extractedUserData['expiration'];

    notifyListeners();

    return true;
  }

  Future<void> logout() async {
    final url = urlStart + 'UserLogout.php/';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {},
        ),
        headers: {
          HttpHeaders.authorizationHeader: _token,
        },
      );
      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']);
      } else {}

      notifyListeners();
    } catch (error) {
      throw error;
    }
    _token = null;
    _expiration = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
