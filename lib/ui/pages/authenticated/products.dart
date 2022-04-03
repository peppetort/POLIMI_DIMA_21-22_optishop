import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
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

    List<ProductModel>? selectedProducts =
        context.select<DataProvider, List<ProductModel>?>(
            (value) => value.productsByCategories[selectedCategoryId]);

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
    if (productsPerRow > 5) {
      productsPerRow = 5;
    }

    _logger.info('AspectRatio: $aspectRatio');
    _logger.info('Products per Row: $productsPerRow');

    //_logger.info(((MediaQuery.of(context).size.width / MediaQuery.of(context).size.height) * 7).round());

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
                  mainAxisSpacing: 15.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 2 / 3,
                ),
                padding: const EdgeInsets.all(15.0),
                itemCount: selectedProducts.length,
                itemBuilder: (BuildContext context, int index) {
                  return ProductCard(
                    selectedProduct: selectedProducts[index],
                  );
                });
  }
}
