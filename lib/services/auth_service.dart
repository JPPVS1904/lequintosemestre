import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class AuthService {
  final String urlBase;

  AuthService({this.urlBase = 'http://127.0.0.1:8000/api/v1'});

  Future<bool> login(String email, String password) async {
    debugPrint('--- INICIANDO REQUISIÇÃO DE LOGIN ---');
    debugPrint('URL: $urlBase/login');
    debugPrint('Dados enviados: Email: $email | Senha: [OCULTA]');

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

      debugPrint('Status Code recebido: ${resposta.statusCode}');
      debugPrint('Corpo da Resposta: ${resposta.body}');

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        debugPrint('Token recebido com sucesso: ${dados['token']}');
        return true;
      } else {
        debugPrint('Falha no login. Credenciais incorretas ou erro no backend.');
        return false;
      }
    } catch (e) {
      debugPrint('Erro CRÍTICO de conexão: $e');
      throw Exception('Erro de conexão. Verifique se a API do Laravel está rodando.');
    }
  }
}
