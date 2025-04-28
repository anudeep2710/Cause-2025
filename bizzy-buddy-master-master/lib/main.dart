import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/routes/app_router.dart';
import 'app/theme/app_theme.dart';
import 'app/providers/theme_provider.dart';
import 'models/employee.dart';
import 'models/expense.dart';
import 'models/product.dart';
import 'models/sale.dart';
import 'models/sustainability.dart';
import 'models/chat_message.dart';
import 'models/market_price.dart';
import 'providers/video_call_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Performance optimizations
  // Disable debug rendering options
  debugPaintSizeEnabled = false;
  debugPaintBaselinesEnabled = false;
  debugPaintLayerBordersEnabled = false;
  debugPaintPointersEnabled = false;

  // Optimize the engine
  if (kReleaseMode) {
    // Only enable in release mode for better debugging in dev
    debugProfileBuildsEnabled = false;
    debugProfileLayoutsEnabled = false;
    debugProfilePaintsEnabled = false;
  }

  // Set the max number of workers for compute operations
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // In release mode, exit the app when an unhandled exception occurs
      // This helps prevent UI freezes
      exit(1);
    }
  };

  // Initialize Hive
  await Hive.initFlutter();

  // Register time adapter
  Hive.registerAdapter(TimeOfDayAdapter());

  // Register Hive adapters
  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(GreenBadgeAdapter());
  Hive.registerAdapter(CarbonFootprintAdapter());
  Hive.registerAdapter(LocalSupplierAdapter());
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(MarketPriceAdapter());

  // Open Hive boxes
  await Hive.openBox<Employee>('employees');
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<Product>('products');
  await Hive.openBox<Sale>('sales');
  await Hive.openBox<GreenBadge>('badges');
  await Hive.openBox<CarbonFootprint>('carbon_footprint');
  await Hive.openBox<LocalSupplier>('local_suppliers');
  await Hive.openBox<ChatMessage>('chat_messages');
  await Hive.openBox<MarketPrice>('market_prices');
  await Hive.openBox('settings');
  await Hive.openBox('dashboard_state');

  // Initialize default language if needed

  runApp(
    const ProviderScope(
      child: BizzyBuddyApp(),
    ),
  );
}

class BizzyBuddyApp extends ConsumerWidget {
  const BizzyBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize Stream Video SDK
    // final videoProvider = ref.read(videoCallProvider);
    // videoProvider.initialize();

    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'BizzyBuddy',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.stylus,
              PointerDeviceKind.trackpad,
            },
          ),
          child: child!,
        );
      },
      checkerboardRasterCacheImages: false,
      checkerboardOffscreenLayers: false,
    );
  }
}
