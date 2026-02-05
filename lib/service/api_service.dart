import 'dart:convert';

import 'package:computer_store/model/product.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future <List<Product>> getProduct() async{
    final url = Uri.parse("https://svdara-only1.github.io/api-shose/");
    final respone = await http.get(url);
    Map<String, dynamic> product = jsonDecode(respone.body); 
    List data = product['products'];
    return data.map((e)=>Product.fromJson(e)).toList();
  }
}