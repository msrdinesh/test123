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
  const Choice({this.title, this.icon, this.onClick});
  final String title;
  final IconData icon;
  final Function onClick;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'English'),
  const Choice(title: 'हिन्दी'),
  const Choice(title: 'தமிழ்'),
  const Choice(title: 'తెలుగు'),
  const Choice(title: 'ಕನ್ನಡ'),
  const Choice(title: 'മലയാളം'),
  const Choice(title: 'मराठी'),
  const Choice(title: 'বাংলা'),
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
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                Text(choice.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ]),
            )));
  }
}
