import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({Key? key}) : super(key: key);

  @override
  _RecoverPasswordPageState createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  bool _isLoading = false;

  SnackBar _getSnackBar(String email) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyText1,
            children: [
              TextSpan(
                text: 'Abbiamo inviato il link per il reset della password a ',
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: OptiShopAppTheme.primaryText,
                    ),
              ),
              TextSpan(
                text: _emailController.text,
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: OptiShopAppTheme.primaryText,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitRecover() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      var result =
          await Provider.of<AuthenticationProvider>(context, listen: false)
              .recoverPassword(email: _emailController.text);

      if (!result) {
        showAlertDialog(context,
            title: 'Attenzione',
            message: Provider.of<AuthenticationProvider>(context, listen: false)
                .lastMessage);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          _getSnackBar(_emailController.text),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: OptiShopAppTheme.defaultPagePadding,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            'Hai dimenticato la password?',
                            style: Theme.of(context).textTheme.headline4,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            'Inserisci il tuo indirizzo email.\nTi invieremo un link per generarne una nuova.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              border: const UnderlineInputBorder(),
                              labelText: 'La tua email',
                              labelStyle: Theme.of(context).textTheme.bodyText2,
                              counterText: '',
                              errorMaxLines: 4,
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.emailAddress,
                            maxLines: 1,
                            maxLength: 50,
                            autocorrect: false,
                            cursorColor: OptiShopAppTheme.secondaryColor,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Inserisci la tua email';
                              } else if (!emailRegex.hasMatch(value)) {
                                return 'Inserisci una email valida';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: BigElevatedButton(
                            onPressed: submitRecover,
                            loading: _isLoading,
                            child: Text(
                              'Invia Email'.toUpperCase(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
