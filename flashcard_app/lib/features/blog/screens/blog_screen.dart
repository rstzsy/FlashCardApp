import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../group/models/group_model.dart';
import '../../group/services/group_service.dart';
import '../models/blog_post_model.dart';
import '../services/blog_service.dart';
import '../widgets/blog_post_card.dart';
import 'create_blog_screen.dart';
import 'group_members_screen.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  List<GroupModel> _myGroups     = [];
  int              _tabIndex     = 0;
  GroupRole        _myRole       = GroupRole.none;
  bool             _loadingGroups = true;

  GroupModel? get _selectedGroup =>
      _myGroups.isEmpty ? null : _myGroups[_tabIndex];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await GroupService.getMyGroups().first;
    if (!mounted) return;
    setState(() {
      _myGroups      = groups;
      _tabIndex      = 0;
      _loadingGroups = false;
    });
    if (groups.isNotEmpty) _loadRole(groups[0].id);
  }

  Future<void> _loadRole(String groupId) async {
    final role = await BlogService.getMyRole(groupId);
    if (mounted) setState(() => _myRole = role);
  }

  void _selectGroup(int index) {
    setState(() {
      _tabIndex = index;
      _myRole   = GroupRole.none;
    });
    _loadRole(_myGroups[index].id);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loadingGroups) {
      return const Scaffold(
        backgroundColor: AppColors.mainColor,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0277BD)),
        ),
      );
    }

    if (_myGroups.isEmpty) return _buildNoGroupsScreen();

    return _buildFeedScreen();
  }

  // ── No groups ──────────────────────────────────────────────────────────────

  Widget _buildNoGroupsScreen() {
    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.group_outlined,
                        size: 40, color: Color(0xFF0277BD),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No groups yet',
                      style: TextStyle(
                        fontSize:   18,
                        fontWeight: FontWeight.w700,
                        color:      Color(0xFF01579B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join or create a group to see\nposts from your community.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black45),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Feed ───────────────────────────────────────────────────────────────────

  Widget _buildFeedScreen() {
    final group   = _selectedGroup!;
    final canPost = BlogService.canPost(_myRole);

    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader()),

          // Group tabs
          SliverToBoxAdapter(child: _buildGroupTabs()),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Role badge + Manage button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  _RoleBadge(role: _myRole),
                  const Spacer(),
                  if (_myRole == GroupRole.admin)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              GroupMembersScreen(group: group),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F7FA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline_rounded,
                                size: 14, color: Color(0xFF0277BD)),
                            SizedBox(width: 5),
                            Text(
                              'Manage',
                              style: TextStyle(
                                fontSize:   12,
                                fontWeight: FontWeight.w700,
                                color:      Color(0xFF0277BD),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Posts
          StreamBuilder<List<BlogPost>>(
            key: ValueKey(group.id), 
            stream: BlogService.getPostsStream(group.id),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF0277BD)),
                    ),
                  ),
                );
              }

              final posts = snap.data ?? [];

              if (posts.isEmpty) {
                return SliverToBoxAdapter(
                    child: _buildEmptyFeed(canPost));
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => BlogPostCard(
                    post:    posts[i],
                    groupId: group.id,
                    myRole:  _myRole,
                  ),
                  childCount: posts.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),

      // FAB — chỉ admin/moderator
      floatingActionButton: canPost
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton(
                backgroundColor: AppColors.skyBottom,
                onPressed: () async {
                  await Navigator.push(        
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateBlogScreen(groupId: group.id),
                    ),
                  );
                },
                child: const Icon(
                    Icons.edit_outlined, color: Colors.white),
              ),
            )
          : null,
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Blog',
            style: TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w600,
              color:      Color(0xFF0277BD),
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize:   30,
                fontWeight: FontWeight.w900,
                color:      Color(0xFF01579B),
                height:     1.2,
              ),
              children: [
                TextSpan(text: 'Share And Discover\nMoments '),
                TextSpan(
                  text:  'With Your\nCommunity',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Group tabs ─────────────────────────────────────────────────────────────

  Widget _buildGroupTabs() {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        itemCount: _myGroups.length,
        itemBuilder: (_, i) {
          final group    = _myGroups[i];
          final selected = i == _tabIndex;

          return GestureDetector(
            onTap: () => _selectGroup(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin:  const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF0277BD)
                    : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? const Color(0xFF0277BD).withOpacity(0.35)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: selected ? 12 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withOpacity(0.25)
                          : Color(group.bgColor).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        group.name.isNotEmpty
                            ? group.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize:   13,
                          fontWeight: FontWeight.w800,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF0277BD),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    group.name,
                    style: TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Empty feed ─────────────────────────────────────────────────────────────

  Widget _buildEmptyFeed(bool canPost) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 24, vertical: 60),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color:        const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.article_outlined,
              size: 40, color: Color(0xFF0277BD),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No posts yet',
            style: TextStyle(
              fontSize:   18,
              fontWeight: FontWeight.w700,
              color:      Color(0xFF01579B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            canPost
                ? 'Tap ✏️ to share the first\npost with your group!'
                : 'Only admins and moderators\ncan post in this group.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

// ── Role Badge ─────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final GroupRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color  bg;
    final Color  fg;

    switch (role) {
      case GroupRole.admin:
        label = '👑 Admin';
        bg    = const Color(0xFFFFF3E0);
        fg    = const Color(0xFFEF6C00);
      case GroupRole.moderator:
        label = '🛡️ Moderator';
        bg    = const Color(0xFFE3F2FD);
        fg    = const Color(0xFF0277BD);
      default:
        label = '👤 Member';
        bg    = const Color(0xFFF3F4F6);
        fg    = Colors.black54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   12,
          fontWeight: FontWeight.w600,
          color:      fg,
        ),
      ),
    );
  }
}