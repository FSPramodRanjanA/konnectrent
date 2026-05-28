import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konnectrent/core/theme/app_theme.dart';
import 'package:konnectrent/core/utils/format_utils.dart';
import 'package:konnectrent/domain/engine/rent_calc_engine.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';

class PrepaymentScreen extends StatefulWidget {
  const PrepaymentScreen({super.key, required this.result});

  final RentCalcResult result;

  @override
  State<PrepaymentScreen> createState() => _PrepaymentScreenState();
}

class _PrepaymentScreenState extends State<PrepaymentScreen> {
  final _controller = TextEditingController(text: '0');
  double _extraPayment = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  RentCalcInput get _updatedInput =>
      widget.result.input.copyWith(extraYearlyPayment: _extraPayment);

  @override
  Widget build(BuildContext context) {
    final input = _updatedInput;
    final (reducedYears, interestSaved) = RentCalcEngine.simulatePrepayment(input);
    final originalYears = widget.result.input.loanTenureYears;
    final yearsSaved = originalYears - reducedYears;

    final originalInterest = widget.result.schedule
        .fold<double>(0, (s, r) => s + r.interestPaid);

    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Payment Simulator')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extra Yearly Payment (₹)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.spaceSM),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: 'e.g. 50000',
                      prefixText: '₹ ',
                    ),
                    onChanged: (v) => setState(
                      () => _extraPayment = double.tryParse(v) ?? 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          Row(
            children: [
              Expanded(
                child: _ResultCard(
                  label: 'Original Tenure',
                  value: '$originalYears years',
                  icon: Icons.calendar_today_outlined,
                  color: AppTheme.primaryIndigo,
                ),
              ),
              const SizedBox(width: AppTheme.spaceSM),
              Expanded(
                child: _ResultCard(
                  label: 'New Tenure',
                  value: '$reducedYears years',
                  icon: Icons.timer_outlined,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Row(
            children: [
              Expanded(
                child: _ResultCard(
                  label: 'Years Saved',
                  value: yearsSaved > 0 ? '$yearsSaved years' : '—',
                  icon: Icons.savings_outlined,
                  color: AppTheme.accentAmber,
                ),
              ),
              const SizedBox(width: AppTheme.spaceSM),
              Expanded(
                child: _ResultCard(
                  label: 'Interest Saved',
                  value: interestSaved > 0
                      ? FormatUtils.toIndianCurrency(interestSaved)
                      : '—',
                  icon: Icons.trending_down_outlined,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMD),
          Card(
            color: AppTheme.primaryTeal.withAlpha(20),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Original total interest',
                    value: FormatUtils.toIndianCurrency(originalInterest),
                  ),
                  if (interestSaved > 0) ...[
                    _SummaryRow(
                      label: 'Interest saved',
                      value: '− ${FormatUtils.toIndianCurrency(interestSaved)}',
                      valueColor: AppTheme.primaryTeal,
                    ),
                    const Divider(),
                    _SummaryRow(
                      label: 'Net interest paid',
                      value: FormatUtils.toIndianCurrency(
                        originalInterest - interestSaved,
                      ),
                      bold: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_extraPayment > 0 && yearsSaved > 0)
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              child: Text(
                'By paying ${FormatUtils.toIndianCurrency(_extraPayment)} extra every year, '
                'you close your loan $yearsSaved years early and save '
                '${FormatUtils.toIndianCurrency(interestSaved)} in interest.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: valueColor,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
