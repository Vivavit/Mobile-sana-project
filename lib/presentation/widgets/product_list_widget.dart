import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';

class ProductListWidget extends StatefulWidget {
  final Function(int)? onItemAdded; // ✅ Proper declaration

  const ProductListWidget({
    super.key,
    this.onItemAdded,
  }); // ✅ Correct constructor

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  final List<Map<String, dynamic>> products = List.generate(4, (index) {
    return {
      "name": "Pizza",
      "description": "Pizza is an Italian dish",
      "price": 2.00,
      "stock": 20,
      "quantity": 0,
      "image":
          "https://imgs.search.brave.com/u92tAzgfpjTYxak7lNIGSshyOIlH-25Y4l2AgWfyDt8/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tYXJr/ZXRwbGFjZS5jYW52/YS5jb20vTUFER3Z1/V09zeUkvNy90aHVt/Ym5haWxfbGFyZ2Uv/Y2FudmEtcGVyc29u/LWhvbGRpbmctcGVw/cGVyb25pLXBpenph/LW9uLXRyYXktTUFE/R3Z1V09zeUkuanBn",
    };
  });

  void updateCart() {
    int totalItems = products.fold(0, (sum, item) => item['quantity'] + sum);
    widget.onItemAdded?.call(totalItems);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
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

                  product['quantity'] == 0
                      ? GestureDetector(
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(
                              alpha: 0.1,
                            ), // ✅ Updated from deprecated .withOpacity()
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
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
                                child: Icon(
                                  Icons.remove,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  product['quantity'].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (product['quantity'] <
                                        product['stock']) {
                                      product['quantity']++;
                                    }
                                  });
                                  updateCart();
                                },
                                child: Icon(
                                  Icons.add,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
