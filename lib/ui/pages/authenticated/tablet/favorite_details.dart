import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('FavoriteDetailsTabletPage');

class FavoriteDetailsTabletPage extends StatelessWidget {
  final String selectedPreferenceId;

  const FavoriteDetailsTabletPage(
      {Key? key, required this.selectedPreferenceId})
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
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: productsPerRow,
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 4 / 7,
            ),
            padding: const EdgeInsets.all(15.0),
            itemCount: savedProducts.length,
            itemBuilder: (BuildContext context, int index) {
              String productId = savedProducts[index];

              return Builder(builder: (context) {
                int? quantity = context.select<UserDataProvider, int?>(
                    (value) => value.userShopPreferences[selectedPreferenceId]
                        ?.savedProducts[productId]);

                return ProductCard(
                  selectedProductId: productId,
                  quantity: quantity ?? 0,
                  onRemoveCallback: () =>
                      Provider.of<UserDataProvider>(context, listen: false)
                          .removeProductFromReference(
                              selectedPreferenceId, productId),
                  onAddCallback: () => Provider.of<UserDataProvider>(context,
                          listen: false)
                      .addProductToPreference(selectedPreferenceId, productId),
                );
              });
            });
  }
}
