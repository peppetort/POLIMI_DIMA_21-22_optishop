import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PrivacyNote extends StatelessWidget {
  const PrivacyNote({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Continuando accetti i nostri Termini di servizio. \n',
            ),
            const TextSpan(
              text: 'Per maggiori informazioni su come OptiShop elabora i tuoi '
                  'dati, puoi consultare l’',
            ),
            TextSpan(
                text: 'Informativa sulla Privacy e '
                    'sui Cookie.',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      fontSize: 11.0,
                      color: Theme.of(context).colorScheme.secondary,
                      height: 1.5,
                      decoration: TextDecoration.underline,
                    ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => {
                      })
          ],
          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                fontSize: 11.0,
                color: Theme.of(context).colorScheme.secondary,
                height: 1.5,
              ),
        ),
      ),
    );
  }
}
