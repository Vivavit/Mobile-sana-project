import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';

class ProductListWidget extends StatefulWidget {
  final Function(int)? onItemAdded;
  final String selectedFilter; // ✅ add filter prop

  const ProductListWidget({
    super.key,
    this.onItemAdded,
    required this.selectedFilter,
  });

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  late List<Map<String, dynamic>> products;

  @override
  void initState() {
    super.initState();
    products = [
      {
        "name": "Pizza",
        "description": "Pizza is an Italian dish",
        "price": 2.00,
        "stock": 20,
        "quantity": 0,
        "image":
            "https://imgs.search.brave.com/u92tAzgfpjTYxak7lNIGSshyOIlH-25Y4l2AgWfyDt8/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tYXJr/ZXRwbGFjZS5jYW52/YS5jb20vTUFER3Z1/V09zeUkvNy90aHVt/Ym5haWxfbGFyZ2Uv/Y2FudmEtcGVyc29u/LWhvbGRpbmctcGVw/cGVyb25pLXBpenph/LW9uLXRyYXktTUFE/R3Z1V09zeUkuanBn",
      },
      {
        "name": "Burger",
        "description": "Beef burger with cheese",
        "price": 1.50,
        "stock": 0,
        "quantity": 0,
        "image":
            "https://imgs.search.brave.com/3TU_P22C-IRDdsmvT022M77jl0iV2CiVcMn4Tlz-5eY/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9yZXMu/Y2xvdWRpbmFyeS5j/b20vdGhlLWluZmF0/dWF0aW9uL2ltYWdl/L3VwbG9hZC9jX2Zp/bGwsd18zODQwLGFy/XzQ6MyxnX2NlbnRl/cixmX2F1dG8vaW1h/Z2VzL0dob3N0YnVy/Z2VyX05pbmFfUGFs/YXp6b2xvX0RDLTEz/X25jeDVtaw",
      },
      {
        "name": "Fries",
        "description": "Crispy French fries",
        "price": 1.00,
        "stock": 3,
        "quantity": 0,
        "image":
            "https://imgs.search.brave.com/ta6LmO6aqPBSIuCkuxb1GzNDyU3Vmdc3Q8LMOBXzsD4/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMDcv/NjcwLzgzNC9zbWFs/bC9mcmVuY2gtZnJp/ZXMtd2l0aC1zb3Vy/LWNyZWFtLWFuZC1r/ZXRjaHVwLXBob3Rv/LmpwZw",
      },
      {
        "name": "Spaghetti",
        "description": "Pasta with tomato sauce",
        "price": 2.50,
        "stock": 10,
        "quantity": 0,
        "image":
            "https://imgs.search.brave.com/afpCeDD0wWxrQfPvCM1PaBaymVMDogvxb-msn0IVxoc/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9tZWRp/YS5nZXR0eWltYWdl/cy5jb20vaWQvMTY1/NTk5NDY4L3Bob3Rv/L3BsYXRlLW9mLXNw/YWdoZXR0aS5qcGc_/cz02MTJ4NjEyJnc9/MCZrPTIwJmM9aWRS/RzRqODV0SWV3ZzZG/YUtFMFR4Q2ppSERK/eHNXZ3FlU3Y4N0J5/UGRPbz0",
      },
    ];
  }

  void updateCart() {
    int totalItems = products.fold(0, (sum, item) => item['quantity'] + sum);
    widget.onItemAdded?.call(totalItems);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Apply filter logic
    List<Map<String, dynamic>> filteredProducts = products.where((product) {
      switch (widget.selectedFilter) {
        case "Out Of Stock":
          return product["stock"] == 0;
        case "In Stock":
          return product["stock"] > 5;
        case "Low Stock":
          return product["stock"] > 0 && product["stock"] <= 5;
        default:
          return true;
      }
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product['image'],
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // ✅ Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product['description'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${product['stock']} in stock",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),

              // ✅ Price + Add/Counter
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "\$ ${product['price'].toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildAddOrCounter(product),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOrCounter(Map<String, dynamic> product) {
    if (product['quantity'] == 0) {
      return GestureDetector(
        onTap: () {
          setState(() {
            product['quantity'] = 1;
          });
          updateCart();
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: const Text(
            'Add',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (product['quantity'] > 0) {
                  product['quantity']--;
                }
              });
              updateCart();
            },
            child: Icon(Icons.remove, color: AppColors.primary, size: 20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              product['quantity'].toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (product['quantity'] < product['stock']) {
                  product['quantity']++;
                }
              });
              updateCart();
            },
            child: Icon(Icons.add, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }
}
