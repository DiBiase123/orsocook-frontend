import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_values.dart';
import 'package:orsocook/screens/legal/colors/section_colors.dart';

class AccordionSection extends StatefulWidget {
  final int index;
  final String title;
  final bool isDarkMode;
  final BuildContext context;
  final Widget body;

  const AccordionSection({
    super.key,
    required this.index,
    required this.title,
    required this.isDarkMode,
    required this.context,
    required this.body,
  });

  @override
  State<AccordionSection> createState() => _AccordionSectionState();
}

class _AccordionSectionState extends State<AccordionSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final color = SectionColors.getColor(widget.index, widget.isDarkMode);
    final bgColor =
        widget.isDarkMode ? color.withAlpha(35) : color.withAlpha(28);
    final borderColor =
        widget.isDarkMode ? color.withAlpha(70) : color.withAlpha(50);
    final headerBgColor =
        widget.isDarkMode ? color.withAlpha(20) : color.withAlpha(15);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: widget.isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _isExpanded ? headerBgColor : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cookie,
                    color: const Color(0xFFB45309),
                    size: 26,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: ResponsiveValues.titleSize(widget.context),
                        fontWeight: FontWeight.w600,
                        color: color,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? Colors.white.withAlpha(20)
                          : color.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: color,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: ResponsiveValues.bodySize(widget.context),
                  height: 1.6,
                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                  letterSpacing: 0.2,
                ),
                child: widget.body,
              ),
            ),
        ],
      ),
    );
  }
}
