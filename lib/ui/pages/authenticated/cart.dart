import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<ProductModel, int> cart = context.watch<CartProvider>().cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrello'),
        centerTitle: true,
        actions: [
          cart.isNotEmpty
              ? IconButton(
                  onPressed: () =>
                      Provider.of<CartProvider>(context, listen: false)
                          .emptyCart(),
                  icon: const Icon(Icons.delete_outline),
                )
              : Container(),
        ],
      ),
      body: cart.isEmpty
          ? Padding(
              padding: OptiShopAppTheme.defaultPagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    child: Image.asset(
                      'assets/images/Ill_inizia_a_esplorare.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Text(
                    'Non hai aggiunto nessun prodotto',
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 30.0),
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      'Esplora i prodotti per categorie e aggiungi al carello quelli che desideri acquistare.',
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: OptiShopAppTheme.primaryText, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  BigElevatedButton(
                    onPressed: () => {Navigator.pop(context)},
                    child: Text(
                      'inizia lo shopping'.toUpperCase(),
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (BuildContext context, int index) {
                            ProductModel product = cart.keys.toList()[index];

                            return Dismissible(
                              key: Key(product.id),
                              onDismissed: (direction) async {
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .removeFromCart(product, force: true);
                              },
                              direction: DismissDirection.endToStart,
                              dismissThresholds: const <DismissDirection,
                                  double>{
                                DismissDirection.endToStart: 0.7,
                              },
                              background: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30.0),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 3.0),
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
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 3.0, horizontal: 0),
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
                                                  width: 2,
                                                  color: OptiShopAppTheme.grey),
                                            )),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: CachedNetworkImage(
                                            imageUrl: product.image,
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                textAlign: TextAlign.start,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!
                                                    .copyWith(
                                                      color: OptiShopAppTheme
                                                          .secondaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                      color: OptiShopAppTheme
                                                          .darkGray,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Center(
                                          child: Text(
                                            'x${cart.values.toList()[index]}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .copyWith(
                                                  color: OptiShopAppTheme
                                                      .secondaryColor,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: OptiShopAppTheme.backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(
                                0, -10), // changes position of shadow
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28.0, vertical: 10.0),
                      child: Center(
                        child: BigElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/results'),
                          // Navigator.pushNamed(context, '/results'),
                          child: Text(
                            'Cerca il migliore'.toUpperCase(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
