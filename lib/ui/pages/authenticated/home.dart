import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/products.dart';
import 'package:flutter/material.dart';
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
                            if (value != 0) {
                              CategoryModel selectedCategory =
                                  categories[value - 1];
                              Provider.of<DataProvider>(context, listen: false)
                                  .selectCategory(selectedCategory.id);
                            } else {
                              Provider.of<DataProvider>(context, listen: false)
                                  .deselectCategory();
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
                              categories
                                  .map((entry) => Tab(
                                        text: entry.name,
                                      ))
                                  .toList()),
                    ),
                  ),
                  const Flexible(
                    flex: 5,
                    child: HomePageBody(),
                  ),
                ],
              ),
            ),
    );
  }
}

class HomePageBody extends StatelessWidget {
  const HomePageBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? selectedCategory = context
        .select<DataProvider, String?>((value) => value.selectedCategory);

    return selectedCategory == null
        ? const Text('all categories')
        : ProductPage(
            selectedCategoryId: selectedCategory,
          );
  }
}
