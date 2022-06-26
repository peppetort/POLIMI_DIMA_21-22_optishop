import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/ShopPreferenceModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/cart_card.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('PreferenceDetailsPage');

class FavoriteDetailsPage extends StatelessWidget {
  final String selectedPreferenceId;

  const FavoriteDetailsPage({Key? key, required this.selectedPreferenceId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _logger.info('Preference details page build');

    ShopPreferenceModel? preference =
        context.select<UserDataProvider, ShopPreferenceModel?>(
            (value) => value.userShopPreferences[selectedPreferenceId]);

    List<String>? savedProducts =
        context.select<UserDataProvider, List<String>?>((value) => value
            .userShopPreferences[selectedPreferenceId]?.savedProducts.keys
            .toList());

    return Scaffold(
      appBar: AppBar(
        title: preference != null ? Text(preference.name) : const Text(''),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              String name = await showInputAlertDialog(context,
                  title: 'Inserisci un nome per la preferenza');

              if (name != '') {
                _logger.info('Nome selezionato $name');

                Provider.of<UserDataProvider>(context, listen: false)
                    .changePreferenceName(selectedPreferenceId, name);
              }
            },
            icon: const Icon(Icons.mode_outlined),
          ),
          IconButton(
            key: const Key("Delete preference test key"),
            onPressed: () {
              Provider.of<UserDataProvider>(context, listen: false)
                  .removePreference(selectedPreferenceId);
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
                            /*          String productId =
                                savedProducts.keys.toList()[index];*/
                            String productId = savedProducts[index];

                            return Builder(builder: (context) {
                              int? quantity = context.select<UserDataProvider,
                                      int?>(
                                  (value) => value
                                      .userShopPreferences[selectedPreferenceId]
                                      ?.savedProducts[productId]);

                              return CartCard(
                                productId: productId,
                                //quantity: savedProducts.values.toList()[index],
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
                                onDismissedCallback: () =>
                                    Provider.of<UserDataProvider>(context,
                                            listen: false)
                                        .removeProductFromReference(
                                            selectedPreferenceId, productId,
                                            delete: true),
                              );
                            });
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
                            Map<String, int>? savedProducts = context
                                .read<UserDataProvider>()
                                .userShopPreferences[selectedPreferenceId]
                                ?.savedProducts;

                            if (savedProducts != null) {
                              Provider.of<CartProvider>(context, listen: false)
                                  .createCart(savedProducts);
                              Navigator.pushNamed(context, '/results');
                            }
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
