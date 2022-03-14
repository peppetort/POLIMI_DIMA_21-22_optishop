import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/categories.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/product_cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('HomePage');

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tabControllerKey = GlobalKey();

  bool _isLoading = false;
  List<CategoryModel>? categories;
  List<ProductModel>? selectedProducts;
  int _selectedTab = 0;

  void _selectCategory(int value) async {
    setState(() {
      _selectedTab = value;
    });
    if (value > 0) {
      setState(() {
        _isLoading = true;
      });
      var res = await Provider.of<DataProvider>(context, listen: false)
          .getProductsByCategory(categories![value - 1]);
      if (!res) {
        showAlertDialog(context,
            title: 'Attenzione',
            message:
                Provider.of<DataProvider>(context, listen: false).lastMessage);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _getPageBody() {
    if (_selectedTab == 0) {
      //TODO: return category page
      return CategoriesPage(
        categories: categories!,
        callback: _selectCategory,
      );
    } else {
      return selectedProducts == null || _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : selectedProducts!.isEmpty
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
                  itemCount: selectedProducts!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ProductCard(
                      product: selectedProducts![index],
                      onAddCallback: () =>
                          Provider.of<DataProvider>(context, listen: false)
                              .addToCart(selectedProducts![index]),
                      onRemoveCallback: () =>
                          Provider.of<DataProvider>(context, listen: false)
                              .removeFromCart(selectedProducts![index]),
                    );
                  });
    }
  }

  @override
  Widget build(BuildContext context) {
    categories = Provider.of<DataProvider>(context).categories;
    selectedProducts =
        Provider.of<DataProvider>(context).productsOfSelectedCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OptiShop'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          icon: const Icon(Icons.person_outline),
        ),
        actions: [
          //TODO: rimuovere solo debug
          IconButton(
            onPressed: () {
              Provider.of<AuthenticationProvider>(context, listen: false)
                  .signOut();
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: categories == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : DefaultTabController(
              key: _tabControllerKey,
              length: categories!.length + 1,
              child: Column(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 130.0),
                    child: Material(
                      color: OptiShopAppTheme.backgroundColor,
                      child: TabBar(
                          onTap: (value) => _selectCategory(value),
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
                          tabs: [
                                const Tab(
                                  text: 'Tutte le categorie',
                                )
                              ] +
                              categories!
                                  .map((entry) => Tab(
                                        text: entry.name,
                                      ))
                                  .toList()),
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: Builder(builder: (BuildContext c) {
                      return _getPageBody();
                    }),
                  ),
                ],
              ),
            ),
    );
  }
}
