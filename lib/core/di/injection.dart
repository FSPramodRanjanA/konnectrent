import 'package:get_it/get_it.dart';
import 'package:konnectrent/core/ads/ad_manager.dart';
import 'package:konnectrent/data/repositories/history_repository_impl.dart';
import 'package:konnectrent/data/repositories/input_repository_impl.dart';
import 'package:konnectrent/domain/repositories/history_repository.dart';
import 'package:konnectrent/domain/repositories/input_repository.dart';
import 'package:konnectrent/presentation/input/input_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton<InputRepository>(() => InputRepositoryImpl());
  getIt.registerLazySingleton<HistoryRepository>(() => HistoryRepositoryImpl());
  getIt.registerFactory<InputBloc>(
    () => InputBloc(repository: getIt<InputRepository>()),
  );
  final adManager = AdManager();
  getIt.registerSingleton<AdManager>(adManager);
  await adManager.init();
}
