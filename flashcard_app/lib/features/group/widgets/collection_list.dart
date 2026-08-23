import 'package:firebase_auth/firebase_auth.dart';
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

Color _parseColor(dynamic raw) {
  try {
    if (raw == null) return const Color(0xFFE9B4B3);
    if (raw is int) return Color(raw);
    if (raw is double) return Color(raw.toInt());
    if (raw is String) {
      final hex = raw.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }
  } catch (_) {}
  return const Color(0xFFE9B4B3);
}

IconData _parseIcon(dynamic raw) {
  final code = _parseIconCode(raw);
  return IconData(code, fontFamily: 'MaterialIcons');
}

// ── Folder widget ─────────────────────────────────────────────────────────────

class _FolderWidget extends StatelessWidget {
  final Color baseColor;
  final IconData icon;
  final double width;
  final double height;
  final double tabW;
  final double tabH;
  final double iconSize;
  final double bodyRadius;
  final double tabRadius;
  final bool showStar;
  final double opacity;

  const _FolderWidget({
    required this.baseColor,
    required this.icon,
    this.width = 64,
    this.height = 54,
    this.tabW = 26,
    this.tabH = 12,
    this.iconSize = 22,
    this.bodyRadius = 8,
    this.tabRadius = 5,
    this.showStar = true,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color tabColor = _darkenColor(baseColor, 0.15);
    final Color iconColor = _darkenColor(baseColor, 0.28);

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: tabW,
                height: tabH + 3,
                decoration: BoxDecoration(
                  color: tabColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(tabRadius),
                    topRight: Radius.circular(tabRadius),
                  ),
                ),
              ),
            ),
            Positioned(
              top: tabH,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(bodyRadius),
                    bottomLeft: Radius.circular(bodyRadius),
                    bottomRight: Radius.circular(bodyRadius),
                  ),
                  boxShadow: opacity == 1.0
                      ? [
                          BoxShadow(
                            color: tabColor.withOpacity(0.22),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(icon,
                            size: iconSize,
                            color: iconColor.withOpacity(0.55)),
                      ),
                    ),
                    if (showStar)
                      Positioned(
                        top: 3,
                        right: 4,
                        child: Icon(Icons.star_outline_rounded,
                            size: iconSize * 0.55,
                            color: Colors.white.withOpacity(0.7)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CollectionList ────────────────────────────────────────────────────────────

class CollectionList extends StatefulWidget {
  final GroupModel group;

  const CollectionList({super.key, required this.group});

  @override
  State<CollectionList> createState() => _CollectionListState();
}

class _CollectionListState extends State<CollectionList> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final result = await GroupService.isAdminByRole(widget.group.id ?? '');
    if (mounted) setState(() => _isAdmin = result);
  }

  void _showShareSheet(BuildContext context) async {
    final sets = await GroupService.getMyFlashcardSets();

    if (!context.mounted) return;

    if (sets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have no flashcard sets to share")),
      );
      return;
    }

    final sharedIds = await GroupService.getSharedSetIds(widget.group.id ?? '');

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ShareSheet(
        group: widget.group,
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
              if (_isAdmin)
                GestureDetector(
                  onTap: () => _showShareSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.highlightColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 4),
                        Text(
                          "Share",
                          style: TextStyle(
                            fontSize: 16,
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
            stream: GroupService.getGroupCollections(widget.group.id ?? ''),
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
                      Icon(Icons.folder_open,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text("No collections yet",
                          style: TextStyle(color: Colors.grey.shade400)),
                      const SizedBox(height: 4),
                      Text("Be the first to share!",
                          style: TextStyle(
                              color: Colors.grey.shade300, fontSize: 12)),
                    ],
                  ),
                );
              }

              return Column(
                children: collections
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CollectionCard(
                            data: c,
                            groupId: widget.group.id ?? '',
                            isAdmin: _isAdmin,
                          ),
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

// ── Share Sheet ───────────────────────────────────────────────────────────────

class _ShareSheet extends StatefulWidget {
  final GroupModel group;
  final List<Map<String, dynamic>> sets;
  final Set<String> sharedSetIds;

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
                    final isShared = widget.sharedSetIds.contains(id);

                    final Color baseColor = _parseColor(
                        set['ColorHex'] ?? set['colorHex'] ?? set['Color']);
                    final IconData iconData =
                        _parseIcon(set['Icon'] ?? set['icon']);

                    return GestureDetector(
                      onTap: isShared
                          ? null
                          : () => setState(() => _selectedSetId = id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isShared
                              ? Colors.grey.shade100
                              : isSelected
                                  ? baseColor.withOpacity(0.12)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isShared
                                ? Colors.grey.shade200
                                : isSelected
                                    ? baseColor
                                    : Colors.grey.shade200,
                            width: isSelected && !isShared ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            _FolderWidget(
                              baseColor: baseColor,
                              icon: iconData,
                              width: 52,
                              height: 44,
                              tabW: 22,
                              tabH: 10,
                              iconSize: 18,
                              bodyRadius: 6,
                              tabRadius: 4,
                              showStar: false,
                              opacity: isShared ? 0.38 : 1.0,
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
                                      color: isShared
                                          ? Colors.grey.shade400
                                          : isSelected
                                              ? _darkenColor(baseColor, 0.3)
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isShared
                                        ? "Already shared"
                                        : "${set['TotalCards'] ?? set['totalCards'] ?? 0} cards",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isShared
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade500,
                                      fontStyle: isShared
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isShared)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text("Shared",
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w500)),
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
                            final selected = widget.sets.firstWhere(
                                (s) => s['setId'] == _selectedSetId);
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
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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

// ── Collection Card ───────────────────────────────────────────────────────────

class _CollectionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String groupId;
  final bool isAdmin;

  const _CollectionCard({
    required this.data,
    required this.groupId,
    required this.isAdmin,
  });

  void _confirmDelete(BuildContext context) {
    final String title = data['title'] ?? 'Untitled';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Remove collection?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          "\"$title\" will be removed from this group. Members will no longer be able to study it.",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(color: Colors.grey.shade500)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final setId = (data['setId'] ?? '').toString();
              if (setId.isNotEmpty) {
                await GroupService.removeCollectionFromGroup(
                  groupId: groupId,
                  setId: setId,
                );
              }
            },
            child: const Text("Remove",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor = _parseColor(data['color']);
    final IconData iconData = _parseIcon(data['iconCode']);
    final String setId = (data['setId'] ?? '').toString();

    return GestureDetector(
      onLongPress: isAdmin ? () => _confirmDelete(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: baseColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            _FolderWidget(
              baseColor: baseColor,
              icon: iconData,
              width: 64,
              height: 54,
              tabW: 26,
              tabH: 12,
              iconSize: 22,
              bodyRadius: 8,
              tabRadius: 5,
              showStar: true,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? 'Untitled',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "by ${data['sharedByName'] ?? 'Unknown'}",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.style_rounded,
                          size: 13, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(
                        "${data['totalCards'] ?? 0} cards",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Study button
            GestureDetector(
              onTap: setId.isNotEmpty
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlashcardStudyScreen(setId: setId),
                        ),
                      )
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: setId.isNotEmpty
                      ? AppColors.highlightColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Study',
                  style: TextStyle(
                      fontSize: 16,
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