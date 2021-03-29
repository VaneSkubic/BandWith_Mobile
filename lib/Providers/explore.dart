import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../consts.dart' as constants;

const urlStart = constants.url;

class Explore with ChangeNotifier {
  dynamic _usersData = [];

  dynamic get usersData {
    return _usersData;
  }

  void toggleFavorite(int index) {
    _usersData[index]['favorite'] = !_usersData[index]['favorite'];
  }

  void removeUser(int index) {
    _usersData.removeAt(index);
  }

  Future<void> getUsers(String token, int count) async {
    final url = urlStart + 'ReadUserInfo.php/';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'Count': count,
          },
        ),
        headers: {
          HttpHeaders.authorizationHeader: token,
        },
      );
      final responseData = jsonDecode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']);
      }

      _usersData.addAll(responseData['data']);

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateLikes(
      String token, String name, String surname, bool status) async {
    final url = urlStart + 'UpdateLikes.php/';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            "Name": name,
            "Surname": surname,
            "Status": status,
          },
        ),
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
}
