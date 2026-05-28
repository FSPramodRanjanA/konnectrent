import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';
import 'package:konnectrent/domain/repositories/input_repository.dart';
import 'package:konnectrent/presentation/input/input_bloc.dart';
import 'package:konnectrent/presentation/input/input_event.dart';
import 'package:konnectrent/presentation/input/input_state.dart';

class MockInputRepository extends Mock implements InputRepository {}

void main() {
  late MockInputRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(RentCalcInput.defaults());
  });

  setUp(() {
    mockRepo = MockInputRepository();
    when(() => mockRepo.loadInputs()).thenAnswer((_) async => null);
    when(() => mockRepo.saveInputs(any())).thenAnswer((_) async {});
  });

  group('RestoreLastSession', () {
    blocTest<InputBloc, InputState>(
      'emits valid state when saved inputs exist',
      build: () {
        when(() => mockRepo.loadInputs())
            .thenAnswer((_) async => RentCalcInput.defaults());
        return InputBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const RestoreLastSession()),
      expect: () => [
        isA<InputState>().having(
          (s) => s.status,
          'status',
          InputStatus.valid,
        ),
      ],
    );

    blocTest<InputBloc, InputState>(
      'emits nothing when no saved inputs',
      build: () => InputBloc(repository: mockRepo),
      act: (bloc) => bloc.add(const RestoreLastSession()),
      expect: () => [],
    );
  });

  group('InputFieldChanged', () {
    blocTest<InputBloc, InputState>(
      'updates monthlyRent and clears error for valid value',
      build: () => InputBloc(repository: mockRepo),
      act: (bloc) => bloc.add(
        const InputFieldChanged(field: 'monthlyRent', value: '25000'),
      ),
      expect: () => [
        isA<InputState>()
            .having((s) => s.inputs.monthlyRent, 'monthlyRent', 25000)
            .having((s) => s.fieldErrors.containsKey('monthlyRent'), 'no error', false),
      ],
    );

    blocTest<InputBloc, InputState>(
      'adds field error for invalid value',
      build: () => InputBloc(repository: mockRepo),
      act: (bloc) => bloc.add(
        const InputFieldChanged(field: 'monthlyRent', value: '0'),
      ),
      expect: () => [
        isA<InputState>()
            .having((s) => s.status, 'status', InputStatus.invalid)
            .having(
              (s) => s.fieldErrors.containsKey('monthlyRent'),
              'has error',
              true,
            ),
      ],
    );

    blocTest<InputBloc, InputState>(
      'updates loanTenureYears as int',
      build: () => InputBloc(repository: mockRepo),
      act: (bloc) => bloc.add(
        const InputFieldChanged(field: 'loanTenureYears', value: '15'),
      ),
      expect: () => [
        isA<InputState>().having(
          (s) => s.inputs.loanTenureYears,
          'loanTenureYears',
          15,
        ),
      ],
    );
  });

  group('CalculatePressed', () {
    blocTest<InputBloc, InputState>(
      'emits [calculating, done] with valid inputs',
      build: () => InputBloc(repository: mockRepo),
      seed: () => InputState(
        status: InputStatus.valid,
        inputs: RentCalcInput.defaults(),
        fieldErrors: const {},
      ),
      act: (bloc) => bloc.add(const CalculatePressed()),
      expect: () => [
        isA<InputState>().having(
          (s) => s.status,
          'calculating',
          InputStatus.calculating,
        ),
        isA<InputState>()
            .having((s) => s.status, 'done', InputStatus.done)
            .having((s) => s.result, 'result not null', isNotNull),
      ],
    );

    blocTest<InputBloc, InputState>(
      'emits invalid state when validation fails',
      build: () => InputBloc(repository: mockRepo),
      seed: () => InputState(
        status: InputStatus.initial,
        inputs: RentCalcInput.defaults().copyWith(monthlyRent: 0),
        fieldErrors: const {},
      ),
      act: (bloc) => bloc.add(const CalculatePressed()),
      expect: () => [
        isA<InputState>().having(
          (s) => s.status,
          'invalid',
          InputStatus.invalid,
        ),
      ],
    );

    blocTest<InputBloc, InputState>(
      'saves inputs to repository on successful calculate',
      build: () => InputBloc(repository: mockRepo),
      seed: () => InputState(
        status: InputStatus.valid,
        inputs: RentCalcInput.defaults(),
        fieldErrors: const {},
      ),
      act: (bloc) => bloc.add(const CalculatePressed()),
      verify: (_) => verify(() => mockRepo.saveInputs(any())).called(1),
    );
  });

  group('ResetInputs', () {
    blocTest<InputBloc, InputState>(
      'returns to initial state',
      build: () => InputBloc(repository: mockRepo),
      seed: () => InputState(
        status: InputStatus.valid,
        inputs: RentCalcInput.defaults().copyWith(monthlyRent: 50000),
        fieldErrors: const {},
      ),
      act: (bloc) => bloc.add(const ResetInputs()),
      expect: () => [
        isA<InputState>().having(
          (s) => s.status,
          'initial',
          InputStatus.initial,
        ),
      ],
    );
  });
}
