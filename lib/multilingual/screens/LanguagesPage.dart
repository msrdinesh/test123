import 'package:flutter/material.dart';
import 'package:cornext_mobile/multilingual/localization/language/languages.dart';
import 'package:cornext_mobile/multilingual/localization/locale_constant.dart';
import 'package:cornext_mobile/multilingual/model/language_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                  child: GridView.count(childAspectRatio: (2 / 1), crossAxisCount: 2, crossAxisSpacing: 4.0, mainAxisSpacing: 8.0, children: [
                    InkWell(
                        onTap: () => {
                              changeLanguage(context, "en"),
                              print("pressed"),
                              func()
                            },
                        child: Center(
                          child: SelectCard(choice: choices[0]),
                        )),
                    InkWell(
                        onTap: () => {
                              changeLanguage(context, "en"),
                              print("pressed"),
                              func()
                            },
                        child: Center(
                          child: SelectCard(choice: choices[1]),
                        )),
                    InkWell(
                        onTap: () => {
                              changeLanguage(context, "en"),
                              print("pressed"),
                              func()
                            },
                        child: Center(
                          child: SelectCard(choice: choices[2]),
                        )),
                    InkWell(
                        onTap: () => {
                              changeLanguage(context, "en"),
                              print("pressed"),
                              func()
                            },
                        child: Center(
                          child: SelectCard(choice: choices[3]),
                        )),
                    InkWell(
                        onTap: () => {
                              changeLanguage(context, "en"),
                              print("pressed"),
                              func()
                            },
                        child: Center(
                          child: SelectCard(choice: choices[4]),
                        )),
                    InkWell(
                        onTap: () => {
                              changeLanguage(context, "en"),
                              print("pressed"),
                              func()
                            },
                        child: Center(
                          child: SelectCard(choice: choices[5]),
                        )),
                    InkWell(
                        onTap: () => {
                              changeLanguage(context, "en"),
                              print("pressed"),
                              func()
                            },
                        child: Center(
                          child: SelectCard(choice: choices[6]),
                        )),
                    InkWell(
                        onTap: () => {
                              changeLanguage(context, "en"),
                              print("pressed"),
                              func()
                            },
                        child: Center(
                          child: SelectCard(choice: choices[7]),
                        ))
                  ])))
        ])));
  }
}

void func() async {
  var prefManager = await SharedPreferences.getInstance();
  String language = prefManager.getString("SelectedLanguageCode");
  print(language);
}

void func1() {
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
  const Choice({this.title, this.icon, this.onClick, this.color});
  final String title;
  final IconData icon;
  final Function onClick;
  final Color color;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'English', color: Color(0xffADD8E6)),
  const Choice(title: 'हिन्दी', color: Color(0xffffb6c1)),
  const Choice(
      title: 'தமிழ்',
      color: Color(
        0xffffd580,
      )),
  const Choice(title: 'తెలుగు', color: Color(0xffffb6c1)),
  const Choice(title: 'ಕನ್ನಡ', color: Color(0xffffb6c1)),
  const Choice(title: 'മലയാളം', color: Color(0xffffb6c1)),
  const Choice(title: 'मराठी', color: Color(0xffffb6c1)),
  const Choice(title: 'বাংলা', color: Color(0xffffb6c1)),
];

class SelectCard extends StatelessWidget {
  const SelectCard({Key key, this.choice}) : super(key: key);
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 100,
        child: Card(
            color: choice.color,
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                Text(choice.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ]),
            )));
  }
}
