import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/blog_post_model.dart';
import 'package:flutter/foundation.dart'; 

enum GroupRole { admin, moderator, member, none }

class BlogService {
  static final _db      = FirebaseFirestore.instance;
  static final _auth    = FirebaseAuth.instance;
  static final _storage = FirebaseStorage.instance;

  static String? get _uid => _auth.currentUser?.uid;

  // ── Role ──────────────────────────────────────────────────────────────────────

  static Future<GroupRole> getMyRole(String groupId) async {
    final uid = _uid;
    if (uid == null) return GroupRole.none;

    final doc = await _db
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .get();

    if (!doc.exists) return GroupRole.none;

    switch (doc.data()?['role']) {
      case 'admin':     return GroupRole.admin;
      case 'moderator': return GroupRole.moderator;
      default:          return GroupRole.member;
    }
  }

  static bool canPost(GroupRole role) =>
      role == GroupRole.admin || role == GroupRole.moderator;

  static bool canDelete(GroupRole role, String postAuthorId) {
    final uid = _uid;
    if (uid == null) return false;
    if (role == GroupRole.admin || role == GroupRole.moderator) return true;
    return postAuthorId == uid;
  }

  // ── Posts stream ──────────────────────────────────────────────────────────────

  static Stream<List<BlogPost>> getPostsStream(String groupId) {
    final uid = _uid;

    return _db
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          if (snap.docs.isEmpty) return <BlogPost>[];

          final futures = snap.docs.map((doc) async {
            final post = BlogPost.fromFirestore(doc.id, doc.data());
            if (uid == null) return post;

            try {
              final results = await Future.wait([
                doc.reference.collection('likes').doc(uid).get(),
                doc.reference.collection('bookmarks').doc(uid).get(),
              ]);
              return post.copyWith(
                isLiked:      results[0].exists,
                isBookmarked: results[1].exists,
              );
            } catch (_) {
              return post;  
            }
          });

          return Future.wait(futures);
        });
  }

  // ── Create post ───────────────────────────────────────────────────────────────

  static Future<void> createPost({
    required String groupId,
    required String title,
    required String content,
    File? image,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final role = await getMyRole(groupId);
    if (!canPost(role)) return;

    final userDoc      = await _db.collection('users').doc(uid).get();
    final userData     = userDoc.data() ?? {};
    final authorName   = userData['name']     ?? 'Unknown';
    final authorAvatar = userData['photoUrl'] ?? '';

    String? imageUrl;
    if (image != null) {
      final ref = _storage
          .ref()
          .child('groups/$groupId/posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image);
      imageUrl = await ref.getDownloadURL();
    }

    await _db
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .add(BlogPost(
          id:           '',
          groupId:      groupId,
          authorId:     uid,
          authorName:   authorName,
          authorAvatar: authorAvatar,
          createdAt:    DateTime.now(),
          title:        title,
          content:      content,
          imageUrl:     imageUrl,
        ).toMap());
  }

  // ── Delete post ───────────────────────────────────────────────────────────────

  static Future<void> deletePost({
    required String groupId,
    required String postId,
    required String postAuthorId,
  }) async {
    final role = await getMyRole(groupId);
    if (!canDelete(role, postAuthorId)) return;

    await _db
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId)
        .delete();
  }

  // ── Like ──────────────────────────────────────────────────────────────────────

  static Future<void> toggleLike({
    required String groupId,
    required String postId,
    required bool   currentlyLiked,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final postRef = _db
        .collection('groups').doc(groupId)
        .collection('posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(uid);

    await _db.runTransaction((tx) async {
      if (currentlyLiked) {
        tx.delete(likeRef);
        tx.update(postRef, {'likes': FieldValue.increment(-1)});
      } else {
        tx.set(likeRef, {'likedAt': FieldValue.serverTimestamp()});
        tx.update(postRef, {'likes': FieldValue.increment(1)});
      }
    });
  }

  // ── Bookmark ──────────────────────────────────────────────────────────────────

  static Future<void> toggleBookmark({
    required String groupId,
    required String postId,
    required bool   currentlyBookmarked,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final postRef     = _db
        .collection('groups').doc(groupId)
        .collection('posts').doc(postId);
    final bookmarkRef = postRef.collection('bookmarks').doc(uid);

    await _db.runTransaction((tx) async {
      if (currentlyBookmarked) {
        tx.delete(bookmarkRef);
        tx.update(postRef, {'bookmarks': FieldValue.increment(-1)});
      } else {
        tx.set(bookmarkRef, {'savedAt': FieldValue.serverTimestamp()});
        tx.update(postRef, {'bookmarks': FieldValue.increment(1)});
      }
    });
  }

  // ── Comments ──────────────────────────────────────────────────────────────────

  static Stream<List<Map<String, dynamic>>> getCommentsStream({
    required String groupId,
    required String postId,
  }) =>
      _db
          .collection('groups').doc(groupId)
          .collection('posts').doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((s) => s.docs
              .map((d) => {'id': d.id, ...d.data()})
              .toList());

  static Future<void> addComment({
    required String groupId,
    required String postId,
    required String text,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final userDoc      = await _db.collection('users').doc(uid).get();
    final userData     = userDoc.data() ?? {};
    final authorName   = userData['name']     ?? 'Unknown';
    final authorAvatar = userData['photoUrl'] ?? ''; 

    final postRef = _db
        .collection('groups').doc(groupId)
        .collection('posts').doc(postId);

    await _db.runTransaction((tx) async {
      tx.set(postRef.collection('comments').doc(), {
        'authorId':     uid,
        'authorName':   authorName,
        'authorAvatar': authorAvatar,
        'text':         text,
        'createdAt':    FieldValue.serverTimestamp(),
      });
      tx.update(postRef, {'comments': FieldValue.increment(1)});
    });
  }

  // ── Promote / Demote ──────────────────────────────────────────────────────────

  static Future<void> promoteMember({
    required String groupId,
    required String targetUid,
  }) async {
    if (await getMyRole(groupId) != GroupRole.admin) return;
    await _db
        .collection('groups').doc(groupId)
        .collection('members').doc(targetUid)
        .update({'role': 'moderator'});
  }

  static Future<void> demoteModerator({
    required String groupId,
    required String targetUid,
  }) async {
    if (await getMyRole(groupId) != GroupRole.admin) return;
    await _db
        .collection('groups').doc(groupId)
        .collection('members').doc(targetUid)
        .update({'role': 'member'});
  }

  // ── Group members ─────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getGroupMembers(
      String groupId) async {
    final snap = await _db
        .collection('groups').doc(groupId)
        .collection('members').get();

    return Future.wait(snap.docs.map((m) async {
      final u = await _db.collection('users').doc(m.id).get();
      return {
        'uid':    m.id,
        'role':   m.data()['role'] ?? 'member',
        'name':   u.data()?['name']   ?? 'Unknown',
        'avatar': u.data()?['photoUrl'] ?? '', 
      };
    }));
  }

  // ── Update post ───────────────────────────────────────────────────────────────
  static Future<void> updatePost({
    required String groupId,
    required String postId,
    required String title,
    required String content,
    File?   newImage,
    String? existingImageUrl,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    String? imageUrl = existingImageUrl;
    if (newImage != null) {
      final ref = _storage
          .ref()
          .child('groups/$groupId/posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(newImage);
      imageUrl = await ref.getDownloadURL();
    }

    await _db
        .collection('groups').doc(groupId)
        .collection('posts').doc(postId)
        .update({
      'title':   title,
      'content': content,
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Replies ───────────────────────────────────────────────────────────────────

  static Stream<List<Map<String, dynamic>>> getRepliesStream({
      required String groupId,
      required String postId,
      required String commentId,
    }) =>
        _db
            .collection('groups').doc(groupId)
            .collection('posts').doc(postId)
            .collection('comments').doc(commentId)
            .collection('replies')
            .orderBy('createdAt', descending: false)
            .snapshots()
            .map((s) => s.docs
                .map((d) => {'id': d.id, ...d.data()})
                .toList());

    static Future<void> addReply({
    required String groupId,
    required String postId,
    required String commentId,
    required String text,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final userDoc = await _db.collection('users').doc(uid).get();
    final userData = userDoc.data() ?? {};

    final postRef = _db
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId);

    await _db.runTransaction((tx) async {
      tx.set(
        postRef
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(),
        {
          'authorId': uid,
          'authorName': userData['name'] ?? 'Unknown',
          'authorAvatar': userData['photoUrl'] ?? '',
          'text': text,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      tx.update(
        postRef,
        {
          'comments': FieldValue.increment(1),
        },
      );
    });
  }

  // ── Delete comment ────────────────────────────────────────────────────────────

  static Future<void> deleteComment({
    required String groupId,
    required String postId,
    required String commentId,
    required String commentAuthorId,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final role = await getMyRole(groupId);
    final canDel = role == GroupRole.admin ||
                  role == GroupRole.moderator ||
                  uid == commentAuthorId;
    if (!canDel) return;

    final commentRef = _db
        .collection('groups').doc(groupId)
        .collection('posts').doc(postId)
        .collection('comments').doc(commentId);

    final repliesSnap = await commentRef.collection('replies').get();
    final batch = _db.batch();
    for (final r in repliesSnap.docs) {
      batch.delete(r.reference);
    }

    batch.delete(commentRef);

    final postRef = _db
        .collection('groups').doc(groupId)
        .collection('posts').doc(postId);
    final totalDeleted = 1 + repliesSnap.docs.length;
    batch.update(postRef, {'comments': FieldValue.increment(-totalDeleted)});

    await batch.commit();
  }
  // ── Delete reply ──────────────────────────────────────────────────────────────

  static Future<void> deleteReply({
    required String groupId,
    required String postId,
    required String commentId,
    required String replyId,
    required String replyAuthorId,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final role = await getMyRole(groupId);
    final canDel = role == GroupRole.admin ||
                  role == GroupRole.moderator ||
                  uid == replyAuthorId;
    if (!canDel) return;

    final replyRef = _db
        .collection('groups').doc(groupId)
        .collection('posts').doc(postId)
        .collection('comments').doc(commentId)
        .collection('replies').doc(replyId);

    final postRef = _db
        .collection('groups').doc(groupId)
        .collection('posts').doc(postId);

    final batch = _db.batch();
    batch.delete(replyRef);
    batch.update(postRef, {'comments': FieldValue.increment(-1)});
    await batch.commit();
  }

  static Future<BlogPost?> getPost({
    required String groupId,
    required String postId,
  }) async {
    final uid = _uid;
    final doc = await _db
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId)
        .get();

    if (!doc.exists) return null;

    final post = BlogPost.fromFirestore(doc.id, doc.data()!);
    if (uid == null) return post;

    final results = await Future.wait([
      doc.reference.collection('likes').doc(uid).get(),
      doc.reference.collection('bookmarks').doc(uid).get(),
    ]);

    return post.copyWith(
      isLiked:      results[0].exists,
      isBookmarked: results[1].exists,
    );
  }
}