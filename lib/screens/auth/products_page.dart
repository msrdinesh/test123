import 'package:flutter/material.dart';
import 'package:feednext/sidebar.dart';

class ProductsPage extends StatefulWidget {
  @override
  ProductsPageState createState() => ProductsPageState();
}

class ProductsPageState extends State<ProductsPage> {
  @override
  Widget build(BuildContext context) {
    const title = 'Floating App Bar';

    return MaterialApp(
        title: title,
        home: Scaffold(
            appBar: AppBar(
                title: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(text: "Feed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40)),
                    TextSpan(text: "Next", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 40)),
                  ]),
                ),
                centerTitle: true,
                backgroundColor: Colors.green,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // do something
                    },
                  )
                ]),
            drawer: sideBar()));
  }
}
