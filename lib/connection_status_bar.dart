library connection_status_bar;

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectionStatusBar extends StatefulWidget {
  final Color color;
  final Widget title;
  final double width;
  final double height;
  final double? collapsedHeight;
  final Offset endOffset;
  final Offset beginOffset;
  final Duration animationDuration;
  final String lookUpAddress;

  ConnectionStatusBar({
    Key? key,
    this.height = 25,
    this.collapsedHeight,
    this.width = double.maxFinite,
    this.color = Colors.redAccent,
    this.endOffset = const Offset(0.0, 0.0),
    this.beginOffset = const Offset(0.0, -1.0),
    this.animationDuration = const Duration(milliseconds: 200),
    this.lookUpAddress = 'google.com',
    this.title = const Text(
      'Please check your internet connection',
      style: TextStyle(color: Colors.white, fontSize: 14),
    ),
  }) : super(key: key);

  _ConnectionStatusBarState createState() => _ConnectionStatusBarState();
}

class _ConnectionStatusBarState extends State<ConnectionStatusBar> with SingleTickerProviderStateMixin {
  late StreamSubscription _connectionChangeStream;
  bool _hasConnection = true;
  late AnimationController controller;
  late Animation<Offset> offset;

  @override
  void initState() {
    _ConnectionStatusSingleton connectionStatus = _ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize(widget.lookUpAddress);
    _connectionChangeStream = connectionStatus.connectionChange.listen(_connectionChanged);
    controller = AnimationController(vsync: this, duration: widget.animationDuration);

    offset = Tween<Offset>(begin: widget.beginOffset, end: widget.endOffset).animate(controller);
    super.initState();
  }

  void _connectionChanged(bool hasConnection) {
    if (_hasConnection == hasConnection) return;
    hasConnection == false ? controller.forward() : controller.reverse();
    _hasConnection = hasConnection;
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offset,
      child: Container(
        child: SafeArea(
          bottom: false,
          child: Container(
            color: widget.color,
            width: widget.width,
            height: _hasConnection ? widget.height : widget.collapsedHeight ?? widget.height,
            child: Center(
              child: widget.title,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _connectionChangeStream.cancel();

    super.dispose();
  }
}

class _ConnectionStatusSingleton {
  String? _lookUpAddress;
  static final _ConnectionStatusSingleton _singleton = _ConnectionStatusSingleton._internal();
  _ConnectionStatusSingleton._internal();

  static _ConnectionStatusSingleton getInstance() => _singleton;

  bool hasConnection = true;

  StreamController<bool> connectionChangeController = StreamController.broadcast();

  final Connectivity _connectivity = Connectivity();

  void initialize(String lookUpAddress) {
    this._lookUpAddress = lookUpAddress;
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    checkConnection();
  }

  Stream<bool> get connectionChange => connectionChangeController.stream;

  void dispose() {
    connectionChangeController.close();
  }

  void _connectionChange(ConnectivityResult result) {
    checkConnection();
  }

  Future<bool> checkConnection() async {
    assert(_lookUpAddress != null || _lookUpAddress != '');
    bool previousConnection = hasConnection;

    try {
      final result = await InternetAddress.lookup(_lookUpAddress!);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }

    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }

    return hasConnection;
  }
}
