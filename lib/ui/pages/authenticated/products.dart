import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/product_cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsPage extends StatefulWidget {
  final CategoryModel initialCategory;

  const ProductsPage({Key? key, required this.initialCategory})
      : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<CategoryModel>? categories;
  List<ProductModel>? selectedProducts;
  late int _selectedTab;
  bool _isLoading = false;

  @override
  void initState() {
    Provider.of<DataProvider>(context, listen: false)
        .getProductsByCategory(widget.initialCategory);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    categories = Provider.of<DataProvider>(context).categories;
    selectedProducts =
        Provider.of<DataProvider>(context).productsOfSelectedCategory;

    if (categories != null) {
      _selectedTab = categories!
          .indexWhere((element) => element.id == widget.initialCategory.id);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prodotti'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              //TODO: push cart page
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: categories == null
          ? const Center(
              child: CupertinoActivityIndicator(
                radius: 20.0,
              ),
            )
          : SafeArea(
              bottom: false,
              child: DefaultTabController(
                length: categories!.length,
                initialIndex: _selectedTab,
                child: Column(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxHeight: 130.0),
                      child: Material(
                        color: OptiShopAppTheme.backgroundColor,
                        child: TabBar(
                            onTap: (int value) async {
                              setState(() {
                                _selectedTab = value;
                                _isLoading = true;
                              });
                              var res = await Provider.of<DataProvider>(context,
                                      listen: false)
                                  .getProductsByCategory(categories![value]);
                              if (!res) {
                                showAlertDialog(context,
                                    title: 'Attenzione',
                                    message: Provider.of<DataProvider>(context,
                                            listen: false)
                                        .lastMessage);
                              }
                              setState(() {
                                _isLoading = false;
                              });
                            },
                            isScrollable: true,
                            unselectedLabelStyle: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(color: OptiShopAppTheme.primaryText),
                            labelStyle: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(fontWeight: FontWeight.bold),
                            indicatorColor: OptiShopAppTheme.primaryColor,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorWeight: 4.0,
                            tabs: categories!
                                .map((entry) => Tab(
                                      text: entry.name,
                                    ))
                                .toList()),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: selectedProducts == null || _isLoading
                          ? const Center(
                              child: CupertinoActivityIndicator(
                                radius: 20.0,
                              ),
                            )
                          : selectedProducts!.isEmpty
                              ? const Center(
                                  child: Text(
                                      'Non ci sono prodotti per questa categoria '),
                                  //TODO: cambiare
                                )
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 15.0,
                                    crossAxisSpacing: 10.0,
                                    childAspectRatio: 2 / 3,
                                  ),
                                  padding: const EdgeInsets.all(15.0),
                                  itemCount: selectedProducts!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ProductCard(
                                      product: selectedProducts![index],
                                      onAddCallback: () =>
                                          Provider.of<DataProvider>(context,
                                                  listen: false)
                                              .addToCart(
                                                  selectedProducts![index]),
                                      onRemoveCallback: () =>
                                          Provider.of<DataProvider>(context,
                                                  listen: false)
                                              .removeFromCart(
                                                  selectedProducts![index]),
                                    );
                                  }),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
