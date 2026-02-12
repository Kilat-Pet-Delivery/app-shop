import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bootstrap.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/notification/presentation/cubit/notification_cubit.dart';
import 'features/notification/presentation/cubit/notification_preferences_cubit.dart';
import 'features/shop_dashboard/presentation/cubit/shop_dashboard_cubit.dart';

class KilatShopApp extends StatelessWidget {
  const KilatShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
        BlocProvider(create: (_) => getIt<ShopDashboardCubit>()),
        BlocProvider(create: (_) => getIt<NotificationCubit>()),
        BlocProvider(create: (_) => getIt<NotificationPreferencesCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Kilat Pet Shop',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter.router,
      ),
    );
  }
}
