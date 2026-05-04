import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTapDetails;

  const EventCard({
    super.key,
    required this.event,
    required this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final bgSecondary = isDarkMode ? const Color(0xFF16191C) : const Color(0xFFF2EDE4);
    final borderUi = isDarkMode ? const Color(0xFF2A2D31) : const Color(0xFFD9D3C8);
    final textPrimary = isDarkMode ? const Color(0xFFF0F2F5) : const Color(0xFF1A1C1E);
    final brandColor = const Color(0xFFC4982A);
    final bgPrimary = isDarkMode ? const Color(0xFF0D0F11) : const Color(0xFFE2D9CC);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgSecondary,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderUi),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.name.isNotEmpty ? event.name : 'Evento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: brandColor.withOpacity(0.1),
                  border: Border.all(color: brandColor.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  event.isFestival ? 'FESTIVAL' : 'ACAMPAMENTO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: brandColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: borderUi)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CAMPANHA 2026',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: textPrimary.withOpacity(0.4),
                    letterSpacing: 1.5,
                  ),
                ),
                InkWell(
                  onTap: onTapDetails,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: textPrimary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'VER DETALHES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: bgPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
