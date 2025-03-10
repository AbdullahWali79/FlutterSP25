// import 'package:flutter/material.dart';
// // 1) Simple Model Class for Snacks
// class SnackItem {
//   final String name;
//   final double price;
//
//   SnackItem({required this.name, required this.price});
// }
// // 2) Our mock list of snacks (for the Snack List Screen)
// final List<SnackItem> allSnacks = [
//   SnackItem(name: 'Chocolate Bar', price: 1.50),
//   SnackItem(name: 'Potato Chips', price: 2.00),
//   SnackItem(name: 'Gummy Bears', price: 1.25),
//   SnackItem(name: 'Pretzels', price: 1.75),
// ];
// // 3) A global cart to keep it simple (just a list of SnackItem)
// List<SnackItem> cart = [];
// void main() {
//   runApp(MyApp());
// }
// // Main App
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Order My Snacks',
//       theme: ThemeData(
//         primarySwatch: Colors.orange, // Basic styling & theme color
//         // Optionally add a custom font if you like, e.g.:
//         // fontFamily: 'MyCustomFont',
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => HomeScreen(),
//         '/snacks': (context) => SnackListScreen(),
//         '/cart': (context) => CartScreen(),
//         '/checkout': (context) => CheckoutScreen(),
//         '/confirmation': (context) => ConfirmationScreen(),
//       },
//     );
//   }
// }
// //-----------------------------------
// //  HOME SCREEN
// //-----------------------------------
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Order My Snacks')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // A GestureDetector on an image (optional)
//             GestureDetector(
//               onTap: () {
//                 // Example action when tapping the image
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('You tapped the image!')),
//                 );
//               },
//               child: Container(
//                 margin: EdgeInsets.all(16.0),
//                 width: 150,
//                 height: 150,
//                 color: Colors.orange.withOpacity(0.3),
//                 child: Icon(Icons.fastfood, size: 64),
//               ),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               child: Text('Start Ordering'),
//               onPressed: () {
//                 Navigator.pushNamed(context, '/snacks');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// //-----------------------------------
// //  SNACK LIST SCREEN
// //-----------------------------------
// class SnackListScreen extends StatefulWidget {
//   @override
//   _SnackListScreenState createState() => _SnackListScreenState();
// }
// class _SnackListScreenState extends State<SnackListScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Choose Your Snacks'),
//         actions: [
//           // Cart button on top-right
//           IconButton(
//             icon: Icon(Icons.shopping_cart),
//             onPressed: () {
//               Navigator.pushNamed(context, '/cart');
//             },
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: allSnacks.length,
//         itemBuilder: (context, index) {
//           final snack = allSnacks[index];
//           return Card(
//             margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             child: ListTile(
//               title: Text(snack.name),
//               subtitle: Text('\$${snack.price.toStringAsFixed(2)}'),
//               trailing: ElevatedButton(
//                 child: Text('Add'),
//                 onPressed: () {
//                   setState(() {
//                     cart.add(snack);
//                   });
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('${snack.name} added to cart')),
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// //-----------------------------------
// //  CART SCREEN
// //-----------------------------------
// class CartScreen extends StatefulWidget {
//   @override
//   _CartScreenState createState() => _CartScreenState();
// }
// class _CartScreenState extends State<CartScreen> {
//   double get totalPrice {
//     double total = 0;
//     for (var item in cart) {
//       total += item.price;
//     }
//     return total;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Your Cart')),
//       body: cart.isEmpty
//           ? Center(child: Text('Your cart is empty.'))
//           : Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: cart.length,
//               itemBuilder: (context, index) {
//                 final snack = cart[index];
//                 return ListTile(
//                   title: Text(snack.name),
//                   subtitle:
//                   Text('\$${snack.price.toStringAsFixed(2)}'),
//                 );
//               },
//             ),
//           ),
//           Divider(),
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Text(
//               'Total: \$${totalPrice.toStringAsFixed(2)}',
//               style: TextStyle(fontSize: 18),
//             ),
//           ),
//           ElevatedButton(
//             child: Text('Proceed to Checkout'),
//             onPressed: () {
//               Navigator.pushNamed(context, '/checkout');
//             },
//           ),
//           SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
// }
// //-----------------------------------
// //  CHECKOUT SCREEN
// //-----------------------------------
// class CheckoutScreen extends StatefulWidget {
//   @override
//   _CheckoutScreenState createState() => _CheckoutScreenState();
// }
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _name = '';
//   String _address = '';
//   String _phone = '';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Checkout')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey, // For validation
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'Full Name'),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Name is required';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) => _name = value!.trim(),
//                 ),
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'Address'),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Address is required';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) => _address = value!.trim(),
//                 ),
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'Phone Number'),
//                   keyboardType: TextInputType.phone,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Phone number is required';
//                     }
//                     if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
//                       return 'Enter only numbers';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) => _phone = value!.trim(),
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   child: Text('Continue'),
//                   onPressed: () {
//                     // Validate form fields
//                     if (_formKey.currentState!.validate()) {
//                       _formKey.currentState!.save();
//                       // Pass user info to Confirmation screen
//                       Navigator.pushNamed(
//                         context,
//                         '/confirmation',
//                         arguments: {
//                           'name': _name,
//                           'address': _address,
//                           'phone': _phone,
//                         },
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// //-----------------------------------
// //  CONFIRMATION SCREEN
// //-----------------------------------
// class ConfirmationScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Retrieve arguments (user info) passed from Checkout Screen
//     final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
//     final name = args['name'] ?? '';
//     final address = args['address'] ?? '';
//     final phone = args['phone'] ?? '';
//
//     // Calculate total price again
//     double total = 0;
//     for (var item in cart) {
//       total += item.price;
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Confirm Your Order')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               'Name: $name',
//               style: TextStyle(fontSize: 16),
//             ),
//             Text(
//               'Address: $address',
//               style: TextStyle(fontSize: 16),
//             ),
//             Text(
//               'Phone: $phone',
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: cart.length,
//                 itemBuilder: (context, index) {
//                   final snack = cart[index];
//                   return ListTile(
//                     title: Text(snack.name),
//                     subtitle: Text('\$${snack.price.toStringAsFixed(2)}'),
//                   );
//                 },
//               ),
//             ),
//             Text(
//               'Total: \$${total.toStringAsFixed(2)}',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               child: Text('Place Order'),
//               onPressed: () {
//                 // Clear the cart
//                 cart.clear();
//                 // Show a simple success message
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: Text('Order Placed!'),
//                     content: Text('Thank you, $name. Your snacks are on the way!'),
//                     actions: [
//                       TextButton(
//                         child: Text('OK'),
//                         onPressed: () {
//                           Navigator.pop(context); // close dialog
//                           Navigator.popUntil(context, ModalRoute.withName('/'));
//                         },
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }