import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavaloon_assessment/presentation/config/routes.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/cart/cart_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/cart/cart_state.dart';

class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (previous, current) => previous.itemCount != current.itemCount,
      builder: (context, state) {
        return IconButton(
          tooltip: 'Cart',
          onPressed: () => Navigator.of(context).pushNamed(Routes.cart),
          icon: Badge.count(
            count: state.itemCount,
            isLabelVisible: state.itemCount > 0,
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        );
      },
    );
  }
}
