import 'package:assignment_hml/testing/Calculator.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('Calculator Integration Tests', () {
    test('Adding two numbers', () {
      // Arrange
      Calculator calculator = Calculator();

      // Act
      int result = calculator.add(2, 3);

      // Assert
      expect(result, equals(5)); // Expectation 1
      expect(result, isNot(equals(4))); // Expectation 2
      expect(result, greaterThan(4)); // Expectation 3
      expect(result, lessThan(10)); // Expectation 4
    });
  });
}
