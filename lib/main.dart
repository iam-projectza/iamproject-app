import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam/src/controllers/category_product_controller.dart';
import 'package:iam/src/helper/dependencies.dart' as dep;
import 'package:iam/src/routes/route_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize lightweight dependencies first
  await dep.initLightweight();

  runApp(const MyApp());

  // Perform heavy initialization in the background
  dep.initHeavy().then((_) {
    print('Heavy initialization complete');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryProductController>(builder: (_){
      return GetMaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        initialRoute: RouteHelper.getInitialPage(),
        getPages: RouteHelper.routes,
        theme: ThemeData(
        ),

      );

    });
  }
}