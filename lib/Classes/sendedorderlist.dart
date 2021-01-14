class SendedOrderList{
  int carrange;
  String orderId;
  String userid;
  String cdate;
  String Payment;

  String branch_id;
  bool deliverycheck;
  String deliverytime;

  double lat_gps;
  double long_gps;
  String address_gps;
  String ttprice;
  int ttitems;

  List<String> item_id_list;
  List<String> title_ar_list;
  List<String> title_en_list;
  List<String> total_price_list;
  List<String> item_no_list;
  List<String> size_list;
  List<String> url_list;
  String OrderStatus;

  SendedOrderList(
      this.carrange,
      this.orderId,
      this.userid,
      this.cdate,
      this.Payment,
      this.branch_id,
      this.deliverycheck,
      this.deliverytime,
      this.lat_gps,
      this.long_gps,
      this.address_gps,
      this.ttprice,
      this.ttitems,
      this.item_id_list,
      this.title_ar_list,
      this.title_en_list,
      this.total_price_list,
      this.item_no_list,
      this.size_list,
      this.url_list,
      this.OrderStatus);
}