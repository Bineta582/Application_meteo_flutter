import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meteo_app/models/meteo_data.dart';
import 'package:provider/provider.dart';
import '../models/meteo_data.dart';
import '../providers/theme_provider.dart';

// ────────────────────────────────
// Widgets helpers pour la page détail
// ────────────────────────────────
class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2));
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isDark;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: isDark ? Colors.white38 : Colors.black38),
        const SizedBox(width: 4),
        Text(value,
            style: TextStyle(
                fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
      ],
    );
  }
}

class _MapTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _MapTypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0288D1)
              : (isDark
              ? const Color(0xFF1A2744).withOpacity(0.92)
              : Colors.white.withOpacity(0.92)),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : Colors.black54)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black54))),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────
// Écran Détail de la ville
// ────────────────────────────────
class CityDetailScreen extends StatefulWidget {
  final MeteoData weather;

  const CityDetailScreen({super.key, required this.weather});

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _openFullScreenMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenMapScreen(weather: widget.weather),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final weather = widget.weather;

    return Scaffold(
      body: Stack(
        children: [
          // Fond dégradé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0A1628), const Color(0xFF0D2137)]
                    : [const Color(0xFFE3F2FD), const Color(0xFFF5F9FF)],
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildAppBar(context, isDark)),
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Opacity(
                      opacity: _controller.value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - _controller.value)),
                        child: child,
                      ),
                    ),
                    child: _buildHeroCard(weather, isDark),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Détails atmosphériques',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0D2137),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildStatsGrid(weather, isDark)),
                SliverToBoxAdapter(child: _buildSunCard(weather, isDark)),
                SliverToBoxAdapter(child: _buildInlineMap(weather, isDark)),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── Widgets internes ────────────────
  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            widget.weather.cityName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0D2137),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(MeteoData weather, bool isDark) {
    return Container(
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
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(weather.cityName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  Text(
                      '${weather.country} · ${weather.latitude.toStringAsFixed(2)}°N, ${weather.longitude.toStringAsFixed(2)}°E',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Image.network(weather.iconUrl,
                  width: 80,
                  height: 80,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.wb_cloudy_rounded,
                    color: Colors.white70,
                    size: 80,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${weather.temperature.toInt()}°C',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 68,
                      fontWeight: FontWeight.w200,
                      height: 1)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(weather.description.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HeroStat(
                    icon: Icons.thermostat_rounded,
                    value: '${weather.feelsLike.toInt()}°',
                    label: 'Ressenti'),
                _Divider(),
                _HeroStat(
                    icon: Icons.arrow_upward_rounded,
                    value: '${weather.tempMax.toInt()}°',
                    label: 'Max'),
                _Divider(),
                _HeroStat(
                    icon: Icons.arrow_downward_rounded,
                    value: '${weather.tempMin.toInt()}°',
                    label: 'Min'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(MeteoData weather, bool isDark) {
    final stats = [
      {
        'icon': Icons.water_drop_rounded,
        'value': '${weather.humidity}%',
        'label': 'Humidité',
        'color': const Color(0xFF4FC3F7)
      },
      {
        'icon': Icons.air_rounded,
        'value': '${weather.windSpeed.toStringAsFixed(1)} m/s',
        'label': 'Vent (${weather.windDirection})',
        'color': const Color(0xFF81D4FA)
      },
      {
        'icon': Icons.compress_rounded,
        'value': '${weather.pressure} hPa',
        'label': 'Pression',
        'color': const Color(0xFF80CBC4)
      },
      {
        'icon': Icons.visibility_rounded,
        'value': '${(weather.visibility / 1000).toStringAsFixed(1)} km',
        'label': 'Visibilité',
        'color': const Color(0xFFFFD54F)
      },
      {
        'icon': Icons.cloud_rounded,
        'value': '${weather.clouds}%',
        'label': 'Nuages',
        'color': const Color(0xFFCE93D8)
      },
      {
        'icon': Icons.location_on_rounded,
        'value':
        '${weather.latitude.toStringAsFixed(1)}°, ${weather.longitude.toStringAsFixed(1)}°',
        'label': 'Coordonnées',
        'color': const Color(0xFFF48FB1)
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2744) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(stat['icon'] as IconData,
                    color: stat['color'] as Color, size: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stat['value'] as String,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0D2137))),
                    Text(stat['label'] as String,
                        style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSunCard(MeteoData weather, bool isDark) {
    String formatTime(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2744) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.wb_twilight_rounded,
                    color: Color(0xFFFFB300), size: 28),
                const SizedBox(height: 8),
                Text(formatTime(weather.sunrise),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0D2137))),
                Text('Lever du soleil',
                    style: TextStyle(
                        fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
              ],
            ),
          ),
          Container(width: 1, height: 60, color: isDark ? Colors.white12 : Colors.black12),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.nightlight_round,
                    color: Color(0xFF5C6BC0), size: 28),
                const SizedBox(height: 8),
                Text(formatTime(weather.sunset),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0D2137))),
                Text('Coucher du soleil',
                    style: TextStyle(
                        fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineMap(MeteoData weather, bool isDark) {
    final cityPos = LatLng(weather.latitude, weather.longitude);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Localisation 🗺️',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0D2137))),
                GestureDetector(
                  onTap: _openFullScreenMap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0288D1).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF0288D1).withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.fullscreen_rounded,
                            size: 14, color: Color(0xFF4FC3F7)),
                        SizedBox(width: 4),
                        Text('Plein écran',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4FC3F7),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 220,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: cityPos, zoom: 11),
                onMapCreated: (controller) => _mapController = controller,
                markers: {
                  Marker(
                      markerId: const MarkerId('cityMarker'),
                      position: cityPos,
                      infoWindow: InfoWindow(title: weather.cityName))
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────
// Écran Carte Plein écran
// ────────────────────────────────
class _FullScreenMapScreen extends StatelessWidget {
  final MeteoData weather;

  const _FullScreenMapScreen({required this.weather});

  @override
  Widget build(BuildContext context) {
    final cityPos = LatLng(weather.latitude, weather.longitude);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: cityPos, zoom: 12),
            markers: {
              Marker(
                  markerId: const MarkerId('cityMarker'),
                  position: cityPos,
                  infoWindow: InfoWindow(title: weather.cityName))
            },
            zoomControlsEnabled: true,
            myLocationButtonEnabled: true,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}