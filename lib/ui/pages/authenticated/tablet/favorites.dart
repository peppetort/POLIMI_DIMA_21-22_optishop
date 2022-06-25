import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/ShopPreferenceModel.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/tablet/favorite_details.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('FavoritesTabletPage');

class FavoritesTabletPage extends StatefulWidget {
  final List<ShopPreferenceModel> userSavedBags;

  const FavoritesTabletPage({Key? key, required this.userSavedBags})
      : super(key: key);

  @override
  State<FavoritesTabletPage> createState() => _FavoritesTabletPageState();
}

class _FavoritesTabletPageState extends State<FavoritesTabletPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    _logger.info('Favorites tablet page build');

    return Row(
      children: [
        Flexible(
          flex: 1,
          child: ListView.builder(
              itemCount: widget.userSavedBags.length,
              itemBuilder: (BuildContext context, int index) {
                ShopPreferenceModel preference = widget.userSavedBags[index];

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: SizedBox(
                    height: 70.0,
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      elevation: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preference.name,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(
                                    color: OptiShopAppTheme.secondaryColor,
                                    fontWeight: selectedIndex == index
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                            ),
                            Text(
                              widget.userSavedBags[index].savedProducts.length >
                                      1
                                  ? widget.userSavedBags[index].savedProducts
                                          .length
                                          .toString() +
                                      ' prodotti'
                                  : widget.userSavedBags[index].savedProducts
                                          .length
                                          .toString() +
                                      ' prodotto',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
        Flexible(
          flex: 2,
          child: FavoriteDetailsTabletPage(
            onDelete: () {
              Provider.of<UserDataProvider>(context, listen: false)
                  .removePreference(widget.userSavedBags[selectedIndex].id);

              setState((){
                selectedIndex = 0;
              });
            },
            selectedPreferenceId: widget.userSavedBags[selectedIndex].id,
          ),
        ),
      ],
    );
  }
}
