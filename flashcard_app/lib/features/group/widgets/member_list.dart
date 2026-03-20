import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import 'member_card.dart';

class MemberList extends StatelessWidget {
  const MemberList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Members",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.highlightColor,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.highlightColor,),
            ],
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              MemberCard("Anna", "assets/account/acc1.jpg"),
              MemberCard("Ivan", "assets/account/acc2.jpg"),
              MemberCard("Alex", "assets/account/acc3.jpg"),
              MemberCard("Kate", "assets/account/acc4.jpg"),
              MemberCard("Thanh", "assets/account/acc5.jpg"),
            ],
          ),
        ),
      ],
    );
  }
}
