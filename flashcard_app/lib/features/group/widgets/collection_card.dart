import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';
import '../../flashcard/screens/flashcard_study_screen.dart';

int _parseIconCode(dynamic value) {
  if (value == null) return Icons.menu_book.codePoint;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? Icons.menu_book.codePoint;
  return Icons.menu_book.codePoint;
}

Color _darkenColor(Color c, double amount) => Color.fromARGB(
      c.alpha,
      (c.red * (1 - amount)).round().clamp(0, 255),
      (c.green * (1 - amount)).round().clamp(0, 255),
      (c.blue * (1 - amount)).round().clamp(0, 255),
    );

// Thử parse tất cả định dạng có thể: int, double, hex string "#RRGGBB", hex string "RRGGBB"
Color _parseColor(dynamic raw, {Color fallback = const Color(0xFFE9B4B3)}) {
  try {
    if (raw == null) return fallback;
    if (raw is int) return Color(raw);
    if (raw is double) return Color(raw.toInt());
    if (raw is String) {
      // Nếu là số thập phân dạng string (Firestore lưu int thành string)
      final asInt = int.tryParse(raw);
      if (asInt != null) return Color(asInt);
      // Nếu là hex "#RRGGBB" hoặc "RRGGBB"
      final hex = raw.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }
  } catch (_) {}
  return fallback;
}

// Parse icon từ hex string (codePoint dạng "e3af") hoặc int
IconData _parseIcon(dynamic raw) {
  try {
    if (raw == null) return Icons.menu_book_rounded;
    if (raw is int) return IconData(raw, fontFamily: 'MaterialIcons');
    if (raw is double) return IconData(raw.toInt(), fontFamily: 'MaterialIcons');
    if (raw is String) {
      // Thử hex trước (vd "e3af"), rồi thử decimal
      final cp = int.tryParse(raw, radix: 16) ?? int.tryParse(raw);
      if (cp != null) return IconData(cp, fontFamily: 'MaterialIcons');
    }
  } catch (_) {}
  return Icons.menu_book_rounded;
}

class CollectionList extends StatelessWidget {
  final GroupModel group;

  const CollectionList({super.key, required this.group});

  void _showShareSheet(BuildContext context) async {
    final sets = await GroupService.getMyFlashcardSets();

    if (!context.mounted) return;

    if (sets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have no flashcard sets to share")),
      );
      return;
    }

    // Lấy danh sách setId đã share trong group
    final sharedIds = await GroupService.getSharedSetIds(group.id ?? '');

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.mainColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ShareSheet(
        group: group,
        sets: sets,
        sharedSetIds: sharedIds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Collections",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.highlightColor,
                ),
              ),
              GestureDetector(
                onTap: () => _showShareSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.highlightColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.upload_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        "Share",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          StreamBuilder<List<Map<String, dynamic>>>(
            stream: GroupService.getGroupCollections(group.id ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final collections = snapshot.data ?? [];

              if (collections.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Icon(Icons.folder_open, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text("No collections yet",
                          style: TextStyle(color: Colors.grey.shade400)),
                      const SizedBox(height: 4),
                      Text("Be the first to share!",
                          style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
                    ],
                  ),
                );
              }

              return Column(
                children: collections
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CollectionCard(data: c, groupId: group.id ?? ''),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Share Sheet ────────────────────────────────────────────────────────────────

class _ShareSheet extends StatefulWidget {
  final GroupModel group;
  final List<Map<String, dynamic>> sets;
  final Set<String> sharedSetIds; // setId đã share rồi

  const _ShareSheet({
    required this.group,
    required this.sets,
    required this.sharedSetIds,
  });

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  String? _selectedSetId;
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                "Share a Collection",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.highlightColor,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.sets.length,
                  itemBuilder: (_, index) {
                    final set = widget.sets[index];
                    final id = set['setId'] as String;
                    final isSelected = _selectedSetId == id;

                    // ── Đã share rồi → disabled ──
                    final isAlreadyShared = widget.sharedSetIds.contains(id);

                    // Parse màu — thử nhiều key name
                    final Color baseColor = _parseColor(
                      set['ColorHex'] ?? set['colorHex'] ?? set['color'],
                    );
                    final Color tabColor = _darkenColor(baseColor, 0.15);
                    final IconData iconData = _parseIcon(set['Icon'] ?? set['icon']);

                    return GestureDetector(
                      // Nếu đã share rồi thì không cho chọn
                      onTap: isAlreadyShared
                          ? null
                          : () => setState(() => _selectedSetId = id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isAlreadyShared
                              ? Colors.grey.shade100
                              : isSelected
                                  ? baseColor.withOpacity(0.15)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isAlreadyShared
                                ? Colors.grey.shade200
                                : isSelected
                                    ? baseColor
                                    : Colors.grey.shade200,
                            width: isSelected && !isAlreadyShared ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // ── Folder mini ──
                            Opacity(
                              opacity: isAlreadyShared ? 0.4 : 1.0,
                              child: SizedBox(
                                width: 52,
                                height: 44,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Container(
                                        width: 22,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: tabColor,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 9,
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: baseColor,
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(6),
                                            bottomLeft: Radius.circular(6),
                                            bottomRight: Radius.circular(6),
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            iconData,
                                            size: 18,
                                            color: _darkenColor(baseColor, 0.28)
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    set['Title'] ?? set['title'] ?? 'Untitled',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isAlreadyShared
                                          ? Colors.grey.shade400
                                          : isSelected
                                              ? tabColor
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isAlreadyShared
                                        ? "Already shared"
                                        : "${set['TotalCards'] ?? set['totalCards'] ?? 0} cards",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isAlreadyShared
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade500,
                                      fontStyle: isAlreadyShared
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Check hoặc "Shared" badge
                            if (isAlreadyShared)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Shared",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            else if (isSelected)
                              Icon(Icons.check_circle_rounded, color: baseColor),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Share button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _selectedSetId == null || _sharing
                        ? null
                        : () async {
                            setState(() => _sharing = true);
                            final selected = widget.sets
                                .firstWhere((s) => s['setId'] == _selectedSetId);
                            await GroupService.shareCollectionToGroup(
                              groupId: widget.group.id ?? '',
                              setData: selected,
                            );
                            if (context.mounted) Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.highlightColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _sharing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Share to Group",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Collection Card trong group ────────────────────────────────────────────────

class _CollectionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String groupId;

  const _CollectionCard({required this.data, required this.groupId});

  @override
  Widget build(BuildContext context) {
    // Thử nhiều key có thể có trong Firestore document
    final Color baseColor = _parseColor(
      data['color'] ?? data['ColorHex'] ?? data['colorHex'],
    );
    final Color tabColor = _darkenColor(baseColor, 0.15);
    final Color iconColor = _darkenColor(baseColor, 0.28);
    final IconData iconData = _parseIcon(data['iconCode'] ?? data['Icon'] ?? data['icon']);

    // setId để navigate
    final String setId = (data['setId'] ?? data['SetId'] ?? '').toString();

    return GestureDetector(
      onTap: () {
        if (setId.isNotEmpty) {
          // TODO: import FlashcardStudyScreen rồi uncomment:
          // Navigator.push(context, MaterialPageRoute(
          //   builder: (_) => FlashcardStudyScreen(setId: setId),
          // ));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: baseColor.withOpacity(0.35),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // ── Folder lớn ──
            SizedBox(
              width: 64,
              height: 54,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 26,
                      height: 12,
                      decoration: BoxDecoration(
                        color: tabColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 9,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tabColor.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Icon(iconData, size: 22,
                                  color: iconColor.withOpacity(0.55)),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 5,
                            child: Icon(Icons.star_outline_rounded, size: 13,
                                color: Colors.white.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? data['Title'] ?? 'Untitled',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "by ${data['sharedByName'] ?? 'Unknown'}",
                    style: TextStyle(
                        fontSize: 12, color: Colors.black.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.style_rounded,
                          size: 13, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(
                        "${data['totalCards'] ?? data['TotalCards'] ?? 0} cards",
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Study button — navigate vào FlashcardStudyScreen
            GestureDetector(
              onTap: setId.isNotEmpty
                  ? () {
                      // TODO: import FlashcardStudyScreen rồi uncomment:
                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: (_) => FlashcardStudyScreen(setId: setId),
                      // ));
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: setId.isNotEmpty
                      ? AppColors.highlightColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Study',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}