import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konnectrent/core/theme/app_theme.dart';
import 'package:konnectrent/core/utils/format_utils.dart';
import 'package:konnectrent/domain/engine/rent_calc_engine.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';

class ScenarioScreen extends StatefulWidget {
  const ScenarioScreen({super.key, required this.baseInput});

  final RentCalcInput baseInput;

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  late RentCalcInput _inputA;
  late RentCalcInput _inputB;

  // Controllers for Scenario B editable fields
  late final TextEditingController _priceB;
  late final TextEditingController _downB;
  late final TextEditingController _rateB;
  late final TextEditingController _rentB;
  int _tenureB = 20;

  @override
  void initState() {
    super.initState();
    _inputA = widget.baseInput;
    _inputB = widget.baseInput;
    _priceB = TextEditingController(
      text: _inputB.propertyPrice.toInt().toString(),
    );
    _downB = TextEditingController(
      text: _inputB.downPayment.toInt().toString(),
    );
    _rateB = TextEditingController(
      text: _inputB.annualInterestRate.toString(),
    );
    _rentB = TextEditingController(
      text: _inputB.monthlyRent.toInt().toString(),
    );
    _tenureB = _inputB.loanTenureYears;
  }

  @override
  void dispose() {
    _priceB.dispose();
    _downB.dispose();
    _rateB.dispose();
    _rentB.dispose();
    super.dispose();
  }

  void _rebuildB() {
    setState(() {
      _inputB = _inputB.copyWith(
        propertyPrice: double.tryParse(_priceB.text) ?? _inputB.propertyPrice,
        downPayment: double.tryParse(_downB.text) ?? _inputB.downPayment,
        annualInterestRate:
            double.tryParse(_rateB.text) ?? _inputB.annualInterestRate,
        monthlyRent: double.tryParse(_rentB.text) ?? _inputB.monthlyRent,
        loanTenureYears: _tenureB,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultA = RentCalcEngine.calculate(_inputA);
    final resultB = RentCalcEngine.calculate(_inputB);

    return Scaffold(
      appBar: AppBar(title: const Text('Scenario Comparison')),
      body: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMD,
              vertical: AppTheme.spaceSM,
            ),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                Expanded(
                  child: Center(
                    child: Text(
                      'Scenario A',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Scenario B',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryIndigo,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Editable B fields
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
              children: [
                _CompareRow(
                  label: 'Monthly Rent',
                  valueA: FormatUtils.toIndianCurrency(_inputA.monthlyRent),
                  widgetB: _EditField(
                    controller: _rentB,
                    onChanged: (_) => _rebuildB(),
                  ),
                ),
                _CompareRow(
                  label: 'Property Price',
                  valueA: FormatUtils.toIndianCurrency(_inputA.propertyPrice),
                  widgetB: _EditField(
                    controller: _priceB,
                    onChanged: (_) => _rebuildB(),
                  ),
                ),
                _CompareRow(
                  label: 'Down Payment',
                  valueA: FormatUtils.toIndianCurrency(_inputA.downPayment),
                  widgetB: _EditField(
                    controller: _downB,
                    onChanged: (_) => _rebuildB(),
                  ),
                ),
                _CompareRow(
                  label: 'Interest Rate',
                  valueA: FormatUtils.toPercent(_inputA.annualInterestRate),
                  widgetB: _EditField(
                    controller: _rateB,
                    onChanged: (_) => _rebuildB(),
                    allowDecimal: true,
                  ),
                ),
                _CompareRow(
                  label: 'Tenure',
                  valueA: '${_inputA.loanTenureYears} yrs',
                  widgetB: DropdownButton<int>(
                    value: _tenureB,
                    isDense: true,
                    items: [10, 15, 20, 25, 30]
                        .map((y) => DropdownMenuItem(
                              value: y,
                              child: Text('$y yrs'),
                            ),)
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        _tenureB = v;
                        _rebuildB();
                      }
                    },
                  ),
                ),
                const Divider(height: AppTheme.spaceXL),
                // Results comparison
                _ResultRow(
                  label: 'Monthly EMI',
                  valueA: FormatUtils.toEmi(resultA.monthlyEmi),
                  valueB: FormatUtils.toEmi(resultB.monthlyEmi),
                  higherIsBetter: false,
                ),
                _ResultRow(
                  label: '10-yr Rent Total',
                  valueA: FormatUtils.toIndianCurrency(resultA.tenYearRentTotal),
                  valueB: FormatUtils.toIndianCurrency(resultB.tenYearRentTotal),
                  higherIsBetter: false,
                ),
                _ResultRow(
                  label: '10-yr Buy Total',
                  valueA: FormatUtils.toIndianCurrency(resultA.tenYearBuyTotal),
                  valueB: FormatUtils.toIndianCurrency(resultB.tenYearBuyTotal),
                  higherIsBetter: false,
                ),
                _ResultRow(
                  label: 'Verdict',
                  valueA: resultA.verdict == Verdict.rentWins
                      ? 'Rent Wins'
                      : 'Buy Wins',
                  valueB: resultB.verdict == Verdict.rentWins
                      ? 'Rent Wins'
                      : 'Buy Wins',
                ),
                _ResultRow(
                  label: 'Break-even',
                  valueA: resultA.breakEvenYear != null
                      ? 'Year ${resultA.breakEvenYear}'
                      : 'Never',
                  valueB: resultB.breakEvenYear != null
                      ? 'Year ${resultB.breakEvenYear}'
                      : 'Never',
                  higherIsBetter: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.valueA,
    required this.widgetB,
  });

  final String label;
  final String valueA;
  final Widget widgetB;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXS),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Center(
              child: Text(
                valueA,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppTheme.primaryTeal),
              ),
            ),
          ),
          Expanded(child: Center(child: widgetB)),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.valueA,
    required this.valueB,
    this.higherIsBetter,
  });

  final String label;
  final String valueA;
  final String valueB;
  final bool? higherIsBetter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSM),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                valueA,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                valueB,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryIndigo,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.onChanged,
    this.allowDecimal = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: TextField(
        controller: controller,
        keyboardType:
            TextInputType.numberWithOptions(decimal: allowDecimal),
        inputFormatters: [
          if (allowDecimal)
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
          else
            FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        onChanged: onChanged,
        style: const TextStyle(
          color: AppTheme.primaryIndigo,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
