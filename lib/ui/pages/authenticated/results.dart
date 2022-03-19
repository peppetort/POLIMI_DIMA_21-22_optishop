import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/MarketModel.dart';
import 'package:dima21_migliore_tortorelli/providers/result.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/loading.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/scroll_column_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('ResultPage');

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

  Widget _getResultListView(Map<MarketModel, Map<String, double>> markets) {
    return ListView.builder(
        itemCount: markets.length,
        itemBuilder: (BuildContext context, int index) {
          MarketModel market = markets.keys.toList()[index];

          return SizedBox(
            height: 100.0,
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
                          vertical: 10.0, horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            market.name,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      color: OptiShopAppTheme.secondaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Flexible(
                            child: Text(
                              market.address,
                              textAlign: TextAlign.start,
                              style:
                                  Theme.of(context).textTheme.bodyText1!.copyWith(
                                        color: OptiShopAppTheme.darkGray,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${markets[market]!['total']!.toStringAsFixed(2)}€',
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
                                    color: OptiShopAppTheme.darkGray,
                                  ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          '${(markets[market]!['distance']! * 1000).round()}m',
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: OptiShopAppTheme.darkGray,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _getMapView() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: OptiShopAppTheme.secondaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('ResultPage build');
    return FutureBuilder(
        future:
            Provider.of<ResultProvider>(context, listen: false).findResults(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<MarketModel, Map<String, double>>> snapshot) {
          _logger.info('ResultPage future build');
          if (snapshot.hasData) {
            Map<MarketModel, Map<String, double>> markets = snapshot.data!;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Risultati'),
                centerTitle: true,
              ),
              body: markets.isEmpty
                  ? Padding(
                      padding: OptiShopAppTheme.defaultPagePadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding:
                                  const EdgeInsets.only(bottom: 10.0, top: 20.0),
                              child: Image.asset(
                                'assets/images/Ill_ooops_1.png',
                                fit: BoxFit.fitWidth,
                              ),
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
                              onPressed: () => Navigator.popUntil(
                                  context, (route) => route.isFirst),
                              child: Text(
                                'Continua lo shopping'.toUpperCase(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : MediaQuery.of(context).orientation == Orientation.portrait
                      ? SafeArea(
                          child: Column(
                            children: [
                              Flexible(
                                flex: 1,
                                child: _getMapView(),
                              ),
                              Flexible(
                                flex: 1,
                                child: _getResultListView(markets),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          children: [
                            Flexible(
                              flex: 2,
                              child: _getResultListView(markets),
                            ),
                            Flexible(
                              flex: 3,
                              child: _getMapView(),
                            ),
                          ],
                        ),
            );
          } else {
            return const LoadingPage(
                title: 'Stiamo cercando i migliori supermercati!',
                subtitle:
                    'OptiShop sta cercando i supermercati con i prezzi più bassi nelle tue vicinanze');
          }
        });
  }
}
