import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/event.dart';

class EventService {
  final String urlBase;

  EventService({this.urlBase = 'http://127.0.0.1:8000/api/v1'});

  Future<List<Event>> fetchAvailableEvents() async {
    try {
      final resposta = await http.get(
        Uri.parse('$urlBase/events?available=true'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
