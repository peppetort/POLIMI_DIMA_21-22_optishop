import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  final Future<dynamic> Function(BuildContext context)? function;
  final Route<Object?> pageBuilder;

  const LoadingPage({Key? key, this.function, required this.pageBuilder})
      : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  void doWork() async {
    if (widget.function != null) {
      await widget.function!(context);
    }
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      Navigator.pushReplacement(context, widget.pageBuilder);
      //TODO: handle exception
    });
  }

  @override
  Widget build(BuildContext context) {
    doWork();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_negativo.png'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
