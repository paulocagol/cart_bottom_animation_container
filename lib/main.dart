import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'adapter/cart_item_adapter.dart';
import 'adapter/product_adapter.dart';
import 'model/cart_item.dart';
import 'model/product.dart';
import 'repository/cart_repository.dart';
import 'screen/home_screen.dart';
import 'screen/product_screen.dart';
import 'widget/cart/app_widget_cart_bottom.dart';
import 'widget/cart/bloc/cart_widget_bloc.dart';
import 'widget/cart/controller/app_widget_cart_bottom_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CartItemAdapter());
  var cartBox = await Hive.openBox<CartItem>('cartBox');

  await cartBox.clear();
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

  final Box<CartItem> cartBox;

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

  final Box<CartItem> cartBox;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartWidgetBloc(
        cartRepository: CartRepository(cartBox),
        appWidgetCartBottomController: AppWidgetCartBottomController(context),
      ),
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
