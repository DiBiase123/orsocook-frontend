import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_utils.dart';
import 'package:orsocook/screens/legal/colors/section_colors.dart';

class CookieSection extends StatelessWidget {
  final int index;
  final String title;
  final String content;
  final bool isDarkMode;
  final BuildContext context;
  final bool isExpandable;

  const CookieSection({
    super.key,
    required this.index,
    required this.title,
    required this.content,
    required this.isDarkMode,
    required this.context,
    this.isExpandable = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = SectionColors.getColor(index, isDarkMode);
    final bgColor = isDarkMode ? color.withAlpha(28) : color.withAlpha(25);
    final borderColor = isDarkMode ? color.withAlpha(60) : color.withAlpha(40);

    if (isExpandable) {
      return _AccordionItem(
        index: index,
        title: title,
        content: content,
        isDarkMode: isDarkMode,
        context: context,
        color: color,
        bgColor: bgColor,
        borderColor: borderColor,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: ResponsiveValues.screenPadding(context),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cookie,
                  color: const Color(0xFFB45309), size: 32), // Icona più grande
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveValues.titleSize(context),
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: ResponsiveValues.bodySize(context),
              height: 1.5,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccordionItem extends StatefulWidget {
  final int index;
  final String title;
  final String content;
  final bool isDarkMode;
  final BuildContext context;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  const _AccordionItem({
    required this.index,
    required this.title,
    required this.content,
    required this.isDarkMode,
    required this.context,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  State<_AccordionItem> createState() => __AccordionItemState();
}

class __AccordionItemState extends State<_AccordionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final headerBgColor = widget.isDarkMode
        ? widget.color.withAlpha(20)
        : widget.color.withAlpha(15);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: _isExpanded
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              )
            : BorderRadius.circular(16),
        border: Border.all(color: widget.borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: _isExpanded
                ? const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  )
                : BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _isExpanded ? headerBgColor : Colors.transparent,
                borderRadius: _isExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.cookie,
                      color: const Color(0xFFB45309),
                      size: 32), // Icona più grande
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: ResponsiveValues.titleSize(widget.context),
                        fontWeight: FontWeight.w600,
                        color: widget.color,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? Colors.white.withAlpha(20)
                          : widget.color.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: widget.color,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                widget.content,
                style: TextStyle(
                  fontSize: ResponsiveValues.bodySize(widget.context),
                  height: 1.5,
                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
