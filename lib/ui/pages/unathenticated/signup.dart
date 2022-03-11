import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/privacy_note.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passConfController = TextEditingController();
  final _prefixController = TextEditingController(text: '39');
  final _phoneController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _switchValue = true;

  bool _isLoading = false;

  final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');
  final prefixRegex = RegExp(r'^\d{1,4}$');
  final phoneRegex =
      RegExp(r'^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$');

  Size getTextWidth(BuildContext context, String text, TextStyle textStyle) =>
      (TextPainter(
              text: TextSpan(text: text, style: textStyle),
              maxLines: 1,
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
              textDirection: TextDirection.ltr)
            ..layout())
          .size;

  void submitSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      var result =
          await Provider.of<AuthenticationProvider>(context, listen: false)
              .signUp(
                  name: _firstNameController.text,
                  surname: _lastNameController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                  phone: _prefixController.text + ' ' + _phoneController.text);

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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crea un account'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: OptiShopAppTheme.defaultPagePadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Nome*',
                            counterText: '',
                            errorMaxLines: 4,
                          ),
                          keyboardType: TextInputType.name,
                          autocorrect: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserire il tuo nome';
                            } else {
                              return null;
                            }
                          }),
                      const SizedBox(height: 20.0),
                      TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Cognome*',
                            counterText: '',
                            errorMaxLines: 4,
                          ),
                          keyboardType: TextInputType.name,
                          autocorrect: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserire il tuo cognome';
                            } else {
                              return null;
                            }
                          }),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Email*',
                          counterText: '',
                          errorMaxLines: 4,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserire la tua email';
                          } else if (!emailRegex.hasMatch(value)) {
                            return 'Email non valida';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              labelText: 'Password*',
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
                              )),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _isPasswordHidden,
                          autocorrect: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserire la password';
                            } else if (!passwordRegex.hasMatch(value)) {
                              return 'La password deve essere lunga almeno 8 caratteri e deve contenere almeno una lettera minuscola, una lettera maiuscola ed un numero';
                            } else {
                              return null;
                            }
                          }),
                      const SizedBox(height: 20.0),
                      TextFormField(
                          controller: _passConfController,
                          decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              labelText: 'Ripeti password*',
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
                              )),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _isPasswordHidden,
                          autocorrect: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ripeti la password';
                            } else if (_passwordController.text !=
                                _passConfController.text) {
                              return 'Le password non corrispondono';
                            } else {
                              return null;
                            }
                          }),
                      const SizedBox(height: 20.0),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 3,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                        controller: _prefixController,
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'Prefisso',
                                          counterText: '',
                                          errorMaxLines: 4,
                                          prefixText: '+',
                                        ),
                                        // focusNode: focusNode,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        keyboardType: TextInputType.phone,
                                        maxLines: 1,
                                        maxLength: 4,
                                        autocorrect: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Inserire il prefisso';
                                          } else if (!prefixRegex
                                              .hasMatch(value)) {
                                            return 'Inserire un prefisso valido';
                                          } else {
                                            return null;
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            const VerticalDivider(thickness: 2),
                            Expanded(
                              flex: 8,
                              child: TextFormField(
                                  controller: _phoneController,
                                  maxLength: 15,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Cellulare',
                                    counterText: '',
                                    errorMaxLines: 4,
                                  ),
                                  keyboardType: TextInputType.number,
                                  autocorrect: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Inserire il tuo numero';
                                    }
                                    if (_prefixController.text.isEmpty) {
                                      return 'Inserire il prefisso';
                                    }
                                    if (!phoneRegex.hasMatch(value)) {
                                      return 'Inserire un numero valido';
                                    }
                                    return null;
                                  }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 3,
                              child: Text(
                                'Desidero ricevere notizie e offerte da Fishop sul mio indirizzo email.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        color: OptiShopAppTheme.primaryText),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: CupertinoSwitch(
                                activeColor: OptiShopAppTheme.secondaryColor,
                                value: _switchValue,
                                onChanged: (bool value) {
                                  setState(() {
                                    _switchValue = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          '* indica un campo obbligatorio',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(
                                  color: OptiShopAppTheme.primaryText,
                                  fontSize: 11.0),
                        ),
                      ),
                      BigElevatedButton(
                        onPressed: submitSignUp,
                        loading: _isLoading,
                        child: Text(
                          'Crea Account'.toUpperCase(),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      const PrivacyNote()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
