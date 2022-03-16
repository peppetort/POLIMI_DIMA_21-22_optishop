import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/products.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/categories.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('HomePage');

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tabControllerKey = GlobalKey();

  //int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<DataProvider>(context, listen: false).getAllCategories();
  }

  void _selectCategory(int value, CategoryModel category) async {
    // setState(() {
    //   _selectedTab = value;
    // });
    if (value > 0) {
      var res = await Provider.of<DataProvider>(context, listen: false)
          .getProductsByCategory(category);
      if (!res) {
        showAlertDialog(context,
            title: 'Attenzione',
            message:
                Provider.of<DataProvider>(context, listen: false).lastMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('Home build');

    // Map<String, CategoryModel> categories =
    //     context.select<DataProvider, Map<String, CategoryModel>>(
    //         (value) => value.categories);

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
      body: categories.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : DefaultTabController(
              key: _tabControllerKey,
              length: categories.length + 1,
              child: Column(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 130.0),
                    child: Material(
                      color: OptiShopAppTheme.backgroundColor,
                      child: TabBar(
                          onTap: (value) {
                            // setState(() {
                            //   _selectedTab = value;
                            // });
                            if (value != 0) {
                              CategoryModel selectedCategory = context
                                  .read<DataProvider>()
                                  .categories
                                  .values
                                  .toList()[value - 1];
                              _selectCategory(value, selectedCategory);
                            } else {
                              // setState(() {
                              //   _selectedTab = value;
                              // });
                            }
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
                          tabs: [
                                const Tab(
                                  text: 'Tutte le categorie',
                                )
                              ] +
                              context
                                  .select<DataProvider,
                                          Map<String, CategoryModel>>(
                                      (value) => value.categories)
                                  .values
                                  .map((entry) => Tab(
                                        text: entry.name,
                                      ))
                                  .toList()),
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: Builder(builder: (c) {
                      return DefaultTabController.of(c)?.index == 0
                          ? CategoriesPage(
                              categories: categories,
                              callback: _selectCategory,
                            )
                          : ProductPage(
                              selectedCategory: categories[
                                  DefaultTabController.of(c)!.index - 1],
                            );
                    }),
                  ),
                ],
              ),
            ),
    );
  }
}
