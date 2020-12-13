library slerver_io;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'slerver_io_constants.dart';
import '../src/slerver_io.dart';
import '../src/slerver_io_route.dart';

class SlerverIORouter {
  final SlerverIO _client;
  final SlerverIORoute _routes = SlerverIORoute();
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0, errorMethodCount: 8, lineLength: 120, colors: true, printEmojis: true, printTime: false));
  static const int maxReconnectionTimes = 30;

  SlerverIORouter(this._client) : assert(_client != null) {
    if (_client.autoReconnect)
      setClientAutoReconnect(10);
    else
      setClientAutoReconnect(1);
  }

  void on(String path, dynamic callback) {
    if(kDebugMode)
      print('Setting up route $path with closure $callback');
    _routes.on(path, callback);
  }

  setAdditionalPath() {
    on(SlerverIOConstants.ERROR_PATH, _client.errorManager);
    on(SlerverIOConstants.CONNECT_PATH, null);
    on(SlerverIOConstants.DISCONNECT_PATH, null);
  }

  setClientAutoReconnect([int times = maxReconnectionTimes]) async {
    int time = times;
    do {
      if (_client.connected) {
        setAdditionalPath();

        _client.getClient().listen(applyRouting)
          ..onError(_client.errorManager)
          ..onDone(_client.onClose);
        Future.delayed(Duration(seconds: 1),
            () => doRouting({'path': SlerverIOConstants.CONNECT_PATH}));
        break;
      } else
        setError();

      await _client.reconnect;
      await Future.delayed(Duration(seconds: Duration.secondsPerMinute >> 3));
      time--;
    } while (time > 0);
  }

  setError() {
    _client.errorManager(_client.error, _client.errorStackTrace);
  }

  void applyRouting(Uint8List data) async {
    StringBuffer content = StringBuffer();

    content.write(String.fromCharCodes(data));
    while (content.length > SlerverIOConstants.MIN_SIZE) {
      num start = content.toString().indexOf(SlerverIOConstants.BEGIN),
          end = content.toString().indexOf(SlerverIOConstants.END);
      String data = content
          .toString()
          .substring(start + SlerverIOConstants.BEGIN_SIZE, end);
      doRouting(json.decode(data));
      String rest =
          content.toString().substring(end + SlerverIOConstants.END_SIZE);
      content.clear();
      content.write(rest);
    }
  }

  doRouting(Map<String, dynamic> meta) async {
    final action = this._routes.getAction(meta['path']);
    final params = meta['params'];
    if (action != null) {
      if (params != null)
        await action.call(params);
      else
        await action.call();
    } else
      _logger
          .d('Unknown action for ${meta['path']} with params $params');
  }
}
