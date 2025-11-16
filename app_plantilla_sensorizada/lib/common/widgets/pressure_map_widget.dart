import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class PressureMapWidget extends StatelessWidget {
  const PressureMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título con icono
          Row(
            children: [
              Icon(
                Symbols.footprint,
                color: cs.primary,
                size: 26,
              ),
              const SizedBox(width: 8),
              Text(
                'Mapa de presión',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Imagen adaptativa con aspecto profesional
          AspectRatio(
            aspectRatio: 1.8, // Ajusta si tu imagen es más ancha o más alta
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/illustrations/pressure_map_placeholder.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
