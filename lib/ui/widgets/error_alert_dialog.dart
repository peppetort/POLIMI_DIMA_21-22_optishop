import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ErrorAlert extends StatelessWidget {
  final VoidCallback onClose;

  const ErrorAlert({Key? key, required this.onClose}) : super(key: key);

  List<double> _getAlertSize(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    double rectWidth = deviceWidth * 0.5;
    double rectHeight = 0;

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      rectHeight = deviceHeight / deviceWidth * rectWidth * 0.8;
    } else {
      rectHeight = deviceWidth / deviceHeight * rectWidth * 2;
    }

    return [rectWidth, rectHeight];
  }

  @override
  Widget build(BuildContext context) {
    List<double> alertSize = _getAlertSize(context);

    return AlertDialog(
      contentPadding: const EdgeInsets.only(bottom: 20.0),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      onClose();
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.close,
                      size: 30.0,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: alertSize.first,
              child: Flexible(
                child: Text(
                  'Ooops!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: OptiShopAppTheme.secondaryColor),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            SizedBox(
              width: alertSize.first,
              child: Flexible(
                child: Text(
                  'Il prodotto non è presente nel catalogo.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            SizedBox(
              width: alertSize.first,
              height: alertSize.last,
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  'assets/images/Ill_ooops_1.png',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
