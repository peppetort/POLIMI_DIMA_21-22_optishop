import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/scroll_column_view.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class AllowLocationPage extends StatelessWidget {
  const AllowLocationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OptiShopAppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ScrollColumnView(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: [
                        Text(
                          'Tanti articoli a pochi passi da te!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: ConstrainedBox(
                      constraints: BoxConstraints.loose(
                          Size(350, MediaQuery.of(context).size.height * 0.3)),
                      child: Container(
                        // width: MediaQuery.of(context).size.height * 0.3,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Image.asset(
                          'assets/images/Ill_attiva_posizione.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Per utilizzare OptiShop è necessario attivare la '
                      'condivisione della posizione.\nLa tua posizione '
                      'verrà usata per mostrarti i supermercati nelle vicinanze.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(height: 1.5),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: OptiShopAppTheme.defaultPagePadding,
              color: OptiShopAppTheme.primaryColor,
              child: BigElevatedButton(
                key: const Key("Location test key"),
                onPressed: () async {
                  PermissionStatus locationPermission =
                      await Provider.of<UserDataProvider>(context,
                              listen: false)
                          .getPermissions();

                  if (locationPermission == PermissionStatus.denied ||
                      locationPermission == PermissionStatus.deniedForever) {
                    await Provider.of<UserDataProvider>(context, listen: false)
                        .askPermissions();
                  }
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: Text(
                  'Attiva posizione'.toUpperCase(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
