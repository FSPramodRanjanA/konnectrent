import 'package:flutter/material.dart';
import 'package:konnectrent/core/di/injection.dart';
import 'package:konnectrent/core/theme/app_theme.dart';
import 'package:konnectrent/core/utils/format_utils.dart';
import 'package:konnectrent/domain/entities/calculation_snapshot.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';
import 'package:konnectrent/domain/repositories/history_repository.dart';
import 'package:intl/intl.dart';

/// Shows saved calculations as a modal bottom sheet.
/// Returns the selected [RentCalcResult] if user taps one, or null.
Future<RentCalcResult?> showHistorySheet(BuildContext context) {
  return showModalBottomSheet<RentCalcResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLG)),
    ),
    builder: (_) => const _HistorySheet(),
  );
}

class _HistorySheet extends StatefulWidget {
  const _HistorySheet();

  @override
  State<_HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<_HistorySheet> {
  final _repo = getIt<HistoryRepository>();
  List<CalculationSnapshot>? _snapshots;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _repo.loadAll();
    if (mounted) setState(() => _snapshots = list);
  }

  Future<void> _delete(String id) async {
    await _repo.delete(id);
    _load();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Delete all saved calculations?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _repo.clearAll();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshots = _snapshots;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppTheme.spaceSM),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
            child: Row(
              children: [
                Text(
                  'Saved Calculations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (snapshots != null && snapshots.isNotEmpty)
                  TextButton(
                    onPressed: _clearAll,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: snapshots == null
                ? const Center(child: CircularProgressIndicator())
                : snapshots.isEmpty
                    ? const Center(
                        child: Text(
                          'No saved calculations yet.\nTap ☆ on the Results screen to save.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        controller: scrollCtrl,
                        itemCount: snapshots.length,
                        itemBuilder: (_, i) =>
                            _SnapshotTile(
                              snapshot: snapshots[i],
                              onTap: () =>
                                  Navigator.pop(context, snapshots[i].result),
                              onDelete: () => _delete(snapshots[i].id),
                            ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({
    required this.snapshot,
    required this.onTap,
    required this.onDelete,
  });

  final CalculationSnapshot snapshot;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final r = snapshot.result;
    final verdictColor = r.verdict == Verdict.rentWins
        ? AppTheme.primaryTeal
        : AppTheme.primaryIndigo;
    final verdictLabel =
        r.verdict == Verdict.rentWins ? 'Rent wins' : 'Buy wins';
    final dateLabel =
        DateFormat('dd MMM yy, h:mm a').format(snapshot.savedAt);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: verdictColor.withAlpha(30),
        child: Icon(
          r.verdict == Verdict.rentWins
              ? Icons.home_outlined
              : Icons.house_outlined,
          color: verdictColor,
          size: 20,
        ),
      ),
      title: Text(snapshot.label),
      subtitle: Text(
        '$verdictLabel · ${FormatUtils.toIndianCurrency(r.rentAdvantage.abs())} diff · $dateLabel',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: onDelete,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
