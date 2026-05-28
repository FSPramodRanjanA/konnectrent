import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:konnectrent/core/theme/app_theme.dart';
import 'package:konnectrent/core/utils/format_utils.dart';
import 'package:konnectrent/domain/engine/rent_calc_engine.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key, required this.input});

  final RentCalcInput input;

  @override
  Widget build(BuildContext context) {
    final result = RentCalcEngine.calculate(input);
    final breakEven = result.breakEvenYear;

    return Scaffold(
      appBar: AppBar(title: const Text('20-Year Cost Chart')),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          children: [
            const _Legend(),
            if (breakEven != null)
              Chip(
                avatar: const Icon(Icons.flag_outlined, size: 16),
                label: Text('Break-even at Year $breakEven'),
              ),
            const SizedBox(height: AppTheme.spaceMD),
            Expanded(
              child: _CostLineChart(result: result, breakEvenYear: breakEven),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spaceSM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendDot(color: AppTheme.primaryTeal, label: 'Rent'),
          SizedBox(width: AppTheme.spaceMD),
          _LegendDot(color: AppTheme.primaryIndigo, label: 'Buy'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _CostLineChart extends StatelessWidget {
  const _CostLineChart({required this.result, this.breakEvenYear});

  final dynamic result;
  final int? breakEvenYear;

  @override
  Widget build(BuildContext context) {
    final cumRent = result.cumulativeRent as List<double>;
    final cumBuy = result.cumulativeBuy as List<double>;
    final breakEven = breakEvenYear;

    final rentSpots = List.generate(
      cumRent.length,
      (i) => FlSpot((i + 1).toDouble(), cumRent[i]),
    );
    final buySpots = List.generate(
      cumBuy.length,
      (i) => FlSpot((i + 1).toDouble(), cumBuy[i]),
    );

    final allVals = [...cumRent, ...cumBuy];
    final maxY = allVals.reduce((a, b) => a > b ? a : b) * 1.1;

    return LineChart(
      LineChartData(
        minX: 1,
        maxX: 20,
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (_, spots) => spots
              .map(
                (_) => const TouchedSpotIndicatorData(
                  FlLine(color: Colors.grey, strokeWidth: 1),
                  FlDotData(),
                ),
              )
              .toList(),
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) {
              final label = spot.barIndex == 0 ? 'Rent' : 'Buy';
              return LineTooltipItem(
                '$label\n${FormatUtils.toIndianCurrency(spot.y)}',
                TextStyle(
                  color: spot.barIndex == 0
                      ? AppTheme.primaryTeal
                      : AppTheme.primaryIndigo,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Year', style: TextStyle(fontSize: 12)),
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (val, _) =>
                  Text(val.toInt().toString(), style: const TextStyle(fontSize: 10)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (val, _) => Text(
                FormatUtils.toIndianCurrency(val),
                style: const TextStyle(fontSize: 9),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        extraLinesData: breakEven != null
            ? ExtraLinesData(
                verticalLines: [
                  VerticalLine(
                    x: breakEven.toDouble(),
                    color: AppTheme.accentAmber,
                    strokeWidth: 2,
                    dashArray: [6, 4],
                    label: VerticalLineLabel(
                      show: true,
                      labelResolver: (_) => 'Break-even',
                      style: const TextStyle(
                        color: AppTheme.accentAmber,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            : null,
        lineBarsData: [
          LineChartBarData(
            spots: rentSpots,
            isCurved: true,
            color: AppTheme.primaryTeal,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: buySpots,
            isCurved: true,
            color: AppTheme.primaryIndigo,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
