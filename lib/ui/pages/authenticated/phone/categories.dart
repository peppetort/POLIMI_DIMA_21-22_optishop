import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/scroll_column_view.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('CategoryPage');

class CategoriesPhonePage extends StatelessWidget {
  final List<CategoryModel> categories;

  const CategoriesPhonePage({Key? key, required this.categories})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _logger.info('CategoryPage build');
    return categories.isEmpty
        ? ScrollColumnView(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                child: Image.asset(
                  'assets/images/Ill_ooops_1.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              Text(
                'Non ci sono categoria',
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              ),
            ],
          )
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 20.0,
              childAspectRatio: 2 / 3,
            ),
            padding: const EdgeInsets.all(15.0),
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  Provider.of<DataProvider>(context, listen: false)
                      .selectCategory(categories[index].id);
                  DefaultTabController.of(context)!.animateTo(index + 1);
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
                            imageUrl: categories[index].image,
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
                      categories[index].name,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: OptiShopAppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              );
            });
  }
}
