

class ItemFoodClass{
  String id;
  String title_ar;
  String title_en;
  String details_ar;
  String details_en;
  String url;
  int arrange;
  bool animation;
  String mid;
  String mtitle_ar;
  String mtitle_en;

  bool heckedNo;
  bool heckedSmall;
  bool heckedMed;
  bool heckedLarg;

  String price_no;
  String price_small;
  String price_mid;
  String price_large;
ItemFoodClass (this.id,this.title_ar,this.title_en,this.details_ar,this.details_en,
    this.price_no, this.price_small, this.price_mid, this.price_large,
    this.url,this.arrange,this.animation,
    this.mid,this.mtitle_ar,this.mtitle_en,this.heckedNo,this.heckedSmall,this.heckedMed,this.heckedLarg);


}