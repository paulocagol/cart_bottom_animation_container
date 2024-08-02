import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../controller/app_widget_cart_bottom_controller.dart';

class WidgetBackgroundContainer extends StatelessWidget {
  final Widget child;
  final AppWidgetCartBottomController controller;

  const WidgetBackgroundContainer({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: controller.currentExtentNotifier,
      builder: (context, currentExtent, child) {
        double borderRadiusValue = 16 * currentExtent;

        double shadowOpacity = 0.2 + (0.3 * currentExtent);

        double scaleEffect = currentExtent > controller.maxProportionalExtent
            ? 1.0 - (0.1 * (currentExtent - controller.maxProportionalExtent) * 5).clamp(0.0, 0.1)
            : 1.0;

        double translateEffect = currentExtent > controller.maxProportionalExtent
            ? 50 * (currentExtent - controller.maxProportionalExtent) * 5
            : 0.0;

        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(shadowOpacity),
              borderRadius: BorderRadius.circular(borderRadiusValue),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(shadowOpacity),
                  offset: const Offset(0, 0),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Transform.scale(
              scale: scaleEffect,
              child: Transform.translate(
                offset: Offset(0, translateEffect),
                child: ClipSmoothRect(
                  radius: const SmoothBorderRadius.all(
                    SmoothRadius(
                      cornerRadius: 30,
                      cornerSmoothing: 1,
                    ),
                  ),
                  child: child!,
                ),
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}
