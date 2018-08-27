import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:unit_converter/category/category.dart';

class CategoryTile extends StatelessWidget {
  final _rowHeight = 100.0;
  final Category category;
  final ValueChanged<Category> onTap;

  CategoryTile({
    Key key,
    @required this.category,
    this.onTap,
  })  : assert(category != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: _rowHeight,
        child: InkWell(
          borderRadius: BorderRadius.circular(_rowHeight / 2),
          highlightColor: category.color['highlight'],
          splashColor: category.color['splash'],
          onTap: () => onTap(category),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Image.asset(category.iconLocation),
                ),
                Center(
                    child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline,
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}