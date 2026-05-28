import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';
import 'package:konnectrent/presentation/chart/chart_screen.dart';
import 'package:konnectrent/presentation/input/input_screen.dart';
import 'package:konnectrent/presentation/loan/loan_details_screen.dart';
import 'package:konnectrent/presentation/pdf/pdf_screen.dart';
import 'package:konnectrent/presentation/prepayment/prepayment_screen.dart';
import 'package:konnectrent/presentation/rent_receipt/rent_receipt_screen.dart';
import 'package:konnectrent/presentation/results/results_screen.dart';
import 'package:konnectrent/presentation/scenario/scenario_screen.dart';

class AppRoutes {
  const AppRoutes._();
  static const input = '/input';
  static const results = '/results';
  static const chart = '/chart';
  static const loan = '/loan';
  static const pdf = '/pdf';
  static const prepayment = '/prepayment';
  static const scenario = '/scenario';
  static const rentReceipt = '/rent-receipt';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.input,
  routes: [
    GoRoute(
      path: AppRoutes.input,
      builder: (_, __) => const InputScreen(),
    ),
    GoRoute(
      path: AppRoutes.results,
      builder: (_, state) =>
          ResultsScreen(result: state.extra! as RentCalcResult),
    ),
    GoRoute(
      path: AppRoutes.chart,
      builder: (_, state) =>
          ChartScreen(input: state.extra! as RentCalcInput),
    ),
    GoRoute(
      path: AppRoutes.loan,
      builder: (_, state) =>
          LoanDetailsScreen(result: state.extra! as RentCalcResult),
    ),
    GoRoute(
      path: AppRoutes.pdf,
      builder: (_, state) =>
          PdfScreen(result: state.extra! as RentCalcResult),
    ),
    GoRoute(
      path: AppRoutes.prepayment,
      builder: (_, state) =>
          PrepaymentScreen(result: state.extra! as RentCalcResult),
    ),
    GoRoute(
      path: AppRoutes.scenario,
      builder: (_, state) =>
          ScenarioScreen(baseInput: state.extra! as RentCalcInput),
    ),
    GoRoute(
      path: AppRoutes.rentReceipt,
      builder: (_, __) => const RentReceiptScreen(),
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.error}')),
  ),
);
