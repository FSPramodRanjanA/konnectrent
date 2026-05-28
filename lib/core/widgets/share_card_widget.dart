import 'package:flutter/material.dart';
import 'package:konnectrent/core/theme/app_theme.dart';
import 'package:konnectrent/core/utils/format_utils.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Captures a result card as a PNG and shares it via system share sheet.
Future<void> shareResultCard(
  BuildContext context,
  RentCalcResult result,
) async {
  final controller = ScreenshotController();
  final bytes = await controller.captureFromLongWidget(
    _ShareCard(result: result),
    pixelRatio: 2.5,
    context: context,
  );
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/konnectrent_result.png');
  await file.writeAsBytes(bytes);
  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Calculated with KonnectRent 🏠',
  );
}

/// The visual card that gets rendered into an image.
class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.result});

  final RentCalcResult result;

  @override
  Widget build(BuildContext context) {
    final isRentWins = result.verdict == Verdict.rentWins;
    final bgColor =
        isRentWins ? AppTheme.rentWinsBackground : AppTheme.buyWinsBackground;
    final verdictLabel = isRentWins ? 'Renting is cheaper' : 'Buying is cheaper';

    return Material(
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgColor, bgColor.withAlpha(200)],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.home_work_outlined, color: Colors.white, size: 28),
                SizedBox(width: AppTheme.spaceSM),
                Text(
                  'KonnectRent',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              verdictLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              'Save ${FormatUtils.toIndianCurrency(result.rentAdvantage.abs())} over 10 years',
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            const Divider(color: Colors.white30),
            const SizedBox(height: AppTheme.spaceSM),
            _Stat(
              label: 'Monthly EMI',
              value: FormatUtils.toEmi(result.monthlyEmi),
            ),
            _Stat(
              label: '10-yr Rent Total',
              value: FormatUtils.toIndianCurrency(result.tenYearRentTotal),
            ),
            _Stat(
              label: '10-yr Buy Total',
              value: FormatUtils.toIndianCurrency(result.tenYearBuyTotal),
            ),
            if (result.breakEvenYear != null)
              _Stat(
                label: 'Break-even Year',
                value: 'Year ${result.breakEvenYear}',
              ),
            const SizedBox(height: AppTheme.spaceMD),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'konnectrent.app',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
