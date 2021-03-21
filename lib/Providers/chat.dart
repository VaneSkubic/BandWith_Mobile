import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../consts.dart' as constants;

const urlStart = constants.url;

class Chat with ChangeNotifier {
  dynamic _userFavorites = [];
  dynamic _userConversations = [];
  dynamic _userMessages = [];

  dynamic get userFavorites {
    return _userFavorites;
  }

  dynamic get userConversations {
    return _userConversations;
  }

  dynamic get userMessages {
    return _userMessages;
  }

  void resetUserMessages() {
    _userMessages = [];
  }

  Future<void> getFavorites(String token) async {
    final url = urlStart + 'GetFavorites.php/';
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

      _userFavorites = responseData['data'];

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> getConversations(String token) async {
    final url = urlStart + 'GetConversations.php/';
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

      _userConversations = responseData['data'];

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> newConversation(
      String token, String name, String surname) async {
    final url = urlStart + 'NewConversation.php/';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            "Name": name,
            "Surname": surname,
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

  Future<void> newMessage(
      String token, String content, String name, String surname) async {
    final url = urlStart + 'NewMessage.php/';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            "Content": content,
            "Name": name,
            "Surname": surname,
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

  Future<void> getMessages(String token, String name, String surname) async {
    final url = urlStart + 'GetMessages.php/';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            "Name": name,
            "Surname": surname,
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

      _userMessages = responseData['data'];

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
