import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/cart_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, int> cart = context.watch<CartProvider>().cart;

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
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(top: 30.0),
                      child: Image.asset(
                        'assets/images/Ill_inizia_a_esplorare.png',
                        fit: BoxFit.fitWidth,
                      ),
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
                      'Esplora i prodotti per categorie e aggiungi al carrello quelli che desideri acquistare.',
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
                            return CartCard(
                              productId: cart.keys.toList()[index],
                              onRemoveCallback: () => Provider.of<CartProvider>(
                                      context,
                                      listen: false)
                                  .removeFromCart(cart.keys.toList()[index]),
                              onDismissedCallback: () =>
                                  Provider.of<CartProvider>(context,
                                          listen: false)
                                      .removeFromCart(cart.keys.toList()[index],
                                          force: true),
                              onAddCallback: () => Provider.of<CartProvider>(
                                      context,
                                      listen: false)
                                  .addToCart(cart.keys.toList()[index]),
                              quantity: cart.values.toList()[index],
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
                            key: const Key('Search test key'),
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
