import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthProvider with ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  void setAccessToken(String token, refreshToken) {
    _accessToken = token;
    notifyListeners();
  }

  void setTokens(String access, String refresh) {
    _accessToken = access;
    _refreshToken = refresh;
    notifyListeners();
  }

  void clearToken() {
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }

  bool get isTokenValid =>
      _accessToken != null && !JwtDecoder.isExpired(_accessToken!);

  void logout(BuildContext context) {
    _accessToken = null;
    notifyListeners();
    Navigator.pushReplacementNamed(context, 'login');
  }

}