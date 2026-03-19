import 'package:flutter/material.dart';
import 'collection_card.dart';

class CollectionList extends StatelessWidget {
  const CollectionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CollectionCard(
          name: "Japanese",
          username: "@amaz",
          categories: const ["N5", "Vocabulary"],
          image: "assets/component/book.png",
          onStart: () {},
        ),

        CollectionCard(
          name: "English Basic",
          username: "@gerasimova",
          categories: ["Grammar", "family", "Flashcard"],
          image: "assets/component/book.png",
          onStart: () {},
        ),

        CollectionCard(
          name: "IELTS Master",
          username: "@anatoly",
          categories: ["fruits"],
          image: "assets/component/book.png",
          onStart: () {},
        ),
      ],
    );
  }
}
