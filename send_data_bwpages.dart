import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "My App", initialRoute: "/", routes: {
      "/": (context) => Homepage(),
      "/second": (context) => secondScr()
    });
  }
}

class Homepage extends StatelessWidget {
  TextEditingController v1 = TextEditingController();
  TextEditingController v2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello 1")),
      body: Container(
        child: Column(children: [
          TextFormField(
            controller: v1,
            decoration: InputDecoration(hintText: "Enter value 1"),
          ),
          TextFormField(
            controller: v2,
            decoration: InputDecoration(hintText: "Enter value 2"),
          ),
          ElevatedButton(
              onPressed: (() => Navigator.pushNamed(context, "/second",
                  arguments: [v1.text, v2.text])),
              child: Text("Send Value")),
        ]),
      ),
    );
  }
}

class secondScr extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)?.settings.arguments as List;

    return Scaffold(
      appBar: AppBar(
        title: Text("Hello"),
      ),
      body: Container(
        child: Column(children: [
          Text("Argument 1: ${args[0]}"),
          Text("Argument 2: ${args[1]}"),
        ]),
      ),
    );
  }
}
