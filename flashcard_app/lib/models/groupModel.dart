import 'package:flutter/material.dart'; 

class GroupModel {
  final String name;
  final String image;
  final int memberCount;
  final String? description;  
  final Color? bgColor;     

  GroupModel({
    required this.name,
    required this.image,
    required this.memberCount,
    this.description,
    this.bgColor,
  });
}