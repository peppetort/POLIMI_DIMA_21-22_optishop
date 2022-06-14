import 'package:dima21_migliore_tortorelli/app_theme.dart';
import 'package:dima21_migliore_tortorelli/models/UserModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger('SettingsPage');
const double stepLength = 0.75;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final double _minDistanceValue = 75;
  final double _maxDistanceValue = 3750;
  late double _currentSliderValue;

  @override
  void initState() {
    final radius =
        Provider.of<UserDataProvider>(context, listen: false).user!.distance;
    _currentSliderValue = radius;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user = Provider.of<UserDataProvider>(context).user;

    const containerHeight = 70.0;
    var _divider = const Divider(
      height: 1,
      thickness: 1,
    );

    if (_currentSliderValue < _minDistanceValue) {
      _currentSliderValue = _minDistanceValue;
    }

    return Scaffold(
      appBar: AppBar(
        title:
            user != null ? Text('${user.name} ${user.surname}') : Container(),
        centerTitle: true,
        leading: IconButton(
          key: const Key('Back test key'),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: user == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    InkWell(
                      key: const Key('Update profile test key'),
                      onTap: () =>
                          Navigator.pushNamed(context, '/updateprofile'),
                      child: Container(
                        padding: OptiShopAppTheme.defaultPagePadding,
                        height: containerHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Informazioni personali',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: OptiShopAppTheme.secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                    _divider,
                    Container(
                      padding: OptiShopAppTheme.defaultPagePadding,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Distanza',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                      color: OptiShopAppTheme.primaryText,
                                    ),
                              ),
                              Text(
                                '${(_currentSliderValue / stepLength).round()} passi / ${(_currentSliderValue).round()} metri',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                      color: OptiShopAppTheme.secondaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0,
                                    ),
                              ),
                            ],
                          ),
                          Slider(
                              activeColor: OptiShopAppTheme.secondaryColor,
                              inactiveColor: OptiShopAppTheme.grey,
                              value: _currentSliderValue,
                              min: _minDistanceValue,
                              max: _maxDistanceValue,
                              onChanged: (double value) {
                                setState(() {
                                  _currentSliderValue = value;
                                });
                              },
                              onChangeEnd: (double value) async {
                                var res = await Provider.of<UserDataProvider>(
                                        context,
                                        listen: false)
                                    .updateUserData(distance: value);
                                if (!res) {
                                  showAlertDialog(context,
                                      title: 'Attenzione',
                                      message:
                                          Provider.of<UserDataProvider>(context)
                                              .lastMessage);
                                }
                              }),
                        ],
                      ),
                    ),
                    _divider,
                    InkWell(
                      onTap: () => {},
                      child: Container(
                        padding: OptiShopAppTheme.defaultPagePadding,
                        height: containerHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Termini e condizioni',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: OptiShopAppTheme.primaryText,
                                  ),
                            ),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                    _divider,
                    InkWell(
                      onTap: () => {},
                      child: Container(
                        padding: OptiShopAppTheme.defaultPagePadding,
                        height: containerHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Informativa sulla privacy',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: OptiShopAppTheme.primaryText,
                                  ),
                            ),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                    _divider,
                    Container(
                      padding: OptiShopAppTheme.defaultPagePadding
                          .copyWith(bottom: 0, top: 20.0),
                      child: Text(
                        'Hai effettuato l\'accesso',
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                              color: OptiShopAppTheme.primaryText,
                            ),
                      ),
                    ),
                    InkWell(
                      key: const Key('Disconnect test key'),
                      onTap: () async {
                        await Provider.of<AuthenticationProvider>(context,
                                listen: false)
                            .signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
                      },
                      child: Container(
                        padding: OptiShopAppTheme.defaultPagePadding,
                        height: containerHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Disconnetti ${user.name} ${user.surname}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Flexible(flex: 1, fit: FlexFit.tight, child: Container())
                  ],
                ),
              ),
      ),
    );
  }
}
