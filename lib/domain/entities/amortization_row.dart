import 'package:equatable/equatable.dart';

/// One row of the annual amortization schedule.
class AmortizationRow extends Equatable {
  const AmortizationRow({
    required this.year,
    required this.principalPaid,
    required this.interestPaid,
    required this.remainingBalance,
  });

  final int year;
  final double principalPaid;
  final double interestPaid;
  final double remainingBalance;

  double get totalPaid => principalPaid + interestPaid;

  @override
  List<Object?> get props => [year, principalPaid, interestPaid, remainingBalance];
}
