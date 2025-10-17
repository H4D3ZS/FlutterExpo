import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'ui_ast.dart';

/// WebSocket emitter for sending UI AST to translator service
class WebSocketEmitter {
  WebSocketChannel? _channel;
  String? _sessionId;
  bool _isConnected = false;
  final String _serverUrl;
  
  WebSocketEmitter(this._serverUrl);

  /// Connect to the translator service
  Future<void> connect() async {
    try {
      _channel = IOWebSocketChannel.connect(_serverUrl);
      _isConnected = true;
      
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
      
      print('Connected to FlutterExpo translator service');
    } catch (e) {
      print('Failed to connect to translator service: $e');
      _isConnected = false;
    }
  }

  /// Emit UI AST update to translator service
  void emitUIUpdate(UIASTDocument document) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected, cannot emit UI update');
      return;
    }

    final message = {
      'type': 'UI_UPDATE',
      'timestamp': DateTime.now().toIso8601String(),
      'sessionId': _sessionId,
      'data': document.toJson(),
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// Emit raw message to translator service
  void emitRawMessage(Map<String, dynamic> message) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected, cannot emit message');
      return;
    }

    _channel!.sink.add(jsonEncode(message));
  }

  /// Emit state delta to translator service
  void emitStateDelta(String screenId, List<Map<String, dynamic>> changes) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected, cannot emit state delta');
      return;
    }

    final message = {
      'type': 'STATE_DELTA',
      'timestamp': DateTime.now().toIso8601String(),
      'sessionId': _sessionId,
      'data': {
        'screenId': screenId,
        'changes': changes,
      },
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data);
      final messageType = message['type'];
      
      switch (messageType) {
        case 'CONNECTION_ACK':
          _sessionId = message['data']['sessionId'];
          print('Connection acknowledged, session ID: $_sessionId');
          break;
        case 'EVENT':
          _handleEvent(message['data']);
          break;
        case 'ERROR':
          print('Received error: ${message['data']['message']}');
          break;
        default:
          print('Unknown message type: $messageType');
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  /// Handle incoming events from web clients
  void _handleEvent(Map<String, dynamic> eventData) {
    // TODO: Implement event handling logic
    print('Received event: $eventData');
  }

  /// Handle WebSocket errors
  void _handleError(error) {
    print('WebSocket error: $error');
    _isConnected = false;
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    print('WebSocket disconnected');
    _isConnected = false;
    _sessionId = null;
  }

  /// Disconnect from translator service
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    _sessionId = null;
  }

  /// Check if WebSocket is connected
  bool get isConnected => _isConnected;
}