# connection_status_bar

A widget that animates when internet connection changes

![](demo.gif)

## Getting Started

add it to your dependecies then use it anywhere on your app, usually in a widget that is on top of all of your widgets.

```dart
ConnectionStatusBar(
    // default title
    title: Text(
        'Please check your internet connection',
        style: TextStyle(color: Colors.white, fontSize: 14),
    ),
    color: Colors.redAccent, // default color
),
```
