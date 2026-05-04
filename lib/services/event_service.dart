import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class EventService {
  final String urlBase;

  EventService({this.urlBase = 'http://127.0.0.1:8000/api/v1'});

  Future<List<Event>> fetchAvailableEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final resposta = await http.get(
        Uri.parse('$urlBase/events?available=true'),
        headers: headers,
      );

      if (resposta.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(resposta.body);
        final List<dynamic> eventsJson = data['data'] ?? [];
        return eventsJson.map((json) => Event.fromJson(json)).toList();
      } else {
        debugPrint('Erro ao buscar eventos: ${resposta.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Erro CRÍTICO de conexão: $e');
      return [];
    }
  }
}
