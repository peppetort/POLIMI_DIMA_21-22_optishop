import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('ProductCard');

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _logger.info('ProductCard build ${product.id}');
    int? quantity =
        context.select<CartProvider, int?>((value) => value.cart[product]);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    width: 1,
                    color: quantity == null
                        ? OptiShopAppTheme.grey
                        : OptiShopAppTheme.primaryColor),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: ItemCounter(
                number: quantity ?? 0,
                addCallback: () =>
                    Provider.of<CartProvider>(context, listen: false)
                        .addToCart(product),
                removeCallback: () =>
                    Provider.of<CartProvider>(context, listen: false)
                        .removeFromCart(product),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5.0,
        ),
        Row(
          children: [
            Text(
              product.name,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: OptiShopAppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(
          height: 5.0,
        ),
        Row(
          children: [
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: OptiShopAppTheme.darkGray,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class ItemCounter extends StatelessWidget {
  final int number;
  final VoidCallback addCallback;
  final VoidCallback removeCallback;

  const ItemCounter(
      {Key? key,
      required this.number,
      required this.addCallback,
      required this.removeCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return number == 0
        ? Column(
            children: [
              InkWell(
                onTap: addCallback,
                child: Container(
                  decoration: const BoxDecoration(
                    color: OptiShopAppTheme.primaryColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          )
        : Column(
            children: [
              InkWell(
                onTap: addCallback,
                child: Container(
                  decoration: const BoxDecoration(
                    color: OptiShopAppTheme.primaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5.0),
                      topLeft: Radius.circular(5.0),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text(
                  number.toString(),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              InkWell(
                onTap: removeCallback,
                child: Container(
                  decoration: const BoxDecoration(
                    color: OptiShopAppTheme.primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                    ),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
  }
}
