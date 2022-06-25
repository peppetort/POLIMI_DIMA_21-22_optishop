import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('ProductPage');

class ProductPage extends StatelessWidget {
  final String selectedCategoryId;

  const ProductPage({Key? key, required this.selectedCategoryId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _logger.info('ProductPage build $selectedCategoryId');

    List<String>? selectedProducts =
        context.select<DataProvider, List<String>?>(
            (value) => value.productsByCategory[selectedCategoryId]);

    double aspectRatio = ((MediaQuery.of(context).size.width /
        MediaQuery.of(context).size.height));
    int productsPerRow = 3;

    if (aspectRatio > 1.5) {
      productsPerRow = (aspectRatio * 3).round();
    } else {
      productsPerRow = (aspectRatio * 6).round();
    }

    //NOTE: setting lower and upper bounds
    if (productsPerRow < 1) {
      productsPerRow = 1;
    }
    if (productsPerRow > 7) {
      productsPerRow = 7;
    }

    _logger.info('AspectRatio: $aspectRatio');
    _logger.info('Products per Row: $productsPerRow');

    return selectedProducts == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : selectedProducts.isEmpty
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Image.asset('assets/images/Ill_ooops_1.png',
                            fit: BoxFit.contain),
                      ),
                    ),
                    Text(
                      'Non ci sono prodotti per questa categoria',
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                  ],
                ),
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: productsPerRow,
                  mainAxisSpacing: 20.0,
                  crossAxisSpacing: 20.0,
                  childAspectRatio: 4/7,
                ),
                padding: const EdgeInsets.all(15.0),
                itemCount: selectedProducts.length,
                itemBuilder: (BuildContext context, int index) {
                  String productId = selectedProducts[index];

                  return Builder(builder: (context) {
                    int? quantity = context.select<CartProvider, int?>(
                        (value) => value.cart[productId]);

                    return ProductCard(
                      selectedProductId: productId,
                      onAddCallback: () =>
                          Provider.of<CartProvider>(context, listen: false)
                              .addToCart(productId),
                      onRemoveCallback: () =>
                          Provider.of<CartProvider>(context, listen: false)
                              .removeFromCart(productId),
                      quantity: quantity ?? 0,
                    );
                  });
                });
  }
}
