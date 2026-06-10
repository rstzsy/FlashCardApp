import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/themes/app_colors.dart';
import '../models/blog_post_model.dart';
import '../services/blog_service.dart';

class EditBlogScreen extends StatefulWidget {
  final String   groupId;
  final BlogPost post;

  const EditBlogScreen({
    super.key,
    required this.groupId,
    required this.post,
  });

  @override
  State<EditBlogScreen> createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  File?   _newImage;
  bool    _removeImage = false;
  bool    _saving      = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl   = TextEditingController(text: widget.post.title);
    _contentCtrl = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source:    ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _newImage    = File(picked.path);
        _removeImage = false;
      });
    }
  }

  Future<void> _save() async {
    final title   = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    setState(() => _saving = true);

    await BlogService.updatePost(
      groupId:          widget.groupId,
      postId:           widget.post.id,
      title:            title,
      content:          content,
      newImage:         _newImage,
      existingImageUrl: _removeImage ? null : widget.post.imageUrl,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentImage = _newImage != null
        ? FileImage(_newImage!)
        : (widget.post.imageUrl != null && !_removeImage
            ? NetworkImage(widget.post.imageUrl!) as ImageProvider
            : null);

    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Column(
        children: [
          // Header
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DD9F5).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: Color(0xFF0277BD)),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Edit Post',
                  style: TextStyle(
                    fontSize:   20,
                    fontWeight: FontWeight.w800,
                    color:      Color(0xFF01579B),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _saving ? null : _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color:        const Color(0xFF0277BD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.w700,
                              color:      Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  _label('Title'),
                  const SizedBox(height: 8),
                  _field(controller: _titleCtrl, hint: 'Post title'),
                  const SizedBox(height: 16),

                  // Content
                  _label('Content'),
                  const SizedBox(height: 8),
                  _field(
                    controller: _contentCtrl,
                    hint:    'Write something...',
                    maxLines: 8,
                  ),
                  const SizedBox(height: 16),

                  // Image
                  _label('Image'),
                  const SizedBox(height: 8),
                  if (currentImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image(
                        image:  currentImage,
                        width:  double.infinity,
                        height: 180,
                        fit:    BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _imgBtn(
                          icon:  Icons.image_outlined,
                          label: 'Change',
                          onTap: _pickImage,
                        ),
                        const SizedBox(width: 8),
                        _imgBtn(
                          icon:  Icons.delete_outline,
                          label: 'Remove',
                          color: Colors.redAccent,
                          onTap: () => setState(() {
                            _newImage    = null;
                            _removeImage = true;
                          }),
                        ),
                      ],
                    ),
                  ] else
                    _imgBtn(
                      icon:  Icons.add_photo_alternate_outlined,
                      label: 'Add Image',
                      onTap: _pickImage,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize:   13,
          fontWeight: FontWeight.w700,
          color:      Color(0xFF0277BD),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) =>
      Container(
        decoration: BoxDecoration(
          color:        Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:      const Color(0xFF4DD9F5).withOpacity(0.1),
              blurRadius: 8,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          maxLines:   maxLines,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText:       hint,
            hintStyle:      const TextStyle(color: Colors.black38),
            contentPadding: const EdgeInsets.all(16),
            border:         InputBorder.none,
          ),
        ),
      );

  Widget _imgBtn({
    required IconData  icon,
    required String    label,
    required VoidCallback onTap,
    Color color = const Color(0xFF0277BD),
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color:        color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.w700,
                  color:      color,
                ),
              ),
            ],
          ),
        ),
      );
}