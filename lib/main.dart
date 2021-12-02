import 'package:../Bloc/Auth/auth_bloc.dart';
import 'package:../Bloc/Cart/cart_bloc.dart';
import 'package:../Bloc/General/general_bloc.dart';
import 'package:../Bloc/Personal/personal_bloc.dart';
import 'package:../Bloc/Product/product_bloc.dart';
import 'package:../Routes/Routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()..add(CheckLoginEvent())),
        BlocProvider(create: (context) => GeneralBloc()),
        BlocProvider(create: (context) => ProductBloc()),
        BlocProvider(create: (context) => PersonalBloc()),
        BlocProvider(create: (context) => CartBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-Commers Products',
        initialRoute: 'loadingPage',
        routes: routes,
      ),
    );
  }
}
