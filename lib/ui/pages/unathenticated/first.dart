import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/privacy_note.dart';
import 'package:flutter/material.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:provider/provider.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: OptiShopAppTheme.defaultPagePadding,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: (MediaQuery.of(context).size.width / 10),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints.loose(
                          Size.fromHeight(
                              MediaQuery.of(context).size.width / 1.5),
                        ),
                        child: Image.asset(
                            'assets/images/logo_positivo_payoff.png'),
                      ),
                    ),
                    Flex(
                      direction: Axis.vertical,
                      children: [
                        BigElevatedButton(
                          onPressed: () => {
                            Navigator.of(context).restorablePushNamed('/signup')
                          },
                          child: const Text('Registrati'),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        BigOutlinedButton(
                          onPressed: () => {
                            Navigator.of(context).restorablePushNamed('/signin')
                          },
                          child: const Text('Accedi'),
                        ),
                      ],
                    ),
                    const PrivacyNote(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
