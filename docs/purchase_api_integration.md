# Purchase API Integration

This document describes how the Flutter app integrates with the Laravel backend for purchase order management.

## Overview

The Flutter app now connects to a Laravel API for all purchase order operations. The integration includes:

1. **Authentication** - Sanctum token-based authentication
2. **Purchase Orders** - CRUD operations for purchase orders
3. **Suppliers** - Fetch and search suppliers
4. **Warehouses** - Warehouse management
5. **Stock Receiving** - Process received stock
6. **Status Management** - Update purchase order status

## API Endpoints

### Authentication
- `POST /login` - User login
- `POST /logout` - User logout
- `GET /me` - Get current user info

### Purchase Orders
- `GET /purchase-orders` - List purchase orders
- `POST /purchase-orders` - Create purchase order
- `GET /purchase-orders/{id}` - Get purchase order details
- `PUT /purchase-orders/{id}` - Update purchase order
- `DELETE /purchase-orders/{id}` - Delete purchase order
- `POST /purchase-orders/{id}/receive` - Receive stock
- `PATCH /purchase-orders/{id}/status` - Update status
- `GET /my-purchase-orders` - Get user's purchase orders

### Suppliers
- `GET /suppliers` - List suppliers
- `GET /suppliers?search={query}` - Search suppliers

### Warehouses
- `GET /warehouses` - List warehouses

## Authentication Flow

1. User logs in via `AuthController.login`
2. Sanctum token is stored in `Session.token`
3. All subsequent requests include `Authorization: Bearer {token}` header
4. Token is automatically added to all API calls

## Usage Examples

### Creating a Purchase Order

```dart
final purchaseService = PurchaseService();

// Create purchase order
final purchaseOrder = await purchaseService.createPurchaseOrder(
  supplierId: 1,
  warehouseId: 1,
  items: [
    {
      'product_id': 1,
      'quantity': 10,
      'unit_price': 25.00,
      'discount': 0,
    },
    {
      'product_id': 2,
      'quantity': 5,
      'unit_price': 15.00,
      'discount': 0,
    },
  ],
  taxRate: 10,
  shippingCost: 5.00,
  notes: 'Monthly inventory restock',
);
```

### Fetching Purchase Orders

```dart
// Fetch all purchase orders
final orders = await purchaseService.fetchPurchaseOrders();

// Filter by status
final pendingOrders = await purchaseService.fetchPurchaseOrders(status: 'pending');

// Search
final searchResults = await purchaseService.fetchPurchaseOrders(
  searchQuery: 'ABC Supplies',
);
```

### Receiving Stock

```dart
// Receive stock
final receivedOrder = await purchaseService.receiveStock(
  orderId: 1,
  receivedItems: [
    {
      'item_id': 1,
      'quantity': 10,
      'received_date': DateTime.now().toIso8601String(),
    },
    {
      'item_id': 2,
      'quantity': 5,
      'received_date': DateTime.now().toIso8601String(),
    },
  ],
);
```

### Updating Status

```dart
// Update status
final updatedOrder = await purchaseService.updatePurchaseStatus(
  orderId: 1,
  status: 'ordered',
);
```

## Permissions

The API checks the following permissions:

- `manage-inventory` - Required for all purchase order operations
- `view-analytics` - Required for viewing analytics
- `checkout` - Required for checkout operations

## Response Format

Laravel API responses follow this format:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

## Error Handling

The API service handles common errors:

- Connection timeouts
- Authentication errors
- Permission denied
- Validation errors
- Server errors

## Data Models

### PurchaseOrder
- `id` - Purchase order ID
- `po_number` - Purchase order number
- `reference_number` - Reference number
- `status` - Current status (draft, pending, ordered, received)
- `supplier_id` - Supplier ID
- `supplier_name` - Supplier name
- `warehouse_id` - Warehouse ID
- `warehouse_name` - Warehouse name
- `notes` - Additional notes
- `tax_rate` - Tax rate percentage
- `shipping_cost` - Shipping cost
- `subtotal` - Subtotal amount
- `tax_amount` - Tax amount
- `total` - Total amount
- `created_at` - Creation timestamp
- `updated_at` - Update timestamp
- `items` - List of purchase order items

### PurchaseOrderItem
- `id` - Item ID
- `product_id` - Product ID
- `product` - Product details
- `quantity` - Quantity ordered
- `unit_price` - Unit price
- `tax_rate` - Tax rate
- `discount` - Discount amount
- `total_price` - Total price
- `received_quantity` - Quantity received

### Supplier
- `id` - Supplier ID
- `name` - Supplier name
- `contact_person` - Contact person
- `phone` - Phone number
- `email` - Email address
- `address` - Address
- `tax_id` - Tax ID

### Warehouse
- `id` - Warehouse ID
- `name` - Warehouse name
- `code` - Warehouse code
- `address` - Address
- `phone` - Phone number
- `is_active` - Active status

## Configuration

Update the `ApiConfig` class in `lib/core/config/api_config.dart` with your Laravel API base URL:

```dart
static const String baseUrl = 'https://your-laravel-api-url.com/api';
```

## Testing

When testing, you can use the mock data in `PurchaseService` as a fallback if the API is unavailable. The service will automatically use mock data when API calls fail.

## Migration Guide

To migrate from mock data to real API:

1. Update `ApiConfig.baseUrl` with your Laravel API URL
2. Ensure the Laravel API is accessible from the Flutter app
3. Update any hardcoded values (like warehouse IDs) to use dynamic values from the API
4. Remove or modify mock data methods that are no longer needed
5. Update UI to handle loading states and errors from API calls