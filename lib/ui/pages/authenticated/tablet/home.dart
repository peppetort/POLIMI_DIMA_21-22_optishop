import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/products.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/tablet/categories.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('HomePage');

class HomeTabletPage extends StatefulWidget {
  const HomeTabletPage({Key? key}) : super(key: key);

  @override
  _HomeTabletPageState createState() => _HomeTabletPageState();
}

class _HomeTabletPageState extends State<HomeTabletPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<DataProvider>(context, listen: false).getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('Home build');

    List<CategoryModel> categories =
        context.select<DataProvider, List<CategoryModel>>(
            (value) => value.categories.values.toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('OptiShop'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          icon: const Icon(Icons.person_outline),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: categories.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: double.infinity,
                      //width: 130.0,
                      padding: const EdgeInsets.all(10.0),
                      child: CategoriesTabletPage(
                        categories: categories,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 7,
                    child: Builder(
                      builder: (context) {
                        _logger.info('HomePageBody build');
                        String? selectedCategory =
                            context.select<DataProvider, String?>(
                                (value) => value.selectedCategory);

                        bool isLoading = context.select<DataProvider, bool>(
                            (value) => value.isLoading);

                        return selectedCategory == null
                            ? Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20.0),
                                        //margin: const EdgeInsets.only(top: 30.0),
                                        child: Image.asset(
                                          'assets/images/Ill_inizia_a_usare_optishop.png',
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Inizia a usare OptiShop',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(height: 1.4),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 30.0),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25.0),
                                      child: Text(
                                        'Seleziona una categoria di prodotti e aggiungi al carrello quelli che vuoi acquistare',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .copyWith(
                                                color:
                                                    OptiShopAppTheme.primaryText,
                                                height: 1.5),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ProductPage(
                                    selectedCategoryId: selectedCategory,
                                  );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
