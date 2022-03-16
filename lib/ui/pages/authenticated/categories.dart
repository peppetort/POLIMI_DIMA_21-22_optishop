import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  final List<CategoryModel> categories;
  final void Function(int, CategoryModel) callback;

  const CategoriesPage(
      {Key? key, required this.categories, required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BigElevatedButton(
      onPressed: () {
        int index = (categories.indexWhere(
                (element) => element.id == 'o8QmLH0UwqwfYx3uA2K9')) +
            1;

        DefaultTabController.of(context)!.animateTo(index);
        callback(index, CategoryModel('o8QmLH0UwqwfYx3uA2K9', 'Bevande', 'TODO'));
      },
      child: Text('Bevande'),
    );
  }
}
