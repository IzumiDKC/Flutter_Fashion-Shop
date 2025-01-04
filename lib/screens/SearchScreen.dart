import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import 'ProductScreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isFilterVisible = false;
  List<dynamic> allProducts = [];
  List<dynamic> displayedProducts = [];
  List<dynamic> brands = [];
  List<dynamic> categories = [];
  String searchQuery = '';
  String selectedPriceRange = 'Tất cả';
  String selectedBrand = 'Tất cả';
  String selectedCategory = 'Tất cả';
  bool isLoading = true;

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ApiClient.setupInterceptors();
    _loadDataFromCacheOrFetch();
  }

  Future<void> _loadDataFromCacheOrFetch() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final cachedProducts = prefs.getString('products');
    final cachedBrands = prefs.getString('brands');
    final cachedCategories = prefs.getString('categories');

    if (cachedProducts != null &&
        cachedBrands != null &&
        cachedCategories != null) {
      // Dữ liệu tồn tại trong cache, sử dụng ngay
      setState(() {
        allProducts = json.decode(cachedProducts);
        displayedProducts = allProducts;
        brands = json.decode(cachedBrands);
        categories = json.decode(cachedCategories);
        isLoading = false;
      });
    } else {
      // Không có cache, gọi API
      await _fetchAndCacheData();
    }
  }

  Future<void> _fetchAndCacheData() async {
    try {
      final productsResponse = await ApiClient.dio.get('api/products');
      final products = productsResponse.data as List;

      final brandsResponse = await ApiClient.dio.get('api/brands');
      final fetchedBrands = brandsResponse.data as List;

      final categoriesResponse = await ApiClient.dio.get('api/categories');
      final fetchedCategories = categoriesResponse.data as List;

      final brandMap = {
        for (var brand in fetchedBrands) brand['id']: brand['name']
      };
      final categoryMap = {
        for (var category in fetchedCategories) category['id']: category['name']
      };

      final mappedProducts = products.map((product) {
        return {
          ...product,
          'brand': brandMap[product['brandId']],
          'category': categoryMap[product['categoryId']],
        };
      }).toList();

      // Lưu dữ liệu vào cache
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('products', json.encode(mappedProducts));
      prefs.setString(
          'brands',
          json.encode(['Tất cả', ...fetchedBrands.map((e) => e['name'])]));
      prefs.setString(
          'categories',
          json.encode(['Tất cả', ...fetchedCategories.map((e) => e['name'])]));

      setState(() {
        allProducts = mappedProducts;
        displayedProducts = mappedProducts;
        brands = ['Tất cả', ...fetchedBrands.map((e) => e['name']).toList()];
        categories =
        ['Tất cả', ...fetchedCategories.map((e) => e['name']).toList()];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  final List<String> priceRanges = [
    'Tất cả',
    'Dưới 100k',
    '100k -> 200k',
    'Trên 200k'
  ];

  bool _matchesPriceRange(dynamic product) {
    double finalPrice = product['finalPrice'] as double;
    switch (selectedPriceRange) {
      case 'Dưới 100k':
        return finalPrice < 100.0;
      case '100k -> 200k':
        return finalPrice >= 100.0 && finalPrice <= 200.0;
      case 'Trên 200k':
        return finalPrice > 200.0;
      default:
        return true;
    }
  }


  void _filterProducts() {
    setState(() {
      displayedProducts = allProducts.where((product) {
        final nameMatches = product['name']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
        final priceMatches = _matchesPriceRange(product);
        final brandMatches = selectedBrand == 'Tất cả' ||
            product['brand'] == selectedBrand;
        final categoryMatches =
            selectedCategory == 'Tất cả' ||
                product['category'] == selectedCategory;
        return nameMatches && priceMatches && brandMatches && categoryMatches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue value) {
                      if (value.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return allProducts
                          .map((product) => product['name'].toString())
                          .where((name) =>
                          name
                              .toLowerCase()
                              .contains(value.text.toLowerCase()));
                    },
                    onSelected: (String selected) {
                      setState(() {
                        searchQuery = selected;
                        _filterProducts();
                      });
                      FocusScope.of(context).unfocus();
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController controller,
                        FocusNode node,
                        VoidCallback onSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: node,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            _filterProducts();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Tìm kiếm sản phẩm...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isFilterVisible ? Icons.close : Icons.menu,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      isFilterVisible = !isFilterVisible;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isFilterVisible)
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedPriceRange,
                          onChanged: (newValue) {
                            setState(() {
                              selectedPriceRange = newValue!;
                              _filterProducts();
                            });
                          },
                          items: priceRanges.map((priceRange) {
                            return DropdownMenuItem<String>(
                              value: priceRange,
                              child: Text(priceRange),
                            );
                          }).toList(),
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.style, color: Colors.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedBrand,
                          onChanged: (newValue) {
                            setState(() {
                              selectedBrand = newValue!;
                              _filterProducts();
                            });
                          },
                          items: brands.map((brand) {
                            return DropdownMenuItem<String>(
                              value: brand,
                              child: Text(brand),
                            );
                          }).toList(),
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.checkroom, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          onChanged: (newValue) {
                            setState(() {
                              selectedCategory = newValue!;
                              _filterProducts();
                            });
                          },
                          items: categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            Expanded(
              child: displayedProducts.isEmpty
                  ? const Center(
                child: Text('Không có sản phẩm nào phù hợp.'),
              )
                  : ListView.builder(
                itemCount: displayedProducts.length,
                itemBuilder: (context, index) {
                  final product = displayedProducts[index];
                  return ProductItem(product: product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


