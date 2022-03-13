import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/products.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OptiShop'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          icon: const Icon(Icons.person_outline),
        ),
        actions: [
          //TODO: rimuovere solo debug
          IconButton(
            onPressed: () {
              Provider.of<AuthenticationProvider>(context, listen: false)
                  .signOut();
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CupertinoActivityIndicator(
                radius: 20.0,
              ),
            )
          : Column(
              children: [
                ElevatedButton(
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductsPage(
                              initialCategory: CategoryModel(
                                'o8QmLH0UwqwfYx3uA2K9',
                                'Bevande',
                                'TODO',
                              ),
                            ),
                          ),
                        ),
                    child: Text('Prodotti')),
              ],
            ),
    );
  }
}
