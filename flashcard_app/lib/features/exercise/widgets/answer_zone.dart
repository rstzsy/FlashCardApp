import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class AnswerZone extends StatefulWidget {
  final List<String> selectedWords;
  final void Function(int) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  const AnswerZone({
    super.key,
    required this.selectedWords,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  State<AnswerZone> createState() => _AnswerZoneState();
}

class _AnswerZoneState extends State<AnswerZone> {
  int? _draggingIndex;
  int? _hoverIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EF),
        border: Border.all(
          color: AppColors.highlightColor,
          width: 2.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child:
          widget.selectedWords.isEmpty
              ? Center(
                child: Text(
                  "Click on the word below!",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: const Color(0xFF7A3333),
                  ),
                ),
              )
              : Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(widget.selectedWords.length, (i) {
                      final isDragging = _draggingIndex == i;
                      final isHover = _hoverIndex == i && _draggingIndex != i;

                      return _buildDraggableChip(i, isDragging, isHover);
                    }),
                  ),
                ),
              ),
    );
  }

  Widget _buildDraggableChip(int index, bool isDragging, bool isHover) {
    final word = widget.selectedWords[index];

    return LongPressDraggable<int>(
      data: index,
      delay: const Duration(milliseconds: 150),

      // Widget is dragging
      feedback: Material(
        color: Colors.transparent,
        child: _ChipContent(word: word, isFloating: true),
      ),

      // Widget save the orignal locateion
      childWhenDragging: _ChipPlaceholder(word: word),

      onDragStarted: () => setState(() => _draggingIndex = index),
      onDragEnd:
          (_) => setState(() {
            _draggingIndex = null;
            _hoverIndex = null;
          }),

      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) {
          setState(() => _hoverIndex = index);
          return details.data != index;
        },
        onLeave: (_) => setState(() => _hoverIndex = null),
        onAcceptWithDetails: (details) {
          setState(() => _hoverIndex = null);
          widget.onReorder(details.data, index);
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration:
                isHover
                    ? BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.highlightColor,
                        width: 2,
                      ),
                    )
                    : null,
            child: GestureDetector(
              onTap: () => widget.onRemove(index),
              child: _ChipContent(word: word, isDragging: isDragging),
            ),
          );
        },
      ),
    );
  }
}

// chip content
class _ChipContent extends StatelessWidget {
  final String word;
  final bool isDragging;
  final bool isFloating;

  const _ChipContent({
    required this.word,
    this.isDragging = false,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 100),
      opacity: isDragging ? 0.4 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isFloating
                  ? const Color.fromARGB(
                    102,
                    252,
                    180,
                    177,
                  ) // another color when dragging
                  : const Color(0x66F7D6D5),
          borderRadius: BorderRadius.circular(999),
          boxShadow:
              isFloating
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          "$word ✕",
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: Color(0xFF7A3333),
          ),
        ),
      ),
    );
  }
}

// save the location when drag
class _ChipPlaceholder extends StatelessWidget {
  final String word;

  const _ChipPlaceholder({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.highlightColor.withOpacity(0.4),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Text(
        "$word ✕",
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: const Color(0xFF7A3333).withOpacity(0.3),
        ),
      ),
    );
  }
}
