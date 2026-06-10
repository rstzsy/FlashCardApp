import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/group_model.dart';

class GroupService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  static int _parseIconCode(dynamic value) {
    if (value == null) return Icons.menu_book.codePoint;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? Icons.menu_book.codePoint;
    return Icons.menu_book.codePoint;
  }

  static int _parseColorHex(dynamic raw) {
    try {
      if (raw == null) return 0xFFE9B4B3;
      if (raw is int) return raw;
      if (raw is double) return raw.toInt();
      if (raw is String) {
        final hex = raw.replaceAll('#', '');
        return int.parse('FF$hex', radix: 16);
      }
    } catch (_) {}
    return 0xFFE9B4B3;
  }

  static Future<GroupModel?> createGroup(GroupModel group) async {
    final uid = _uid;
    if (uid == null) return null;

    final ref = _db.collection('groups').doc();
    await ref.set(group.toMap(uid));
    await ref.collection('members').doc(uid).set({
      'role': 'admin',
      'joinedAt': FieldValue.serverTimestamp(),
    });

    return GroupModel(
      id: ref.id,
      name: group.name,
      image: group.image,
      memberCount: group.memberCount,
      description: group.description,
      bgColor: group.bgColor,
      createdBy: uid,
    );
  }

  static Stream<List<GroupModel>> getMyGroups() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('groups')
        .snapshots()
        .asyncMap((groupSnap) async {
          final List<GroupModel> result = [];

          for (final groupDoc in groupSnap.docs) {
            final memberDoc = await _db
                .collection('groups')
                .doc(groupDoc.id)
                .collection('members')
                .doc(uid)
                .get();

            if (memberDoc.exists) {
              result.add(GroupModel.fromFirestore(
                groupDoc.id,
                groupDoc.data(),
              ));
            }
          }

          return result;
        });
  }

  static Future<List<Map<String, dynamic>>> getMyFlashcardSets() async {
    final uid = _uid;
    if (uid == null) return [];

    final snapshot = await _db
        .collection('FlashcardSets')
        .where('UserId', isEqualTo: uid)
        .orderBy('CreatedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {'setId': doc.id, ...doc.data()}).toList();
  }

  static Future<void> shareCollectionToGroup({
    required String groupId,
    required Map<String, dynamic> setData,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final userDoc = await _db.collection('users').doc(uid).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown';

    final int colorInt = _parseColorHex(setData['ColorHex'] ?? setData['Color']);
    final int iconCode = _parseIconCode(setData['Icon']);

    await _db
        .collection('groups')
        .doc(groupId)
        .collection('collections')
        .doc(setData['setId'])
        .set({
      'setId':        setData['setId'],
      'sharedBy':     uid,
      'sharedByName': userName,
      'title':        setData['Title'] ?? '',
      'subtitle':     setData['Subtitle'] ?? '',
      'totalCards':   setData['TotalCards'] ?? 0,
      'color':        colorInt,
      'iconCode':     iconCode,
      'sharedAt':     FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<Map<String, dynamic>>> getGroupCollections(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('collections')
        .orderBy('sharedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  static Future<Set<String>> getSharedSetIds(String groupId) async {
    final snap = await _db
        .collection('groups')
        .doc(groupId)
        .collection('collections')
        .get();
    return snap.docs
        .map((d) => (d.data()['setId'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  static Future<void> removeCollectionFromGroup({
    required String groupId,
    required String setId,
  }) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('collections')
        .doc(setId)
        .delete();
  }

  static bool isAdmin(GroupModel group) {
    final uid = _uid;
    if (uid == null) return false;
    return group.createdBy == uid;
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final uid = _uid;
    if (uid == null) return [];

    final snap = await _db.collection('users').get();
    return snap.docs
        .where((doc) => doc.id != uid)
        .map((doc) => {'uid': doc.id, ...doc.data()})
        .toList();
  }

  static Future<void> sendInvitation({
    required String groupId,
    required String groupName,
    required String toUid,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final userDoc = await _db.collection('users').doc(uid).get();
    final fromName = userDoc.data()?['name'] ?? 'Unknown';

    final inviteId = '${groupId}_$toUid';

    final inviteRef = _db.collection('invitations').doc(inviteId);
    final existing = await inviteRef.get();

    if (existing.exists && existing.data()?['status'] == 'pending') return;

    await inviteRef.set({
      'groupId':   groupId,
      'groupName': groupName,
      'fromUid':   uid,
      'fromName':  fromName,
      'toUid':     toUid,
      'status':    'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Set<String>> getExistingMemberIds(String groupId) async {
    if (groupId.isEmpty) return {};
    
    final snap = await _db
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .get();
        
    return snap.docs.map((d) => d.id).toSet();
  }

  static Future<Set<String>> getPendingInvitationUids(String groupId) async {
    final snap = await FirebaseFirestore.instance
        .collection('invitations')
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'pending')
        .get();

    return snap.docs
        .map((d) => (d.data()['toUid'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
  }
}