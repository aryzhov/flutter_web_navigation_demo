import 'package:flutter_web/material.dart';

const pages = ["Home", "Products", "Services", "News", "Events", "About"];

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {

TabController tabController;

  @override
  void initState() {
    super.initState();
     tabController = TabController(length: pages.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(tabController),
    );
  }
}

class MyHomePage extends StatefulWidget {

  final TabController tabController;

  MyHomePage(this.tabController);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello"),
        bottom: TabBar(
          controller: widget.tabController, 
          tabs: [
            for(var p in pages)
              Tab(text: p),
          ]
        ),
      ),
      body: TabBarView(
        controller: widget.tabController,
        children: [
          for(var p in pages)
            SomePage(p),
        ],
      ), 
    );
  }
}

class SomePage extends StatelessWidget {

  final String text;

  SomePage(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text,),
    );
  }

}