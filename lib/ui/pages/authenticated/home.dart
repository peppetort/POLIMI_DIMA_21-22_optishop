import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OptiShop'),
        leading: IconButton(icon: const Icon(Icons.logout), onPressed: ()=> Provider.of<AuthenticationProvider>(context, listen: false).signOut(),),
      ),
      body: SafeArea(
        child: Center(
          child: Text('HOME'),
        ),
      ),
    );
  }

}