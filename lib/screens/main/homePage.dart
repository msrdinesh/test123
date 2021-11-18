import 'package:flutter/material.dart';
import 'package:ecommerce_int2/screens/add_contact.dart';
import 'package:ecommerce_int2/screens/view_screen.dart';
import 'package:ecommerce_int2/screens/edit_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  navigatToAddScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddContact();
    }));
  }

  navigatToViewScreen(id) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      //TODO id;
      return ViewContact();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: navigatToAddScreen,
      ),
    );
  }
}
