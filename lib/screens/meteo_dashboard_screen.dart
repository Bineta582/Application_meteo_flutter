import 'package:flutter/material.dart';
import 'package:meteo_app/models/meteo_data.dart';
import 'package:meteo_app/providers/meteo_provider.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/meteo_provider.dart';
import '../models/meteo_data.dart';
import 'city_detail_screen.dart';
import 'loading_screen.dart';

class MeteoDashboardScreen extends StatefulWidget {
  const MeteoDashboardScreen({super.key});

  @override
  State<MeteoDashboardScreen> createState() => _WeatherDashboardScreenState();
}

class _WeatherDashboardScreenState extends State<MeteoDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final weatherProvider = context.watch<MeteoProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, themeProvider),
                Expanded(
                  child: _buildContent(
                      context, weatherProvider.weatherList, isDark),
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF0A1628), const Color(0xFF0D1F35)]
              : [const Color(0xFFE3F2FD), const Color(0xFFF5F9FF)],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<MeteoProvider>().reset();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tableau de bord',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0D2137),
                  ),
                ),
                Text(
                  '5 villes — Données en direct',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: themeProvider.toggleTheme,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                color: isDark
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

  Widget _buildContent(
      BuildContext context, List<MeteoData> weatherList, bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // En-tête avec widget météo principal (première ville)
        if (weatherList.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildFeaturedCity(context, weatherList[0], isDark),
          ),

        // Titre de la liste
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'Toutes les villes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0D2137),
              ),
            ),
          ),
        ),

        // Liste des villes
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              return AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  final delay = index * 0.1;
                  final animValue = Curves.easeOutCubic.transform(
                    (_entranceController.value - delay)
                        .clamp(0.0, 1.0)
                        .toDouble(),
                  );
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - animValue)),
                    child: Opacity(
                      opacity: animValue,
                      child: child,
                    ),
                  );
                },
                child: _WeatherCard(
                  weather: weatherList[index],
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CityDetailScreen(
                        weather: weatherList[index],
                      ),
                    ),
                  ),
                ),
              );
            },
            childCount: weatherList.length,
          ),
        ),

        // Bouton Recommencer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: _buildRestartButton(context, isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCity(
      BuildContext context, MeteoData weather, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CityDetailScreen(weather: weather)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0277BD), Color(0xFF0288D1), Color(0xFF26C6DA)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0288D1).withOpacity(0.35),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.cityName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      weather.country,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                Image.network(
                  weather.iconUrl,
                  width: 64,
                  height: 64,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.cloud_rounded,
                    color: Colors.white70,
                    size: 64,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather.temperature.toInt()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.w200,
                    height: 1,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'C',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 28,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
            Text(
              weather.description.toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _FeaturedStat(
                    icon: Icons.water_drop_rounded,
                    value: '${weather.humidity}%',
                    label: 'Humidité'),
                const SizedBox(width: 24),
                _FeaturedStat(
                    icon: Icons.air_rounded,
                    value: '${weather.windSpeed.toInt()} m/s',
                    label: 'Vent'),
                const SizedBox(width: 24),
                _FeaturedStat(
                    icon: Icons.thermostat_rounded,
                    value: '${weather.feelsLike.toInt()}°',
                    label: 'Ressenti'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestartButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        context.read<MeteoProvider>().reset();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => const LoadingScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white60 : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Recommencer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final MeteoData weather;
  final bool isDark;
  final VoidCallback onTap;

  const _WeatherCard({
    required this.weather,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2744) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône météo
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  weather.iconUrl,
                  width: 48,
                  height: 48,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.cloud_rounded,
                    color: isDark
                        ? const Color(0xFF4FC3F7)
                        : const Color(0xFF0288D1),
                    size: 32,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Infos ville
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.cityName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0D2137),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    weather.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _SmallStat(
                        icon: Icons.water_drop_rounded,
                        value: '${weather.humidity}%',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      _SmallStat(
                        icon: Icons.air_rounded,
                        value: '${weather.windSpeed.toInt()} m/s',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Température
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${weather.temperature.toInt()}°',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w200,
                    color: isDark ? Colors.white : const Color(0xFF0D2137),
                    height: 1,
                  ),
                ),
                Text(
                  '↑${weather.tempMax.toInt()}° ↓${weather.tempMin.toInt()}°',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isDark;

  const _SmallStat({
    required this.icon,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ],
    );
  }
}

class _FeaturedStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _FeaturedStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
