import 'package:flutter/material.dart';
import 'package:feednext/pages/login_page.dart';

class sideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Hello, User'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: BoxDecoration(color: Colors.green),
          ),
          ListTile(leading: Icon(Icons.home), title: Text('Home'), onTap: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()))),
          ListTile(leading: Icon(Icons.person), title: Text('Profile'), onTap: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()))),
          ListTile(leading: Icon(Icons.subscriptions), title: Text('Subscriptions'), onTap: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()))),
          ListTile(leading: Icon(Icons.add_shopping_cart), title: Text('Your Orders'), onTap: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()))),
          Divider(),
          ListTile(leading: Icon(Icons.web), title: Text('Delivery Address(es)'), onTap: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()))),
          ListTile(leading: Icon(Icons.question_answer_outlined), title: Text('FAQS'), onTap: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()))),
          Divider(),
          ListTile(title: Text('Sign In'), leading: Icon(Icons.person_add), onTap: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()))),
        ],
      ),
    );
  }

  void _redirectToLogin(context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }
}
