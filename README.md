# Introduction

This project is a small demo of a solution that combines TabBar navigation with URL navigation in a Flutter Web application. It allows preserving the current tab in the URL. I made this project to demonstrate an approach, since this is a typical design for websites.

With the current design of Flutter Web, it's not a trivial task to achieve consistent behavior between a `TabBar` and a `Navigator`. I am not completely satisfied with my solution for the reasons I describe in the **Issues** section.

# Implementation Details

1. Class `MyApp` creates a `MaterialApp` and handles `Navigator` page changes. The `Navigator` object is made is accessible inside `MyApp` by defining and using `navigagorKey`. It's necessary since the navigator is created inside `MaterialApp` and would not be availble from the build context.

2. We make `MyHomePage` a stateful widget. It keeps a `TabController` in its state, and the state extends `SingleTickerProviderStateMixin` to be passed to `TabController`. It creates a `Scaffold` with a `TabBar`, and a `TabView`. It accepts an `onTabChanged` callback that gets called when the user clicks on a tab. 

3. We define the `onGenerateRoute` handler for `MaterialApp`, which returns a `MyHomePage` with the page index corresponding to the route name. We specify `isInitialRoute: true` when we create a route as a hack to avoid a sliding animation that `Navigator` would otherwise make when the current tab is changed.

6. We define class `PageTracker` that implements `NavigationObserver`. This is the only way to get the current page of the navigator, as the `NavigatorState` class does not expise it. We instantiate a `PageTracker` in `MyApp` and specify that instance in `navigatorObservers` parameter of `MaterialApp`. Now we can access the current page index from `MyApp`.

7. We add a listener to `tabController`. At the end of the tab change animation, we call `Navigator.pushReplacementNamed` with a page name that corresponds to the newly selected tab, but only if it's not already the current page, which we know from `PageTracker`. 

8. We add a `PageNotFound` widget that gets rendered by `onGenerateRoute` if the URL does not correspond to one of our page names.

# Running

To run this project, first follow the [Getting Started](https://github.com/flutter/flutter_web) guide for Flutter Web, then run `webdev serve`.

# Issues

The main issue with this solution is that `Navigator` throws away the current instance of `MyHomePage` and replaces it with a new instance every time the user clicks on a tab. You can see why this happens if you replace the line: 
```
      settings: RouteSettings(name: settings.name, isInitialRoute: true),
```
with
```
      settings: settings;
```
You will see a brief sliding animation at the end of the tab change animation: the old instance of `MyHomePage` gets replaced with a new instance of `MyHomePage`. That's not efficient. If `MyHomePage` becomes a stateful widget, its state won't be preserved, as for a brief moment both instances of `MyHomePage` exist in the `Navigator`. 

Another issue is the appearance of the Back button if the page is refreshed, or if the initial URL is not the home page (go to a tab and copy/paste the URL in a new browser tab). I couldn't figure out why this happens and I did not find a workaround for this quirk.

Finally, this soluton contains some parts that are not obvious to understand. I had to stumble on and work around a few issues in order to make it work, and without  understanding the reasons why it's made this way it would be easy to break it as the project evolves. 

# Thoughts

The soluton would be a lot simpler if there was a way to get the current route from `Navigator`, and if `Navigator` allowed to set the current route without replacing the underlying widget. 

Perhaps route/URL management and page transitons should be decoupled. This would allow making custom solutons for page navigation that go beyond the capabilities of Navigator: a controller which is not a widget and does route/URL management, and a view widget that does the fancy page transitions.

Also not addressed and unclear are nested navigators. It would be logical if URL structure corresponded to the structure of navigators, but I doubt that it's how it works. I could be wrong.

My conclusion after implementing this solution is that URL management in Flutter Web needs improvements in order to provide the full range of functionality expected from a website. Having said that, I am a big fan of Flutter, and I am optimistic about the future for Flutter Web, and I appreciate all the hard work that the Flutter team has done and continues to do.