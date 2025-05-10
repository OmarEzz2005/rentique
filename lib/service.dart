import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  static const String apiUrl = "https://fakestoreapi.com/products";

  // Fetch products from API
  static Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the data
        List<dynamic> products = json.decode(response.body);
        return products;
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      throw Exception("Failed to load products: $e");
    }
  }
}
