import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/ShopPreferenceModel.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/phone/favorites.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/tablet/favorites.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('PreferencePage');

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool preferencesLoadingError = false;
  bool isLoading = false;

  @override
  void initState() {
    _loadPreferences();
    super.initState();
  }

  void _loadPreferences() async {
    setState(() {
      isLoading = true;
      preferencesLoadingError = false;
    });

    bool res = await Provider.of<UserDataProvider>(context, listen: false)
        .getUserPreferences();

    if (!res) {
      setState(() {
        preferencesLoadingError = true;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('Shop preferences build');

    List<ShopPreferenceModel> userSavedBags =
        context.select<UserDataProvider, List<ShopPreferenceModel>>(
            (value) => value.userShopPreferences.values.toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricerche salvate'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : preferencesLoadingError
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
                        'Errore durante il caricamento delle preferenze',
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Padding(
                        padding: OptiShopAppTheme.defaultPagePadding,
                        child: BigElevatedButton(
                          onPressed: () => _loadPreferences(),
                          // Navigator.pushNamed(context, '/results'),
                          child: Text(
                            'Riprova'.toUpperCase(),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : userSavedBags.isEmpty
                  ? Padding(
                      padding: OptiShopAppTheme.defaultPagePadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(top: 30.0),
                              child: Image.asset(
                                'assets/images/Ill_inizia_a_esplorare.png',
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Text(
                            'Non hai salvato nessuna ricerca',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 30.0),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Text(
                              'Aggiungi i prodotti al carrello e salvalo per ritrovarlo qui in qualsiasi momento',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                      color: OptiShopAppTheme.primaryText,
                                      height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          BigElevatedButton(
                            onPressed: () => {Navigator.pop(context)},
                            child: Text(
                              'inizia lo shopping'.toUpperCase(),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            if (constraints.maxWidth > 600) {
                              return FavoritesTabletPage(
                                userSavedBags: userSavedBags,
                              );
                            } else {
                              return FavoritesPhonePage(
                                userSavedBags: userSavedBags,
                              );
                            }
                          },
                        ),
                      ),
                    ),
    );
  }
}
