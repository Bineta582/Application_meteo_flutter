import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:meteo_app/providers/meteo_provider.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'meteo_dashboard_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeteoProvider>().loadWeather();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final weatherProvider = context.watch<MeteoProvider>();
    final isDark = themeProvider.isDarkMode;

    // Navigation automatique quand c'est chargé
    if (weatherProvider.state == WeatherState.success &&
        weatherProvider.weatherList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) =>
              const MeteoDashboardScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: weatherProvider.state == WeatherState.error
                      ? _buildErrorWidget(context, weatherProvider, isDark)
                      : _buildLoadingContent(
                      context, weatherProvider, isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            const Color(0xFF0A1628),
            const Color(0xFF0D2137),
            const Color(0xFF071020),
          ]
              : [
            const Color(0xFFE3F2FD),
            const Color(0xFFBBDEFB),
            const Color(0xFFE3F2FD),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Chargement météo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0D2137),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent(
      BuildContext context, MeteoProvider provider, bool isDark) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Jauge circulaire animée
            _buildCircularGauge(provider, isDark),
            const SizedBox(height: 40),
            // Villes en cours de chargement
            _buildCitiesProgress(provider, isDark),
            const SizedBox(height: 30),
            // Message dynamique
            _buildLoadingMessage(provider, isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularGauge(MeteoProvider provider, bool isDark) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Halo lumineux
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FC3F7).withOpacity(
                        0.1 + _glowController.value * 0.15),
                    blurRadius: 40 + _glowController.value * 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),

            // Arc de progression
            SizedBox(
              width: 220,
              height: 220,
              child: AnimatedBuilder(
                animation: _rotateController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: GaugePainter(
                      progress: provider.progress,
                      rotateValue: _rotateController.value,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),

            // Contenu central
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(provider.progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0D2137),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '5 villes',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCitiesProgress(MeteoProvider provider, bool isDark) {
    final cities = [
      {'name': 'Dakar', 'flag': '🇸🇳'},
      {'name': 'Paris', 'flag': '🇫🇷'},
      {'name': 'New York', 'flag': '🇺🇸'},
      {'name': 'Tokyo', 'flag': '🇯🇵'},
      {'name': 'Dubai', 'flag': '🇦🇪'},
    ];

    return Column(
      children: cities.asMap().entries.map((entry) {
        final i = entry.key;
        final city = entry.value;
        final cityProgress = (i + 1) / cities.length;
        final isDone = provider.progress >= cityProgress - 0.05;
        final isLoading = !isDone &&
            provider.progress >= cityProgress - 0.25 &&
            provider.state == WeatherState.loading;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(city['flag']!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  city['name']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                    isDone ? FontWeight.w600 : FontWeight.w400,
                    color: isDone
                        ? (isDark ? Colors.white : const Color(0xFF0D2137))
                        : (isDark ? Colors.white38 : Colors.black38),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isDone
                    ? const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF4CAF50), size: 18)
                    : isLoading
                    ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      isDark
                          ? const Color(0xFF4FC3F7)
                          : const Color(0xFF0288D1),
                    ),
                  ),
                )
                    : Icon(Icons.radio_button_unchecked_rounded,
                    color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                    size: 18),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingMessage(MeteoProvider provider, bool isDark) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(provider.loadingMessage),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_download_rounded,
              size: 16,
              color: isDark
                  ? const Color(0xFF4FC3F7)
                  : const Color(0xFF0288D1),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                provider.loadingMessage,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(
      BuildContext context, MeteoProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 60,
              color: Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Oups ! Une erreur est survenue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0D2137),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            provider.errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => provider.loadWeather(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Réessayer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0288D1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double progress;
  final double rotateValue;
  final bool isDark;

  GaugePainter({
    required this.progress,
    required this.rotateValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 12.0;

    // Fond de la jauge
    final bgPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      bgPaint,
    );

    // Arc de progression
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + (2 * math.pi * progress),
          colors: [
            const Color(0xFF0288D1),
            const Color(0xFF4FC3F7),
            const Color(0xFF81D4FA),
          ],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );

      // Point brillant à la tête de la jauge
      if (progress > 0.02) {
        final angle = -math.pi / 2 + 2 * math.pi * progress;
        final dotX = center.dx + radius * math.cos(angle);
        final dotY = center.dy + radius * math.sin(angle);
        final dotPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) =>
      oldDelegate.progress != progress ||
          oldDelegate.rotateValue != rotateValue;
}
