import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'log.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    // Add your desired page widgets for each tab
    Text('Home'),
    Text('Settings'),
    Profile(),
  ];

  List<String> cartItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      drawer: SafeArea(
        child: Drawer(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {},
                ),
                SizedBox(height: 16.0),
                Column(
                  children: [
                    ListTile(
                      title: Text("Home"),
                      leading: Icon(Icons.home),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Home(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: Text("My products"),
                      leading: Icon(Icons.add_shopping_cart),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartPage(cartItems: cartItems),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: Text("About"),
                      leading: Icon(Icons.help_center),
                      onTap: () {},
                    ),
                    ListTile(
                      title: Text("Logout"),
                      leading: Icon(Icons.exit_to_app),
                      onTap: () async {
                        Navigator.pop(context);
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found'));
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                child: Column(
                  children: [
                    Image.network(
                      product['imageUrl'], // Assuming the field name is 'imageUrl' in your Firestore document
                      height: 100.0,
                      width: 100.0,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return CircularProgressIndicator();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error);
                      },
                    ),
                    Text(product['name']), // Assuming the field name is 'name' in your Firestore document
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          cartItems.add(product['name']);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added to cart: ${product['name']}')),
                        );
                      },
                      child: Text('Add to Cart'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 2) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Profile'),
            content: Profile(),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }
}

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Talel Zairi',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Omer Ali',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot product;

  const ProductDetailsPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']), // Assuming the field name is 'name' in your Firestore document
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Product Details'),
            SizedBox(height: 16.0),
            Text('Name: ${product['name']}'), // Assuming the field name is 'name' in your Firestore document
            SizedBox(height: 16.0),
            Image.network(
              product['imageUrl'], // Assuming the field name is 'imageUrl' in your Firestore document
              height: 200.0,
              width: 200.0,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return CircularProgressIndicator();
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<String> cartItems;

  const CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isOrdered = false;

  void _handleBuyButton() {
    setState(() {
      isOrdered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: widget.cartItems.isEmpty
                ? Center(child: Text('Your cart is empty.'))
                : ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return ListTile(
                        title: Text(item),
                      );
                    },
                  ),
          ),
          ElevatedButton(
            onPressed: isOrdered ? null : _handleBuyButton,
            child: Text('Buy'),
          ),
          if (isOrdered)
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.green,
              child: Text(
                'Order placed successfully!',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
