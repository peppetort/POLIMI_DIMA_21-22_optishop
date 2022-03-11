import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/error.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({Key? key}) : super(key: key);

  static Route<void> pageBuilder(BuildContext context, Object? arguments) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => const UpdatePasswordPage(),
    );
  }

  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');

  bool _isOldPasswordHodden = true;
  bool _isPasswordHidden = true;
  bool _isLoading = false;

  void _submitChange() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      var reAuthRes =
          await Provider.of<AuthenticationProvider>(context, listen: false)
              .reAuthenticate(password: _oldPasswordController.text);

      if (!reAuthRes) {
        showAlertDialog(context,
            title: 'Attenzione',
            message: Provider.of<AuthenticationProvider>(context, listen: false)
                .lastMessage);
        setState(() {
          _isLoading = false;
        });
      } else {
        var changePwdRes =
            await Provider.of<AuthenticationProvider>(context, listen: false)
                .changePassword(password: _passwordController.text);

        if (!changePwdRes) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ErrorPage()),
          );
          setState(() {
            _isLoading = false;
          });
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            fit: StackFit.loose,
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: OptiShopAppTheme.defaultPagePadding,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                  bottom: 15.0, top: 20.0),
                              child: Image.asset(
                                'assets/images/Ill_modifica_password.png',
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                'Modifica la password',
                                style: Theme.of(context).textTheme.headline5,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Text(
                                'Scegli una password sicura.\n Deve essere composta da un minimo di 8 caratteri e includere almeno un numero e una lettera maiuscola.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                      height: 1.5,
                                      color: OptiShopAppTheme.primaryText,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                  top: 15.0, bottom: 30.0),
                              child: TextFormField(
                                controller: _oldPasswordController,
                                decoration: InputDecoration(
                                  border: const UnderlineInputBorder(),
                                  labelText: 'Vecchia password',
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                        color: OptiShopAppTheme.primaryText,
                                      ),
                                  counterText: '',
                                  errorMaxLines: 4,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isOldPasswordHodden =
                                            !_isOldPasswordHodden;
                                      });
                                    },
                                    icon: _isOldPasswordHodden
                                        ? const Icon(Icons.visibility_off)
                                        : const Icon(Icons.visibility),
                                  ),
                                ),
                                obscureText: _isOldPasswordHodden,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.visiblePassword,
                                maxLines: 1,
                                maxLength: 50,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Inserire il valore';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  border: const UnderlineInputBorder(),
                                  labelText: 'Nuova password',
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                        color: OptiShopAppTheme.primaryText,
                                      ),
                                  counterText: '',
                                  errorMaxLines: 4,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordHidden = !_isPasswordHidden;
                                      });
                                    },
                                    icon: _isPasswordHidden
                                        ? const Icon(Icons.visibility_off)
                                        : const Icon(Icons.visibility),
                                  ),
                                ),
                                obscureText: _isPasswordHidden,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.visiblePassword,
                                maxLines: 1,
                                maxLength: 50,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Inserire il valore';
                                  } else if (!passwordRegex.hasMatch(value)) {
                                    return 'Password non valida';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  border: const UnderlineInputBorder(),
                                  labelText: 'Conferma password',
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                        color: OptiShopAppTheme.primaryText,
                                      ),
                                  counterText: '',
                                  errorMaxLines: 4,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordHidden = !_isPasswordHidden;
                                      });
                                    },
                                    icon: _isPasswordHidden
                                        ? const Icon(Icons.visibility_off)
                                        : const Icon(Icons.visibility),
                                  ),
                                ),
                                obscureText: _isPasswordHidden,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.visiblePassword,
                                maxLines: 1,
                                maxLength: 50,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Inserire il valore';
                                  } else if (_passwordController.text !=
                                      _confirmPasswordController.text) {
                                    return 'Le password non corrispondono';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: BigElevatedButton(
                                onPressed: _submitChange,
                                loading: _isLoading,
                                child: Text(
                                  'modifica password'.toUpperCase(),
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
              Positioned(
                  right: 0.0,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
