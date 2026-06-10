import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/userModel.dart';

class GroupModel {
  final String id;          
  final String name;
  final String image;
  final int memberCount;
  final String description;
  final int bgColor;       
  final String? createdBy;
  final List<UserModel> members;

  GroupModel({
    required this.id,      
    required this.name,
    required this.image,
    required this.memberCount,
    required this.description,
    required this.bgColor,
    this.createdBy,
    this.members = const [],
  });

  factory GroupModel.fromFirestore(String id, Map<String, dynamic> data) {
    return GroupModel(
      id:          id,
      name:        data['name'] ?? '',
      image:       data['image'] ?? 'assets/component/book_watermark.png',
      memberCount: data['memberCount'] ?? 1,
      description: data['description'] ?? '',
      bgColor:     data['bgColor'] ?? 0xFFDFF2EB,  
      createdBy:   data['createdBy'],
      members:     const [],
    );
  }

  Map<String, dynamic> toMap(String uid) {
    return {
      'name':        name,
      'image':       image,
      'memberCount': memberCount,
      'description': description,
      'bgColor':     bgColor,   
      'createdBy':   uid,
      'createdAt':   FieldValue.serverTimestamp(),
    };
  }
}