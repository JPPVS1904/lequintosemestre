import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String urlBase;

  // ip da máquina onde está rodando o laravel
  AuthService({this.urlBase = 'http://127.0.0.1:8000/api/v1'});

  Future<bool> login(String email, String password) async {
    try {
      final resposta = await http.post(
        Uri.parse('$urlBase/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        final token = dados['token'] ?? dados['access_token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token.toString());
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Erro CRÍTICO de conexão: $e');
      throw Exception('Erro de conexão. Verifique se a API do Laravel está rodando.');
    }
  }
}
