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

    return selectedProducts == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : selectedProducts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: Image.asset(
                        'assets/images/Ill_ooops_1.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Text(
                      'Non ci sono prodotti per questa categoria',
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 15.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 2 / 3,
                ),
                padding: const EdgeInsets.all(15.0),
                itemCount: selectedProducts.length,
                itemBuilder: (BuildContext context, int index) {
                  return ProductCard(
                    product: selectedProducts[index],
                  );
                });
  }
}
