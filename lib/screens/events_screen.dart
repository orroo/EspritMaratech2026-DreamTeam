import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum EventKind { daily, weekly, special }

class RctEvent {
  final String id;
  final String title;
  final DateTime date;
  final String group; // ex: "B"
  final EventKind kind; // daily/weekly/special
  final String location;
  final String description;
  final List<String> participants;

  const RctEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.group,
    required this.kind,
    required this.location,
    required this.description,
    required this.participants,
  });
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  // UI-only mock events (replace later with Firebase)
  final List<RctEvent> _events = [
    RctEvent(
      id: "1",
      title: "big event",
      date: DateTime.now().add(const Duration(hours: 2)),
      group: "B",
      kind: EventKind.daily,
      location: "cook town",
      description: "events YAAAAAY",
      participants: const ["Amine", "Sonia", "Karim", "Yassine", "Meriem"],
    ),
    RctEvent(
      id: "2",
      title: "Long Run (Weekend)",
      date: DateTime.now().add(const Duration(days: 1, hours: 1)),
      group: "A",
      kind: EventKind.weekly,
      location: "Belvédère Park",
      description: "Easy pace + hydration stops.",
      participants: const ["Fares", "Montassar"],
    ),
    RctEvent(
      id: "3",
      title: "Race Day – 10K",
      date: DateTime.now().add(const Duration(days: 3, hours: 3)),
      group: "All",
      kind: EventKind.special,
      location: "Avenue Habib Bourguiba",
      description: "Official national race. Wear club colors.",
      participants: const ["Team RCT"],
    ),
  ];

  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : AppColors.ivory;
    final card = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final border = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? Colors.white.withOpacity(0.70) : Colors.black.withOpacity(0.60);

    final dayEvents = _events.where((e) => _isSameDay(e.date, _selectedDay)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Events"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        children: [
          _WeekStrip(
            selected: _selectedDay,
            onSelect: (d) => setState(() => _selectedDay = d),
          ),

          const SizedBox(height: 14),

          // “Calendar-like” header card (no real calendar)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                _DateBadge(date: _selectedDay),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _prettyDay(_selectedDay),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${dayEvents.length} session(s) planned",
                        style: TextStyle(
                          color: textSub,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.calendar_month_rounded, color: AppColors.terracotta.withOpacity(0.9)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          if (dayEvents.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Icon(Icons.nightlight_round, color: textSub),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "No events for this day.\nCheck tomorrow or switch group.",
                      style: TextStyle(color: textSub, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            )
          else
            ...dayEvents.map((e) => _EventCard(
                  event: e,
                  isDark: isDark,
                  onTap: () => _openEventDetails(e),
                )),
        ],
      ),
    );
  }

  void _openEventDetails(RctEvent e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EventDetailsSheet(event: e),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _prettyDay(DateTime d) {
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final wd = weekdays[(d.weekday - 1).clamp(0, 6)];
    return "$wd • ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }
}

/* -------------------- UI pieces -------------------- */
class _WeekStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  const _WeekStrip({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final start = DateTime(selected.year, selected.month, selected.day)
        .subtract(const Duration(days: 3));
    final days = List.generate(7, (i) => start.add(Duration(days: i)));

    return SizedBox(
      height: 64, // ✅ was 62 (prevents overflow)
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final d = days[i];
          final isSelected =
              d.year == selected.year && d.month == selected.month && d.day == selected.day;

          final bg = isSelected
              ? AppColors.terracotta.withOpacity(isDark ? 0.22 : 0.18)
              : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05));

          final border = isSelected
              ? AppColors.terracotta.withOpacity(0.55)
              : (isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06));

          final text = isSelected
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? Colors.white.withOpacity(0.78) : Colors.black.withOpacity(0.72));

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onSelect(d),
            child: Container(
              width: 60, // ✅ slightly smaller
              padding: const EdgeInsets.symmetric(vertical: 8), // ✅ less padding
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ✅ prevents stretching
                  children: [
                    Text(
                      _wd(d.weekday),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: text,
                        fontSize: 11, // ✅ was 12
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.day.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: text,
                        fontSize: 15, // ✅ was 16
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _wd(int weekday) {
    const w = ["M", "T", "W", "T", "F", "S", "S"];
    return w[(weekday - 1).clamp(0, 6)];
  }
}


class _DateBadge extends StatelessWidget {
  final DateTime date;
  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.08);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.terracotta.withOpacity(isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date.month.toString().padLeft(2, '0'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
          Text(
            date.day.toString(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final RctEvent event;
  final bool isDark;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final border = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? Colors.white.withOpacity(0.70) : Colors.black.withOpacity(0.60);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimePill(time: _hhmm(event.date), kind: event.kind),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      color: textMain,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: Icons.groups_2_rounded,
                        text: "Group ${event.group}",
                        isDark: isDark,
                      ),
                      _MetaChip(
                        icon: Icons.place_rounded,
                        text: event.location,
                        isDark: isDark,
                      ),
                      _MetaChip(
                        icon: Icons.people_alt_rounded,
                        text: "${event.participants.length} participants",
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textSub, fontWeight: FontWeight.w600, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _hhmm(DateTime d) =>
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";

  static String _kindLabel(EventKind k) {
    switch (k) {
      case EventKind.daily:
        return "DAILY";
      case EventKind.weekly:
        return "WEEKLY";
      case EventKind.special:
        return "SPECIAL";
    }
  }

  static Color _kindColor(EventKind k) {
    switch (k) {
      case EventKind.daily:
        return AppColors.terracotta;
      case EventKind.weekly:
        return const Color(0xFF5E574D);
      case EventKind.special:
        return const Color(0xFFB3B6B7);
    }
  }
}

class _TimePill extends StatelessWidget {
  final String time;
  final EventKind kind;

  const _TimePill({required this.time, required this.kind});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.08);

    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _EventCard._kindColor(kind).withOpacity(isDark ? 0.22 : 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            _EventCard._kindLabel(kind),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0.8,
              color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _MetaChip({required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05);
    final fg = isDark ? Colors.white.withOpacity(0.78) : Colors.black.withOpacity(0.72);
    final border = isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w700, color: fg, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EventDetailsSheet extends StatelessWidget {
  final RctEvent event;
  const _EventDetailsSheet({required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheet = isDark ? const Color(0xFF161616) : Colors.white;
    final border = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? Colors.white.withOpacity(0.72) : Colors.black.withOpacity(0.62);

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.40,
      maxChildSize: 0.92,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: sheet,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border.all(color: border),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(18),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                event.title,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: textMain),
              ),
              const SizedBox(height: 10),
              Text(
                event.description,
                style: TextStyle(color: textSub, fontWeight: FontWeight.w600, height: 1.35),
              ),
              const SizedBox(height: 16),

              _detailRow(Icons.calendar_month_rounded, _fullDate(event.date), textMain, textSub),
              const SizedBox(height: 10),
              _detailRow(Icons.groups_2_rounded, "Group ${event.group}", textMain, textSub),
              const SizedBox(height: 10),
              _detailRow(Icons.place_rounded, event.location, textMain, textSub),
              const SizedBox(height: 10),
              _detailRow(Icons.people_alt_rounded, "${event.participants.length} participants", textMain, textSub),

              const SizedBox(height: 16),

              Text("Participants", style: TextStyle(color: textMain, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: event.participants
                    .take(12)
                    .map((p) => Chip(
                          label: Text(p, style: const TextStyle(fontWeight: FontWeight.w800)),
                          backgroundColor: AppColors.terracotta.withOpacity(isDark ? 0.18 : 0.12),
                          side: BorderSide(color: border),
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String value, Color textMain, Color textSub) {
    return Row(
      children: [
        Icon(icon, color: AppColors.terracotta),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: textSub, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  String _fullDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return "$dd/$mm/${d.year} • $hh:$mi";
    }
}
