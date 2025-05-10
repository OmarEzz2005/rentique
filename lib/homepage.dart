import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'service.dart'; // Import the ProductService class
import 'productDetails.dart'; // Import the ProductDetails class
import 'product.dart'; // Import the Product model
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class StudentHome extends StatefulWidget {
  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  late Future<List<dynamic>> products;
  bool _isAscending = true; // To toggle between ascending and descending
  double _minPrice = 0; // Default minimum price
  double _maxPrice = 100000; // Default maximum price
  bool _isFilterApplied = false; // To track if the filter is applied
  String? _selectedCategory;
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedIndex = 0; // To track the selected index for bottom navigation
  bool _isListening = false;
  stt.SpeechToText _speech = stt.SpeechToText();

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          print('Error: $error');
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _searchController.text = result.recognizedWords;
              _searchQuery = result.recognizedWords.toLowerCase();
            });
          },
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the products fetch request
    products = _getFilteredProducts();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        // If focus is lost, make Home tab active
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }

  Future<List<dynamic>> _getFilteredProducts() async {
    List<dynamic> allProducts = await ProductService.fetchProducts();
    return allProducts.where((product) {
      bool matchesSearch = product['title'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesPrice =
          product['price'] >= _minPrice && product['price'] <= _maxPrice;
      bool matchesCategory =
          _selectedCategory == null || product['category'] == _selectedCategory;

      return matchesSearch && matchesPrice && matchesCategory;
    }).toList();
  }

  Widget _buildHorizontalItem(
    String imagePath,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.red : Colors.black),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.red : Colors.black,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeaf2ef),
      body: SafeArea(
        child: ListView(
          children: [
            // Header
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 40,
                          height: 40,
                        ),
                        Text(
                          'Rentique',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff4392F9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons
                        .person_2_outlined, // You can choose another postfix icon
                    color: Color.fromARGB(255, 0, 0, 0),
                    size: 35,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },

                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 10, bottom: 5),
                  hintText: "Search any product...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                          : IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic_off : Icons.mic,
                            ),
                            onPressed: _listen,
                          ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Featured',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              100,
                              100,
                              100,
                              100,
                            ), // Position where the menu will appear
                            items: [
                              PopupMenuItem(
                                child: ListTile(
                                  leading: const Icon(Icons.sort),
                                  title: const Text("Sort by Ascending Price"),
                                  onTap: () {
                                    setState(() {
                                      _isAscending = true; // Sort ascending
                                    });
                                    Navigator.pop(context); // Close the menu
                                  },
                                ),
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                  leading: const Icon(Icons.sort),
                                  title: const Text("Sort by Descending Price"),
                                  onTap: () {
                                    setState(() {
                                      _isAscending = false; // Sort descending
                                    });
                                    Navigator.pop(context); // Close the menu
                                  },
                                ),
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                  leading: const Icon(Icons.clear),
                                  title: const Text("Clear Filters"),
                                  onTap: () {
                                    setState(() {
                                      _isAscending =
                                          true; // Reset to default (ascending)
                                    });
                                    Navigator.pop(context); // Close the menu
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                        icon: const Icon(Icons.sort, size: 18),
                        label: const Text("Sort"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Show filter menu with price input fields
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Filter by Price',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Min Price Input Field (empty with only hint text)
                                    Text('Enter Min Price'),
                                    TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter min price',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          // Only update the price if the input is valid
                                          _minPrice =
                                              double.tryParse(value) ??
                                              _minPrice;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    // Max Price Input Field (empty with only hint text)
                                    Text('Enter Max Price'),
                                    TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter max price',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          // Only update the price if the input is valid
                                          _maxPrice =
                                              double.tryParse(value) ??
                                              _maxPrice;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    // Display the selected prices below the input fields
                                    Text(
                                      'Min Price: \$${_minPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Max Price: \$${_maxPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Apply filter and close the sheet
                                        setState(() {
                                          _isFilterApplied = true;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Apply Filter'),
                                    ),
                                    const SizedBox(height: 10),
                                    // Button to reset the filter
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          // Reset min and max prices to defaults
                                          _minPrice = 0;
                                          _maxPrice = 100000;
                                          _isFilterApplied = false;
                                        });
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red, // Red button for reset
                                      ),
                                      child: const Text('Remove Filters'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.filter_list, size: 18),
                        label: const Text("Filter"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              height: 100, // Adjust height as needed
              padding: const EdgeInsets.only(top: 15, bottom: 10, left: 10),
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildHorizontalItem('assets/images/item3.png', 'All', () {
                    setState(() {
                      _selectedCategory = null;
                      products = _getFilteredProducts();
                    });
                  }),

                  _buildHorizontalItem(
                    'assets/images/item1.png',
                    'Jewelery',
                    () {
                      setState(() {
                        _selectedCategory = 'jewelery';
                        products = _getFilteredProducts();
                      });
                    },
                  ),
                  _buildHorizontalItem(
                    'assets/images/item2.png',
                    'Electronics',
                    () {
                      setState(() {
                        _selectedCategory = 'electronics';
                        products = _getFilteredProducts();
                      });
                    },
                  ),

                  _buildHorizontalItem('assets/images/item4.png', 'Men', () {
                    setState(() {
                      _selectedCategory = 'men\'s clothing';
                      products = _getFilteredProducts();
                    });
                  }),
                  _buildHorizontalItem('assets/images/item5.png', 'Women', () {
                    setState(() {
                      _selectedCategory = 'women\'s clothing';
                      products = _getFilteredProducts();
                    });
                  }),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Container(
              margin: const EdgeInsets.only(left: 10),
              child: const Text(
                'All Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            const SizedBox(height: 10),

            FutureBuilder<List<dynamic>>(
              future: products, // Pass the future to FutureBuilder
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products available'));
                } else {
                  List<dynamic> productsList = snapshot.data!;

                  if (_isFilterApplied) {
                    productsList =
                        productsList.where((product) {
                          double productPrice =
                              (product['price'] as num).toDouble();
                          return productPrice >= _minPrice &&
                              productPrice <= _maxPrice;
                        }).toList();
                  }

                  if (_searchQuery.isNotEmpty) {
                    productsList =
                        productsList.where((product) {
                          final title =
                              product['title'].toString().toLowerCase();
                          return title.contains(_searchQuery);
                        }).toList();
                  }
                  productsList.sort((a, b) {
                    double aPrice =
                        (a['price'] as num)
                            .toDouble(); // Assuming price is a number
                    double bPrice =
                        (b['price'] as num)
                            .toDouble(); // Assuming price is a number

                    return _isAscending
                        ? aPrice.compareTo(bPrice) // Ascending order
                        : bPrice.compareTo(aPrice); // Descending order
                  });
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 300, // Height of each item
                        ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: productsList.length,
                    itemBuilder: (context, index) {
                      final product = productsList[index];
                      final item = Product(
                        title: product['title'],
                        description: product['description'],
                        price: (product['price'] as num).toDouble(),
                        imageUrl: product['image'],
                      );

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetails(product: item),
                            ),
                          );
                        },
                        child: Container(
                          height: 80,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  product['image'], // Use the image URL from the API
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                product['title'], // Product title
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                product['description'], // Product description
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '\$${product['price']}', // Product price
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", _selectedIndex == 0, () {
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StudentHome()),
              );
            }),
            _buildNavItem(
              Icons.favorite_border,
              "Wishlist",
              _selectedIndex == 1,
              () {
                setState(() {
                  _selectedIndex = 1;
                });
                // Handle Wishlist tap logic
              },
            ),
            const SizedBox(width: 60), // For FAB
            _buildNavItem(Icons.search, "Search", _selectedIndex == 2, () {
              setState(() {
                _selectedIndex = 2;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Request focus after the frame has been built.
                print('Requesting focus...');
                _searchFocusNode.requestFocus(); // Focus the TextField
                FocusScope.of(context).requestFocus(
                  _searchFocusNode,
                ); // Ensure it is focused properly
              });
            }),

            _buildNavItem(Icons.settings, "Settings", _selectedIndex == 3, () {
              setState(() {
                _selectedIndex = 3;
              });
              // Handle Settings tap logic
            }),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle FAB tap
          print("Floating Action Button tapped");
        },

        backgroundColor: Colors.white,
        child: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
      ),

      // Floating Action Button location
      floatingActionButtonLocation:
          FloatingActionButtonLocation
              .centerDocked, // This docks the FAB to the center of the bottom bar
    );
  }
}
