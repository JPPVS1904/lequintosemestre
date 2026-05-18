import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class EventService {
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

  // Busca eventos
  Future<List<Event>> fetchEvents({bool isAdmin = false}) async {
    try {
      final headers = await _authHeaders();
      final endpoint = isAdmin
          ? '$urlBase/events'
          : '$urlBase/events?available=true';

      debugPrint('[EventService] Fetching events from: $endpoint');
      final response = await http.get(Uri.parse(endpoint), headers: headers);

      debugPrint('[EventService] Events status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> eventsJson = data['data'] ?? [];
        debugPrint('[EventService] Events loaded: ${eventsJson.length}');
        return eventsJson.map((json) => Event.fromJson(json)).toList();
      } else {
        debugPrint('[EventService] Erro ao buscar eventos: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('[EventService] Erro de conexão eventos: $e');
      return [];
    }
  }

  // Busca inscrições do usuário
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
          (data['data'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
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

  // Inscreve em um evento
  Future<Map<String, dynamic>> subscribe(int eventId, int userId, {String subscriptionType = 'Campista'}) async {
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
        return {'success': false, 'message': data['message'] ?? 'Erro ao cancelar.'};
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

  // Cria um evento do tipo Acampamento (POST /v1/campings)
  Future<Map<String, dynamic>> createCamping(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$urlBase/campings'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Erro ao criar acampamento.'};
    } catch (e) {
      return {'success': false, 'message': 'Sem conexão com o servidor.'};
    }
  }

  /// Cria um evento do tipo Festival (POST /v1/festivals)
  Future<Map<String, dynamic>> createFestival(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$urlBase/festivals'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Erro ao criar festival.'};
    } catch (e) {
      return {'success': false, 'message': 'Sem conexão com o servidor.'};
    }
  }

  /// Cria um Evento (POST /v1/events)
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$urlBase/events'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      }
      String message = data['message'] ?? 'Erro ao criar evento.';
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        message = (errors.values.first as List).first.toString();
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Sem conexão com o servidor.'};
    }
  }
}
