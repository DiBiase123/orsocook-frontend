import 'package:flutter/material.dart';
import 'package:orsocook/screens/legal/colors/section_colors.dart';
import 'package:orsocook/screens/legal/data/cookie_table_data.dart';

class CookieTable extends StatelessWidget {
  final bool isDarkMode;
  final double screenWidth;

  const CookieTable(
      {super.key, required this.isDarkMode, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return _buildDesktopTable();
        } else {
          return _buildMobileTable();
        }
      },
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 32,
        horizontalMargin: 16,
        headingRowColor: WidgetStateProperty.resolveWith(
          (states) => isDarkMode
              ? Colors.white.withAlpha(15)
              : Colors.blue.withAlpha(15),
        ),
        dataRowColor:
            WidgetStateProperty.resolveWith((states) => Colors.transparent),
        dividerThickness: 0.5,
        columns: const [
          DataColumn(
              label: Text('Categoria',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          DataColumn(
              label: Text('Finalità',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          DataColumn(
              label: Text('Esempi',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        ],
        rows: cookieTableData.map((row) => _buildDataRow(row)).toList(),
      ),
    );
  }

  Widget _buildMobileTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cookieTableData.map((row) => _buildCompactRow(row)).toList(),
    );
  }

  DataRow _buildDataRow(CookieTableRow row) {
    final color = SectionColors.getColor(row.index, isDarkMode);
    return DataRow(cells: [
      DataCell(Text(row.category,
          style: TextStyle(
              fontWeight: FontWeight.w700, color: color, fontSize: 14))),
      DataCell(Text(row.purpose,
          style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black87))),
      DataCell(Text(row.examples,
          style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black87))),
    ]);
  }

  Widget _buildCompactRow(CookieTableRow row) {
    final color = SectionColors.getColor(row.index, isDarkMode);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? color.withAlpha(15) : color.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDarkMode ? color.withAlpha(40) : color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text(row.category,
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: color, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text('📌 ${row.purpose}',
                style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    height: 1.4)),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text('💡 ${row.examples}',
                style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}
