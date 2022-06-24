import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/cart_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductAlert extends StatelessWidget {
  final String productId;
  final VoidCallback onClose;

  const ProductAlert({Key? key, required this.productId, required this.onClose})
      : super(key: key);

  List<double> _getAlertSize(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    double rectWidth = deviceWidth * 0.6;
    double rectHeight = 0;

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      rectHeight = deviceHeight / deviceWidth * rectWidth * 0.8;
    } else {
      rectHeight = deviceWidth / deviceHeight * rectWidth * 2;
    }

    return [rectWidth, rectHeight];
  }

  @override
  Widget build(BuildContext context) {
    List<double> alertSize = _getAlertSize(context);

    ProductModel? product = context.select<DataProvider, ProductModel?>(
        (value) => value.loadedProducts[productId]);

    int? cartQuantity =
        context.select<CartProvider, int?>((value) => value.cart[productId]);

    return AlertDialog(
      contentPadding: const EdgeInsets.only(bottom: 20.0),
      content: product == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            onClose();
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 30.0,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: alertSize.first,
                    height: alertSize.last,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: product.image == ''
                          ? Container()
                          : CachedNetworkImage(
                              imageUrl: product.image,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(
                                    color: OptiShopAppTheme.secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              product.description,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(
                                      color: OptiShopAppTheme.darkGray,
                                      fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                        cartQuantity != null
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ItemCounter(
                              number: cartQuantity,
                              addCallback: () =>
                                  Provider.of<CartProvider>(context, listen: false)
                                      .addToCart(productId),
                              removeCallback: () =>
                                  Provider.of<CartProvider>(context, listen: false)
                                      .removeFromCart(productId),
                            ),
                          ],
                        )
                            : InkWell(
                          onTap: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .addToCart(productId);
                          },
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: OptiShopAppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
