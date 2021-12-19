// import 'package:cornext_mobile/constants/appcolors.dart';
import 'dart:io';

import 'package:cornext_mobile/constants/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:cornext_mobile/screens/signin/signin.dart';
import 'package:cornext_mobile/routes/routes.dart';
import 'package:cornext_mobile/screens/home/homescreen.dart';
import 'package:uni_links/uni_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cornext_mobile/services/sharedprefrencesservice/sharedpreferenceservice.dart';
import 'package:cornext_mobile/models/signinmodel.dart';
import 'package:cornext_mobile/services/ordersummaryservice/ordersummaryservice.dart';
// import 'package:cornext_mobile/screens/ordersummary/ordersummary.dart';
import 'package:cornext_mobile/services/homescreenservices/homescreenservices.dart';
// import 'package:cornext_mobile/services/refreshtokenservice/refreshtokenservice.dart';
// import 'package:cornext_mobile/utils/apierrors/apierror.dart';
import 'package:cornext_mobile/components/widgets/appbarwidget.dart';
import 'package:cornext_mobile/screens/cart/cartscreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cornext_mobile/multilingual/localization/locale_constant.dart';
import 'package:cornext_mobile/multilingual/screens/LanguagesPage.dart';
import 'package:cornext_mobile/multilingual/localization/localizations_delegate.dart';
import 'dart:convert';
// import 'package:connectivity/connectivity.dart';
// import 'package:cornext_mobile/screens/farmdetails/farmdetails.dart';
// import 'package:cornext_mobile/screens/feedbackform/feedbackform.dart';

Future<void> main() async {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

/// Class to help in network handshake for https APIs
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  // getLinks() async {
  //   data = await getInitialLink();
  //   return '';
  // }
  bool _isSelected = false;
  String language;
  Locale _locale;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    func();
  }

  final HomeScreenServices homeScreenServices = HomeScreenServices();

  fetchCartDetails(context) {
    homeScreenServices.getCartQuantityDetails().then((res) {
      // print(res.body);
      final data = json.decode(res.body);
      if (data != null && data['noOfItemsInCart'] != null) {
        // setState(() {
        noOfProductsAddedInCart = int.parse(data['noOfItemsInCart']);
        // });
      } else if (data['error'] != null && data['error'] == "invalid_token") {
        // RefreshTokenService().getAccessTokenUsingRefreshToken().then((res) {
        //   final refreshTokenData = json.decode(res.body);
        //   // print(data);
        //   if (RefreshTokenService()
        //       .getAccessTokenFromData(refreshTokenData, context, )) {
        //     fetchCartDetails(context);
        //   }
        // });
        SharedPreferenceService().removeUserInfo();
        Navigator.pushNamed(context, '/login');
      }
    }, onError: (err) {
      // ApiErros().apiErrorNotifications(err, context, '/home',);
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  void func() async {
    var prefManager = await SharedPreferences.getInstance();
    await prefManager.clear();
    language = prefManager.getString("SelectedLanguageCode");
  }

  @override
  Widget build(BuildContext context) {
    func();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        supportedLocales: [
          Locale('en', ''),
          Locale('hi', ''),
          Locale('te', ''),
          Locale('ta', ''),
          Locale('ka', ''),
          Locale('mal', ''),
          Locale('mar', ''),
          Locale('be', '')
        ],
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale?.languageCode == locale?.languageCode && supportedLocale?.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales?.first;
        },
        theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.green,
            primaryColor: mainAppColor,
            cursorColor: mainAppColor,
            fontFamily: 'Raleway',
            textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Raleway')
            // appBarTheme: AppBarTheme(elevation: 5),
            // canvasColor: mainAppColor
            // typography: Typography.material2018(),
            // textSelectionHandleColor: Colors.transparent,
            // fontFamily: 'Roboto_Condensed',
            // appBarTheme: AppBarTheme(elevation: 1000)
            // fontFamily: 'Roboto'
            ),
        // initialRoute: '/',
        onGenerateRoute: configureRoutes(),
        builder: (BuildContext context, Widget child) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(
              textScaleFactor: 1.0,
            ),
            child: child,
          );
        },
        title: "Choose a language",
        home: Builder(
            builder: (context) => Scaffold(
                    body: Column(children: <Widget>[
                  Text("Choose a language"),
                  new Flexible(
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: GridView.count(childAspectRatio: (2 / 1), crossAxisCount: 2, crossAxisSpacing: 4.0, mainAxisSpacing: 8.0, children: [
                            InkWell(
                                onTap: () => {
                                      changeLanguage(context, "en"),
                                      AppLocalizationsDelegate(),
                                      setState(() {
                                        _isSelected = true;
                                      })
                                    },
                                child: Center(
                                  child: SelectCard(choice: choices[0]),
                                )),
                            InkWell(
                                onTap: () => {
                                      changeLanguage(context, "hi"),
                                      AppLocalizationsDelegate(),
                                      setState(() {
                                        _isSelected = true;
                                      })
                                    },
                                child: Center(
                                  child: SelectCard(choice: choices[1]),
                                )),
                            InkWell(
                                onTap: () => {
                                      changeLanguage(context, "ta"),
                                      AppLocalizationsDelegate(),
                                      setState(() {
                                        _isSelected = true;
                                      })
                                    },
                                child: Center(
                                  child: SelectCard(choice: choices[2]),
                                )),
                            InkWell(
                                onTap: () => {
                                      changeLanguage(context, "te"),
                                      AppLocalizationsDelegate(),
                                      setState(() {
                                        _isSelected = true;
                                      })
                                    },
                                child: Center(
                                  child: SelectCard(choice: choices[3]),
                                )),
                            InkWell(
                                onTap: () => {
                                      changeLanguage(context, "ka"),
                                      AppLocalizationsDelegate(),
                                      setState(() {
                                        _isSelected = true;
                                      })
                                    },
                                child: Center(
                                  child: SelectCard(choice: choices[4]),
                                )),
                            InkWell(
                                onTap: () => {
                                      changeLanguage(context, "mal"),
                                      AppLocalizationsDelegate(),
                                      setState(() {
                                        _isSelected = true;
                                      })
                                    },
                                child: Center(
                                  child: SelectCard(choice: choices[5]),
                                )),
                            InkWell(
                                onTap: () => {
                                      changeLanguage(context, "mar"),
                                      AppLocalizationsDelegate(),
                                      setState(() {
                                        _isSelected = true;
                                      })
                                    },
                                child: Center(
                                  child: SelectCard(choice: choices[6]),
                                )),
                            InkWell(
                                onTap: () => {
                                      changeLanguage(context, "be"),
                                      AppLocalizationsDelegate(),
                                      setState(() {
                                        _isSelected = true;
                                      })
                                    },
                                child: Center(
                                  child: SelectCard(choice: choices[7]),
                                ))
                          ]))),
                  _isSelected
                      ? FlatButton(
                          onPressed: () {
                            print("pressed button");
                            Navigator.pushNamed(context, '/login');
                          },
                          color: Colors.yellow,
                          minWidth: 340.0,
                          child: Text('Contineu in English'))
                      : SizedBox(height: 0, width: 0),
                  SizedBox(height: 210)
                ])))
        // home: language == null ? LanguagePage() : HomePage(),
//         home: FutureBuilder(
//             // stream: getLinksStream(),
//             // initialData: getLinks(),
//             future: getInitialLink(),
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 // our app started by configured links
//                 // var uri = Uri.parse(snapshot.data);
//                 // print(uri);
//                 if (snapshot.data != null) {
//                   var uri = Uri.parse(snapshot.data);
//                   var list = uri.queryParametersAll;
//                   print(uri);
//                   print(list);
//                   final splitedUriData = uri.toString().split("https://cornext.feednext.app/");
//                   if (list.keys.length == 0 && uri.toString() != "") {
//                     if (splitedUriData[splitedUriData.length - 1].trim().length > 0) {
//                       return FutureBuilder(
//                         future: SharedPreferenceService().checkAccessTokenAndUpdateuserDetails(),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             print(snapshot.data);
//                             final val = snapshot.data;
//                             if (val.get("access_token") == null) {
//                               // Navigator.pushNamed(context, "/login");
//                               // Navigator.pushNamedAndRemoveUntil(
//                               //     context, '/login', ModalRoute.withName('/login'));
//                               signInDetails = {
//                                 "userName": "Hello, User",
//                                 "userId": ""
//                               };
//                               return HomePage();
//                             } else {
//                               // setState(() {
//                               signInDetails['access_token'] = val.get("access_token");
//                               signInDetails['refresh_token'] = val.get("refresh_token");
//                               signInDetails['userName'] = val.get('userName');
//                               signInDetails['userId'] = val.get('userId');
//                               signInDetails['emailId'] = val.get('emailId');
//                               signInDetails['mobileNo'] = val.get('mobileNo');
//                               orderIdFromDeepLink = splitedUriData[splitedUriData.length - 1].trim().toString();
//                               // Navigator.pushNamed(context, '/ordersummary');
//                               fetchCartDetails(context);
//                               return CartPage();
//                             }
//                           } else {
//                             return HomePage();
//                           }
//                         },
//                       );
//                     } else {
//                       return HomePage();
//                     }
//                   } else if (list.keys.length > 0) {
//                     // SharedPreferenceService()
//                     //     .checkAccessTokenAndUpdateuserDetails()
//                     //     .then((val) {
//                     //   if (val.get("access_token") == null) {
//                     //     // Navigator.pushNamed(context, "/login");
//                     //     // Navigator.pushNamedAndRemoveUntil(
//                     //     //     context, '/login', ModalRoute.withName('/login'));
//                     //     signInDeatils = {
//                     //       "userName": "Hello, User",
//                     //       "userId": ""
//                     //     };
//                     //     return HomePage();
//                     //   } else {
//                     //     // setState(() {
//                     //     signInDeatils['access_token'] = val.get("access_token");
//                     //     signInDeatils['refresh_token'] =
//                     //         val.get("refresh_token");
//                     //     signInDeatils['userName'] = val.get('userName');
//                     //     signInDeatils['userId'] = val.get('userId');
//                     //     orderIdFromDeepLink = int.parse(list.keys.first);
//                     //     // Navigator.pushNamed(context, '/ordersummary');
//                     //     return OrderSummary();
//                     //   }
//                     // });

//                     return FutureBuilder(
//                       future: SharedPreferenceService().checkAccessTokenAndUpdateuserDetails(),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData) {
//                           print(snapshot.data);
//                           final val = snapshot.data;
//                           if (val.get("access_token") == null) {
//                             // Navigator.pushNamed(context, "/login");
//                             // Navigator.pushNamedAndRemoveUntil(
//                             //     context, '/login', ModalRoute.withName('/login'));
//                             signInDetails = {
//                               "userName": "Hello, User",
//                               "userId": ""
//                             };
//                             return HomePage();
//                           } else {
//                             // setState(() {
//                             signInDetails['access_token'] = val.get("access_token");
//                             signInDetails['refresh_token'] = val.get("refresh_token");
//                             signInDetails['userName'] = val.get('userName');
//                             signInDetails['userId'] = val.get('userId');
//                             signInDetails['emailId'] = val.get('emailId');
//                             signInDetails['mobileNo'] = val.get('mobileNo');
//                             orderIdFromDeepLink = list.keys.first;
//                             // Navigator.pushNamed(context, '/ordersummary');
//                             fetchCartDetails(context);
//                             return CartPage();
//                           }
//                         } else {
//                           return HomePage();
//                         }
//                       },
//                     );
//                     // return HomePage();
//                     // Navigator.pushNamedAndRemoveUntil(context, '/yourorderdetails',
//                     //     ModalRoute.withName('/yourorderdetails'));
//                   } else {
//                     return HomePage();
//                   }
//                 } else {
//                   // print('data');
//                   // our app started normally
//                   return HomePage();
//                 } // we retrieve all query parameters , tzd://genius-team.com?product_id=1
// // return Text(list.map((f)=>f.toString()).join(‘-’)); // we just print all //parameters but you can now do whatever you want, for example open //product details page.
//               } else {
//                 // print('data');
//                 // our app started normally
//                 return HomePage();
//               }
//             })
        // home: FormDetailsPage()
        );
  }
}
