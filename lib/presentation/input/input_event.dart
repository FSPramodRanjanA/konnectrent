import 'package:equatable/equatable.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';

sealed class InputEvent extends Equatable {
  const InputEvent();
}

class InputFieldChanged extends InputEvent {
  const InputFieldChanged({required this.field, required this.value});
  final String field;
  final String value;

  @override
  List<Object?> get props => [field, value];
}

class CalculatePressed extends InputEvent {
  const CalculatePressed();

  @override
  List<Object?> get props => [];
}

class RestoreLastSession extends InputEvent {
  const RestoreLastSession();

  @override
  List<Object?> get props => [];
}

class ResetInputs extends InputEvent {
  const ResetInputs();

  @override
  List<Object?> get props => [];
}

/// Apply a full [RentCalcInput] from a city preset or history load.
class ApplyPreset extends InputEvent {
  const ApplyPreset(this.input);
  final RentCalcInput input;

  @override
  List<Object?> get props => [input];
}

class TaxBenefitToggled extends InputEvent {
  const TaxBenefitToggled({required this.enabled});
  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

class TaxSlabChanged extends InputEvent {
  const TaxSlabChanged(this.slab);
  final int slab;

  @override
  List<Object?> get props => [slab];
}
