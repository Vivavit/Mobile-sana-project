import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/product_list_widget.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/search_widget.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String selectedFilter = "All";
  bool showCheckoutBar = false; // ✅ Correct variable name
  int totalItems = 0;

  final List<String> filters = ["All", "Out Of Stock", "In Stock", "Low Stock"];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 5),
              const SearchWidget(),

              // Filter chips
              SizedBox(
                height: 50,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: filters.map((filter) {
                    final bool isSelected = selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(filter),
                        showCheckmark: false,
                        selected: isSelected,
                        onSelected: (value) {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.secondary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        side: BorderSide(color: AppColors.primary),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ✅ Product list
              ProductListWidget(
                onItemAdded: (count) {
                  setState(() {
                    totalItems = count;
                    showCheckoutBar = count > 0;
                  });
                },
              ),
            ],
          ),
        ),

        // ✅ Checkout bar
        if (showCheckoutBar)
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$totalItems item${totalItems > 1 ? 's' : ''} in cart",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () {
                      // TODO: Go to checkout page
                    },
                    child: const Text("Checkout"),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
