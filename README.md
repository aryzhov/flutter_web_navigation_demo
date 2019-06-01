# Introduction

This project is a small demo of a soluion that combines TabBar navigation with URL navigation in a Flutter Web application. It allows preserving the current tab in the URL. Since this is a typical design for websites, I made this project to demonstrate this solution as it could be used to other developers. 

With the current design of Flutter Web, it's not a trivial task to achieve consistent behavior between a `TabBar` and a `Navigator`. I am not happy with my solution for the reasons I describe below, and I hope that the Flutter Team considers this in future versions of Flutter Web.

# Implementation Details

1. We make `MyApp` a stateful widget. It creates a `TabController` but does not render a `TabBar` or `TabView`. 

2. The `Scaffold`, the `TabBar`, and the `TabBarView` are rendered by the widget `MyHomePage`, which gets the tab controller from `MyApp`.

3. We make the `Navigator` object accessible inside `MyApp` by defining and using `navigagorKey`. It's necessary since the navigator is created in MaterialApp.

4. We define the `onGenerateRoute` handler for the app, which returns a `MyHomePage` but has a side-effect of switching to the that corresponds to the route name. We need to use `WidgetsBinding.addPostFrameCallback` in order to avoid changing state during a render, which would result in an exception.

5. We specify `isInitialRoute: true` when we create a route as a hack to avoid a sliding animation that `Navigator` would otherwise make when the current tab is changed.

6. We define class `PageTracker` that implements `NavigationObserver`. This is the only way to get the current page of the navigator, as the `NavigatorState` class does not expise it. We instantiate a `PageTracker` in `MyApp` and specify that instance in `navigatorObservers` parameter of `MaterialApp`. Now we can access the current page index from `MyApp`.

7. We add a listener to `tabController`. At the end of the tab change animation, we call `Navigator.pushReplacementNamed` with a page name that corresponds to the newly selected tab, but only if it's not already the current page, which we know from `PageTracker`. 

8. We add a `PageNotFound` widget that gets rendered by `onGenerateRoute` if the URL does not correspond to one of our page names.

# Issues

The main issue with this solution is that `Navigator` throws away the current instance of `MyHomePage` and replaces it with a new instance every time the user clicks on a tab. You can see why this happens if you replace the line: 
```
      settings: RouteSettings(name: settings.name, isInitialRoute: true),
```
with
```
      settings: settings;
```
You will see a brief sliding animation at the end of the tab change animation: the old instance of `MyHomePage` gets replaced with a new instance of `MyHomePage`. That's not efficient. If `MyHomePage` becomes a stateful widget, its state won't be preserved, as for a brief period of time both instances of `MyHomePage` exist in the `Navigator`. 

Another issue with this solution is its complexity. I had to stumble on a few issues that I had to overcome in order to make it work, and without documentation it would be hard to understand the reasons for adding all that complexity. 

# Thoughts

The soluton would be a lot simpler if there was a way to get the current route from `Navigator`, and if `Navigator` allowed to set the current route without replacing the underlying widget. 

Perhaps route/URL management and page transitons should be decoupled. This would allow making custom solutons for page navigation that go beyond the capabilities of Navigator: a controller which is not a widget and does route/URL management, and a view widget that does the fancy page transitions.
