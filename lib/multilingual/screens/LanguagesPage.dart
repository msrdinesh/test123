import 'package:flutter/material.dart';
import 'package:cornext_mobile/multilingual/localization/language/languages.dart';
import 'package:cornext_mobile/multilingual/localization/locale_constant.dart';
import 'package:cornext_mobile/multilingual/model/language_data.dart';

class LanguagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Choose a language",
        home: Scaffold(
            body: Column(children: <Widget>[
          Text("Choose a language"),
          new Flexible(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: GridView.count(
                      childAspectRatio: (2 / 1),
                      crossAxisCount: 2,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 8.0,
                      children: List.generate(choices.length, (index) {
                        return InkWell(
                            onTap: choices[index].onClick,
                            child: Center(
                              child: SelectCard(choice: choices[index]),
                            ));
                      }))))
        ])));
  }
}

void func1(context) {
  // changeLanguage(context, "en");
}

void func2() {}
void func3() {}
void func4() {}
void func5() {}
void func6() {}
void func7() {}
void func8() {}

class Choice {
  const Choice({this.title, this.icon, this.onClick});
  final String title;
  final IconData icon;
  final Function onClick;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Home', icon: Icons.home, onClick: func1),
  const Choice(title: 'Contact', icon: Icons.contacts, onClick: func2),
  const Choice(title: 'Map', icon: Icons.map, onClick: func3),
  const Choice(title: 'Phone', icon: Icons.phone, onClick: func4),
  const Choice(title: 'Camera', icon: Icons.camera_alt, onClick: func5),
  const Choice(title: 'Setting', icon: Icons.settings, onClick: func6),
  const Choice(title: 'Album', icon: Icons.photo_album, onClick: func7),
  const Choice(title: 'WiFi', icon: Icons.wifi, onClick: func8),
];

class SelectCard extends StatelessWidget {
  const SelectCard({Key key, this.choice}) : super(key: key);
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 100,
        child: Card(
            color: Colors.orange,
            child: Center(
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                Expanded(child: Icon(choice.icon, size: 50)),
                Text(choice.title),
              ]),
            )));
  }
}
