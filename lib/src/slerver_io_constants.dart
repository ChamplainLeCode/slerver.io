library slerver_io;

/// This class resume the set of constants use.
class SlerverIOConstants {

  /// Start pattern of each message
  static const String BEGIN = '##SLERVERBEGIN##';
  /// End pattern of each message
  static const String END = '##SLERVEREND##';
  /// Path for message that retends connection
  static const String POOLING_PATH = '__pooling__';
  /// Path for disconnecting message, this occurs when client is disconnected
  static const String DISCONNECT_PATH = 'disconnect';
  /// Path for connecting message, this occurs when client is connected
  static const String CONNECT_PATH = 'connect';
  /// Path for error message, this occurs when some exception is thrown
  static const String ERROR_PATH = 'error';
  /// Size of Begin pattern
  static const int BEGIN_SIZE = BEGIN.length;
  /// Size of End pattern
  static const int END_SIZE = END.length;
  /// Min size of any message
  static const int MIN_SIZE = BEGIN_SIZE + END_SIZE;

  SlerverIOConstants._internal();
}
