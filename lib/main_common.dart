import 'package:exness_clone/config/flavor_config.dart';
import 'package:exness_clone/core/app_router.dart';
import 'package:exness_clone/provider/datafeed_provider.dart';
import 'package:exness_clone/provider/theme_provider.dart';
import 'package:exness_clone/services/storage_service.dart';
import 'package:exness_clone/services/trading_view_service.dart';
import 'package:exness_clone/theme/theme.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/account/buy_sell_trade/cubit/trade_cubit.dart';
import 'package:exness_clone/view/account/withdraw_deposit/bloc/select_account_bloc.dart';
import 'package:exness_clone/view/account/withdraw_deposit/cubit/transaction_cubit.dart';
import 'package:exness_clone/view/account/withdraw_deposit/provider/bank_provider.dart';
import 'package:exness_clone/view/app_auth/app_auth_screen.dart';
import 'package:exness_clone/view/app_auth/provider/app_auth_provider.dart';
import 'package:exness_clone/view/auth_screen/login/bloc/login_bloc.dart';
import 'package:exness_clone/view/auth_screen/register/bloc/registration_bloc.dart';
import 'package:exness_clone/view/profile/add_account/bloc/bank_account_bloc.dart';
import 'package:exness_clone/view/profile/crypto_wallet/bloc/crypto_deposit/crypto_deposit_bloc.dart';
import 'package:exness_clone/view/profile/user_profile/bloc/user_profile_bloc.dart';
import 'package:exness_clone/view/trade/bloc/accounts_bloc.dart';
import 'package:exness_clone/wrapper/network_listener_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'cubit/bloc_observer/bloc_observer.dart';
import 'cubit/network/network_cubit.dart';
import 'cubit/symbol/symbol_cubit.dart';
import 'network/api_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  Bloc.observer = AppBlocObserver();

  await StorageService.initialize();
  ApiService.initialize();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AppAuthProvider()),
      ChangeNotifierProvider(create: (_) => DataFeedProvider()),
      ChangeNotifierProvider(create: (_) => DepositController()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
        BlocProvider<RegistrationBloc>(create: (context) => RegistrationBloc()),
        BlocProvider<UserProfileBloc>(create: (_) => UserProfileBloc()),
        BlocProvider<SelectedAccountCubit>(
            create: (_) => SelectedAccountCubit()),
        BlocProvider(create: (_) => AccountsBloc()..add(LoadAccounts())),
        BlocProvider(
            create: (_) => BankAccountBloc(
                userProfileBloc: context.read<UserProfileBloc>())),
        BlocProvider(create: (_) => DepositCryptoCubit()),
        BlocProvider(create: (_) => TransactionCubit()),
        BlocProvider<TradeCubit>(
          create: (context) => TradeCubit(),
        ),
        BlocProvider(create: (context) => NetworkCubit()),
    BlocProvider(
    create: (_) => SymbolCubit()..getAllSymbols()),
      ],
      child: MaterialApp.router(
        scaffoldMessengerKey: SnackBarService.messengerKey,
        debugShowCheckedModeBanner: false,
        title: FlavorConfig.title,
        darkTheme: AppThemeData.darkTheme,
        theme: AppThemeData.lightTheme,
        themeMode: themeProvider.themeMode,
        routerConfig: appRouter,
        builder: (context, child) {
          return NetworkListenerWrapper(child: child!);
        },
      ),
    );
  }
}
