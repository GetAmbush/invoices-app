import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:invoice_app/src/core/di/di.dart';
import 'package:invoice_app/src/core/presenter/routes/app_route.gr.dart';
import 'package:invoice_app/src/features/onboarding/domain/usecase/finished_onboarding.dart';

import 'src/app.dart';
import 'src/core/data/datasources/local_datasource.dart';

Future<void> main() async {
  configureDependencies(Environment.prod);
  await getIt.get<ILocalDataSource>().initLocalDataSource();
  runApp(App());
}

@RoutePage()
class MainPage extends StatelessWidget {
  MainPage({super.key});
  final IFinishedOnboarding _hasFinishedOnboarding = getIt();

  @override
  Widget build(BuildContext context) {
    route(context);
    return Container();
  }

  void route(BuildContext context) {
    if (_hasFinishedOnboarding.get()) {
      context.router.replace(InvoiceListRoute());
    } else {
      context.router.replace(const OnBoardingRoute());
    }
  }
}
