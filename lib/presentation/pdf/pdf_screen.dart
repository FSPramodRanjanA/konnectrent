import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:konnectrent/core/ads/ad_manager.dart';
import 'package:konnectrent/core/di/injection.dart';
import 'package:konnectrent/core/pdf/pdf_generator.dart';
import 'package:konnectrent/core/theme/app_theme.dart';
import 'package:konnectrent/core/utils/format_utils.dart';
import 'package:konnectrent/core/widgets/ad_banner_widget.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';
import 'package:printing/printing.dart';

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key, required this.result});

  final RentCalcResult result;

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  bool _generating = false;
  bool _rewardEarned = false;

  /// Generates and shares the PDF directly (called after reward earned).
  Future<void> _generateAndShare() async {
    setState(() => _generating = true);
    try {
      final bytes = await compute(PdfGenerator.build, widget.result);
      if (!mounted) return;
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'konnectrent_report.pdf',
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  /// Shows rewarded ad first — generates PDF only after user earns reward.
  void _onGeneratePressed() {
    // If reward already earned this session, skip the ad
    if (_rewardEarned) {
      _generateAndShare();
      return;
    }

    final adManager = getIt<AdManager>();
    adManager.showRewarded(
      onRewarded: () {
        setState(() => _rewardEarned = true);
        _generateAndShare();
      },
      onNotReady: () {
        // Ad not loaded yet — allow export for free with a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad not available — exporting for free this time.'),
            duration: Duration(seconds: 2),
          ),
        );
        _generateAndShare();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      appBar: AppBar(title: const Text('Export PDF')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: AppTheme.primaryTeal,
                        size: 28,
                      ),
                      const SizedBox(width: AppTheme.spaceSM),
                      Text(
                        'Report Preview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const Divider(height: AppTheme.spaceXL),
                  _PreviewRow(
                    label: 'Verdict',
                    value: result.verdict == Verdict.rentWins
                        ? 'Renting is cheaper'
                        : result.verdict == Verdict.buyWins
                            ? 'Buying is cheaper'
                            : 'Break-even',
                  ),
                  _PreviewRow(
                    label: 'Monthly EMI',
                    value: FormatUtils.toEmi(result.monthlyEmi),
                  ),
                  _PreviewRow(
                    label: '10-yr Rent Total',
                    value: FormatUtils.toIndianCurrency(result.tenYearRentTotal),
                  ),
                  _PreviewRow(
                    label: '10-yr Buy Total',
                    value: FormatUtils.toIndianCurrency(result.tenYearBuyTotal),
                  ),
                  _PreviewRow(
                    label: 'You Save',
                    value: FormatUtils.toIndianCurrency(
                      result.rentAdvantage.abs(),
                    ),
                  ),
                  if (result.breakEvenYear != null)
                    _PreviewRow(
                      label: 'Break-even Year',
                      value: '${result.breakEvenYear}',
                    ),
                  const SizedBox(height: AppTheme.spaceSM),
                  const _SectionTag(label: '✓ Input summary table'),
                  const _SectionTag(label: '✓ Cost comparison (10yr / 20yr)'),
                  const _SectionTag(label: '✓ Full amortization schedule'),
                  const _SectionTag(label: '✓ Disclaimer'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          _generating
              ? const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppTheme.spaceSM),
                      Text('Generating PDF…'),
                    ],
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: _onGeneratePressed,
                  icon: Icon(
                    _rewardEarned
                        ? Icons.share_outlined
                        : Icons.play_circle_outline,
                  ),
                  label: Text(
                    _rewardEarned
                        ? 'Generate & Share PDF'
                        : 'Watch Ad to Export PDF',
                  ),
                ),
          const SizedBox(height: AppTheme.spaceSM),
          Text(
            _rewardEarned
                ? 'PDF is generated on-device and shared via your system share sheet.'
                : 'Watch a short ad to unlock the PDF export.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceMD),
          const Center(child: AdBannerWidget()),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

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
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SectionTag extends StatelessWidget {
  const _SectionTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spaceXS),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppTheme.primaryTeal,
          ),
          const SizedBox(width: AppTheme.spaceXS),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
