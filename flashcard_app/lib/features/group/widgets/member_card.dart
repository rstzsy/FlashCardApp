import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class MemberCard extends StatelessWidget {
  final String name;
  final String? avatar;
  final bool isOwner;

  const MemberCard({
    super.key,
    required this.name,
    this.avatar,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.mainColor,                          
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent, width: 2), 
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,            
                backgroundImage: avatar != null
                    ? (avatar!.startsWith('http')
                        ? NetworkImage(avatar!) as ImageProvider
                        : AssetImage(avatar!))
                    : null,
                child: avatar == null
                    ? Icon(
                        Icons.person,
                        size: 35,
                        color: isOwner ? AppColors.highlightColor : Colors.grey,
                      )
                    : null,
              ),
              if (isOwner)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isOwner
                  ? AppColors.highlightColor
                  : const Color.fromARGB(225, 19, 64, 122),
            ),
          ),

          const SizedBox(height: 4),

          Visibility(
            visible: isOwner,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.highlightColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Owner',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}