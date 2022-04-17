import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/ShopPreferenceModel.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/tablet/favorite_details.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
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
                    height: 50.0,
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      elevation: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                            Row(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    String name = await showInputAlertDialog(
                                        context,
                                        title:
                                            'Inserisci un nome per la preferenza');

                                    if (name != '') {
                                      Provider.of<UserDataProvider>(context,
                                              listen: false)
                                          .changePreferenceName(
                                              widget.userSavedBags[index].id,
                                              name);
                                    }
                                  },
                                  child: const Icon(
                                    Icons.mode_outlined,
                                    color: OptiShopAppTheme.secondaryColor,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                InkWell(
                                  onTap: () {
                                    Provider.of<UserDataProvider>(context,
                                            listen: false)
                                        .removePreference(widget
                                            .userSavedBags[index].id);
                                    setState(() {
                                      selectedIndex = 0;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: OptiShopAppTheme.secondaryColor,
                                  ),
                                )
                              ],
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
            selectedPreferenceId: widget.userSavedBags[selectedIndex].id,
          ),
        ),
      ],
    );
  }
}
