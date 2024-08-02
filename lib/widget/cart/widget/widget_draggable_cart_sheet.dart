import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

import '../controller/app_widget_cart_bottom_controller.dart';
import 'widget_horizontal_list_cart.dart';
import 'widget_vertical_list_cart.dart';

class WidgetDraggableSheet extends StatelessWidget {
  final AppWidgetCartBottomController controller;

  const WidgetDraggableSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: DraggableSheet(
        controller: controller.sheetController,
        minExtent: Extent.proportional(controller.minProportionalExtent),
        maxExtent: Extent.proportional(controller.maxProportionalExtent),
        initialExtent: Extent.proportional(controller.minProportionalExtent),
        physics: BouncingSheetPhysics(
          parent: SnappingSheetPhysics(
            snappingBehavior: SnapToNearest(
              snapTo: [
                Extent.proportional(controller.minProportionalExtent),
                Extent.proportional(controller.middleProportionalExtent),
                Extent.proportional(controller.maxProportionalExtent),
              ],
            ),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.currentExtent <= controller.maxProportionalExtent)
                  Container(
                    height: 10,
                    width: 100,
                    decoration: ShapeDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    child: Divider(
                      thickness: 2,
                      color: Colors.white.withOpacity(0.5),
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2 + (0.3 * controller.currentExtent)),
                        blurRadius: 10,
                        spreadRadius: 0.1,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: constraints.maxHeight - 10,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(33)),
                      child: Navigator(
                        key: controller.navigatorKey,
                        observers: [controller.heroController],
                        onGenerateRoute: (RouteSettings settings) {
                          return PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 800),
                            reverseTransitionDuration: const Duration(milliseconds: 800),
                            barrierColor: Theme.of(context).colorScheme.secondary,
                            opaque: true,
                            settings: settings,
                            pageBuilder: (context, animation, secondaryAnimation) {
                              if (settings.name == "/vertical") {
                                return WidgetVerticalListCart(
                                  cartItemKeys: controller.cartItemKeys,
                                  scrollController: controller.scrollController,
                                );
                              }
                              return WidgetHorizontalListCart(controller: controller);
                            },
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.fastOutSlowIn;

                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
