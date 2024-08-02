import 'package:cart_bottom_animation_container/repository/cart_repository.dart';
import 'package:cart_bottom_animation_container/widget/cart/app_widget_cart_bottom.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'adapter/product_adapter.dart';
import 'model/product.dart';
import 'screen/home_screen.dart';
import 'screen/product_screen.dart';
import 'widget/cart/cubit/cart_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  var cartBox = await Hive.openBox<Product>('cartBox');

  // await cartBox.clear();
  runApp(DevicePreview(
    enabled: true,
    builder: (context) => App(cartBox: cartBox),
  ));
}

class App extends StatelessWidget {
  const App({
    super.key,
    required this.cartBox,
  });

  final Box<Product> cartBox;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Device Preview Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WrapCartBottom(cartBox: cartBox),
    );
  }
}

class WrapCartBottom extends StatelessWidget {
  const WrapCartBottom({
    super.key,
    required this.cartBox,
  });

  final Box<Product> cartBox;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit(CartRepository(cartBox)),
      child: AppWidgetCartBottom(
        child: Navigator(
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/product':
                page = ProductScreen(product: settings.arguments as Product);
                break;
              case '/':
              default:
                page = const HomeScreen();
            }
            return MaterialPageRoute(builder: (_) => page);
          },
        ),
      ),
    );
  }
}
