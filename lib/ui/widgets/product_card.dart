import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('ProductCard');

class ProductCard extends StatelessWidget {
  final String selectedProductId;
  final int quantity;
  final VoidCallback onAddCallback;
  final VoidCallback onRemoveCallback;

  const ProductCard(
      {Key? key,
      required this.selectedProductId,
      required this.onAddCallback,
      required this.onRemoveCallback,
      required this.quantity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _logger.info('ProductCard build $selectedProductId');

    Provider.of<DataProvider>(context, listen: false)
        .getProduct(selectedProductId);

    ProductModel? product = context.select<DataProvider, ProductModel?>(
        (value) => value.loadedProducts[selectedProductId]);

    return product == null
        ? Container(
            color: OptiShopAppTheme.grey,
          )
        : Column(
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
                          color: quantity == 0
                              ? OptiShopAppTheme.grey
                              : OptiShopAppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
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
                  Align(
                    alignment: Alignment.topRight,
                    child: ItemCounter(
                      number: quantity,
                      addCallback: () => onAddCallback(),
                      removeCallback: () => onRemoveCallback(),
                      prodId: selectedProductId,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      product.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: OptiShopAppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      product.description,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: OptiShopAppTheme.darkGray,
                          ),
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
  final String prodId;

  const ItemCounter(
      {Key? key,
      required this.number,
      required this.addCallback,
      required this.removeCallback,
      required this.prodId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return number == 0
        ? Column(
            children: [
              Material(
        child: InkWell(
          key: Key(prodId),
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
              ),
              ),
            ],
          )
        : Column(
            children: [
              Material(
      child: InkWell(
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
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.5, vertical: 5.0),
                color: Colors.white,
                child: Text(
                  number.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              Material(
    child: InkWell(
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
              ),
            ],
          );
  }
}
