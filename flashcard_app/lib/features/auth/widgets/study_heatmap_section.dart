import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class StudyHeatmapSection extends StatefulWidget {
  const StudyHeatmapSection({super.key});

  @override
  State<StudyHeatmapSection> createState() => _StudyHeatmapSectionState();
}

class _StudyHeatmapSectionState extends State<StudyHeatmapSection> {
  Map<String, int> _dailyCounts = {};
  bool _isLoading      = true;
  int  _displayYear    = DateTime.now().year;
  int  _displayQuarter = ((DateTime.now().month - 1) ~/ 3) + 1;
  int  _streak         = 0;
  _PopupInfo? _popup;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  int get _firstMonth => (_displayQuarter - 1) * 3 + 1;
  int get _lastMonth  => _displayQuarter * 3;

  Future<void> _loadAll() async {
    await Future.wait([_loadHeatmapData(), _loadStreak()]);
  }

  Future<void> _loadStreak() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final s = (doc.data()?['streak'] as int?) ?? 0;
      if (mounted) setState(() => _streak = s);
    } catch (_) {}
  }

  Future<void> _loadHeatmapData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _isLoading = false); return; }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('StudySessions')
          .where('UserId', isEqualTo: uid)
          .get();

      final Map<String, int> counts = {};
      for (final doc in snap.docs) {
        final data  = doc.data();
        final ts    = data['StudiedAt'] as Timestamp?;
        final words = (data['WordsStudied'] as num?)?.toInt() ?? 0;
        if (ts == null) continue;

        final d = ts.toDate().toLocal();

        if (d.year != _displayYear) continue;
        if (d.month < _firstMonth || d.month > _lastMonth) continue;

        final key = _fmtKey(d.year, d.month, d.day);
        counts[key] = (counts[key] ?? 0) + words;
      }
      if (mounted) setState(() { _dailyCounts = counts; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _isCurrentQuarter {
    final now = DateTime.now();
    return _displayYear == now.year && _displayQuarter == ((now.month - 1) ~/ 3) + 1;
  }

  void _prev() {
    setState(() { _isLoading = true; _popup = null; });
    if (_displayQuarter == 1) { _displayYear--; _displayQuarter = 4; }
    else { _displayQuarter--; }
    _loadHeatmapData();
  }

  void _next() {
    if (_isCurrentQuarter) return;
    setState(() { _isLoading = true; _popup = null; });
    if (_displayQuarter == 4) { _displayYear++; _displayQuarter = 1; }
    else { _displayQuarter++; }
    _loadHeatmapData();
  }

  void _onCellTap(_PopupInfo info) {
    setState(() => _popup = (_popup?.key == info.key) ? null : info);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { if (_popup != null) setState(() => _popup = null); },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Study Activity',
                  style: TextStyle(
                    color: AppColors.highlightColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
                Row(children: [
                  _NavBtn(icon: Icons.chevron_left_rounded,  onTap: _prev),
                  const SizedBox(width: 4),
                  Text('Q$_displayQuarter · $_displayYear',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(width: 4),
                  _NavBtn(icon: Icons.chevron_right_rounded, onTap: _next, disabled: _isCurrentQuarter),
                ]),
              ],
            ),

            // ── streak badge ──
            // const SizedBox(height: 8),
            // _StreakBadge(streak: _streak),

            const SizedBox(height: 12),

            // ── heatmap card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12, offset: const Offset(0, 4),
                )],
              ),
              child: _isLoading
                  ? const SizedBox(height: 110, child: Center(child: CircularProgressIndicator()))
                  : _QuarterHeatmap(
                      year:        _displayYear,
                      firstMonth:  _firstMonth,
                      dailyCounts: _dailyCounts,
                      activePopup: _popup,
                      onCellTap:   _onCellTap,
                    ),
            ),

            // ── popup ──
            if (_popup != null) _DayPopup(info: _popup!),

            const SizedBox(height: 6),

            // ── legend ──
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Less', style: TextStyle(fontSize: 9, color: Colors.black38)),
                const SizedBox(width: 3),
                ...[0.0, 0.15, 0.40, 0.70, 0.95].map((v) => Container(
                  width: 9, height: 9,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: _cellColor(v),
                    borderRadius: BorderRadius.zero,
                  ),
                )),
                const SizedBox(width: 3),
                const Text('More', style: TextStyle(fontSize: 9, color: Colors.black38)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _PopupInfo {
  final String key;
  final int    words, year, month, day;
  const _PopupInfo({required this.key, required this.words,
    required this.year, required this.month, required this.day});
}

// ─────────────────────────────────────────────────────────────────────────────
class _DayPopup extends StatelessWidget {
  final _PopupInfo info;
  const _DayPopup({required this.info});

  static const _weekdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
  static const _months   = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December',
  ];

  String get _dateLabel {
    final dow = _weekdays[DateTime(info.year, info.month, info.day).weekday - 1];
    return '$dow ${_months[info.month - 1]} ${info.day}, ${info.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D47A1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.6),
            children: info.words == 0
                ? [
                    const TextSpan(text: 'No cards reviewed\non '),
                    TextSpan(text: _dateLabel),
                  ]
                : [
                    TextSpan(
                      text: '${info.words} cards ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: 'reviewed on\n'),
                    TextSpan(text: _dateLabel),
                  ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// class _StreakBadge extends StatelessWidget {
//   final int streak;
//   const _StreakBadge({required this.streak});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         const Text('🔥', style: TextStyle(fontSize: 16)),
//         const SizedBox(width: 4),
//         RichText(
//           text: TextSpan(
//             style: const TextStyle(fontSize: 13, color: Colors.black54),
//             children: [
//               TextSpan(
//                 text: '$streak',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15,
//                   color: Colors.deepOrange,
//                 ),
//               ),
//               const TextSpan(text: ' day streak'),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// ─────────────────────────────────────────────────────────────────────────────
class _QuarterHeatmap extends StatelessWidget {
  final int year, firstMonth;
  final Map<String, int> dailyCounts;
  final _PopupInfo? activePopup;
  final void Function(_PopupInfo) onCellTap;

  const _QuarterHeatmap({
    required this.year,
    required this.firstMonth,
    required this.dailyCounts,
    required this.activePopup,
    required this.onCellTap,
  });

  static const _rowLabels  = ['M','T','W','T','F','S','S'];
  static const _monthNames = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];

  static const double _lblW     = 12.0;
  static const double _lblGap   =  4.0;
  static const double _cellGap  =  2.5;
  static const double _monthGap =  6.0;
  static const double _headerH  = 14.0;

  @override
  Widget build(BuildContext context) {
    final numColsList = List.generate(3, (mi) {
      final m      = firstMonth + mi;
      final days   = DateUtils.getDaysInMonth(year, m);
      final offset = DateTime(year, m, 1).weekday - 1;
      return ((offset + days) / 7).ceil();
    });

    int maxW = 1;
    for (int mi = 0; mi < 3; mi++) {
      final m    = firstMonth + mi;
      final days = DateUtils.getDaysInMonth(year, m);
      for (int d = 1; d <= days; d++) {
        final w = dailyCounts[_fmtKey(year, m, d)] ?? 0;
        if (w > maxW) maxW = w;
      }
    }

    return LayoutBuilder(builder: (ctx, constraints) {
      final totalCols     = numColsList.fold(0, (a, b) => a + b);
      final availW        = constraints.maxWidth - _lblW - _lblGap - _monthGap * 2;
      final totalCellGaps = numColsList.fold(0, (a, b) => a + (b - 1));
      final cs            = ((availW - _cellGap * totalCellGaps) / totalCols).clamp(0.0, 18.0);
      final gridH         = _headerH + 7 * cs + 6 * _cellGap;

      return SizedBox(
        height: gridH,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // day-of-week labels
            Padding(
              padding: EdgeInsets.only(top: _headerH),
              child: Column(
                children: List.generate(7, (row) => SizedBox(
                  width: _lblW,
                  height: cs + (row < 6 ? _cellGap : 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(_rowLabels[row],
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.black38)),
                  ),
                )),
              ),
            ),
            SizedBox(width: _lblGap),

            // 3 month blocks
            ...List.generate(3, (mi) {
              final month   = firstMonth + mi;
              final days    = DateUtils.getDaysInMonth(year, month);
              final offset  = DateTime(year, month, 1).weekday - 1;
              final numCols = numColsList[mi];

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: _headerH,
                        child: Text(_monthNames[month - 1],
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black45)),
                      ),
                      ...List.generate(7, (row) => Padding(
                        padding: EdgeInsets.only(bottom: row < 6 ? _cellGap : 0),
                        child: Row(
                          children: List.generate(numCols, (col) {
                            final idx     = col * 7 + row;
                            final day     = idx - offset + 1;
                            final isBlank = day < 1 || day > days;

                            return Padding(
                              padding: EdgeInsets.only(right: col < numCols - 1 ? _cellGap : 0),
                              child: SizedBox(
                                width: cs, height: cs,
                                child: isBlank
                                    ? const SizedBox.shrink()
                                    : _HeatCell(
                                        year:     year,
                                        month:    month,
                                        day:      day,
                                        words:    dailyCounts[_fmtKey(year, month, day)] ?? 0,
                                        maxW:     maxW,
                                        isActive: activePopup?.key == _fmtKey(year, month, day),
                                        onTap:    onCellTap,
                                      ),
                              ),
                            );
                          }),
                        ),
                      )),
                    ],
                  ),
                  if (mi < 2) SizedBox(width: _monthGap),
                ],
              );
            }),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _HeatCell extends StatelessWidget {
  final int  year, month, day, words, maxW;
  final bool isActive;
  final void Function(_PopupInfo) onTap;

  const _HeatCell({
    required this.year, required this.month, required this.day,
    required this.words, required this.maxW,
    required this.isActive, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final intensity = _wordsToBucket(words);
    final key       = _fmtKey(year, month, day);

    return GestureDetector(
      onTap: () => onTap(_PopupInfo(
        key: key, words: words, year: year, month: month, day: day,
      )),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color:        _cellColor(intensity),
          borderRadius: BorderRadius.zero,
          border: isActive
              ? Border.all(color: const Color(0xFF0D47A1), width: 1.5)
              : null,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
String _fmtKey(int y, int m, int d) =>
    '$y-${m.toString().padLeft(2,'0')}-${d.toString().padLeft(2,'0')}';

Color _cellColor(double intensity) {
  if (intensity == 0)    return const Color(0xFFBBDEFB); // chưa học
  if (intensity < 0.25)  return const Color(0xFF90CAF9); // 1–9 cards
  if (intensity < 0.55)  return const Color(0xFF42A5F5); // 10–99 cards
  if (intensity < 0.85)  return const Color(0xFF1565C0); // 100–999 cards
  return const Color(0xFF0D2F6E);                         // 1000+ cards
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;
  const _NavBtn({required this.icon, required this.onTap, this.disabled = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: disabled ? null : onTap,
    child: Icon(icon, size: 20, color: disabled ? Colors.black12 : Colors.black45),
  );
}

double _wordsToBucket(int words) {
  if (words <= 0)   return 0.0;
  if (words < 10)   return 0.15;
  if (words < 100)  return 0.40;
  if (words < 1000) return 0.70;
  return 0.95;
}