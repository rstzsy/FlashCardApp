import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

class GroupController extends ChangeNotifier {
  List<GroupModel> _groups = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _subscription;

  List<GroupModel> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void listenToGroups() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    _subscription?.cancel();

    // Query tất cả groups, filter phía client xem uid có trong members không
    _subscription = FirebaseFirestore.instance
        .collection('groups')
        .snapshots()
        .asyncMap((groupSnap) async {
          final List<GroupModel> result = [];

          for (final doc in groupSnap.docs) {
            // Kiểm tra xem user có trong subcollection members không
            final memberDoc = await FirebaseFirestore.instance
                .collection('groups')
                .doc(doc.id)
                .collection('members')
                .doc(uid)
                .get();

            if (memberDoc.exists) {
              result.add(GroupModel.fromFirestore(doc.id, doc.data()));
            }
          }

          return result;
        })
        .listen(
          (groupList) {
            _groups = groupList;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _errorMessage = "Không thể tải danh sách nhóm.";
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<GroupModel?> createGroup(GroupModel group) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newGroup = await GroupService.createGroup(group);
      return newGroup;
    } catch (e) {
      _errorMessage = "Không thể tạo nhóm. Vui lòng thử lại.";
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}