import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/products.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('HomePage');

class HomeTabletPage extends StatefulWidget {
  final List<CategoryModel> categories;

  const HomeTabletPage({Key? key, required this.categories}) : super(key: key);

  @override
  _HomeTabletPageState createState() => _HomeTabletPageState();
}

class _HomeTabletPageState extends State<HomeTabletPage> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    _logger.info('Home Tablet build');

    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Container(
            height: double.infinity,
            //width: 130.0,
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedCategory = widget.categories[index].id;
                    });
                    Provider.of<DataProvider>(context, listen: false)
                        .getProductsByCategory(widget.categories[index].id);
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
                            width:
                                widget.categories[index].id == selectedCategory
                                    ? 2
                                    : 1,
                            color:
                                widget.categories[index].id == selectedCategory
                                    ? OptiShopAppTheme.primaryColor
                                    : OptiShopAppTheme.grey,
                          ),
                          borderRadius:
                              widget.categories[index].id == selectedCategory
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
                            color:
                                widget.categories[index].id == selectedCategory
                                    ? OptiShopAppTheme.primaryColor
                                    : OptiShopAppTheme.backgroundColor,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(5.0),
                              bottomRight: Radius.circular(5.0),
                            )),
                        child: Text(
                          widget.categories[index].name,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
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
            ),
          ),
        ),
        Flexible(
          flex: 7,
          child: selectedCategory == null
              ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(
                          'Seleziona una categoria di prodotti e aggiungi al carrello quelli che vuoi acquistare',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(
                                  color: OptiShopAppTheme.primaryText,
                                  height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              : ProductPage(
                  selectedCategoryId: selectedCategory!,
                ),
        ),
      ],
    );
  }
}
