import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/action_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/expanded_fab.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('FavoriteDetailsTabletPage');

class FavoriteDetailsTabletPage extends StatelessWidget {
  final String selectedPreferenceId;
  final VoidCallback onDelete;

  const FavoriteDetailsTabletPage(
      {Key? key, required this.selectedPreferenceId, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _logger.info('Favorite details tablet page build');

    double a = ((MediaQuery.of(context).size.width /
        MediaQuery.of(context).size.height));
    int productsPerRow = 3;

    if (a > 1.5) {
      productsPerRow = (a * 2).round();
    } else {
      productsPerRow = (a * 6).round();
    }

    //NOTE: setting lower and upper bounds
    if (productsPerRow < 1) {
      productsPerRow = 1;
    }
    if (productsPerRow > 5) {
      productsPerRow = 5;
    }

    List<String>? savedProducts =
        context.select<UserDataProvider, List<String>?>((value) => value
            .userShopPreferences[selectedPreferenceId]?.savedProducts.keys
            .toList());

    return savedProducts == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: productsPerRow,
                            mainAxisSpacing: 20.0,
                            crossAxisSpacing: 20.0,
                            childAspectRatio: 5 / 7,
                          ),
                          padding: const EdgeInsets.all(15.0),
                          itemCount: savedProducts.length,
                          itemBuilder: (BuildContext context, int index) {
                            String productId = savedProducts[index];

                            return Builder(builder: (context) {
                              int? quantity = context.select<UserDataProvider,
                                      int?>(
                                  (value) => value
                                      .userShopPreferences[selectedPreferenceId]
                                      ?.savedProducts[productId]);

                              return ProductCard(
                                selectedProductId: productId,
                                quantity: quantity ?? 0,
                                onRemoveCallback: () =>
                                    Provider.of<UserDataProvider>(context,
                                            listen: false)
                                        .removeProductFromReference(
                                            selectedPreferenceId, productId),
                                onAddCallback: () =>
                                    Provider.of<UserDataProvider>(context,
                                            listen: false)
                                        .addProductToPreference(
                                            selectedPreferenceId, productId),
                              );
                            });
                          }),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: BigElevatedButton(
                            onPressed: () {
                              Map<String, int>? savedProducts = context
                                  .read<UserDataProvider>()
                                  .userShopPreferences[selectedPreferenceId]
                                  ?.savedProducts;

                              if (savedProducts != null) {
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .createCart(savedProducts);
                                Navigator.pushNamed(context, '/results');
                              }
                            },
                            child: Text(
                              'Avvia ricerca'.toUpperCase(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 70.0,
                        )
                      ],
                    )
                  ],
                ),
                ExpandableFab(step: 60.0, children: [
                  ActionButton(
                    icon: const Icon(Icons.text_fields),
                    onPressed: () async {
                      String name = await showInputAlertDialog(context,
                          title: 'Inserisci un nome per la preferenza');

                      if (name != '') {
                        Provider.of<UserDataProvider>(context, listen: false)
                            .changePreferenceName(selectedPreferenceId, name);
                      }
                    },
                  ),
                  ActionButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                  )
                ]),
              ],
            ),
          );
  }
}
