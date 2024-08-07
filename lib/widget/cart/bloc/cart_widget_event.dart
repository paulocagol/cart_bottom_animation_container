part of 'cart_widget_bloc.dart';

sealed class CartWidgetEvent extends Equatable {
  const CartWidgetEvent();

  @override
  List<Object> get props => [];
}

class CartWidgetHideEvent extends CartWidgetEvent {}

class CartWidgetShowEvent extends CartWidgetEvent {}

class CartWidgetToggleEvent extends CartWidgetEvent {}

class CartWidgetAddEvent extends CartWidgetEvent {
  const CartWidgetAddEvent({
    required this.tag,
    required this.vsync,
    required this.product,
    required this.quantity,
  });

  final String tag;
  final int quantity;
  final Product product;
  final TickerProvider vsync;

  @override
  List<Object> get props => [product, quantity];
}

class CartWidgetRemoveEvent extends CartWidgetEvent {
  const CartWidgetRemoveEvent({required this.item});

  final CartItem item;

  @override
  List<Object> get props => [item];
}

class CartWidgetLoadEvent extends CartWidgetEvent {}

class CartWidgetClearEvent extends CartWidgetEvent {}

class CartWidgetShowErrorEvent extends CartWidgetEvent {
  const CartWidgetShowErrorEvent({
    required this.context,
    required this.error,
  });

  final BuildContext context;
  final String error;

  @override
  List<Object> get props => [error];
}
