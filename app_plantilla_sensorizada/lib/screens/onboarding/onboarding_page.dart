import 'package:flutter/material.dart';
import '../../common/widgets/primary_button.dart';
import 'widgets/onboarding_content.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/illustrations/connected_world.svg",
      "title": "Conecta tus plantillas",
      "description":
      "Empareja tus plantillas sensorizadas y empieza a registrar tu forma de caminar de manera sencilla.",
    },
    {
      "image": "assets/illustrations/undraw_app-benchmarks_ls0m.svg",
      "title": "Observa tu pisada",
      "description":
      "Consulta en tiempo real la presión de cada paso y conoce cómo se reparte tu apoyo al caminar.",
    },
    {
      "image": "assets/illustrations/heart.svg",
      "title": "Detecta posibles anomalías",
      "description":
      "Recibe una estimación del riesgo de sufrir una patología relacionada con la marcha, basada en tus hábitos diarios.",
    },
  ];


  void _nextPage() {
    if (_currentPage == onboardingData.length - 1) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 4,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: onboardingData.length,
                    onPageChanged: (value) {
                      setState(() => _currentPage = value);
                    },
                    itemBuilder: (context, index) => OnboardingContent(
                      image: onboardingData[index]["image"]!,
                      title: onboardingData[index]["title"]!,
                      description: onboardingData[index]["description"]!,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: "Atrás",
                          onPressed: _previousPage,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: _currentPage == onboardingData.length - 1
                              ? "Comenzar"
                              : "Siguiente",
                          onPressed: _nextPage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// Skip button (top-right)
            Positioned(
              top: 12,
              right: 16,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  "Saltar",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
