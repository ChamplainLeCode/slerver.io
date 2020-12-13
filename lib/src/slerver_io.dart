library slerver_io;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import './slerver_io_router.dart';
import 'package:slerver_io/src/slerver_io_constants.dart';
import 'package:logger/logger.dart';

class SlerverIO {
  Socket _client;
  StreamController<Uint8List> _dataStream;
  final bool autoReconnect;
  bool connected = false;
  dynamic error, errorStackTrace;
  final Logger l = Logger(printer: PrettyPrinter(methodCount: 0, errorMethodCount: 8, lineLength: 120, colors: true, printEmojis: true, printTime: false));
  final String address;
  final int port;
  SlerverIORouter routerIO;
  SlerverIORedirectRoute _redirectRoute = SlerverIORedirectRoute();

  SlerverIO._empty({this.autoReconnect = true, this.address, this.port});

  get setClose => null;

  close() async {
    try {
      _redirectRoute?.close();
    } catch (e, stack) {
      errorManager(e, stack);
    }
    if (autoReconnect) return routerIO.setClientAutoReconnect();
    l.d('Connection terminated');
  }

  SlerverIORedirectRoute get router => _redirectRoute;

  static Future<SlerverIO> connect(String address, int port,
      {autoReconnect = true}) async {
    assert(address != null && port != null);
    return await SlerverIO._empty(
            autoReconnect: autoReconnect, address: address, port: port)
        ._initClient();
  }

  StreamController<Uint8List> get getDataStream => _dataStream;

  Future<SlerverIO> _initClient() async {
    try {
      if (_client == null) _client = await Socket.connect(address, port);
      l.d('Client connected to {} port {} ',
          [_client.address.host, _client.port]);
      if (_dataStream == null || _dataStream.isClosed)
        _dataStream = StreamController.broadcast(onCancel: close);

      /// To manage our socket we bind to a Stream Controller
      try {
        //  _dataStream.addStream(_client);
        _client.addStream(_dataStream.stream);
      } catch (e) {}
      _dataStream.stream.handleError(errorManager);

      _redirectRoute.controller.stream.listen((entry) {
        routerIO.on(entry.key, entry.value);
      });

      this.connected = true;
      routerIO = SlerverIORouter(this);
    } on SocketException catch (error) {
      this.error = error;
      this.connected = false;
    } catch (e, stack) {
      this.connected = false;
      this.error = e;
      this.errorStackTrace = stack;
    }
    return this;
  }

  Future<SlerverIO> get reconnect => _initClient();

  void errorManager(Object error, [StackTrace stackTrace]) {
    l.e('Error occurs', [error, stackTrace]);
    if (connected)
      this
          .routerIO
          .doRouting({'path': SlerverIOConstants.ERROR_PATH, 'params': error});
  }

  Socket getClient() => _client;

  static String hashAddress(String address, int port) {
    assert(address != null && port != null, 'Address or port cannot be null');
    return '$address:$port';
  }

  onClose() {
    this.connected = false;
    close();
  }

  onPause() {
    l.w('Pause event ');
    onResume();
  }

  onResume() {
    l.w('Resume event');
    onClose();
  }

  send(Map<String, Object> data) {
    try {
      _dataStream.add(Uint8List.fromList(
          '${SlerverIOConstants.BEGIN}${json.encode(data)}${SlerverIOConstants.END}'
              .codeUnits));
    } on StateError catch (e, stack) {
      errorManager(e, stack);
      reconnect;
    } catch (e, stack) {
      errorManager(e, stack);
    }
  }
}

class SlerverIORedirectRoute {
  final StreamController<MapEntry<String, dynamic>> controller =
      StreamController.broadcast();

  close() {
    controller?.close();
  }

  void on(String path, dynamic callback) =>
      controller.add(MapEntry(path, callback));
}
