import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/MarketModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/loading.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/scroll_column_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:provider/provider.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<MarketModel>? markets;

/*  final MapController _mapController = MapController(
    initMapWithUserPosition: false,
    areaLimit: BoundingBox(
      east: 10.4922941,
      north: 47.8084648,
      south: 45.817995,
      west: 5.9559113,
    ),
  );*/

  @override
  void initState() {
    super.initState();
    Provider.of<DataProvider>(context, listen: false).findResults();
  }

  void _loadResults() async {
    var res =
        await Provider.of<DataProvider>(context, listen: false).findResults();

    if (!res) {
      showAlertDialog(context,
          title: 'Attenzione',
          message:
              Provider.of<DataProvider>(context, listen: false).lastMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    markets = Provider.of<DataProvider>(context).resultMarkets;

    return markets == null
        ? const LoadingPage(
            title: 'Stiamo cercando i migliori supermercati!',
            subtitle:
                'OptiShop sta cercando i supermercati che nelle tue vicinanze che hanno i prezzi più bassi')
        : Scaffold(
            appBar: AppBar(
              title: const Text('Risultati'),
              centerTitle: true,
            ),
            body: markets!.isEmpty
                ? Padding(
                    padding: OptiShopAppTheme.defaultPagePadding,
                    child: ScrollColumnView(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.only(bottom: 10.0, top: 20.0),
                          child: Image.asset(
                            'assets/images/Ill_ooops_1.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                'Ci dispiace!\nNon abbiamo trovato nessun supermercato intorno a te',
                                style: Theme.of(context).textTheme.headline5,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Text(
                                'Prova ad ampliare il raggio di ricerca dalle impostazioni',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                      height: 1.5,
                                      color: OptiShopAppTheme.primaryText,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 30.0),
                          child: BigElevatedButton(
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                                context, '/', (route) => false),
                            child: Text(
                              'Continua lo shopping'.toUpperCase(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )

                /* Center(
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
                          'Ci dispiace!\nNon abbiamo trovato nessun supermercato intorno a te',
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )*/
                : SafeArea(
                    child: Column(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: OptiShopAppTheme.secondaryColor,
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: ListView.builder(
                              itemCount: markets!.length,
                              itemBuilder: (BuildContext context, int index) {
                                MarketModel market = markets![index];

                                return SizedBox(
                                  height: 80.0,
                                  child: Card(
                                    clipBehavior: Clip.hardEdge,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    elevation: 1.0,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  market.name,
                                                  textAlign: TextAlign.start,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5!
                                                      .copyWith(
                                                        color: OptiShopAppTheme
                                                            .secondaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                const SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  '${market.address} - ${market.distance}m',
                                                  textAlign: TextAlign.start,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1!
                                                      .copyWith(
                                                        color: OptiShopAppTheme
                                                            .darkGray,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '10€',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .copyWith(
                                                      color: OptiShopAppTheme
                                                          .darkGray,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
          );
  }
}
