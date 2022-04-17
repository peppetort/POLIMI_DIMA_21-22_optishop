import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/products.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('HomePage');

class HomePhonePage extends StatefulWidget {
  final List<CategoryModel> categories;

  const HomePhonePage({Key? key, required this.categories}) : super(key: key);

  @override
  _HomePhonePageState createState() => _HomePhonePageState();
}

class _HomePhonePageState extends State<HomePhonePage> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    _logger.info('Home Phone build');

    return DefaultTabController(
      length: widget.categories.length + 1,
      initialIndex: 0,
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 130.0),
            child: Material(
              color: OptiShopAppTheme.backgroundColor,
              child: TabBar(
                  onTap: (value) {
                    if (value != 0) {
                      String categoryId = widget.categories[value - 1].id;
                      setState(() {
                        selectedCategory = categoryId;
                      });
                      Provider.of<DataProvider>(context, listen: false)
                          .getProductsByCategory(categoryId);
                    } else {
                      setState(() {
                        selectedCategory = null;
                      });
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
                      widget.categories
                          .map((entry) => Tab(
                                text: entry.name,
                              ))
                          .toList()),
            ),
          ),
          Flexible(
            flex: 5,
            child: selectedCategory == null
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 15.0,
                      crossAxisSpacing: 20.0,
                      childAspectRatio: 2 / 3,
                    ),
                    padding: const EdgeInsets.all(15.0),
                    itemCount: widget.categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Material(
                          child: InkWell(
                        onTap: () {
                          Provider.of<DataProvider>(context, listen: false)
                              .getProductsByCategory(
                                  widget.categories[index].id);
                          DefaultTabController.of(context)!
                              .animateTo(index + 1);
                          setState(() {
                            selectedCategory = widget.categories[index].id;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    width: 1,
                                    color: OptiShopAppTheme.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: CachedNetworkImage(
                                    imageUrl: widget.categories[index].image,
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              widget.categories[index].name,
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color: OptiShopAppTheme.secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ));
                    })
                : ProductPage(
                    selectedCategoryId: selectedCategory!,
                  ),
          ),
        ],
      ),
    );
  }
}
