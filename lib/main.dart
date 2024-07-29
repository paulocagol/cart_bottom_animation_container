import 'package:cart_bottom_animation_container/widget/cart/app_widget_cart_bottom.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'screen/home_screen.dart';
import 'widget/cart/cubit/cart_cubit.dart';

void main() {
  runApp(DevicePreview(
    enabled: true,
    builder: (context) => const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit(),
      child: MaterialApp(
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        title: 'Device Preview Example',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const WrapCartBottom(),
      ),
    );
  }
}

class WrapCartBottom extends StatelessWidget {
  const WrapCartBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return AppWidgetCartBottom(child: const HomeScreen());
  }
}
