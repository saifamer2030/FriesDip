import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/Classes/BranchListClass.dart';
import 'package:friesdip/Classes/FoodListClass.dart';
import 'package:friesdip/Classes/ItemFoodClass.dart';
import 'package:friesdip/Classes/UsersClass.dart';
import 'package:friesdip/ScreenPage/cur_loc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:time_range/time_range.dart';
import 'package:toast/toast.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';


class UsersAdmin extends StatefulWidget {
  UsersAdmin();

  @override
  _UsersAdminState createState() => _UsersAdminState();
}

class _UsersAdminState extends State<UsersAdmin> {
  var _controller = ScrollController();

  final userdatabaseReference =
      FirebaseDatabase.instance.reference().child("userdata");
  bool isLoaded = true;
  String url, id;
  var i;
  bool _load2 = false;
  bool isSearch = false;
  String filtter = '';
  String filt = "";

  TextEditingController searchcontroller = TextEditingController();

  List<UsersClass> SearchList = [];
  List<UsersClass> costantList = [];
  List<UsersClass> UsersList = [];

  void filterSearchResults(String filtter) {
    SearchList.clear();
    SearchList.addAll(UsersList);
    if (filtter == '') {
      setState(() {
        UsersList.clear();
        UsersList.addAll(costantList);
      });
      return;
    } else {
      setState(() {
        List<UsersClass> ListData = [];
        SearchList.forEach((item) {
          if (item.cName.toString().contains(filtter) ||
              item.cPhone.toString().contains(filtter)) {
            ListData.add(item);
          }
        });
        setState(() {
          UsersList.clear();
          UsersList.addAll(ListData);
        });
        return;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    searchcontroller.addListener(() {
      if (searchcontroller.text == '') {
        setState(() {
          filtter = '';
        });
      } else {
        setState(() {
          filtter = searchcontroller.text;
        });
      }
    });
    getData();
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _load2
        ? new Container(
            child: SpinKitCircle(
              color: Theme.of(context).accentColor,
            ),
          )
        : new Container();
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: Column(
        children: [
          Container(
            // width: 210,
            height: 30,
            margin: EdgeInsets.only(left: 2),
            decoration: BoxDecoration(
              color: Color.fromARGB(97, 248, 248, 248),
              border: Border.all(
                width: 1,
                color: Color.fromARGB(97, 216, 216, 216),
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),

            child: Container(
                height: 13,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {
                        filt = value;
                        filterSearchResults(filt);
                      });
                    },
                    controller: searchcontroller,
                    // focusNode: focus,
                    decoration: InputDecoration(
                      labelText:
                          searchcontroller.text.isEmpty ? "بحث بالاسم" : '',
                      labelStyle:
                          TextStyle(color: Colors.black, fontSize: 18.0),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      suffixIcon: searchcontroller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.cancel, color: Colors.black),
                              onPressed: () {
                                setState(() {
                                  searchcontroller.clear();

                                  setState(() {
                                    filt = '';
                                    filterSearchResults(filt);
                                  });
                                });
                              },
                            )
                          : null,
                      errorStyle: TextStyle(color: Colors.blue),
                      enabled: true,
                      alignLabelWithHint: true,
                    ),
                  ),
                )),
          ),
          Expanded(
              child: UsersList.length == 0
                  ? Center(
                      child: Text(
                      translator.translate('no_data'),
                    ))
                  : new ListView.builder(
                      physics: BouncingScrollPhysics(),
                      controller: _controller,
                      itemCount: UsersList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return firebasedata(
                          index,
                        );
                      })),
        ],
      ),
    ));
  }

  Widget firebasedata(var index) {
    return Card(
      elevation: 10,
      shape:
          new RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      margin: EdgeInsets.all(6),
      child: ListTile(
        title: Text(
          UsersList[index].cName == null
              ? translator.translate('no_data')
              : UsersList[index].cName,
          textDirection: TextDirection.rtl,
          style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.green[800]),
        ),
        subtitle: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                if (UsersList[index].cPhone != null) {
                  _makePhoneCall('tel:${UsersList[index].cPhone}');
                }
              },
              child: Text(
                UsersList[index].cPhone == null
                    ? translator.translate('no_data')
                    : UsersList[index].cPhone,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.fiber_manual_record,
                  size: 25,
                  color: Colors.green,
                ),
                Text(
                  UsersList[index].cGender != null
                      ? UsersList[index].cGender == 0
                          ? translator.translate('Male')
                          : translator.translate('Female')
                      : translator.translate('no_data'),
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ],
        ),

        leading: FlatButton(
          highlightColor: Theme.of(context).accentColor,
          // onLongPress: ()  async {
          // },
          onPressed: () {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  Widget cancelButton = FlatButton(
                    child: Text(translator.translate('cancel')),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  );
                  Widget continueButton = FlatButton(
                    child: Text(translator.translate('confirmation')),
                    onPressed: () async {
                      if (UsersList[index].blocked == null) {
                        UsersList[index].blocked = false;
                      }

                      setState(() {
                        UsersList[index].blocked = !UsersList[index].blocked;
                        print("hhhh${UsersList[index].blocked}");
                      });
                      userdatabaseReference.child(UsersList[index].cId).update({
                        "blocked": UsersList[index].blocked,
                      }).then((value) {
                        if (UsersList[index].blocked) {
                          Fluttertoast.showToast(
                              msg: "تم الحظر",
                              backgroundColor: Colors.black,
                              textColor: Colors.white);
                        } else {
                          Fluttertoast.showToast(
                              msg: "تم الغاء الحظر",
                              backgroundColor: Colors.black,
                              textColor: Colors.white);
                        }
                        Navigator.of(context).pop();
                      });
                    },
                  );

                  return AlertDialog(
                    title: Text(translator.translate('confirmation')),
                    content: Text("هل انت متاكد؟؟؟"),
                    actions: [
                      cancelButton,
                      continueButton,
                    ],
                  );
                });
          },
          child: Icon(
            Icons.block,
            color: UsersList[index].blocked != null
                ? UsersList[index].blocked
                    ? Colors.red
                    : Colors.green
                : Colors.green,
          ),
        ),

        trailing: FlatButton(
          highlightColor: Theme.of(context).accentColor,
          // onLongPress: ()  async {
          // },
          onPressed: () {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  Widget cancelButton = FlatButton(
                    child: Text(translator.translate('cancel')),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  );
                  Widget continueButton = FlatButton(
                    child: Text(translator.translate('confirmation')),
                    onPressed: () async {
                      if (UsersList[index].deleted == null) {
                        UsersList[index].deleted = false;
                      }

                      setState(() {
                        UsersList[index].deleted = !UsersList[index].deleted;
                        print("hhhh${UsersList[index].deleted}");
                      });
                      userdatabaseReference.child(UsersList[index].cId).update({
                        "deleted": UsersList[index].deleted,
                      }).then((value) {
                        if (UsersList[index].blocked) {
                          Fluttertoast.showToast(
                              msg:
                                  "سيتم الحذف قريبا يمكنك الرجوع قبل اتمام عملية الحذف",
                              backgroundColor: Colors.black,
                              textColor: Colors.white);
                        } else {
                          Fluttertoast.showToast(
                              msg: "تم الغاء الحذف",
                              backgroundColor: Colors.black,
                              textColor: Colors.white);
                        }
                        Navigator.of(context).pop();
                      });
                    },
                  );

                  return AlertDialog(
                    title: Text(translator.translate('confirmation')),
                    content: Text("هل انت متاكد؟؟؟"),
                    actions: [
                      cancelButton,
                      continueButton,
                    ],
                  );
                });
          },
          child: Icon(
            Icons.delete,
            color: UsersList[index].deleted != null
                ? UsersList[index].deleted
                    ? Colors.red
                    : Colors.green
                : Colors.green,
          ),
        ),
        // IconButton(
        //   icon: Icon(Icons.content_copy),
        //   color: Colors.grey,
        //   focusColor: Colors.red,
        //   splashColor:  Colors.yellow,
        //   hoverColor:  Colors.orange,
        //   highlightColor:  Colors.teal,
        //   //onPressed: () {},
        //   onLongPress: () => {
        //     //do something
        //   },
        // ),
      ),
    );
  }

  void getData() {
    FirebaseDatabase.instance
        .reference()
        .child("userdata")
        .once()
        .then((DataSnapshot snapshot) async {
      var KEYS = snapshot.value.keys;
      var DATA = snapshot.value;
      // print("${snapshot.value}hhh");

      UsersList.clear();
      for (var individualkey in KEYS) {
        UsersClass usersclass = new UsersClass(
          DATA[individualkey]['cId'],
          DATA[individualkey]['cName'],
          DATA[individualkey]['cPhone'],
          DATA[individualkey]['cGender'],
          DATA[individualkey]['blocked'],
          DATA[individualkey]['deleted'],
        );
        setState(() {
          UsersList.add(usersclass);
          costantList.add(usersclass);
        });
      }
    });
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
