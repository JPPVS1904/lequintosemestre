import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

/// Serviço responsável pelas requisições relacionadas a eventos e inscrições.
/// Interage com a API V1 para listar atividades, buscar inscrições, enviar respostas de formulários e atualizar perfil.
class EventService {
  /// A URL base da API V1.
  final String urlBase;

  EventService({this.urlBase = 'http://127.0.0.1:8000/api/v1'});

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    debugPrint('[EventService] Token present: ${token != null}');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Busca as atividades disponíveis utilizando o endpoint `/v1/activities`.
  /// Retorna apenas atividades disponíveis (`available=true`).
  /// Retorna uma lista de objetos [Event]. Em caso de erro, retorna uma lista vazia.
  Future<List<Event>> fetchEvents() async {
    try {
      final headers = await _authHeaders();
      final endpoint = '$urlBase/activities?available=true';

      debugPrint('[EventService] Fetching activities from: $endpoint');
      final response = await http.get(Uri.parse(endpoint), headers: headers);

      debugPrint('[EventService] Activities status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> eventsJson = data['data'] ?? [];
        debugPrint('[EventService] Activities loaded: ${eventsJson.length}');
        return eventsJson.map((json) => Event.fromJson(json)).toList();
      } else {
        debugPrint(
          '[EventService] Erro ao buscar atividades: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('[EventService] Erro de conexão atividades: $e');
      return [];
    }
  }

  /// Busca todas as inscrições associadas a um [userId].
  /// Retorna uma lista de mapas com os dados brutos das inscrições do usuário logado.
  Future<List<Map<String, dynamic>>> fetchSubscriptions(int userId) async {
    try {
      final headers = await _authHeaders();
      final url = '$urlBase/subscriptions?user_id=$userId';
      debugPrint('[EventService] Fetching subscriptions from: $url');
      final response = await http.get(Uri.parse(url), headers: headers);

      debugPrint('[EventService] Subscriptions status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = List<Map<String, dynamic>>.from(
          (data['data'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ??
              [],
        );
        debugPrint('[EventService] Subscriptions loaded: ${list.length}');
        return list;
      }
      debugPrint('[EventService] Subscriptions error body: ${response.body}');
      return [];
    } catch (e) {
      debugPrint('[EventService] Erro ao buscar inscrições: $e');
      return [];
    }
  }

  // Busca detalhes de uma inscrição
  Future<Map<String, dynamic>?> fetchSubscriptionDetail(
    int subscriptionId,
  ) async {
    try {
      final headers = await _authHeaders();
      final url = '$urlBase/subscriptions/$subscriptionId';
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('[EventService] Erro ao buscar detalhes da inscrição: $e');
      return null;
    }
  }

  // Busca perguntas de uma categoria
  Future<List<Map<String, dynamic>>> fetchQuestions(int categoryId) async {
    try {
      final headers = await _authHeaders();
      final url = '$urlBase/questions?category_id=$categoryId';
      debugPrint('[EventService] Fetching questions from: $url');
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(
          (data['data'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ??
              [],
        );
      }
      return [];
    } catch (e) {
      debugPrint('[EventService] Erro ao buscar perguntas: $e');
      return [];
    }
  }

  // Envia respostas do questionário
  Future<Map<String, dynamic>> submitAnswers(
    int preRegistrationId,
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      final headers = await _authHeaders();
      final payload = {
        'pre_registration_id': preRegistrationId,
        'answers': answers,
      };

      final response = await http.post(
        Uri.parse('$urlBase/answers'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao enviar respostas.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Sem conexão com o servidor.'};
    }
  }

  // Inscreve em uma atividade
  Future<Map<String, dynamic>> subscribe(
    int eventId,
    int userId, {
    String subscriptionType = 'Campista',
    int? sectorId,
    int? sector2Id,
  }) async {
    try {
      final headers = await _authHeaders();
      final payload = {
        'subscription_date': DateTime.now().toIso8601String().split('T')[0],
        'subscription_type': subscriptionType,
        'was_selected': false,
        'substitute_position': 0,
        'paid_the_fee': false,
        'is_quitter': false,
        'payment_code': 'N/A',
        'qrcode_data': 'N/A',
        'used_qrcode': false,
        'selection_method_id': 1,
        'user_id': userId,
        'event_id': eventId,
        if (sectorId != null) 'sector_id': sectorId,
        if (sector2Id != null) 'sector2_id': sector2Id,
      };

      debugPrint('[EventService] Subscribing as $subscriptionType: $payload');
      final response = await http.post(
        Uri.parse('$urlBase/subscriptions'),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('[EventService] Subscribe status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        String message = data['message'] ?? 'Erro ao se inscrever.';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          message = (errors.values.first as List).first.toString();
        }
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Sem conexão com o servidor.'};
    }
  }

  // Cancela uma inscrição
  Future<Map<String, dynamic>> cancelSubscription(int subscriptionId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$urlBase/subscriptions/$subscriptionId'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao cancelar.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Sem conexão com o servidor.'};
    }
  }

  // Atualiza o perfil do usuário
  Future<Map<String, dynamic>> updateProfile(
    int userId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final headers = await _authHeaders();
      final response = await http.put(
        Uri.parse('$urlBase/users/$userId'),
        headers: headers,
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        String message = data['message'] ?? 'Erro ao atualizar perfil.';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          message = (errors.values.first as List).first.toString();
        }
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Sem conexão com o servidor.'};
    }
  }

  // INBOX
  Future<List<dynamic>> fetchInboxMessages() async {
    try {
      final headers = await _authHeaders();
      final res = await http.get(
        Uri.parse('$urlBase/inbox-messages'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        return decoded['data'] ?? [];
      }
    } catch (e) {
      debugPrint('[EventService] Erro inbox: $e');
    }
    return [];
  }

  Future<bool> markInboxMessageAsRead(int id) async {
    try {
      final headers = await _authHeaders();
      final res = await http.put(
        Uri.parse('$urlBase/inbox-messages/$id/read'),
        headers: headers,
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[EventService] Erro read inbox: $e');
      return false;
    }
  }

  Future<bool> markAllInboxMessagesAsRead() async {
    try {
      final headers = await _authHeaders();
      final res = await http.put(
        Uri.parse('$urlBase/inbox-messages/read-all'),
        headers: headers,
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[EventService] Erro read all inbox: $e');
      return false;
    }
  }

  Future<bool> deleteInboxMessage(int id) async {
    try {
      final headers = await _authHeaders();
      final res = await http.delete(
        Uri.parse('$urlBase/inbox-messages/$id'),
        headers: headers,
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[EventService] Erro delete inbox: $e');
      return false;
    }
  }
}
