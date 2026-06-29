import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço responsável pela autenticação do usuário.
/// Comunica-se com os endpoints de autenticação (login, cadastro e logout) da API Laravel.
class AuthService {
  /// A URL base para a API V1. Por padrão aponta para o localhost.
  final String urlBase;

  AuthService({this.urlBase = 'http://127.0.0.1:8000/api/v1'});

  /// Realiza o login do usuário com CPF e senha.
  /// Se [remember] for true, poderia indicar ao backend para gerar um token de longa duração (se implementado).
  /// Retorna um Map com a chave 'success' indicando o sucesso da operação,
  /// e o 'data' ou 'message' dependendo do resultado.
  Future<Map<String, dynamic>> login(
    String cpf,
    String password, {
    bool remember = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$urlBase/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'cpf': cpf.replaceAll(RegExp(r'\D'), ''),
          'password': password,
          'remember': remember,
        }),
      );

      debugPrint('[AuthService] Login status: ${response.statusCode}');
      debugPrint('[AuthService] Login body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'] ?? data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        if (token != null) {
          await prefs.setString('auth_token', token.toString());
        }
        if (data['data'] != null) {
          final userData = data['data'];
          await prefs.setString('user_data', jsonEncode(userData));
          debugPrint('[AuthService] Saved user_data: ${jsonEncode(userData)}');
        }
        return {'success': true, 'data': data};
      } else {
        String message = data['message'] ?? 'CPF ou senha incorretos.';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          message = (errors.values.first as List).first.toString();
        }
        return {'success': false, 'message': message};
      }
    } catch (e) {
      debugPrint('[AuthService] Erro CRÍTICO de conexão: $e');
      return {
        'success': false,
        'message':
            'Sem conexão com o servidor. Verifique se o backend está rodando.',
      };
    }
  }

  /// Cadastra um novo usuário no sistema.
  /// O [payload] deve conter as informações necessárias para o cadastro (nome, email, cpf, senha, etc).
  /// Retorna um Map com o resultado da operação, em caso de erro, a primeira mensagem de validação é retornada em 'message'.
  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    try {
      debugPrint('[AuthService] Register payload: ${jsonEncode(payload)}');
      final response = await http.post(
        Uri.parse('$urlBase/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint('[AuthService] Register status: ${response.statusCode}');
      debugPrint('[AuthService] Register body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        String message = data['message'] ?? 'Erro ao realizar cadastro.';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          message = (errors.values.first as List).first.toString();
        }
        return {'success': false, 'message': message};
      }
    } catch (e) {
      debugPrint('[AuthService] Erro de conexão: $e');
      return {'success': false, 'message': 'Erro de conexão com o servidor.'};
    }
  }

  /// Sair – limpa os tokens armazenados
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
}
