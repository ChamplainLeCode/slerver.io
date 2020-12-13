library slerver_io;
/// Type for route action
typedef ArgumentCallback<T, M> = Future<T> Function(M);

/// Route subscriber.
class SlerverIORoute {

  /// Map of routes
  static Map<String, dynamic> routes = <String, dynamic>{};

  /// function use to subcribe routes
  void on(String path, dynamic callback) => routes[path] = callback;

  /// Return action for specific path
  getAction(String path) => routes[path];
}
