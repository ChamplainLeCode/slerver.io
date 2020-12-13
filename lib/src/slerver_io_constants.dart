library slerver_io;

class SlerverIOConstants {
  static const String BEGIN = '##SLERVERBEGIN##',
      END = '##SLERVEREND##',
      POOLING_PATH = '__pooling__',
      DISCONNECT_PATH = 'disconnect',
      CONNECT_PATH = 'connect',
      ERROR_PATH = 'error';
  static const int BEGIN_SIZE = BEGIN.length,
      END_SIZE = END.length,
      MIN_SIZE = BEGIN_SIZE + END_SIZE;
}
