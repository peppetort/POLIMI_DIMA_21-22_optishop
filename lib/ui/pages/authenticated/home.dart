import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/phone/home.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/tablet/home.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('HomePage');

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool errorLoadingCategory = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    setState(() {
      errorLoadingCategory = false;
    });

    bool res = await Provider.of<DataProvider>(context, listen: false)
        .getAllCategories();

    if (!res) {
      setState(() {
        errorLoadingCategory = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('Home build');

    List<CategoryModel> categories =
        context.select<DataProvider, List<CategoryModel>>(
            (value) => value.loadedCategories.values.toList());

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
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
            icon: const Icon(Icons.favorite_border_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: errorLoadingCategory
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Image.asset('assets/images/Ill_ooops_1.png',
                            fit: BoxFit.contain),
                      ),
                    ),
                    Text(
                      'Errore durante il caricamento dell categorie',
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: OptiShopAppTheme.defaultPagePadding,
                      child: BigElevatedButton(
                        onPressed: () => _loadCategories(),
                        // Navigator.pushNamed(context, '/results'),
                        child: Text(
                          'Riprova'.toUpperCase(),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : categories.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      if (constraints.maxWidth > 600) {
                        return HomeTabletPage(categories: categories);
                      } else {
                        return HomePhonePage(categories: categories);
                      }
                    },
                  ),
      ),
    );
  }
}
