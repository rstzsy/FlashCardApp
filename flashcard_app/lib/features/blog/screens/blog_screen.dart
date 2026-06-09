import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../models/blog_post_model.dart';
import '../services/blog_service.dart';
import '../widgets/blog_post_card.dart';
import 'create_blog_screen.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final List<BlogPost> _posts = BlogService.getDummyPosts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nền giống home: AppColors.mainColor = #E0F7FA
      backgroundColor: AppColors.mainColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ──
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: const BoxDecoration(
                // Solid color giống home header: AppColors.primary = #B3E5FC
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Blog',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          // Dùng màu chữ tối vì nền xanh nhạt
                          color: Color(0xFF0277BD),
                        ),
                      ),
                      // Row(
                      //   children: [
                      //     _HeaderIcon(icon: Icons.videocam_outlined),
                      //     const SizedBox(width: 8),
                      //     _HeaderIcon(icon: Icons.photo_camera_outlined),
                      //     const SizedBox(width: 8),
                      //     _HeaderIcon(icon: Icons.ios_share_outlined),
                      //   ],
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Title
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        // Chữ đậm xanh đậm thay vì trắng (vì nền nhạt)
                        color: Color(0xFF01579B),
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(text: 'Share And Discover\nMoments '),
                        TextSpan(
                          text: 'With Your\nCommunity',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Posts ──
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => BlogPostCard(post: _posts[index]),
              childCount: _posts.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── FAB: create post ──
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          // FAB dùng xanh sky giống AppColors.skyBottom
          backgroundColor: AppColors.skyBottom,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateBlogScreen()),
            );
          },
          child: const Icon(Icons.edit_outlined, color: Colors.white),
        ),
      ),
    );
  }
}

// ── Header icon button ────────────────────────────────────────────────────────

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  const _HeaderIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        // Nền icon nửa trong suốt tông xanh
        color: const Color(0xFF4DD9F5).withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF0277BD)),
    );
  }
}