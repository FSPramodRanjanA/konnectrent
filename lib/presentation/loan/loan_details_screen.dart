import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:konnectrent/core/ads/ad_manager.dart';
import 'package:konnectrent/core/di/injection.dart';
import 'package:konnectrent/core/router/app_router.dart';
import 'package:konnectrent/core/theme/app_theme.dart';
import 'package:konnectrent/core/utils/format_utils.dart';
import 'package:konnectrent/domain/entities/amortization_row.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';

class LoanDetailsScreen extends StatefulWidget {
  const LoanDetailsScreen({super.key, required this.result});

  final RentCalcResult result;

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Show interstitial on first entry per session.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adManager = getIt<AdManager>();
      if (adManager.isReady) adManager.showInterstitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final totalInterest = result.schedule.fold<double>(
      0,
      (sum, row) => sum + row.interestPaid,
    );
    final totalPaid = result.monthlyEmi * 12 * result.input.loanTenureYears;
    final effectiveAnnualCost =
        (result.monthlyEmi * 12) + result.input.annualMaintenance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.savings_outlined),
            tooltip: 'Pre-payment Simulator',
            onPressed: () =>
                context.push(AppRoutes.prepayment, extra: result),
          ),
          IconButton(
            icon: const Icon(Icons.compare_arrows_outlined),
            tooltip: 'Compare Scenarios',
            onPressed: () =>
                context.push(AppRoutes.scenario, extra: result.input),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF',
            onPressed: () => context.push(AppRoutes.pdf, extra: result),
          ),
        ],
      ),
      body: Column(
        children: [
          _SummaryRow(
            cards: [
              _SummaryCard(
                label: 'Monthly EMI',
                value: FormatUtils.toEmi(result.monthlyEmi),
                icon: Icons.calendar_month_outlined,
                color: AppTheme.primaryTeal,
              ),
              _SummaryCard(
                label: 'Total Interest',
                value: FormatUtils.toIndianCurrency(totalInterest),
                icon: Icons.trending_up_outlined,
                color: AppTheme.errorRed,
              ),
            ],
          ),
          _SummaryRow(
            cards: [
              _SummaryCard(
                label: 'Total Paid',
                value: FormatUtils.toIndianCurrency(totalPaid),
                icon: Icons.payments_outlined,
                color: AppTheme.primaryIndigo,
              ),
              _SummaryCard(
                label: 'Annual Cost',
                value: FormatUtils.toIndianCurrency(effectiveAnnualCost),
                icon: Icons.account_balance_wallet_outlined,
                color: AppTheme.accentAmber,
              ),
            ],
          ),
          const _AmortizationHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: result.schedule.length,
              itemBuilder: (ctx, i) => _AmortizationRow(
                row: result.schedule[i],
                isEven: i.isEven,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceXS,
      ),
      child: Row(
        children: cards
            .map((c) => Expanded(child: c))
            .toList(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.spaceXS),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _AmortizationHeader extends StatelessWidget {
  const _AmortizationHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryTeal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceSM,
      ),
      child: const Row(
        children: [
          Expanded(child: Text('Year', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(child: Text('Principal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
          Expanded(child: Text('Interest', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
          Expanded(child: Text('Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _AmortizationRow extends StatelessWidget {
  const _AmortizationRow({required this.row, required this.isEven});

  final AmortizationRow row;
  final bool isEven;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? Colors.white : AppTheme.surfaceLight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceSM,
      ),
      child: Row(
        children: [
          Expanded(child: Text('${row.year}')),
          Expanded(
            child: Text(
              FormatUtils.toIndianCurrency(row.principalPaid),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              FormatUtils.toIndianCurrency(row.interestPaid),
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppTheme.errorRed),
            ),
          ),
          Expanded(
            child: Text(
              FormatUtils.toIndianCurrency(row.remainingBalance),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
