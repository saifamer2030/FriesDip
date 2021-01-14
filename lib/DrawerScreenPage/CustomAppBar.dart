import 'package:flutter/material.dart';
import 'package:friesdip/DrawerScreenPage/FollowOrder.dart';
import 'package:friesdip/ScreenPage/ShoppingBasket.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor = Colors.black;
  final Text title;
  final AppBar appBar;
  final List<Widget> widgets;

  /// you can add more fields that meet your needs

  const BaseAppBar({Key key, this.title, this.appBar, this.widgets})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Center(
          child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
              Radius.circular(5.0) //                 <--- border radius here
              ),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            translator.translate('appTitle'),
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "Estedad-Black"),
          ),
        ),
      )),
      backgroundColor:Theme.of(context).primaryColor,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
          onPressed: () {
            // do something
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Hero(tag: new Text("hero1"), child: ShoppingBasket())));
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}
