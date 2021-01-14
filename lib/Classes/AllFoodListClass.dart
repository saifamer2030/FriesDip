

import 'dart:ui';

import 'ItemFoodClass.dart';

class AllFoodListClass{
  String id;
  String ar_title;
  String en_title;
  int arrange;
  Color color;
  bool colorcheck;
  List<ItemFoodClass> foodList = [];


  AllFoodListClass (this.id,this.ar_title,this.en_title,this.arrange,
      this.color,
      this.colorcheck,
      this.foodList,
      );


}
