import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(FlutterExpoDevClient());
}

class FlutterExpoDevClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterExpo Dev Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: DevClientHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DevClientHome extends StatefulWidget {
  @override
  _DevClientHomeState createState() => _DevClientHomeState();
}

class _DevClientHomeState extends State<DevClientHome> {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  Map<String, dynamic>? _currentUI;
  Map<String, dynamic>? _appConfig;
  String _connectionUrl = 'ws://192.168.1.100:3001'; // Default local network
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = _connectionUrl;
    _tryAutoConnect();
  }

  void _tryAutoConnect() {
    // Try to connect automatically on startup
    Future.delayed(Duration(seconds: 1), () {
      _connectToTranslator();
    });
  }

  void _connectToTranslator() {
    try {
      _channel?.sink.close();
      _channel = WebSocketChannel.connect(Uri.parse(_connectionUrl));
      
      setState(() => _isConnected = true);
      
      _channel!.stream.listen(
        (data) {
          final message = jsonDecode(data);
          _handleMessage(message);
        },
        onError: (error) {
          setState(() => _isConnected = false);
          print('WebSocket error: \$error');
        },
        onDone: () {
          setState(() => _isConnected = false);
          print('WebSocket connection closed');
        },
      );
      
      print('Connected to FlutterExpo translator');
    } catch (e) {
      setState(() => _isConnected = false);
      print('Connection failed: \$e');
    }
  }

  void _handleMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'APP_CONFIG':
        setState(() {
          _appConfig = message['data'];
        });
        break;
      case 'COMPONENT_SPEC':
        setState(() {
          _currentUI = message['data'];
        });
        break;
      case 'CONNECTION_ACK':
        print('Connection acknowledged: \${message['data']['sessionId']}');
        break;
    }
  }

  void _sendEvent(String componentId, String event, [Map<String, dynamic>? data]) {
    if (_channel != null && _isConnected) {
      final eventMessage = {
        'type': 'EVENT',
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'componentId': componentId,
          'event': event,
          'data': data ?? {},
        }
      };
      _channel!.sink.add(jsonEncode(eventMessage));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlutterExpo Dev Client'),
        backgroundColor: _isConnected ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: _showQRCode,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: !_isConnected ? FloatingActionButton(
        onPressed: _connectToTranslator,
        child: Icon(Icons.refresh),
        tooltip: 'Reconnect',
      ) : null,
    );
  }

  Widget _buildBody() {
    if (!_isConnected) {
      return _buildConnectionScreen();
    }
    
    if (_currentUI != null) {
      return _buildDynamicUI(_currentUI!);
    }
    
    return _buildWaitingScreen();
  }

  Widget _buildConnectionScreen() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_android,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              'FlutterExpo Dev Client',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Connect to your Flutter development environment',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'WebSocket URL',
                hintText: 'ws://192.168.1.100:3001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              onChanged: (value) => _connectionUrl = value,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _connectToTranslator,
              icon: Icon(Icons.connect_without_contact),
              label: Text('Connect'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Or scan QR code from your development environment',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Connected to FlutterExpo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          Text(
            'Waiting for your Flutter app to load...',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (_appConfig != null) ...[
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _appConfig!['title'] ?? 'Flutter App',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Routes: \${(_appConfig!['routes'] as List?)?.join(', ') ?? 'None'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDynamicUI(Map<String, dynamic> uiSpec) {
    try {
      final components = uiSpec['components'];
      return _buildFromSpec(components);
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error rendering UI'),
            Text('\$e', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }
  }

  Widget _buildFromSpec(Map<String, dynamic> spec) {
    final type = spec['type'] ?? 'div';
    final props = spec['props'] ?? {};
    final style = spec['style'] ?? {};
    final children = spec['children'] as List? ?? [];

    switch (type) {
      case 'div':
        if (props['className'] == 'flutter-scaffold') {
          return _buildScaffold(children, style);
        } else if (props['className'] == 'flutter-column') {
          return _buildColumn(children, style);
        } else if (props['className'] == 'flutter-row') {
          return _buildRow(children, style);
        } else {
          return _buildContainer(children, style);
        }
      
      case 'header':
        return _buildAppBar(children, style, props);
      
      case 'button':
        return _buildButton(children, style, props);
      
      case 'span':
        return _buildText(props, style);
      
      default:
        return _buildContainer(children, style);
    }
  }

  Widget _buildScaffold(List children, Map<String, dynamic> style) {
    Widget? appBar;
    Widget? body;
    Widget? fab;

    for (final child in children) {
      final childType = child['props']?['className'];
      if (childType == 'flutter-appbar') {
        appBar = _buildFromSpec(child);
      } else if (childType == 'flutter-fab') {
        fab = _buildFromSpec(child);
      } else {
        body = _buildFromSpec(child);
      }
    }

    return Scaffold(
      appBar: appBar as PreferredSizeWidget?,
      body: body,
      floatingActionButton: fab,
      backgroundColor: _parseColor(style['backgroundColor']),
    );
  }

  Widget _buildAppBar(List children, Map<String, dynamic> style, Map<String, dynamic> props) {
    String title = '';
    if (children.isNotEmpty) {
      title = children.first['props']?['children'] ?? '';
    }

    return AppBar(
      title: Text(title),
      backgroundColor: _parseColor(style['backgroundColor']),
      foregroundColor: _parseColor(style['color']),
    );
  }

  Widget _buildColumn(List children, Map<String, dynamic> style) {
    return Column(
      mainAxisAlignment: _parseMainAxisAlignment(style['justifyContent']),
      crossAxisAlignment: _parseCrossAxisAlignment(style['alignItems']),
      children: children.map((child) => _buildFromSpec(child)).toList(),
    );
  }

  Widget _buildRow(List children, Map<String, dynamic> style) {
    return Row(
      mainAxisAlignment: _parseMainAxisAlignment(style['justifyContent']),
      crossAxisAlignment: _parseCrossAxisAlignment(style['alignItems']),
      children: children.map((child) => _buildFromSpec(child)).toList(),
    );
  }

  Widget _buildContainer(List children, Map<String, dynamic> style) {
    return Container(
      width: _parseDouble(style['width']),
      height: _parseDouble(style['height']),
      padding: _parseEdgeInsets(style['padding']),
      margin: _parseEdgeInsets(style['margin']),
      decoration: BoxDecoration(
        color: _parseColor(style['backgroundColor']),
        borderRadius: BorderRadius.circular(_parseDouble(style['borderRadius']) ?? 0),
      ),
      child: children.isNotEmpty 
        ? (children.length == 1 
          ? _buildFromSpec(children.first)
          : Column(children: children.map((child) => _buildFromSpec(child)).toList()))
        : null,
    );
  }

  Widget _buildButton(List children, Map<String, dynamic> style, Map<String, dynamic> props) {
    final text = children.isNotEmpty ? children.first['props']?['children'] ?? 'Button' : 'Button';
    final isDisabled = props['disabled'] == true;

    return ElevatedButton(
      onPressed: isDisabled ? null : () {
        _sendEvent(props['id'] ?? 'button', 'onClick');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _parseColor(style['backgroundColor']),
        foregroundColor: _parseColor(style['color']),
        padding: _parseEdgeInsets(style['padding']),
      ),
      child: Text(text),
    );
  }

  Widget _buildText(Map<String, dynamic> props, Map<String, dynamic> style) {
    return Text(
      props['children'] ?? '',
      style: TextStyle(
        fontSize: _parseDouble(style['fontSize']),
        color: _parseColor(style['color']),
        fontWeight: _parseFontWeight(style['fontWeight']),
      ),
    );
  }

  // Helper methods for parsing styles
  Color? _parseColor(dynamic color) {
    if (color == null) return null;
    if (color is String && color.startsWith('#')) {
      return Color(int.parse(color.substring(1), radix: 16) + 0xFF000000);
    }
    return null;
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll('px', ''));
      return parsed;
    }
    return null;
  }

  EdgeInsets? _parseEdgeInsets(dynamic padding) {
    if (padding == null) return null;
    if (padding is String) {
      final parts = padding.split(' ');
      if (parts.length == 4) {
        return EdgeInsets.fromLTRB(
          double.tryParse(parts[3].replaceAll('px', '')) ?? 0,
          double.tryParse(parts[0].replaceAll('px', '')) ?? 0,
          double.tryParse(parts[1].replaceAll('px', '')) ?? 0,
          double.tryParse(parts[2].replaceAll('px', '')) ?? 0,
        );
      }
    }
    return null;
  }

  MainAxisAlignment _parseMainAxisAlignment(dynamic alignment) {
    switch (alignment) {
      case 'center': return MainAxisAlignment.center;
      case 'flex-start': return MainAxisAlignment.start;
      case 'flex-end': return MainAxisAlignment.end;
      case 'space-between': return MainAxisAlignment.spaceBetween;
      case 'space-around': return MainAxisAlignment.spaceAround;
      case 'space-evenly': return MainAxisAlignment.spaceEvenly;
      default: return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _parseCrossAxisAlignment(dynamic alignment) {
    switch (alignment) {
      case 'center': return CrossAxisAlignment.center;
      case 'flex-start': return CrossAxisAlignment.start;
      case 'flex-end': return CrossAxisAlignment.end;
      case 'stretch': return CrossAxisAlignment.stretch;
      default: return CrossAxisAlignment.center;
    }
  }

  FontWeight? _parseFontWeight(dynamic weight) {
    if (weight == null) return null;
    switch (weight.toString()) {
      case '100': return FontWeight.w100;
      case '200': return FontWeight.w200;
      case '300': return FontWeight.w300;
      case '400': return FontWeight.w400;
      case '500': return FontWeight.w500;
      case '600': return FontWeight.w600;
      case '700': return FontWeight.w700;
      case '800': return FontWeight.w800;
      case '900': return FontWeight.w900;
      case 'bold': return FontWeight.bold;
      default: return FontWeight.normal;
    }
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connection QR Code'),
        content: Container(
          width: 200,
          height: 200,
          child: QrImageView(
            data: _connectionUrl,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'WebSocket URL',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _connectionUrl = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _connectToTranslator();
            },
            child: Text('Connect'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _urlController.dispose();
    super.dispose();
  }
}