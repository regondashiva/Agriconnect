import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants/api_constants.dart';

typedef ProduceCreatedCallback = void Function(Map<String, dynamic> produce);
typedef MatchUpdatedCallback = void Function(Map<String, dynamic> match);

class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  io.Socket? _socket;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  final List<ProduceCreatedCallback> _produceListeners = [];
  final List<MatchUpdatedCallback> _matchListeners = [];

  void init() {
    if (_socket != null) return;

    _socket = io.io(
      ApiConstants.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket?.onConnect((_) {
      _isConnected = true;
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
    });

    _socket?.on('produce.created', (data) {
      if (data is Map<String, dynamic>) {
        for (final cb in _produceListeners) {
          cb(data);
        }
      }
    });

    _socket?.on('match.updated', (data) {
      if (data is Map<String, dynamic>) {
        for (final cb in _matchListeners) {
          cb(data);
        }
      }
    });

    _socket?.connect();
  }

  void joinBuyerRoom(String buyerId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('joinRoom', 'buyer_');
    }
  }

  void onProduceCreated(ProduceCreatedCallback callback) {
    _produceListeners.add(callback);
  }

  void onMatchUpdated(MatchUpdatedCallback callback) {
    _matchListeners.add(callback);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }
}