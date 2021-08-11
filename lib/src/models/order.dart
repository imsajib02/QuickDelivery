import '../helpers/custom_trace.dart';
import '../models/address.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/product_order.dart';
import '../models/user.dart';

class Order {
  String id;
  List<ProductOrder> productOrders;
  OrderStatus orderStatus;
  int statusID;
  bool isActive;
  double tax;
  double deliveryFee;
  String hint;
  int driverID;
  DateTime dateTime;
  int userID;
  User user;
  int paymentID;
  Payment payment;
  int deliveryAddressID;
  Address deliveryAddress;

  Order();

  Order.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      userID = jsonMap['user_id'] ?? 0;
      statusID = jsonMap['order_status_id'] == null ? 0 : jsonMap['order_status_id'];
      tax = jsonMap['tax'] != null ? jsonMap['tax'].toDouble() : 0.0;
      deliveryFee = jsonMap['delivery_fee'] != null ? jsonMap['delivery_fee'].toDouble() : 0.0;
      hint = jsonMap['hint'] == null ? '' : jsonMap['hint'].toString();
      isActive = jsonMap['active'] ?? false;
      driverID = jsonMap['driver_id'] ?? 0;
      orderStatus = jsonMap['order_status'] != null ? OrderStatus.fromJSON(jsonMap['order_status']) : new OrderStatus();
      orderStatus.id = statusID.toString();
      dateTime = DateTime.parse(jsonMap['updated_at']);
      user = jsonMap['user'] != null ? User.fromJSON(jsonMap['user']) : new User();
      user.id = userID.toString();
      paymentID = jsonMap['payment_id'] ?? 0;
      payment = jsonMap['payment'] != null ? Payment.fromJSON(jsonMap['payment']) : new Payment.init();
      payment.id = paymentID.toString();
      deliveryAddressID = jsonMap['delivery_address_id'];
      deliveryAddress = jsonMap['delivery_address'] != null ? Address.fromJSON(jsonMap['delivery_address']) : new Address();
      deliveryAddress.id = deliveryAddressID.toString();
      productOrders = jsonMap['product_orders'] != null ? List.from(jsonMap['product_orders']).map((element) => ProductOrder.fromJSON(element)).toList() : [];
    } catch (e) {
      id = '';
      tax = 0.0;
      deliveryFee = 0.0;
      hint = '';
      orderStatus = new OrderStatus();
      dateTime = DateTime(0);
      user = new User();
      payment = new Payment.init();
      deliveryAddress = new Address();
      productOrders = [];
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["user_id"] = user?.id;
    map["order_status_id"] = orderStatus?.id;
    map["tax"] = tax;
    map["delivery_fee"] = deliveryFee;
    map["products"] = productOrders.map((element) => element.toMap()).toList();
    map["payment"] = payment?.toMap();
    if (deliveryAddress?.id != null && deliveryAddress?.id != 'null') map["delivery_address_id"] = deliveryAddress.id;
    return map;
  }

  Map deliveredMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["order_status_id"] = 5;
    return map;
  }
}
