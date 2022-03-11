import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/UserModel.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final _prefixController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final prefixRegex = RegExp(r'^\d{1,4}$');
  final phoneRegex =
      RegExp(r'^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$');

  void _setControllers(UserModel userModel) {
    _nameController.text = userModel.name;
    _surnameController.text = userModel.surname;
    _prefixController.text = userModel.phone.split(' ').first;
    _phoneController.text = userModel.phone.split(' ').last;
  }

  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      var result = await Provider.of<UserDataProvider>(context, listen: false)
          .updateUserData(
              name: _nameController.text,
              surname: _surnameController.text,
              phone: _prefixController.text.trim() + ' ' + _phoneController.text.trim());

      if (!result) {
        showAlertDialog(context,
            title: 'Attenzione',
            message: Provider.of<UserDataProvider>(context, listen: false)
                .lastMessage);
        setState(() {
          _isLoading = false;
        });
      }else{
        Navigator.pop(context);
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user = Provider.of<UserDataProvider>(context).user;

    if (user != null) {
      _setControllers(user);
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Modifica il profilo'),
          centerTitle: true,
        ),
        body: user == null
            ? const Center(
                child: CupertinoActivityIndicator(
                  radius: 20.0,
                ),
              )
            : SafeArea(
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
                              controller: _nameController,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Nome',
                                counterText: '',
                                errorMaxLines: 4,
                              ),
                              keyboardType: TextInputType.name,
                              autocorrect: true,
                              onEditingComplete: () {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Inserisci il tuo nome';
                                } else {
                                  return null;
                                }
                              }),
                          const SizedBox(height: 20.0),
                          TextFormField(
                              controller: _surnameController,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Cognome',
                                counterText: '',
                                errorMaxLines: 4,
                              ),
                              keyboardType: TextInputType.name,
                              autocorrect: true,
                              onEditingComplete: () {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Inserisci il tuo cognome';
                                } else {
                                  return null;
                                }
                              }),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            initialValue: user.email,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Email',
                              suffixIcon: Icon(Icons.lock_outline),
                            ),
                            enabled: false,
                          ),
                          const SizedBox(height: 20.0),
                          InkWell(
                            onTap: () => Navigator.pushNamed(context, '/updatepassword'),
                            child: TextFormField(
                              initialValue: 'thisisnotmypassword',
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Password',
                                suffixIcon: Icon(Icons.edit_outlined),
                              ),
                              obscureText: true,
                              enabled: false,
                            ),
                          ),
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
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            keyboardType: TextInputType.phone,
                                            maxLines: 1,
                                            maxLength: 4,
                                            autocorrect: true,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
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
                          BigElevatedButton(
                            loading: _isLoading,
                            onPressed: _submitUpdate,
                            child: Text(
                              'salva'.toUpperCase(),
                            ),
                          ),
                          const SizedBox(height: 30.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
