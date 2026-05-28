import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:konnectrent/core/di/injection.dart';
import 'package:konnectrent/core/router/app_router.dart';
import 'package:konnectrent/core/theme/app_theme.dart';
import 'package:konnectrent/core/utils/format_utils.dart';
import 'package:konnectrent/core/widgets/ad_banner_widget.dart';
import 'package:konnectrent/core/widgets/share_card_widget.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';
import 'package:konnectrent/domain/repositories/history_repository.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.result});

  final RentCalcResult result;

  Future<void> _saveToHistory(BuildContext context) async {
    final ctrl = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Save Calculation'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'e.g. 2BHK Koramangala',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (label != null && label.isNotEmpty && context.mounted) {
      await getIt<HistoryRepository>().save(result, label);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to history')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final verdictColor = result.verdict == Verdict.rentWins
        ? AppTheme.rentWinsBackground
        : AppTheme.buyWinsBackground;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: verdictColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share result card',
            onPressed: () => shareResultCard(context, result),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border_outlined),
            tooltip: 'Save to history',
            onPressed: () => _saveToHistory(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppTheme.spaceXL),
        children: [
          _VerdictCard(result: result, color: verdictColor),
          _BreakEvenChip(result: result),
          // ── Affordability chip ───────────────────────────────────────────
          if (result.affordabilityRatio != null)
            _AffordabilityChip(ratio: result.affordabilityRatio!),
          // ── Tax benefit banner ───────────────────────────────────────────
          if (result.taxBenefitTotal != null && result.taxBenefitTotal! > 0)
            _TaxBenefitBanner(result: result),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMD,
              vertical: AppTheme.spaceSM,
            ),
            child: Text(
              '5yr / 10yr / 20yr Comparison',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
              child: _HorizonBarChart(result: result),
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          // ── Navigation buttons ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.chart, extra: result.input),
                    icon: const Icon(Icons.show_chart),
                    label: const Text('20-yr Chart'),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSM),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.loan, extra: result),
                    icon: const Icon(Icons.table_rows_outlined),
                    label: const Text('Loan Breakdown'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      AppRoutes.scenario,
                      extra: result.input,
                    ),
                    icon: const Icon(Icons.compare_arrows_outlined),
                    label: const Text('Compare'),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSM),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.pdf, extra: result),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Export PDF'),
                  ),
                ),
              ],
            ),
          ),
          // ── SIP vs Property card ─────────────────────────────────────────
          if (result.sipCorpus != null)
            _SipCard(result: result),
          const SizedBox(height: AppTheme.spaceMD),
          const Center(child: AdBannerWidget()),
        ],
      ),
    );
  }
}

// ── Affordability Chip ────────────────────────────────────────────────────────

class _AffordabilityChip extends StatelessWidget {
  const _AffordabilityChip({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    final IconData icon;

    if (ratio <= 30) {
      color = AppTheme.primaryTeal;
      label = 'EMI is ${ratio.toStringAsFixed(0)}% of income — Comfortable';
      icon = Icons.check_circle_outline;
    } else if (ratio <= 40) {
      color = AppTheme.accentAmber;
      label = 'EMI is ${ratio.toStringAsFixed(0)}% of income — Stretch';
      icon = Icons.warning_amber_outlined;
    } else {
      color = AppTheme.errorRed;
      label = 'EMI is ${ratio.toStringAsFixed(0)}% of income — High Risk';
      icon = Icons.error_outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceXS,
      ),
      child: Chip(
        avatar: Icon(icon, size: 18, color: color),
        label: Text(label),
        backgroundColor: color.withAlpha(25),
        side: BorderSide(color: color.withAlpha(80)),
      ),
    );
  }
}

// ── Tax Benefit Banner ────────────────────────────────────────────────────────

class _TaxBenefitBanner extends StatelessWidget {
  const _TaxBenefitBanner({required this.result});

  final RentCalcResult result;

  @override
  Widget build(BuildContext context) {
    final saving = result.taxBenefitTotal!;
    final effective = result.effectiveBuyTotal ?? result.tenYearBuyTotal;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceXS,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.primaryIndigo.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.primaryIndigo.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.savings_outlined,
            color: AppTheme.primaryIndigo,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tax saving: ${FormatUtils.toIndianCurrency(saving)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryIndigo,
                  ),
                ),
                Text(
                  'Effective buy total: ${FormatUtils.toIndianCurrency(effective)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── SIP vs Property Card ──────────────────────────────────────────────────────

class _SipCard extends StatelessWidget {
  const _SipCard({required this.result});

  final RentCalcResult result;

  @override
  Widget build(BuildContext context) {
    final corpus = result.sipCorpus!;
    final propertyFuture = result.input.propertyPrice *
        (1 + result.input.annualAppreciation / 100) * 20;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceXS,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.primaryTeal.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppTheme.primaryTeal),
              const SizedBox(width: AppTheme.spaceSM),
              Text(
                'SIP vs Property (20 years)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryTeal,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSM),
          _SipRow(
            label: 'Invest rent savings as SIP',
            value: FormatUtils.toIndianCurrency(corpus),
            color: AppTheme.primaryTeal,
          ),
          _SipRow(
            label: 'Property value in 20 yrs',
            value: FormatUtils.toIndianCurrency(propertyFuture),
            color: AppTheme.primaryIndigo,
          ),
          const SizedBox(height: AppTheme.spaceXS),
          Text(
            corpus > propertyFuture
                ? '📈 SIP corpus beats property value by ${FormatUtils.toIndianCurrency(corpus - propertyFuture)}'
                : '🏠 Property value beats SIP by ${FormatUtils.toIndianCurrency(propertyFuture - corpus)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: corpus > propertyFuture
                  ? AppTheme.primaryTeal
                  : AppTheme.primaryIndigo,
            ),
          ),
        ],
      ),
    );
  }
}

class _SipRow extends StatelessWidget {
  const _SipRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Verdict Card ──────────────────────────────────────────────────────────────

class _VerdictCard extends StatelessWidget {
  const _VerdictCard({required this.result, required this.color});

  final RentCalcResult result;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isRentWins = result.verdict == Verdict.rentWins;
    final label = isRentWins ? 'Renting is cheaper' : 'Buying is cheaper';
    final sub =
        'You save ${FormatUtils.toIndianCurrency(result.rentAdvantage.abs())} over 10 years';
    final icon = isRentWins ? Icons.home_outlined : Icons.house_outlined;

    return Container(
      margin: const EdgeInsets.all(AppTheme.spaceMD),
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 48),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXS),
                Text(
                  sub,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: AppTheme.spaceSM),
                Text(
                  'Monthly EMI: ${FormatUtils.toEmi(result.monthlyEmi)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (result.input.stampDutyAmount > 0) ...[
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(
                    'Upfront cost (incl. stamp duty): '
                    '${FormatUtils.toIndianCurrency(result.input.totalUpfrontCost)}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Break-Even Chip ───────────────────────────────────────────────────────────

class _BreakEvenChip extends StatelessWidget {
  const _BreakEvenChip({required this.result});

  final RentCalcResult result;

  @override
  Widget build(BuildContext context) {
    final year = result.breakEvenYear;
    final label = year != null
        ? 'Buying becomes cheaper at Year $year'
        : 'Buying does not break even within 30 years';
    final icon = year != null ? Icons.flag_outlined : Icons.block_outlined;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        backgroundColor: year != null
            ? AppTheme.primaryIndigo.withAlpha(30)
            : Colors.grey.shade200,
      ),
    );
  }
}

// ── Bar Chart ─────────────────────────────────────────────────────────────────

class _HorizonBarChart extends StatelessWidget {
  const _HorizonBarChart({required this.result});

  final RentCalcResult result;

  @override
  Widget build(BuildContext context) {
    const rentColor = AppTheme.primaryTeal;
    const buyColor = AppTheme.primaryIndigo;

    double maxVal = [
      result.fiveYearRentTotal,
      result.fiveYearBuyTotal,
      result.tenYearRentTotal,
      result.tenYearBuyTotal,
      result.twentyYearRentTotal,
      result.twentyYearBuyTotal,
    ].reduce((a, b) => a > b ? a : b);
    maxVal *= 1.1;

    return BarChart(
      BarChartData(
        maxY: maxVal,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = rodIndex == 0 ? 'Rent' : 'Buy';
              return BarTooltipItem(
                '$label\n${FormatUtils.toIndianCurrency(rod.toY)}',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                const labels = ['5yr', '10yr', '20yr'];
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) return const SizedBox();
                return Text(labels[idx], style: const TextStyle(fontSize: 11));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, _) => Text(
                FormatUtils.toIndianCurrency(value),
                style: const TextStyle(fontSize: 9),
              ),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: [
          _group(0, result.fiveYearRentTotal, result.fiveYearBuyTotal,
              rentColor, buyColor,),
          _group(1, result.tenYearRentTotal, result.tenYearBuyTotal,
              rentColor, buyColor,),
          _group(2, result.twentyYearRentTotal, result.twentyYearBuyTotal,
              rentColor, buyColor,),
        ],
      ),
    );
  }

  BarChartGroupData _group(
    int x,
    double rentVal,
    double buyVal,
    Color rentColor,
    Color buyColor,
  ) =>
      BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: rentVal,
            color: rentColor,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: buyVal,
            color: buyColor,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 4,
      );
}
