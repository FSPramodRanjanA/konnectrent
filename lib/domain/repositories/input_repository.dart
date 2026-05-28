import 'package:konnectrent/domain/entities/rent_calc_input.dart';

/// Abstract contract for persisting/restoring user inputs.
abstract class InputRepository {
  /// Saves the current inputs to persistent storage.
  Future<void> saveInputs(RentCalcInput input);

  /// Returns the last saved inputs, or null if none exist.
  Future<RentCalcInput?> loadInputs();
}
