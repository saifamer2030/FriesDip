import 'package:friesdip/Classes/OrderItem.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'OrderItemforBill.dart';

class DatabaseHelper {

	static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
	static Database _database;
	DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper
	factory DatabaseHelper() {
		if (_databaseHelper == null) {
			_databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
		}
		return _databaseHelper;
	}

	Future<Database> get database async {

		if (_database == null) {
			_database = await initializeDatabase();
		}
		return _database;
	}
	// Future<Database> initializeDatabase() async {
	// 	// Get the directory path for both Android and iOS to store database.
	// 	Directory directory = await getApplicationDocumentsDirectory();
	// 	String path = directory.path + 'order1.db';
	//
	// 	// Open/create the database at a given path
	// 	var orderDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
	// 	return orderDatabase;
	// }
	Future<Database> initializeDatabase() async {
		Directory directory = await getApplicationDocumentsDirectory();
		String path = p.join(directory.toString(),'order1.db');

		Database database = await openDatabase(path, version: 1, onCreate: _createDb);
		return database;
	}


	void _createDb(Database db, int newVersion) async {
		await db.execute('create table order_table( id INTEGER PRIMARY KEY, item_id  TEXT, title_ar TEXT, title_en TEXT, details_ar TEXT, details_en TEXT, selected_price TEXT, price_no TEXT,price_small TEXT,price_mid TEXT,price_large TEXT,url TEXT, category_id TEXT, cat_title_ar TEXT, cat_title_en TEXT, heckedNo INTEGER, heckedSmall INTEGER, heckedMed INTEGER, heckedLarg INTEGER, total_price INTEGER, item_no INTEGER, size INTEGER)');
	}
	// Fetch Operation: Get all order objects from database
	Future<List<Map<String, dynamic>>> getOrderMapList() async {
		Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $orderTable order by $colPriority ASC');
		var result = await db.query("order_table", orderBy: 'id DESC');
		return result;
	}
	// Insert Operation: Insert a order object to database
	Future<int> insertOrder(OrderItem order) async {
		Database db = await this.database;
		var result = await db.insert("order_table", order.toMap());
		return result;
	}
	Future<bool> inCart(OrderItem order) async {
	Database db = await this.database;
		List<Map<String,dynamic>> maps = await db.query(
				'order_table',
				where: 'item_id = ?',
				whereArgs: [order.item_id],
				limit: 1
		);
		return maps.length != 0;
	}
	Future<int> updateOrder(OrderItem order) async {
		var db = await this.database;
		var result = await db.update("order_table", order.toMap(), where: 'item_id = ?', whereArgs: [order.item_id]);
		return result;
	}
	Future<int> updateOrdercost(OrderItem order) async {
		var db = await this.database;
		var result = await db.update("order_table", order.toMap(), where: 'item_id = ?', whereArgs: [order.item_id]);
		return result;
	}
	// Delete Operation: Delete a order object from database
	Future<int> deleteOrder(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM order_table WHERE id = $id');
		return result;
	}
	// Get number of order objects in database
	Future<int> getCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from order_table');
		int result = Sqflite.firstIntValue(x);
		return result;
	}
	// Get the 'Map List' [ List<Map> ] and convert it to 'order List' [ List<order> ]
	Future<List<OrderItem>> getOrderList() async {

		var orderMapList = await getOrderMapList(); // Get 'Map List' from database
		int count = orderMapList.length;         // Count the number of map entries in db table
		// DateTime now = DateTime.now();
//
//      deletolditem(widget.document['userId'],widget.document['offer_id'],
//          widget.document['total_price'],widget.document['item_no']);

		List<OrderItem> orderList = List<OrderItem>();
		// For loop to create a 'order List' from a 'Map List'
		for (int i = 0; i < count; i++) {

			// DateTime enddate=DateTime.parse("${orderMapList[i]['end_date']} 23:59:00");
			// if( now.isAfter(enddate )) {
			// 	print("mmmmmm${orderMapList[i]['id']}");
			// 	deleteOrder(orderMapList[i]['id']);
			//
			// }else{
				orderList.add(OrderItem.fromMapObject(orderMapList[i]));
			//	print("mmmmmm${orderMapList[i]['id']}");

			//}

		}

		return orderList;
	}
	Future<int> calcTotalprice() async {
		var orderMapList = await getOrderMapList(); // Get 'Map List' from database
		int count = orderMapList.length;         // Count the number of map entries in db table
		int totalprice = 0;
		List<OrderItem> orderList = List<OrderItem>();
		for (int i = 0; i < count; i++) {
				totalprice=totalprice+orderMapList[i]['total_price'];
		}
		return totalprice;
	}
	Future<int> calcTotalItems() async {
		var orderMapList = await getOrderMapList(); // Get 'Map List' from database
		int count = orderMapList.length;         // Count the number of map entries in db table
		int totalitem = 0;
		List<OrderItem> orderList = List<OrderItem>();
		for (int i = 0; i < count; i++) {
			totalitem=totalitem+orderMapList[i]['item_no'];
		}
		return totalitem;
	}


	Future<OrderItemforBill> alldatafororder() async {
		var orderMapList = await getOrderMapList(); // Get 'Map List' from database
		int count = orderMapList.length;         // Count the number of map entries in db table

		String item_id1="";
		String title_ar1="";
		String title_en1="";
		String url1="";
		String total_price1="";
		String item_no1="";
		String size1="";


		List<OrderItem> orderList = List<OrderItem>();
		for (int i = 0; i < count; i++) {
			//totalitem=totalitem+orderMapList[i]['item_no'];
			 item_id1=item_id1+","+orderMapList[i]['item_id'];
			 title_ar1=title_ar1+","+orderMapList[i]['title_ar'];
			 title_en1=title_en1+","+orderMapList[i]['title_en'];
			 url1=url1+","+orderMapList[i]['url'];
			 total_price1=total_price1+","+orderMapList[i]['total_price'].toString();
			 item_no1=item_no1+","+orderMapList[i]['item_no'].toString();
			 size1=size1+","+orderMapList[i]['size'].toString();
			 // print("jjjjsize:$size1");
			 // print("jjjjitem_no:$item_no1");
			 // print("jjjjtotal_price:$total_price1");
			 // print("jjjjurl1:$url1");

		}
		return
			OrderItemforBill(
				item_id1,
				title_ar1,
				title_en1,
				url1,
				total_price1,
				item_no1,
				size1,
		);
	}
}







