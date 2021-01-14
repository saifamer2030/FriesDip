
import 'package:cloud_firestore/cloud_firestore.dart';
class OrderItem {
  int _id;
  String _item_id;
  String _title_ar;
  String _title_en;
  String _details_ar;
  String _details_en;
  String  _selected_price;
  String _price_no;
  String _price_small;
  String _price_mid;
  String _price_large;
  String _url;
  String _category_id;
  String _cat_title_ar;
  String _cat_title_en;

  int _heckedNo;
  int _heckedSmall;
  int _heckedMed;
  int _heckedLarg;

  int _total_price;
  int _item_no;

  int _size;

  OrderItem.withId(
      this._id,
      this._item_id,
      this._title_ar,
      this._title_en,
      this._details_ar,
      this._details_en,
      this._selected_price,   this._price_no, this._price_small, this._price_mid, this._price_large,
      this._url,
      this._category_id,
      this._cat_title_ar,
      this._cat_title_en,
      this._heckedNo,
      this._heckedSmall,
      this._heckedMed,
      this._heckedLarg,
      this._total_price,
      this._item_no,
  this._size
      );

  OrderItem(
      this._item_id,
      this._title_ar,
      this._title_en,
      this._details_ar,
      this._details_en,
      this._selected_price, this._price_no, this._price_small, this._price_mid, this._price_large,
      this._url,
      this._category_id,
      this._cat_title_ar,
      this._cat_title_en,
      this._heckedNo,
      this._heckedSmall,
      this._heckedMed,
      this._heckedLarg,
      this._total_price,
      this._item_no,
      this._size
      );

  String get selected_price => _selected_price;

  set selected_price(String value) {
    _selected_price = value;
  }

  String get price_no => _price_no;

  set price_no(String value) {
    _price_no = value;
  }

  int get size => _size;

  set size(int value) {
    _size = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

//////////////////////////////
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['item_id'] = _item_id;
    map['title_ar'] = _title_ar;
    map['title_en'] = _title_en;
    map['details_ar'] = _details_ar;
    map['details_en'] = _details_en;
    map['selected_price'] = _selected_price;

    map['price_no'] = _price_no;
    map['price_small'] = _price_small;
    map['price_mid'] = _price_mid;
    map['price_large'] = _price_large;

    map['url'] = _url;
    map['category_id'] = _category_id;
    map['cat_title_ar'] = _cat_title_ar;
    map['cat_title_en'] = _cat_title_en;
    map['heckedNo'] = _heckedNo;
    map['heckedSmall'] = _heckedSmall;
    map['heckedMed'] = _heckedMed;
    map['heckedLarg'] = _heckedLarg;
    map['total_price'] = _total_price;
    map['item_no'] = _item_no;
    map['size'] = _size;

    return map;
  }

// Extract a Note object from a Map object
  OrderItem.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._item_id = map['item_id'];
    this._title_ar = map['title_ar'];
    this._title_en = map['title_en'];
    this._details_ar = map['details_ar'];
    this._details_en = map['details_en'];
    this._selected_price = map['selected_price'];

    this._price_no = map['price_no'];
    this._price_small = map['price_small'];
    this._price_mid = map['price_mid'];
    this._price_large = map['price_large'];

    this._url = map['url'];
    this._category_id = map['category_id'];
    this._cat_title_ar = map['cat_title_ar'];
    this._cat_title_en = map['cat_title_en'];
    this._heckedNo = map['heckedNo'];
    this._heckedSmall = map['heckedSmall'];
    this._heckedMed = map['heckedMed'];
    this._heckedLarg = map['heckedLarg'];
    this._total_price = map['total_price'];
    this._item_no = map['item_no'];
    this._size = map['size'];

  }

  String get item_id => _item_id;

  set item_id(String value) {
    _item_id = value;
  }

  int get item_no => _item_no;

  set item_no(int value) {
    _item_no = value;
  }

  int get total_price => _total_price;

  set total_price(int value) {
    _total_price = value;
  }

  int get heckedLarg => _heckedLarg;

  set heckedLarg(int value) {
    _heckedLarg = value;
  }

  int get heckedMed => _heckedMed;

  set heckedMed(int value) {
    _heckedMed = value;
  }

  int get heckedSmall => _heckedSmall;

  set heckedSmall(int value) {
    _heckedSmall = value;
  }

  int get heckedNo => _heckedNo;

  set heckedNo(int value) {
    _heckedNo = value;
  }

  String get cat_title_en => _cat_title_en;

  set cat_title_en(String value) {
    _cat_title_en = value;
  }

  String get cat_title_ar => _cat_title_ar;

  set cat_title_ar(String value) {
    _cat_title_ar = value;
  }

  String get category_id => _category_id;

  set category_id(String value) {
    _category_id = value;
  }

  String get url => _url;

  set url(String value) {
    _url = value;
  }


  String get details_en => _details_en;

  set details_en(String value) {
    _details_en = value;
  }

  String get details_ar => _details_ar;

  set details_ar(String value) {
    _details_ar = value;
  }

  String get title_en => _title_en;

  set title_en(String value) {
    _title_en = value;
  }

  String get title_ar => _title_ar;

  set title_ar(String value) {
    _title_ar = value;
  }

  String get price_large => _price_large;

  set price_large(String value) {
    _price_large = value;
  }

  String get price_mid => _price_mid;

  set price_mid(String value) {
    _price_mid = value;
  }

  String get price_small => _price_small;

  set price_small(String value) {
    _price_small = value;
  }
}