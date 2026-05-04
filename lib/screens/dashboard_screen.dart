import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../widgets/event_card.dart';
import '../widgets/theme_toggle_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    final events = await _eventService.fetchAvailableEvents();

    if (mounted) {
      setState(() {
        _events = events;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool modoEscuro = Theme.of(context).brightness == Brightness.dark;

    final bgGradient = modoEscuro 
        ? const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFF020304), Color(0xFF0D0F11), Color(0xFF242830)],
          )
        : const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFFC8BFB0), Color(0xFFE2D9CC), Color(0xFFF5F0E8)],
          );

    final corTextoPrincipal = modoEscuro ? const Color(0xFFF0F2F5) : const Color(0xFF1A1C1E);
    final corTextoSecundario = modoEscuro ? const Color(0xFF9BA1A6) : const Color(0xFF44474A);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Eventos Disponíveis',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: corTextoPrincipal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Inscreva-se nos próximos eventos.',
                            style: TextStyle(
                              fontSize: 14,
                              color: corTextoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const ThemeToggleButton(),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Color(0xFFC4982A)),
                            const SizedBox(height: 16),
                            Text(
                              'Buscando dados...',
                              style: TextStyle(color: corTextoSecundario),
                            ),
                          ],
                        ),
                      )
                    : _events.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: modoEscuro ? const Color(0xFF16191C).withOpacity(0.5) : const Color(0xFFF2EDE4).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: (modoEscuro ? const Color(0xFF2A2D31) : const Color(0xFFD9D3C8)),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'NENHUM EVENTO ENCONTRADO',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: corTextoSecundario,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: _fetchEvents,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: corTextoPrincipal,
                                        foregroundColor: modoEscuro ? const Color(0xFF0D0F11) : const Color(0xFFE2D9CC),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      child: const Text('SINCRONIZAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.0)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            itemCount: _events.length,
                            itemBuilder: (context, index) {
                              final event = _events[index];
                              return EventCard(
                                event: event,
                                onTapDetails: () {
                                  // Open details
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
