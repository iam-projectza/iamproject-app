import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam/src/controllers/auth/firebase/authenication_repository.dart';
import 'package:iam/src/controllers/order_controller.dart';
import 'package:iam/src/helper/dependencies.dart' as dep;
import 'package:iam/src/helper/services/category_service.dart';
import 'package:iam/src/routes/route_helper.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register core services early
  Get.put(AuthenticationRepository());
  Get.put(CategoryService());

  // Initialize lightweight dependencies
  await dep.initLightweight();

  // Test OrderController registration
  print('🧪 TESTING ORDER CONTROLLER REGISTRATION...');
  try {
    final orderController = Get.find<OrderController>();
    print('✅ ORDER CONTROLLER SUCCESSFULLY REGISTERED');
    print('   - OrderRepo: ${orderController.orderRepo != null ? "✅" : "❌"}');
  } catch (e) {
    print('❌ ORDER CONTROLLER REGISTRATION FAILED: $e');
  }

  // Start heavy initialization in the background
  dep.initHeavy().then((_) {
    print('Heavy initialization complete');
  });

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'IAM App',
      debugShowCheckedModeBanner: false,
      initialRoute: RouteHelper.getInitialPage(),
      getPages: RouteHelper.routes,
      theme: ThemeData(
        useMaterial3: true,
      ),
      onUnknownRoute: (settings) => GetPageRoute(
        page: () => const Scaffold(
          body: Center(child: Text('404 - Page not found')),
        ),
      ),
    );
  }
}