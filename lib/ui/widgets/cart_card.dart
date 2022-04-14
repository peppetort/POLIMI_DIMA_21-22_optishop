import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartCard extends StatelessWidget {
  final String preferenceId;
  final String productId;
  final int quantity;

  const CartCard(
      {Key? key,
      required this.productId,
      required this.preferenceId,
      required this.quantity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    ProductModel? product = context.select<DataProvider, ProductModel?>(
        (value) => value.loadedProducts[productId]);

    return product == null
        ? Container()
        : Dismissible(
            key: Key(product.id),
            onDismissed: (direction) async {
              //TODO: rimuovere da preferito
            },
            direction: DismissDirection.endToStart,
            dismissThresholds: const <DismissDirection, double>{
              DismissDirection.endToStart: 0.7,
            },
            background: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              margin: const EdgeInsets.symmetric(vertical: 3.0),
              color: OptiShopAppTheme.secondaryColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.delete_outline,
                      color: OptiShopAppTheme.backgroundColor,
                    ),
                  ),
                ],
              ),
            ),
            child: SizedBox(
              height: 100.0,
              child: Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 3.0, horizontal: 0),
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                elevation: 2.0,
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            right: BorderSide(
                                width: 2, color: OptiShopAppTheme.grey),
                          )),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CachedNetworkImage(
                          imageUrl: product.image,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: OptiShopAppTheme.secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              product.description,
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color: OptiShopAppTheme.darkGray,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ItemCounter(
                      number: quantity,
                      addCallback: () =>
                          Provider.of<UserDataProvider>(context, listen: false)
                              .addProductToPreference(preferenceId, productId),
                      removeCallback: () =>
                          Provider.of<UserDataProvider>(context, listen: false)
                              .removeProductFromReference(
                                  preferenceId, productId),
                    )
                  ],
                ),
              ),
            ),
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
    return Row(
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
          padding: const EdgeInsets.symmetric(horizontal: 8.5, vertical: 5.0),
          color: Colors.white,
          child: Text(
            number.toString(),
            textAlign: TextAlign.center,
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
