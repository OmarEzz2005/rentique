import 'package:flutter/material.dart';
import 'product.dart';

class ProductDetails extends StatefulWidget {
  final Product product;

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final TextEditingController _deliveryTimeController = TextEditingController(
    text: '5 hours',
  );

  String _selectedSize = 'M'; // Default size
  final List<String> _availableSizes = ['S', 'M', 'L', 'XL'];

  @override
  void dispose() {
    _deliveryTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Padding(
        padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  widget.product.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.scaleDown,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.product.title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.product.description,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${widget.product.price}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Color(0xffFFCCD5)),
                  child: Row(
                    children: const [
                      Text('Delivery within:', style: TextStyle(fontSize: 16)),
                      Text(
                        '  5 hours',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Selected Size Text
                Text(
                  'Selected Size: $_selectedSize',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                // Dropdown for sizes
                DropdownButton<String>(
                  value: _selectedSize,
                  isExpanded: true,
                  items:
                      _availableSizes.map((size) {
                        return DropdownMenuItem<String>(
                          value: size,
                          child: Text(size),
                        );
                      }).toList(),
                  onChanged: (newSize) {
                    setState(() {
                      _selectedSize = newSize!;
                    });
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $_selectedSize size to cart!'),
                        ),
                      );
                    },
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
