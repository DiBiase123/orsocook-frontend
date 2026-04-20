import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_utils.dart';
import 'package:orsocook/screens/legal/colors/section_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AccordionSection extends StatefulWidget {
  final int index;
  final String title;
  final bool isDarkMode;
  final BuildContext context;
  final Widget body;
  final bool isExpanded;
  final ValueChanged<bool> onToggle;

  const AccordionSection({
    super.key,
    required this.index,
    required this.title,
    required this.isDarkMode,
    required this.context,
    required this.body,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<AccordionSection> createState() => _AccordionSectionState();
}

class _AccordionSectionState extends State<AccordionSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  void didUpdateWidget(AccordionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != _isExpanded) {
      _isExpanded = widget.isExpanded;
    }
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      widget.onToggle(_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = SectionColors.getColor(widget.index, widget.isDarkMode);
    final bgColor =
        widget.isDarkMode ? color.withAlpha(35) : color.withAlpha(28);
    final borderColor =
        widget.isDarkMode ? color.withAlpha(70) : color.withAlpha(50);
    final headerBgColor =
        widget.isDarkMode ? color.withAlpha(20) : color.withAlpha(15);

    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: _isExpanded
              ? const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                )
              : BorderRadius.circular(16),
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
              onTap: _toggle,
              borderRadius: _isExpanded
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    )
                  : BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    Icon(
                      Icons.cookie,
                      color: const Color(0xFFB45309),
                      size: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.poppins(
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: DefaultTextStyle(
                  style: GoogleFonts.openSans(
                    fontSize: ResponsiveValues.bodySize(widget.context),
                    height: 1.6,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  child: widget.body,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
