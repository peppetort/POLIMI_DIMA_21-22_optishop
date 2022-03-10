import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context,
    {required String title, required String message}) async {
  Theme.of(context).platform == TargetPlatform.iOS
      ? await showCupertinoDialog(
          context: context,
          builder: (context) {
            return Theme(
              data: ThemeData.light(),
              child: CupertinoAlertDialog(
                title: Text(title),
                content: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
                      child: Text('Chiudi'),
                    ),
                  ),
                ],
              ),
            );
          },
        )
      : await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              titleTextStyle: Theme.of(context).textTheme.headline5,
              content: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(message),
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
                    child: Text('Chiudi'),
                  ),
                ),
              ],
            );
          },
        );
}
