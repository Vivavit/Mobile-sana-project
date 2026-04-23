class Config {
  // static const String server = 'http://192.168.100.9:8000';
  // static const String server = 'http://172.17.2.174:8000';
  // static const String server = 'http://192.168.100.122:8000';
  static const String server = 'http://10.0.2.2:8000'; // Android emulator host
  // static const String server = 'http://127.0.0.1:8000';
  // static const String server = 'https://inventory-api-pm4i.onrender.com';
  static const String apiBaseUrl = '$server/api';

  static String getProductImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    if (imagePath.isEmpty) {
      // Return a default placeholder with product initials would be generated
      return 'https://via.placeholder.com/300x200/E9FFFA/03624C?text=No+Image';
    }
    return '$server/storage/products/$imagePath';
  }
}
