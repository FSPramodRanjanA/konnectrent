import 'package:equatable/equatable.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';

enum InputStatus { initial, valid, invalid, calculating, done }

/// Single state class for InputBloc — no sealed class hierarchy.
class InputState extends Equatable {
  const InputState({
    required this.status,
    required this.inputs,
    required this.fieldErrors,
    this.result,
  });

  final InputStatus status;
  final RentCalcInput inputs;
  final Map<String, String> fieldErrors;
  final RentCalcResult? result;

  factory InputState.initial() => InputState(
        status: InputStatus.initial,
        inputs: RentCalcInput.defaults(),
        fieldErrors: const {},
      );

  bool get isValid => fieldErrors.isEmpty && status != InputStatus.invalid;

  InputState copyWith({
    InputStatus? status,
    RentCalcInput? inputs,
    Map<String, String>? fieldErrors,
    RentCalcResult? result,
  }) =>
      InputState(
        status: status ?? this.status,
        inputs: inputs ?? this.inputs,
        fieldErrors: fieldErrors ?? this.fieldErrors,
        result: result ?? this.result,
      );

  @override
  List<Object?> get props => [status, inputs, fieldErrors, result];
}
