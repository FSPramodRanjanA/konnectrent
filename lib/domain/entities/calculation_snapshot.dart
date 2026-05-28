import 'package:equatable/equatable.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';

/// A saved calculation result with a user label and timestamp.
class CalculationSnapshot extends Equatable {
  const CalculationSnapshot({
    required this.id,
    required this.label,
    required this.result,
    required this.savedAt,
  });

  final String id;
  final String label;
  final RentCalcResult result;
  final DateTime savedAt;

  @override
  List<Object?> get props => [id, label, result, savedAt];
}
