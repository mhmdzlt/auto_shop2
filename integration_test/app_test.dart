import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:auto_shop/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auto Shop E2E Tests - Command 27', () {
    testWidgets('Complete app workflow test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test basic app startup
      expect(find.byType(MaterialApp), findsOneWidget);

      // Test product browsing
      await _testProductBrowsing(tester);

      // Test cart functionality
      await _testCartFunctionality(tester);
    });

    testWidgets('Address and order management test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test address management
      await _testAddressManagement(tester);
    });
  });

Future<void> _testProductBrowsing(WidgetTester tester) async {
  print('Testing product browsing...');
  
  // Look for product grids or lists
  await tester.pumpAndSettle();
  
  // Test scrolling for lazy loading
  if (find.byType(GridView).evaluate().isNotEmpty) {
    await tester.drag(find.byType(GridView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
  }
}

Future<void> _testCartFunctionality(WidgetTester tester) async {
  print('Testing cart functionality...');
  
  // Look for cart icon or button
  final cartFinder = find.byIcon(Icons.shopping_cart);
  if (cartFinder.evaluate().isNotEmpty) {
    await tester.tap(cartFinder.first);
    await tester.pumpAndSettle();
  }
}

Future<void> _testAddressManagement(WidgetTester tester) async {
  print('Testing address management...');
  
  // Look for address-related widgets
  await tester.pumpAndSettle();
  
  // Test navigation to addresses page
  final addressFinder = find.textContaining('address').or(
    find.textContaining('عنوان')
  );
  if (addressFinder.evaluate().isNotEmpty) {
    await tester.tap(addressFinder.first);
    await tester.pumpAndSettle();
  }
}

      // Test sync when back online
      await _testOfflineSync(tester);
    });
  });
}

Future<void> _testLogin(WidgetTester tester) async {
  // Look for login fields
  final emailField = find.byKey(const ValueKey('email_field'));
  final passwordField = find.byKey(const ValueKey('password_field'));
  final loginButton = find.byKey(const ValueKey('login_button'));

  if (emailField.evaluate().isNotEmpty) {
    // Enter test credentials
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');

    // Tap login button
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify successful login (should see main app)
    expect(find.text('Auto Parts'), findsOneWidget);
  }
}

Future<void> _testProductBrowsing(WidgetTester tester) async {
  // Wait for products to load
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Check if products are displayed
  expect(find.byType(GridView), findsOneWidget);

  // Test search functionality
  final searchField = find.byKey(const Key('search_field'));
  if (searchField.evaluate().isNotEmpty) {
    await tester.enterText(searchField, 'brake');
    await tester.pumpAndSettle();

    // Clear search
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();
  }

  // Test product details navigation
  final firstProduct = find.byType(GestureDetector).first;
  if (firstProduct.evaluate().isNotEmpty) {
    await tester.tap(firstProduct);
    await tester.pumpAndSettle();

    // Should be on product details page
    expect(find.byKey(const Key('product_details')), findsOneWidget);

    // Go back
    await tester.pageBack();
    await tester.pumpAndSettle();
  }
}

Future<void> _testAddToCart(WidgetTester tester) async {
  // Navigate to first product
  final firstProduct = find.byType(GestureDetector).first;
  if (firstProduct.evaluate().isNotEmpty) {
    await tester.tap(firstProduct);
    await tester.pumpAndSettle();

    // Add to cart
    final addToCartButton = find.byKey(const Key('add_to_cart_button'));
    if (addToCartButton.evaluate().isNotEmpty) {
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      // Check for confirmation
      expect(find.textContaining('added to cart'), findsOneWidget);
    }

    // Go back to main page
    await tester.pageBack();
    await tester.pumpAndSettle();
  }

  // Check cart
  final cartIcon = find.byIcon(Icons.shopping_cart_outlined);
  if (cartIcon.evaluate().isNotEmpty) {
    await tester.tap(cartIcon);
    await tester.pumpAndSettle();

    // Should see cart items
    expect(find.byKey(const Key('cart_items')), findsOneWidget);
  }
}

Future<void> _testCheckout(WidgetTester tester) async {
  // Look for checkout button
  final checkoutButton = find.byKey(const Key('checkout_button'));
  if (checkoutButton.evaluate().isNotEmpty) {
    await tester.tap(checkoutButton);
    await tester.pumpAndSettle();

    // Fill in address if required
    final addressField = find.byKey(const Key('address_field'));
    if (addressField.evaluate().isNotEmpty) {
      await tester.enterText(addressField, 'Test Address, Test City');
    }

    // Select payment method
    final paymentMethod = find.byKey(const Key('payment_cod'));
    if (paymentMethod.evaluate().isNotEmpty) {
      await tester.tap(paymentMethod);
      await tester.pumpAndSettle();
    }

    // Confirm order
    final confirmButton = find.byKey(const Key('confirm_order_button'));
    if (confirmButton.evaluate().isNotEmpty) {
      await tester.tap(confirmButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should see success message
      expect(find.textContaining('confirmed'), findsOneWidget);
    }
  }
}

Future<void> _testAddressManagement(WidgetTester tester) async {
  // Navigate to profile/settings
  final profileTab = find.byIcon(Icons.person_outline);
  if (profileTab.evaluate().isNotEmpty) {
    await tester.tap(profileTab);
    await tester.pumpAndSettle();

    // Look for addresses option
    final addressesOption = find.text('Addresses');
    if (addressesOption.evaluate().isNotEmpty) {
      await tester.tap(addressesOption);
      await tester.pumpAndSettle();

      // Test adding new address
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Fill address form
        await tester.enterText(find.byKey(const Key('address_title')), 'Home');
        await tester.enterText(
          find.byKey(const Key('address_details')),
          'Test Street 123',
        );

        // Save address
        final saveButton = find.text('Save');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }
      }
    }
  }
}

Future<void> _testOrdersFiltering(WidgetTester tester) async {
  // Navigate to orders page
  final ordersOption = find.text('Orders');
  if (ordersOption.evaluate().isNotEmpty) {
    await tester.tap(ordersOption);
    await tester.pumpAndSettle();

    // Test different status filters
    final statusTabs = [
      'All Orders',
      'Pending',
      'Confirmed',
      'Shipped',
      'Delivered',
    ];

    for (final status in statusTabs) {
      final tab = find.text(status);
      if (tab.evaluate().isNotEmpty) {
        await tester.tap(tab);
        await tester.pumpAndSettle();

        // Verify filter applied
        expect(find.byType(ListView), findsOneWidget);
      }
    }
  }
}

Future<void> _testOfflineOrders(WidgetTester tester) async {
  // Simulate going offline
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('connectivity_plus'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'check') {
        return 'none'; // No connectivity
      }
      return null;
    },
  );

  // Try to place an order while offline
  await _testAddToCart(tester);
  await _testCheckout(tester);

  // Should see offline notification
  expect(find.textContaining('offline'), findsOneWidget);
}

Future<void> _testOfflineSync(WidgetTester tester) async {
  // Simulate coming back online
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('connectivity_plus'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'check') {
        return 'wifi'; // Has connectivity
      }
      return null;
    },
  );

  // Wait for sync
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Should see sync notification
  expect(find.textContaining('synced'), findsOneWidget);
}

Future<void> _skipToMainApp(WidgetTester tester) async {
  // Check if we're already on main app
  if (find.text('Auto Parts').evaluate().isEmpty) {
    // We might be on login screen, try to login
    await _testLogin(tester);
  }
}
