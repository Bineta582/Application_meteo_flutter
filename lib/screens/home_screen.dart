import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'loading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient animé
          _buildBackground(isDark),
          // Particules décoratives
          _buildParticles(isDark),
          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Barre du haut
                _buildTopBar(context, themeProvider),
                // Contenu centré
                Expanded(child: _buildMainContent(context, isDark)),
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
            const Color(0xFF0A1628),
          ]
              : [
            const Color(0xFFB3E5FC),
            const Color(0xFFE3F2FD),
            const Color(0xFFB3E5FC),
          ],
        ),
      ),
    );
  }

  Widget _buildParticles(bool isDark) {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            progress: _rotateController.value,
            isDark: isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MetéoVision',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: themeProvider.isDarkMode
                      ? const Color(0xFF4FC3F7)
                      : const Color(0xFF0277BD),
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Météo Mondiale',
                style: TextStyle(
                  fontSize: 11,
                  color: themeProvider.isDarkMode
                      ? Colors.white38
                      : Colors.black38,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: themeProvider.toggleTheme,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.white10
                    : Colors.black.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? Colors.white12
                      : Colors.black12,
                ),
              ),
              child: Icon(
                themeProvider.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                color: themeProvider.isDarkMode
                    ? const Color(0xFFFFD54F)
                    : const Color(0xFF5C6BC0),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Globe animé
          AnimatedBuilder(
            animation: Listenable.merge([_floatController, _pulseController]),
            builder: (context, child) {
              final floatOffset = math.sin(_floatController.value * math.pi) * 12;
              return Transform.translate(
                offset: Offset(0, floatOffset),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Anneau externe
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, _) => Transform.rotate(
                        angle: _rotateController.value * 2 * math.pi,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (isDark
                                  ? const Color(0xFF4FC3F7)
                                  : const Color(0xFF0288D1))
                                  .withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Halo pulsé
                    Transform.scale(
                      scale: 0.85 + _pulseController.value * 0.1,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark
                              ? const Color(0xFF4FC3F7)
                              : const Color(0xFF0288D1))
                              .withOpacity(0.06),
                        ),
                      ),
                    ),
                    // Icône météo principale
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: isDark
                              ? [
                            const Color(0xFF1A3A5C),
                            const Color(0xFF0D2137),
                          ]
                              : [
                            Colors.white,
                            const Color(0xFFE3F2FD),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark
                                ? const Color(0xFF4FC3F7)
                                : const Color(0xFF0288D1))
                                .withOpacity(0.25),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.wb_cloudy_rounded,
                        size: 70,
                        color: isDark
                            ? const Color(0xFF4FC3F7)
                            : const Color(0xFF0288D1),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 50),

          // Titre
          Text(
            'Bienvenue sur\nMétéoFlow 🌤',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0D2137),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 16),

          // Sous-titre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Découvrez la météo en temps réel\npour 5 villes du monde entier',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 60),

          // Bouton principal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _AnimatedButton(
              onTap: () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) => const LoadingScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              ),
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 24),

          // Villes disponibles
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: ['🇸🇳 Dakar', '🇫🇷 Paris', '🇺🇸 New York', '🇯🇵 Tokyo', '🇦🇪 Dubai']
                .map((city) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: Text(
                city,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _AnimatedButton({required this.onTap, required this.isDark});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDark
                  ? [const Color(0xFF0288D1), const Color(0xFF4FC3F7)]
                  : [const Color(0xFF0277BD), const Color(0xFF0288D1)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0288D1).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lancer l\'expérience',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  ParticlePainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = (isDark ? const Color(0xFF4FC3F7) : const Color(0xFF0288D1))
          .withOpacity(0.08);

    final positions = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.2),
      Offset(size.width * 0.05, size.height * 0.7),
      Offset(size.width * 0.9, size.height * 0.65),
      Offset(size.width * 0.15, size.height * 0.9),
      Offset(size.width * 0.75, size.height * 0.85),
    ];

    for (int i = 0; i < positions.length; i++) {
      final offset = math.sin(progress * 2 * math.pi + i * 1.0) * 20;
      final x = positions[i].dx + math.cos(i * 0.8) * offset;
      final y = positions[i].dy + math.sin(i * 0.6) * offset;
      canvas.drawCircle(Offset(x, y), 30 + i * 8.0, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
