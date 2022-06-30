import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
@override
Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "splah screen demo",
      debugShowCheckedModeBanner: false,
      home: LoadingScreen()
    );
  }
}

class LoadingScreen extends StatefulWidget
{
  _LoadingScreen createState()=> _LoadingScreen();
}

class _LoadingScreen extends State<LoadingScreen>
{
  @override
  void initState()
  {
    super.initState();

  Timer(
    Duration(seconds: 3),
    ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()))
  );

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/splash.png'),
          fit: BoxFit.fill,
          )
      ),
    );
  }
  }


  class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Splash Screen")),
      body: Center(
          child: Text(
        "Hello world",
        textScaleFactor: 2,
      )),
    );
  }
}
