import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:konnectrent/core/di/injection.dart';
import 'package:konnectrent/core/router/app_router.dart';
import 'package:konnectrent/core/theme/app_theme.dart';
import 'package:konnectrent/domain/entities/city_preset.dart';
import 'package:konnectrent/domain/repositories/input_repository.dart';
import 'package:konnectrent/presentation/history/history_bottom_sheet.dart';
import 'package:konnectrent/presentation/input/input_bloc.dart';
import 'package:konnectrent/presentation/input/input_event.dart';
import 'package:konnectrent/presentation/input/input_state.dart';

class InputScreen extends StatelessWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InputBloc(repository: getIt<InputRepository>())
        ..add(const RestoreLastSession()),
      child: const _InputView(),
    );
  }
}

class _InputView extends StatelessWidget {
  const _InputView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<InputBloc, InputState>(
      listenWhen: (p, c) => c.status == InputStatus.done && c.result != null,
      listener: (ctx, state) =>
          ctx.go(AppRoutes.results, extra: state.result),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('KonnectRent'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Saved calculations',
              onPressed: () => _openHistory(context),
            ),
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined),
              tooltip: 'Rent Receipt',
              onPressed: () => context.push(AppRoutes.rentReceipt),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset to defaults',
              onPressed: () =>
                  context.read<InputBloc>().add(const ResetInputs()),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'About',
              onPressed: () => context.push(AppRoutes.about),
            ),
          ],
        ),
        body: const _InputForm(),
      ),
    );
  }

  Future<void> _openHistory(BuildContext context) async {
    final result = await showHistorySheet(context);
    if (result != null && context.mounted) {
      context.read<InputBloc>().add(ApplyPreset(result.input));
    }
  }
}

class _InputForm extends StatelessWidget {
  const _InputForm();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InputBloc, InputState>(
      builder: (ctx, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppTheme.spaceXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── City Preset picker ───────────────────────────────────────
              _CityPresetPicker(),
              // ── Rent section ─────────────────────────────────────────────
              _SectionCard(
                title: 'If You Rent',
                icon: Icons.home_outlined,
                color: AppTheme.primaryTeal,
                children: [
                  _NumericField(
                    label: 'Monthly Rent (₹)',
                    field: 'monthlyRent',
                    initialValue: state.inputs.monthlyRent.toInt().toString(),
                    error: state.fieldErrors['monthlyRent'],
                    hint: 'e.g. 20000',
                  ),
                  _NumericField(
                    label: 'Annual Rent Increase (%)',
                    field: 'annualRentIncrease',
                    initialValue: state.inputs.annualRentIncrease.toString(),
                    error: state.fieldErrors['annualRentIncrease'],
                    hint: '0–20',
                    allowDecimal: true,
                  ),
                ],
              ),
              // ── Buy section ───────────────────────────────────────────────
              _SectionCard(
                title: 'If You Buy',
                icon: Icons.house_outlined,
                color: AppTheme.primaryIndigo,
                children: [
                  _NumericField(
                    label: 'Property Price (₹)',
                    field: 'propertyPrice',
                    initialValue: state.inputs.propertyPrice.toInt().toString(),
                    error: state.fieldErrors['propertyPrice'],
                    hint: 'e.g. 6000000',
                  ),
                  _NumericField(
                    label: 'Down Payment (₹)',
                    field: 'downPayment',
                    initialValue: state.inputs.downPayment.toInt().toString(),
                    error: state.fieldErrors['downPayment'],
                    hint: 'e.g. 1200000',
                  ),
                  _NumericField(
                    label: 'Home Loan Interest Rate (%)',
                    field: 'annualInterestRate',
                    initialValue: state.inputs.annualInterestRate.toString(),
                    error: state.fieldErrors['annualInterestRate'],
                    hint: '5–20',
                    allowDecimal: true,
                  ),
                  _TenureDropdown(value: state.inputs.loanTenureYears),
                  _NumericField(
                    label: 'Annual Property Appreciation (%)',
                    field: 'annualAppreciation',
                    initialValue: state.inputs.annualAppreciation.toString(),
                    error: state.fieldErrors['annualAppreciation'],
                    hint: '0–15',
                    allowDecimal: true,
                  ),
                  _NumericField(
                    label: 'Annual Maintenance (₹)',
                    field: 'annualMaintenance',
                    initialValue:
                        state.inputs.annualMaintenance.toInt().toString(),
                    error: state.fieldErrors['annualMaintenance'],
                    hint: 'e.g. 10000',
                  ),
                  _NumericField(
                    label: 'Opportunity Cost Rate (%)',
                    field: 'opportunityCostRate',
                    initialValue: state.inputs.opportunityCostRate.toString(),
                    error: state.fieldErrors['opportunityCostRate'],
                    hint: 'Nifty 50 avg ~12%',
                    allowDecimal: true,
                  ),
                ],
              ),
              // ── Stamp Duty section ────────────────────────────────────────
              _SectionCard(
                title: 'Stamp Duty & Registration',
                icon: Icons.receipt_long_outlined,
                color: AppTheme.accentAmber,
                children: [
                  _NumericField(
                    label: 'Stamp Duty (%)',
                    field: 'stampDutyRate',
                    initialValue: state.inputs.stampDutyRate.toString(),
                    error: state.fieldErrors['stampDutyRate'],
                    hint: 'e.g. 5 (Maharashtra)',
                    allowDecimal: true,
                  ),
                  _NumericField(
                    label: 'Registration Charges (%)',
                    field: 'registrationRate',
                    initialValue: state.inputs.registrationRate.toString(),
                    error: state.fieldErrors['registrationRate'],
                    hint: 'Typically 1%',
                    allowDecimal: true,
                  ),
                ],
              ),
              // ── EMI Affordability ────────────────────────────────────────
              _SectionCard(
                title: 'EMI Affordability (Optional)',
                icon: Icons.account_balance_wallet_outlined,
                color: AppTheme.primaryTeal,
                children: [
                  _NumericField(
                    label: 'Monthly Income (₹)',
                    field: 'monthlyIncome',
                    initialValue: state.inputs.monthlyIncome > 0
                        ? state.inputs.monthlyIncome.toInt().toString()
                        : '',
                    error: state.fieldErrors['monthlyIncome'],
                    hint: 'Leave blank to skip',
                  ),
                ],
              ),
              // ── Tax Benefit section ───────────────────────────────────────
              _TaxBenefitSection(),
              // ── CTA ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMD,
                  vertical: AppTheme.spaceSM,
                ),
                child: state.status == InputStatus.calculating
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: () =>
                            ctx.read<InputBloc>().add(const CalculatePressed()),
                        icon: const Icon(Icons.calculate_outlined),
                        label: const Text('Calculate'),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── City Preset Picker ────────────────────────────────────────────────────────

class _CityPresetPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMD,
        AppTheme.spaceMD,
        AppTheme.spaceMD,
        0,
      ),
      child: Row(
        children: [
          const Icon(Icons.location_city_outlined,
              color: AppTheme.primaryTeal, size: 20,),
          const SizedBox(width: AppTheme.spaceSM),
          Text('Quick fill by city:',
              style: Theme.of(context).textTheme.bodyMedium,),
          const SizedBox(width: AppTheme.spaceSM),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('Select city'),
                isExpanded: true,
                items: CityPreset.all
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.name,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (name) {
                  if (name == null) return;
                  final preset = CityPreset.all
                      .firstWhere((c) => c.name == name);
                  context.read<InputBloc>().add(ApplyPreset(preset.input));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tax Benefit section ───────────────────────────────────────────────────────

class _TaxBenefitSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InputBloc, InputState>(
      builder: (ctx, state) {
        return _SectionCard(
          title: 'Tax Benefit (Sec 80C + 24b)',
          icon: Icons.savings_outlined,
          color: AppTheme.primaryIndigo,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Include Tax Benefit'),
              subtitle: const Text('Reduces effective buy cost'),
              value: state.inputs.includeTaxBenefit,
              activeThumbColor: AppTheme.primaryIndigo,
              onChanged: (v) =>
                  ctx.read<InputBloc>().add(TaxBenefitToggled(enabled: v)),
            ),
            if (state.inputs.includeTaxBenefit) ...[
              const SizedBox(height: AppTheme.spaceSM),
              DropdownButtonFormField<int>(
                initialValue: state.inputs.taxSlab,
                decoration: const InputDecoration(labelText: 'Tax Slab'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('0% (No Tax)')),
                  DropdownMenuItem(value: 5, child: Text('5% Slab')),
                  DropdownMenuItem(value: 20, child: Text('20% Slab')),
                  DropdownMenuItem(value: 30, child: Text('30% Slab')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ctx.read<InputBloc>().add(TaxSlabChanged(v));
                  }
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: AppTheme.spaceSM),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMD),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _NumericField extends StatefulWidget {
  const _NumericField({
    required this.label,
    required this.field,
    required this.initialValue,
    this.error,
    this.hint,
    this.allowDecimal = false,
  });

  final String label;
  final String field;
  final String initialValue;
  final String? error;
  final String? hint;
  final bool allowDecimal;

  @override
  State<_NumericField> createState() => _NumericFieldState();
}

class _NumericFieldState extends State<_NumericField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_NumericField old) {
    super.didUpdateWidget(old);
    // Sync controller when preset is applied
    if (old.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMD),
      child: Semantics(
        label: widget.label,
        child: TextFormField(
          key: ValueKey(widget.field),
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            errorText: widget.error,
          ),
          keyboardType:
              TextInputType.numberWithOptions(decimal: widget.allowDecimal),
          inputFormatters: [
            if (widget.allowDecimal)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            else
              FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (v) => context.read<InputBloc>().add(
                InputFieldChanged(field: widget.field, value: v),
              ),
        ),
      ),
    );
  }
}

class _TenureDropdown extends StatelessWidget {
  const _TenureDropdown({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMD),
      child: DropdownButtonFormField<int>(
        initialValue: value,
        decoration: const InputDecoration(labelText: 'Loan Tenure (years)'),
        items: const [10, 15, 20, 25, 30]
            .map((y) => DropdownMenuItem(
                  value: y,
                  child: Text('$y years'),
                ),)
            .toList(),
        onChanged: (y) {
          if (y != null) {
            context.read<InputBloc>().add(
                  InputFieldChanged(
                    field: 'loanTenureYears',
                    value: y.toString(),
                  ),
                );
          }
        },
      ),
    );
  }
}
