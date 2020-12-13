library slerver_io;

typedef ArgumentCallback<T, M> = Future<T> Function(M);

class SlerverIORoute {
  static Map<String, dynamic> routes = {};

  void on(String path, dynamic callback) => routes[path] = callback;

  getAction(String path) => routes[path];
}
