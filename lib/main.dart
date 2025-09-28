import 'package:expense_tracker/common/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/app_router.dart';
import 'providers/storage_provider.dart';
import 'views/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageInitializer = ref.watch(storageInitializerProvider);

    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.generateRoute,
      navigatorKey: AppRouter.key,
      initialRoute: AppConstants.home,
      home: storageInitializer.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Text('Error initializing app:\n$error'),
          ),
        ),
        data: (data) => const HomeScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}