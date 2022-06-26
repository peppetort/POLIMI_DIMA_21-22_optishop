import 'dart:async';

import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/MarketModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/result.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('ResultPage');

class ResultsPage extends StatelessWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            Provider.of<ResultProvider>(context, listen: false).findResults(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<MarketModel, Map<String, double>>> snapshot) {
          _logger.info('ResultPage future build');
          if (snapshot.hasData) {
            Map<MarketModel, Map<String, double>> markets = snapshot.data!;

            return ResultContent(markets: markets);
          } else {
            return Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: Padding(
                padding: OptiShopAppTheme.defaultPagePadding,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo_scritta.png'),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                        child: Text(
                          'Stiamo cercando i migliori supermercati!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                        child: Text(
                          'OptiShop sta cercando i supermercati con i prezzi più bassi nelle tue vicinanze',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(height: 1.5),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: CupertinoActivityIndicator(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}

class ResultContent extends StatefulWidget {
  final Map<MarketModel, Map<String, double>> markets;

  const ResultContent({Key? key, required this.markets}) : super(key: key);

  @override
  State<ResultContent> createState() => _ResultContentState();
}

class _ResultContentState extends State<ResultContent> {
  bool saved = false;

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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
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

  @override
  Widget build(BuildContext context) {
    _logger.info('Result page content build');

    LocationData? lastUserLocation =
        context.read<ResultProvider>().lastUserLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Risultati'),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('Preference test key'),
            onPressed: () async {
              String name = await showInputAlertDialog(context,
                  title: 'Inserisci un nome per la preferenza');

              if (name != '') {
                _logger.info('Nome selezionato $name}');

                setState(() {
                  saved = true;
                });

                Provider.of<UserDataProvider>(context, listen: false)
                    .createNewShopPreference(
                        name, context.read<CartProvider>().cart);
              }
            },
            icon:
                saved ? const Icon(Icons.star) : const Icon(Icons.star_outline),
          ),
        ],
      ),
      body: widget.markets.isEmpty
          ? Padding(
              padding: OptiShopAppTheme.defaultPagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                      child: Image.asset(
                        'assets/images/Ill_ooops_1.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
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
                          style:
                              Theme.of(context).textTheme.bodyText2!.copyWith(
                                    height: 1.5,
                                    color: OptiShopAppTheme.primaryText,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                    child: BigElevatedButton(
                      key: const Key('Continue shopping test key'),
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
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
                        child: lastUserLocation != null
                            ? MapView(
                                userLocation: lastUserLocation,
                                markets: widget.markets.keys.toList(),
                              )
                            : Container(),
                      ),
                      Flexible(
                        flex: 1,
                        child: _getResultListView(widget.markets),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: _getResultListView(widget.markets),
                      ),
                      Flexible(
                        flex: 3,
                        child: lastUserLocation != null
                            ? MapView(
                                userLocation: lastUserLocation,
                                markets: widget.markets.keys.toList(),
                              )
                            : Container(),

/*                        FutureBuilder(

                          future: _getMapView(
                              context, widget.markets.keys.toList()),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data as Widget;
                            } else {
                              return Container();
                            }
                          },
                        ),*/
                      ),
                    ],
                  ),
                ),
    );
  }
}

class MapView extends StatefulWidget {
  final List<MarketModel> markets;
  final LocationData userLocation;

  const MapView({Key? key, required this.markets, required this.userLocation})
      : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Set<Marker> marketsMarkers = {};
  final Completer<GoogleMapController> _controller = Completer();
  late final CameraPosition userMapPosition;

  @override
  void initState() {
    marketsMarkers.addAll(
      widget.markets
          .map(
            (e) => Marker(
              markerId: MarkerId(e.id),
              position: LatLng(e.latitude, e.longitude),
              infoWindow: InfoWindow(
                title: e.name,
                snippet: e.address,
              ),
              icon: BitmapDescriptor.defaultMarker,
            ),
          )
          .toSet(),
    );

    if (widget.userLocation.latitude != null &&
        widget.userLocation.longitude != null) {
      userMapPosition = CameraPosition(
        target: LatLng(
            widget.userLocation.latitude!, widget.userLocation.longitude!),
        zoom: 14.4746,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('MapView build');

    return widget.userLocation.longitude == null ||
            widget.userLocation.latitude == null
        ? const Center(
            child: Icon(Icons.error),
          )
        : SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: GoogleMap(
              mapType: MapType.normal,
              markers: marketsMarkers,
              initialCameraPosition: userMapPosition,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          );
  }
}
