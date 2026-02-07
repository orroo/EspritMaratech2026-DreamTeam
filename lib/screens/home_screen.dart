import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F0F10) : const Color(0xFFF7F3E3);
    final card = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.08);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Running Club Tunis"),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notifications (UI only)")),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // HERO
          _HeroCard(
            imagePath: 'assets/images/marathon_1.jpg',
            title: "Plus qu’un club…\nune famille.",
            subtitle:
                "Au RCT, la passion c’est la course à pied et le sport en général.",
            isDark: isDark,
          ),

          const SizedBox(height: 14),

          // ABOUT (French text you provided, polished)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bienvenue au RCT",
                  style: TextStyle(
                    color: textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Bienvenue sur le blog officiel de l’association sportive « Running Club Tunis ». "
                  "Au RCT, la passion, c’est la course à pied et le sport en général. "
                  "Courir est un sport accessible à tous ! Quel que soit votre niveau, "
                  "si vous êtes motivés pour pratiquer ce sport passionnant aux bienfaits multiples, "
                  "rejoignez-nous pour des séances de coaching adaptées à votre niveau ou personnalisées.\n\n"
                  "Running Club Tunis… Plus qu’un club… une famille.",
                  style: TextStyle(
                    color: textSub,
                    height: 1.45,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // WHAT WE DO
          Text(
            "Nos activités",
            style: TextStyle(
              color: textMain,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),

          _ActivityGrid(isDark: isDark),

          const SizedBox(height: 14),

          // GALLERY
          Text(
            "Moments RCT",
            style: TextStyle(
              color: textMain,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _GalleryItem(path: 'assets/images/marathon_1.jpg'),
                _GalleryItem(path: 'assets/images/marathon_2.jpg'),
                _GalleryItem(path: 'assets/images/marathon_3.jpg'),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // CTA
            Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rejoindre une séance",
                  style: TextStyle(
                    color: textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Consulte les séances d'aujourd'hui et les événements de ton groupe.",
                  style: TextStyle(
                    color: textSub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final bool isDark;

  const _HeroCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            height: 210,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            height: 210,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.20),
                  Colors.black.withOpacity(0.70),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ActivityGrid extends StatelessWidget {
  final bool isDark;
  const _ActivityGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.08);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? Colors.white70 : Colors.black54;

    Widget tile(IconData icon, String t, String s) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.terracotta.withOpacity(isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: textMain),
            ),
            const SizedBox(height: 10),
            Text(
              t,
              style: TextStyle(
                color: textMain,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s,
              style: TextStyle(
                color: textSub,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.05,
      children: [
        tile(Icons.groups_2_outlined, "Groupes", "Plusieurs niveaux\npour tous."),
        tile(Icons.run_circle_outlined, "Coaching", "Séances adaptées\net progressives."),
        tile(Icons.event_available_outlined, "Événements", "Sorties longues\n+ courses officielles."),
        tile(Icons.favorite_border, "Santé", "Motivation, discipline\net bien-être."),
      ],
    );
  }
}

class _GalleryItem extends StatelessWidget {
  final String path;
  const _GalleryItem({required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.35),
            ],
          ),
        ),
      ),
    );
  }
}
