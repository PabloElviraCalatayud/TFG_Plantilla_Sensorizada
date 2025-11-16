import 'package:flutter/material.dart';
import 'widgets/recommendation_card.dart';

class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final List<Map<String, String>> recommendations = [
      {
        "image": "assets/recommendations/stretching.png",
        "title": "Estiramientos diarios",
        "description":
        "Dedica 5 minutos a estirar tobillos y gemelos para mejorar la movilidad y reducir tensiones."
      },
      {
        "image": "assets/recommendations/posture.png",
        "title": "Revisa tu postura al caminar",
        "description":
        "Mantén la mirada al frente y reparte el peso hacia la zona media del pie."
      },
      {
        "image": "assets/recommendations/footwear.png",
        "title": "Usa un calzado adecuado",
        "description":
        "Elige un calzado amortiguado que reduzca impactos y mejore la distribución de presión."
      },
      {
        "image": "assets/recommendations/warmup.png",
        "title": "Activa tus pies",
        "description":
        "Antes de caminar distancias largas, realiza pequeños ejercicios de movilidad para preparar la pisada."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recomendaciones"),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: recommendations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return RecommendationCard(
            imagePath: recommendations[index]["image"]!,
            title: recommendations[index]["title"]!,
            description: recommendations[index]["description"]!,
          );
        },
      ),
    );
  }
}
