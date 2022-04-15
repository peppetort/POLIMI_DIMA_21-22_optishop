import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/ShopPreferenceModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/cart_card.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('PreferenceDetailsPage');

class FavoriteDetailsPage extends StatelessWidget {
  final ShopPreferenceModel preference;

  const FavoriteDetailsPage({Key? key, required this.preference})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _logger.info('Preference details page build');

    Map<String, dynamic>? savedProducts = context
        .watch<UserDataProvider>()
        .userShopPreferences[preference.id]
        ?.savedProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(preference.name),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              //TODO: modificare nome
            },
            icon: const Icon(Icons.mode_outlined),
          ),
          IconButton(
            onPressed: () {
              Provider.of<UserDataProvider>(context, listen: false)
                  .removePreference(preference.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline),
          )
        ],
      ),
      body: savedProducts == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          itemCount: savedProducts.length,
                          itemBuilder: (BuildContext context, int index) {
                            String productId =
                                savedProducts.keys.toList()[index];

                            return CartCard(
                              productId: productId,
                              quantity: savedProducts.values.toList()[index],
                              onRemoveCallback: () =>
                                  Provider.of<UserDataProvider>(context,
                                          listen: false)
                                      .removeProductFromReference(
                                          preference.id, productId),
                              onAddCallback: () =>
                                  Provider.of<UserDataProvider>(context,
                                          listen: false)
                                      .addProductToPreference(
                                          preference.id, productId),
                              onDismissedCallback: () =>
                                  Provider.of<UserDataProvider>(context,
                                          listen: false)
                                      .removeProductFromReference(
                                          preference.id, productId,
                                          delete: true),
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
                          onPressed: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .createCart(savedProducts);
                            Navigator.pushNamed(context, '/results');
                          },
                          child: Text(
                            'Avvia ricerca'.toUpperCase(),
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
