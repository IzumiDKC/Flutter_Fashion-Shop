import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fb88/screens/RegisterScreen.dart';
import '../models/AuthModels.dart';
import '../models/Brand.dart';
import '../models/Product.dart';
import '../models/Category.dart';
import '../models/UserProfile.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://2136-14-169-18-85.ngrok-free.app/",
      connectTimeout: 5000,
      receiveTimeout: 3000,
    ),
  );

  static String? token;

  static final authInterceptor = InterceptorsWrapper(
    onRequest: (options, handler) {
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  );

  static final loggingInterceptor = InterceptorsWrapper(
    onRequest: (options, handler) {
      print('Request: ${options.method} ${options.uri}');
      print('Headers: ${options.headers}');
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('Response: ${response.data}');
      return handler.next(response);
    },
    onError: (error, handler) {
      print('Error: ${error.message}');
      return handler.next(error);
    },
  );

  static void setupInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Thêm token nếu có
        options.headers['Authorization'] = 'Bearer ${ApiClient.token}';
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await dio.get("api/products");
      List<Product> products =
      (response.data as List).map((e) => Product.fromJson(e)).toList();
      return products;
    } catch (e) {
      throw Exception("Error during GET request: $e");
    }
  }

  Future<List<Brand>> getBrands() async {
    try {
      final response = await dio.get("api/brands");
      List<Brand> brands =
      (response.data as List).map((e) => Brand.fromJson(e)).toList();
      return brands;
    } catch (e) {
      throw Exception("Error during GET request: $e");
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await dio.get("api/categories");
      List<Category> categories =
      (response.data as List).map((e) => Category.fromJson(e)).toList();
      return categories;
    } catch (e) {
      throw Exception("Error during GET request: $e");
    }
  }

  Future<Response> login(LoginRequest request) async {
    try {
      final response = await dio.post("api/auth/login", data: request.toJson());

      print("Login response: ${response.data}");

      if (response.data == null || !response.data.containsKey('token')) {
        throw Exception("Token not found in response");
      }

      token = response.data['token'];
      print("Token saved: $token");

      return response;
    } catch (e) {
      if (e is DioError) {
        print("DioError: ${e.response?.data ?? e.message}");
      } else {
        print("Login error: $e");
      }
      throw Exception("Error during login: $e");
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      await dio.post("api/auth/register", data: request.toJson());
    } catch (e) {
      throw Exception("Error during POST register request: $e");
    }
  }

  Future<UserProfile> getProfile(String userId) async {
    try {
      final response = await dio.get("/api/account/profile/$userId");
      return UserProfile.fromJson(response.data);
    } catch (e) {
      print("Lỗi khi GET thông tin người dùng: $e");
      throw Exception("Lỗi khi GET thông tin người dùng: $e");
    }
  }



  // Update user profile
  /*Future<void> updateProfile(
      String userId, UpdatedProfile updatedProfile) async {
    try {
      await dio.put("api/account/update-profile/$userId",
          data: updatedProfile.toJson());
    } catch (e) {
      throw Exception("Error during PUT profile update request: $e");
    }
  }

  // Get products on sale
  Future<List<Product>> getProductsOnSale() async {
    try {
      final response = await dio.get("onsale");
      List<Product> products =
          (response.data as List).map((e) => Product.fromJson(e)).toList();
      return products;
    } catch (e) {
      throw Exception("Error during GET sale products request: $e");
    }
  }

  // Get user orders
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final response = await dio.get("api/Orders/user-orders/$userId");
      List<Order> orders =
          (response.data as List).map((e) => Order.fromJson(e)).toList();
      return orders;
    } catch (e) {
      throw Exception("Error during GET user orders request: $e");
    }
  }

  // Create order
  Future<Order> createOrder(CreateOrderRequest createOrderRequest) async {
    try {
      final response = await dio.post("api/Orders/create",
          data: createOrderRequest.toJson());
      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception("Error during POST order request: $e");
    }
  }
}*/

  void main() {
    // Initialize Dio interceptors
    ApiClient.setupInterceptors();

    // Example usage of API methods
    final apiClient = ApiClient();

    // Get products
    apiClient.getProducts().then((products) {
      print('Fetched Products: $products');
    }).catchError((e) {
      print('Request failed: $e');
    });

    // Get categories
    apiClient.getCategories().then((categories) {
      print('Fetched Categories: $categories');
    }).catchError((e) {
      print('Request failed: $e');
    });
  }
}
