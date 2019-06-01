import 'package:flutter_web/material.dart';

const pageNames = ["Home", "Products", "Services", "News", "Events", "About"];
const title = "Flutter Web Navigation With Tabs";

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {

  final navigatorKey = GlobalKey<NavigatorState>(debugLabel: "Navigator");
  final navigatorPage = PageTracker();
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: pageNames.length, vsync: this);
    tabController.addListener(() {
      if(!tabController.indexIsChanging) {
        final page = tabController.index;
        final nav = navigatorKey.currentState;
        if(navigatorPage.page != page) {
          final pageName = page == 0 ? '': '/${pageNames[page]}';
          print("Push replacement: $pageName");
          nav.pushReplacementNamed(pageName);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey,
      initialRoute: '',
      onGenerateRoute: _generateRoute,
      navigatorObservers: [
        navigatorPage,
      ],
    );
  }

  Route _generateRoute(RouteSettings settings) {
    final int page = getPageFromRoute(settings);
    return MaterialPageRoute(
      settings: RouteSettings(name: settings.name, isInitialRoute: true),
      builder: (context) {
        if(page != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _goToPage(page));
          return MyHomePage(tabController);
        } else {
          return PageNotFound(settings.name);
        }
      },
    );
  }

  _goToPage(int page) {
    tabController.index = page;
    print("Set tab index: $page");
  }

}

class MyHomePage extends StatelessWidget {

  final TabController tabController;
  
  MyHomePage(this.tabController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: TabBar(
          controller: tabController, 
          tabs: [
            for(var p in pageNames)
              Tab(text: p),
          ]
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          for(var p in pageNames)
            PageStub(p),
        ],
      ), 
    );
  }
}

class PageStub extends StatelessWidget {

  final String text;

  PageStub(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text,),
    );
  }

}

int getPageFromRoute(RouteSettings rs) {
  if(rs.name == null) return null;
  final pageName = rs.name.startsWith('/') ? rs.name.substring(1): rs.name;
  final page = pageName == '' ? 0 : pageNames.indexOf(pageName);
  return page >= 0 ? page: null;
}

class PageTracker extends NavigatorObserver {

  int page = 0;

  @override
  void didPop(Route route, Route previousRoute) {
    page = getPageFromRoute(previousRoute.settings) ?? page;
  }

  @override
  void didPush(Route route, Route previousRoute) {
    page = getPageFromRoute(route.settings) ?? page;
  }

  @override
  void didRemove(Route route, Route previousRoute) {
    page = getPageFromRoute(previousRoute.settings) ?? page;
  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    page = getPageFromRoute(newRoute.settings) ?? page;
  }

  @override
  void didStartUserGesture(Route route, Route previousRoute) {
    // nothing
  }

  @override
  void didStopUserGesture() {
    // nothing
  }

}

class PageNotFound extends StatelessWidget {

  final String pageName;

  PageNotFound(this.pageName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Page not found: $pageName"),
            RaisedButton(child: Text("Home Page"), onPressed: () {
              Navigator.pushReplacementNamed(context, '');
            },),
          ],
        ),
      ),
    );
  }

}