import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/phone/categories.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/products.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('HomePage');

class HomePhonePage extends StatefulWidget {
  const HomePhonePage({Key? key}) : super(key: key);

  @override
  _HomePhonePageState createState() => _HomePhonePageState();
}

class _HomePhonePageState extends State<HomePhonePage> {
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

    String? selectedCategory = context.read<DataProvider>().selectedCategory;
    int initialIndex = selectedCategory != null
        ? categories.indexWhere((element) => element.id == selectedCategory) + 1
        : 0;

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
              length: categories.length + 1,
              initialIndex: initialIndex,
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
                  Flexible(
                    flex: 5,
                    //NOTE: builder in order to rebuild the tree only from this point on when a selectedCategory change happen
                    child: Builder(
                      builder: (context) {
                        _logger.info('HomePageBody build');
                        String? selectedCategory =
                            context.select<DataProvider, String?>(
                                (value) => value.selectedCategory);

                        bool isLoading = context.select<DataProvider, bool>(
                            (value) => value.isLoading);

                        return isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : selectedCategory == null
                                ? CategoriesPhonePage(categories: categories)
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
