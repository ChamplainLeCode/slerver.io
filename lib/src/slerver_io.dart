library slerver_io;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:slerver_io/src/slerver_io_constants.dart';
import 'package:logger/logger.dart';

import 'slerver_io_router.dart';

class SlerverIO {
  Socket _client;
  StreamController<Uint8List> _dataStream;
  /// To check whether client should reconnect or not without the application closed.
  final bool autoReconnect;
  /// Whether client is connected to `Slerver`
  bool connected = false;
  /// Stacktrace set when an exception is thrown
  dynamic error, errorStackTrace;
  /// logger, for log reporting. see alson [logger](https://pub.dev/packages/logger)
  final Logger l = Logger(printer: PrettyPrinter(methodCount: 0, errorMethodCount: 8, lineLength: 120, colors: true, printEmojis: true, printTime: false));
  /// IP address to which `slerver` is bound
  final String address;
  /// port number on which `slerver` is listens
  final int port;
  /// Instance of Router, see also `SlerverIORouter`
  SlerverIORouter routerIO;

  SlerverIORedirectRoute _redirectRoute = SlerverIORedirectRoute();

  SlerverIO._empty({this.autoReconnect = true, this.address, this.port});

  /// Close all files descriptor
  close() async {
    try {
      _redirectRoute?.close();
    } catch (e, stack) {
      errorManager(e, stack);
    }
    if (autoReconnect) return routerIO.setClientAutoReconnect();
    l.d('Connection terminated');
  }

  /// Getter for set of subscribed routes.
  SlerverIORedirectRoute get router => _redirectRoute;

  /// Unique way to create an instance of Slerver client
  static Future<SlerverIO> connect(String address, int port,
      {autoReconnect = true}) async {
    assert(address != null && port != null);
    return await SlerverIO._empty(
            autoReconnect: autoReconnect, address: address, port: port)
        ._initClient();
  }

  /// Current instance of the Socket outgoing data stream.
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

  /// Main function for error management
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

  /// When socket stream close is triggered
  onClose() {
    this.connected = false;
    close();
  }
  /// When socket stream is sent to pause
  onPause() {
    l.w('Pause event ');
    onResume();
  }
  /// When socket is resume
  onResume() {
    l.w('Resume event');
    onClose();
  }

  /// function use to send data to `send data`. 
  /// ### Note that *data arg* should contain params & papth field
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
