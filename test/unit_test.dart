import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sale Price Calculation', () {
    test('Sale price calculation with valid purchase price', () {
      // Define initial purchase price and expected sale price
      double purchasePrice = 100.0;
      double expectedSalePrice = 140.0; // 40% increase from purchase price

      // Call the calculateSalePrice method
      double calculatedSalePrice = _calculateSalePrice(purchasePrice);

      // Expect the calculated sale price to match the expected value
      expect(calculatedSalePrice, equals(expectedSalePrice));
    });

    test('Sale price calculation with negative purchase price', () {
      // Define initial purchase price and expected sale price
      double purchasePrice = -50.0;
      double expectedSalePrice = 0.0; // Sale price should not be negative

      // Call the calculateSalePrice method
      double calculatedSalePrice = _calculateSalePrice(purchasePrice);

      // Expect the calculated sale price to match the expected value
      expect(calculatedSalePrice, equals(expectedSalePrice));
    });
  });
}

// Helper function to calculate sale price (updated to handle negative purchase prices)
double _calculateSalePrice(double purchasePrice) {
  if (purchasePrice < 0) {
    // If purchase price is negative, return 0 as sale price
    return 0.0;
  } else {
    // Applying a 40% increase to the purchase price
    return purchasePrice + (0.4 * purchasePrice);
  }
}
