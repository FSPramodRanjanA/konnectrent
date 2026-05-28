import 'package:konnectrent/domain/entities/calculation_snapshot.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';

/// Abstract contract for persisting calculation history.
abstract class HistoryRepository {
  Future<void> save(RentCalcResult result, String label);
  Future<List<CalculationSnapshot>> loadAll();
  Future<void> delete(String id);
  Future<void> clearAll();
}
