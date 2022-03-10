import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/privacy_note.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/scroll_column_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _isLoading = false;

  void submitLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      var result =
          await Provider.of<AuthenticationProvider>(context, listen: false)
              .signIn(
                  email: _emailController.text,
                  password: _passwordController.text);

      if (!result) {
        showAlertDialog(context,
            title: 'Attenzione',
            message: Provider.of<AuthenticationProvider>(context, listen: false)
                .lastMessage);
        setState(() {
          _isLoading = false;
        });
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var socialButtonWidth = ((MediaQuery.of(context).size.width - 56) / 3) -
        (MediaQuery.of(context).size.width / 15);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: ScrollColumnView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 28.0,
                          right: 28.0,
                        ),
                        child: Text(
                          'Effettua l\'accesso',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 28.0,
                          right: 28.0,
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Email',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserire una email valida';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 28.0,
                          right: 28.0,
                        ),
                        child: TextFormField(
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            autocorrect: false,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.send,
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              labelText: 'Password',
                              counterText: '',
                              errorMaxLines: 4,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _hidePassword = !_hidePassword;
                                  });
                                },
                                icon: _hidePassword
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Inserire la password';
                              } else {
                                return null;
                              }
                            }),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 30.0,
                          left: 28.0,
                          right: 28.0,
                        ),
                        child: Center(
                          child: BigElevatedButton(
                            onPressed: _isLoading ? null : submitLogin,
                            child: _isLoading
                                ? const CircularProgressIndicator.adaptive(
                                    backgroundColor:
                                        OptiShopAppTheme.backgroundColor,
                                  )
                                : const Text('Accedi'),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 40.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Problemi di accesso?',
                                style: Theme.of(context).textTheme.bodyText1!),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, '/recover'),
                              child: Text(
                                'Recupera password',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 30.0, left: 40.0, right: 40.0, bottom: 5.0),
                  width: double.infinity,
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Oppure accedi con",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => {},
                              child: Container(
                                //TODO: substitute container with other access methods icons
                                height: socialButtonWidth,
                                width: socialButtonWidth,
                                color: OptiShopAppTheme.secondaryColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => {},
                              child: Container(
                                height: socialButtonWidth,
                                width: socialButtonWidth,
                                color: OptiShopAppTheme.secondaryColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => {},
                              child: Container(
                                height: socialButtonWidth,
                                width: socialButtonWidth,
                                color: OptiShopAppTheme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: PrivacyNote(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
