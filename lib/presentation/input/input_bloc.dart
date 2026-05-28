import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konnectrent/domain/engine/rent_calc_engine.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';
import 'package:konnectrent/domain/repositories/input_repository.dart';
import 'package:konnectrent/domain/validation/input_validator.dart';
import 'package:konnectrent/domain/validation/validation_result.dart';
import 'package:konnectrent/presentation/input/input_event.dart';
import 'package:konnectrent/presentation/input/input_state.dart';

class InputBloc extends Bloc<InputEvent, InputState> {
  InputBloc({required InputRepository repository})
      : _repository = repository,
        super(InputState.initial()) {
    on<InputFieldChanged>(_onFieldChanged);
    on<CalculatePressed>(_onCalculate);
    on<RestoreLastSession>(_onRestore);
    on<ResetInputs>(_onReset);
    on<ApplyPreset>(_onApplyPreset);
    on<TaxBenefitToggled>(_onTaxToggled);
    on<TaxSlabChanged>(_onTaxSlabChanged);
  }

  final InputRepository _repository;

  void _onFieldChanged(InputFieldChanged event, Emitter<InputState> emit) {
    final updated = _applyField(state.inputs, event.field, event.value);
    final errors = Map<String, String>.from(state.fieldErrors);
    final err = InputValidator.validateField(event.field, event.value);
    if (err != null) {
      errors[event.field] = err;
    } else {
      errors.remove(event.field);
    }
    emit(state.copyWith(
      status: errors.isEmpty ? InputStatus.valid : InputStatus.invalid,
      inputs: updated,
      fieldErrors: errors,
    ),);
  }

  Future<void> _onCalculate(
    CalculatePressed event,
    Emitter<InputState> emit,
  ) async {
    final validation = InputValidator.validate(state.inputs);
    if (validation is Invalid) {
      emit(state.copyWith(
        status: InputStatus.invalid,
        fieldErrors: validation.fieldErrors,
      ),);
      return;
    }
    emit(state.copyWith(status: InputStatus.calculating),);
    final result = RentCalcEngine.calculate(state.inputs);
    await _repository.saveInputs(state.inputs);
    emit(state.copyWith(
      status: InputStatus.done,
      result: result,
      fieldErrors: const {},
    ),);
  }

  Future<void> _onRestore(
    RestoreLastSession event,
    Emitter<InputState> emit,
  ) async {
    final saved = await _repository.loadInputs();
    if (saved != null) {
      emit(state.copyWith(
        inputs: saved,
        status: InputStatus.valid,
        fieldErrors: const {},
      ),);
    }
  }

  void _onReset(ResetInputs event, Emitter<InputState> emit) {
    emit(InputState.initial());
  }

  void _onApplyPreset(ApplyPreset event, Emitter<InputState> emit) {
    emit(state.copyWith(
      inputs: event.input,
      status: InputStatus.valid,
      fieldErrors: const {},
    ),);
  }

  void _onTaxToggled(TaxBenefitToggled event, Emitter<InputState> emit) {
    emit(state.copyWith(
      inputs: state.inputs.copyWith(includeTaxBenefit: event.enabled),
    ),);
  }

  void _onTaxSlabChanged(TaxSlabChanged event, Emitter<InputState> emit) {
    emit(state.copyWith(
      inputs: state.inputs.copyWith(taxSlab: event.slab),
    ),);
  }

  RentCalcInput _applyField(RentCalcInput input, String field, String raw) {
    final value = double.tryParse(raw) ?? 0;
    switch (field) {
      case 'monthlyRent':
        return input.copyWith(monthlyRent: value);
      case 'annualRentIncrease':
        return input.copyWith(annualRentIncrease: value);
      case 'propertyPrice':
        return input.copyWith(propertyPrice: value);
      case 'downPayment':
        return input.copyWith(downPayment: value);
      case 'annualInterestRate':
        return input.copyWith(annualInterestRate: value);
      case 'loanTenureYears':
        return input.copyWith(loanTenureYears: value.toInt());
      case 'annualAppreciation':
        return input.copyWith(annualAppreciation: value);
      case 'annualMaintenance':
        return input.copyWith(annualMaintenance: value);
      case 'opportunityCostRate':
        return input.copyWith(opportunityCostRate: value);
      case 'stampDutyRate':
        return input.copyWith(stampDutyRate: value);
      case 'registrationRate':
        return input.copyWith(registrationRate: value);
      case 'monthlyIncome':
        return input.copyWith(monthlyIncome: value);
      case 'extraYearlyPayment':
        return input.copyWith(extraYearlyPayment: value);
      default:
        return input;
    }
  }
}
