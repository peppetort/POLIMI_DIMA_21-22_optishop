import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('CategoryPage');

class CategoriesTabletPage extends StatefulWidget {
  final List<CategoryModel> categories;

  const CategoriesTabletPage({Key? key, required this.categories})
      : super(key: key);

  @override
  State<CategoriesTabletPage> createState() => _CategoriesTabletPageState();
}

class _CategoriesTabletPageState extends State<CategoriesTabletPage> {
  late String selectedCategoryId;

  @override
  void initState() {
    super.initState();
    selectedCategoryId =
        Provider.of<DataProvider>(context, listen: false).selectedCategory ??
            '';
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('CategoryPage build');
    return ListView.builder(
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Provider.of<DataProvider>(context, listen: false)
                .selectCategory(widget.categories[index].id);
            setState(() {
              selectedCategoryId = widget.categories[index].id;
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: widget.categories[index].id == selectedCategoryId
                        ? 2
                        : 1,
                    color: widget.categories[index].id == selectedCategoryId
                        ? OptiShopAppTheme.primaryColor
                        : OptiShopAppTheme.grey,
                  ),
                  borderRadius:
                      widget.categories[index].id == selectedCategoryId
                          ? const BorderRadius.only(
                              topRight: Radius.circular(5.0),
                              topLeft: Radius.circular(5.0),
                            )
                          : BorderRadius.circular(5.0),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    color: widget.categories[index].id == selectedCategoryId
                        ? OptiShopAppTheme.primaryColor
                        : OptiShopAppTheme.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0),
                    )),
                child: Text(
                  widget.categories[index].name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: OptiShopAppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
            ],
          ),
        );
      },
    );
  }
}
