import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/ShopPreferenceModel.dart';
import 'package:flutter/material.dart';

import 'favorite_details.dart';

class FavoritesPhonePage extends StatelessWidget {
  final List<ShopPreferenceModel> userSavedBags;

  const FavoritesPhonePage({Key? key, required this.userSavedBags})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: userSavedBags.length,
        itemBuilder: (BuildContext context, int index) {
          ShopPreferenceModel preference = userSavedBags[index];

          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoriteDetailsPage(
                  selectedPreferenceId: preference.id,
                ),
              ),
            ),
            child: SizedBox(
              height: 50.0,
              child: Card(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                elevation: 1.0,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          preference.name,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
                                    color: OptiShopAppTheme.secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
