import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyLinkBox extends StatefulWidget {
  final String link;

  const CopyLinkBox({super.key, required this.link});

  @override
  State<CopyLinkBox> createState() => _CopyLinkBoxState();
}

class _CopyLinkBoxState extends State<CopyLinkBox> {
  bool copied = false;

  void copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.link));

    setState(() {
      copied = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.link,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          IconButton(
            icon: Icon(
              copied ? Icons.check : Icons.copy,
              color: copied ? Colors.green : Colors.black,
            ),
            onPressed: copyLink,
          ),
        ],
      ),
    );
  }
}