import 'package:flutter/material.dart';
import 'package:orsocook/theme/informativa_cookie_theme.dart';
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
          return _buildDesktopTable(constraints);
        } else {
          return _buildMobileTable();
        }
      },
    );
  }

  Widget _buildDesktopTable(BoxConstraints constraints) {
    final tableWidth = constraints.maxWidth;
    // Ribilancia le larghezze: più spazio per Esempi
    final col1Width = tableWidth * 0.22; // 22% per Categoria
    final col2Width = tableWidth * 0.33; // 33% per Finalità
    final col3Width = tableWidth * 0.45; // 45% per Esempi

    return DataTable(
      columnSpacing: 4,
      horizontalMargin: 0,
      headingRowColor: WidgetStateProperty.resolveWith(
        (states) =>
            isDarkMode ? Colors.white.withAlpha(15) : Colors.blue.withAlpha(15),
      ),
      dataRowColor:
          WidgetStateProperty.resolveWith((states) => Colors.transparent),
      dividerThickness: 0.5,
      columns: [
        DataColumn(
          label: SizedBox(
            width: col1Width,
            child: const Center(
              child: Text('Categoria',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: col2Width,
            child: const Center(
              child: Text('Finalità',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: col3Width,
            child: const Center(
              child: Text('Esempi',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ),
      ],
      rows: cookieTableData
          .map((row) => _buildDataRow(row, col1Width, col2Width, col3Width))
          .toList(),
    );
  }

  Widget _buildMobileTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...cookieTableData.map((row) => _buildCompactRow(row)),
        const SizedBox(height: 8),
      ],
    );
  }

  DataRow _buildDataRow(CookieTableRow row, double col1Width, double col2Width,
      double col3Width) {
    final color = InformativaCookieTheme.getColor(row.index, isDarkMode);
    return DataRow(cells: [
      DataCell(
        SizedBox(
          width: col1Width,
          child: Center(
            child: Text(
              row.category,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: color, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: col2Width,
          child: Center(
            child: Text(
              row.purpose,
              style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black87),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: col3Width,
          child: Center(
            child: Text(
              row.examples,
              style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black87),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildCompactRow(CookieTableRow row) {
    final color = InformativaCookieTheme.getColor(row.index, isDarkMode);
    final bool isLast = cookieTableData.last == row;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
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
