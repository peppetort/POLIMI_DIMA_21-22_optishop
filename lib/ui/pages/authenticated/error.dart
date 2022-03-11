import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/scroll_column_view.dart';
import 'package:flutter/material.dart';

import '../../widgets/big_button.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: OptiShopAppTheme.defaultPagePadding,
      color: OptiShopAppTheme.backgroundColor,
      child: ScrollColumnView(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10.0, top: 100.0),
            child: Image.asset(
              'assets/images/Ill_ooops_2.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  'Ooops!',
                  style: Theme.of(context).textTheme.headline4,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  'Qualcosa deve essere andato storto.\n Per favore riprova.',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
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
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Prova di nuovo'.toUpperCase(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
