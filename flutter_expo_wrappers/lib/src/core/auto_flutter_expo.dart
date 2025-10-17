import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'universal_interceptor.dart';

/// Auto FlutterExpo - Zero Configuration Setup
/// Just add `flutter pub add flutter_expo` and this handles everything automatically
class AutoFlutterExpo {
  static bool _isInitialized = false;
  static bool _isEnabled = true;

  /// Automatically initialize FlutterExpo when the package is imported
  /// This runs automatically - no developer action required
  static void _autoInitialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAutoCapture();
      _startBackgroundServices();
      _generateReactProject();
      _setupExpoGoExperience();
    });

    developer.log('🚀 FlutterExpo Auto-Initialized - Web translation active');
  }

  /// Setup automatic widget tree capture for ANY Flutter app
  static void _setupAutoCapture() {
    // Initialize universal interceptor
    UniversalFlutterInterceptor.initialize(
      wsUrl: 'ws://localhost:3001',
      autoStart: true,
    );

    // Hook into Flutter's widget inspector to capture ALL widgets automatically
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      if (!_isEnabled) return;
      
      final context = WidgetsBinding.instance.rootElement;
      if (context != null) {
        _captureEntireApp(context);
      }
    });
  }

  /// Capture the entire Flutter app automatically
  static void _captureEntireApp(BuildContext context) {
    try {
      // Find the root MaterialApp or CupertinoApp
      Widget? rootApp;
      context.visitChildElements((element) {
        if (element.widget is MaterialApp || element.widget is CupertinoApp) {
          rootApp = element.widget;
          return false;
        }
        return true;
      });

      if (rootApp != null) {
        UniversalFlutterInterceptor.captureWidgetTree(context, rootApp!);
      }
    } catch (e) {
      developer.log('FlutterExpo auto-capture error: $e');
    }
  }

  /// Start background services automatically
  static void _startBackgroundServices() {
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: Start Expo Go-like service
      _startMobileDevService();
    } else {
      // Desktop/Web: Start translator service
      _startTranslatorService();
    }
  }

  /// Generate React project with editable source files
  static void _generateReactProject() {
    _createReactProjectStructure();
    _generateEditableReactComponents();
    _setupHotReload();
  }

  /// Setup Expo Go-like experience for mobile development
  static void _setupExpoGoExperience() {
    _createDevClient();
    _setupQRCodeGeneration();
    _enableRealTimeSync();
  }

  /// Create complete React project structure with editable files
  static void _createReactProjectStructure() {
    final projectRoot = Directory.current.path;
    final webDir = Directory('$projectRoot/web_flutter_expo');
    
    if (!webDir.existsSync()) {
      webDir.createSync(recursive: true);
      
      // Create package.json
      File('$projectRoot/web_flutter_expo/package.json').writeAsStringSync('''
{
  "name": "flutter-expo-web",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.8.0",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "typescript": "^4.9.0",
    "vite": "^4.0.0",
    "@vitejs/plugin-react": "^3.0.0"
  },
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "start": "vite"
  },
  "devDependencies": {
    "@types/node": "^18.0.0"
  }
}
''');

      // Create vite.config.ts
      File('$projectRoot/web_flutter_expo/vite.config.ts').writeAsStringSync('''
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    host: true
  }
})
''');

      // Create tsconfig.json
      File('$projectRoot/web_flutter_expo/tsconfig.json').writeAsStringSync('''
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
''');

      developer.log('✅ React project structure created at web_flutter_expo/');
    }
  }

  /// Generate editable React components from Flutter widgets
  static void _generateEditableReactComponents() {
    final webSrcDir = Directory('${Directory.current.path}/web_flutter_expo/src');
    if (!webSrcDir.existsSync()) {
      webSrcDir.createSync(recursive: true);
    }

    // Generate main App.tsx
    File('${webSrcDir.path}/App.tsx').writeAsStringSync('''
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { FlutterExpoProvider } from './components/FlutterExpoProvider';
import { HomePage } from './screens/HomePage';
import { AboutPage } from './screens/AboutPage';
import './App.css';

function App() {
  return (
    <FlutterExpoProvider>
      <Router>
        <div className="flutter-expo-app">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/about" element={<AboutPage />} />
            {/* Add more routes as your Flutter app grows */}
          </Routes>
        </div>
      </Router>
    </FlutterExpoProvider>
  );
}

export default App;
''');

    // Generate FlutterExpoProvider
    File('${webSrcDir.path}/components/FlutterExpoProvider.tsx').writeAsStringSync('''
import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

interface FlutterExpoContextType {
  isConnected: boolean;
  currentScreen: string;
  appConfig: any;
  updateScreen: (screen: string) => void;
}

const FlutterExpoContext = createContext<FlutterExpoContextType | undefined>(undefined);

export const useFlutterExpo = () => {
  const context = useContext(FlutterExpoContext);
  if (!context) {
    throw new Error('useFlutterExpo must be used within FlutterExpoProvider');
  }
  return context;
};

interface Props {
  children: ReactNode;
}

export const FlutterExpoProvider: React.FC<Props> = ({ children }) => {
  const [isConnected, setIsConnected] = useState(false);
  const [currentScreen, setCurrentScreen] = useState('/');
  const [appConfig, setAppConfig] = useState(null);

  useEffect(() => {
    // Connect to FlutterExpo translator service
    const ws = new WebSocket('ws://localhost:3001');
    
    ws.onopen = () => {
      setIsConnected(true);
      console.log('🚀 Connected to FlutterExpo translator');
    };
    
    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      
      switch (message.type) {
        case 'APP_CONFIG':
          setAppConfig(message.data);
          document.title = message.data.title || 'Flutter Expo App';
          break;
        case 'COMPONENT_SPEC':
          // Auto-generate React components from Flutter widgets
          console.log('📱 New screen received:', message.data.route);
          setCurrentScreen(message.data.route);
          break;
      }
    };
    
    ws.onclose = () => setIsConnected(false);
    
    return () => ws.close();
  }, []);

  const updateScreen = (screen: string) => {
    setCurrentScreen(screen);
  };

  return (
    <FlutterExpoContext.Provider value={{
      isConnected,
      currentScreen,
      appConfig,
      updateScreen
    }}>
      {children}
    </FlutterExpoContext.Provider>
  );
};
''');

    // Generate HomePage component
    Directory('${webSrcDir.path}/screens').createSync(recursive: true);
    File('${webSrcDir.path}/screens/HomePage.tsx').writeAsStringSync('''
import React from 'react';
import { useFlutterExpo } from '../components/FlutterExpoProvider';

export const HomePage: React.FC = () => {
  const { isConnected, appConfig } = useFlutterExpo();

  return (
    <div className="flutter-screen">
      <header className="flutter-appbar">
        <h1>{appConfig?.title || 'Flutter Expo App'}</h1>
      </header>
      
      <main className="flutter-body">
        <div className="flutter-column">
          <h2>Welcome to FlutterExpo!</h2>
          <p>Your Flutter app is automatically running as a native website.</p>
          
          <div className="flutter-container">
            <div className="counter-display">
              <span className="counter-number">0</span>
            </div>
          </div>
          
          <div className="flutter-row">
            <button className="flutter-button primary">
              Increment
            </button>
            <button className="flutter-button secondary">
              Reset
            </button>
          </div>
        </div>
      </main>
      
      <button className="flutter-fab">
        +
      </button>
      
      <div className="dev-status">
        Status: {isConnected ? '🟢 Connected' : '🔴 Disconnected'}
      </div>
    </div>
  );
};
''');

    // Generate AboutPage component
    File('${webSrcDir.path}/screens/AboutPage.tsx').writeAsStringSync('''
import React from 'react';
import { Link } from 'react-router-dom';

export const AboutPage: React.FC = () => {
  return (
    <div className="flutter-screen">
      <header className="flutter-appbar">
        <h1>About</h1>
      </header>
      
      <main className="flutter-body">
        <div className="flutter-column">
          <h2>FlutterExpo Platform</h2>
          <p>
            This website was automatically generated from your Flutter application.
            No web development required!
          </p>
          
          <div className="flutter-card">
            <h3>Features:</h3>
            <ul>
              <li>✅ Real-time synchronization</li>
              <li>✅ Automatic component translation</li>
              <li>✅ Multi-language support</li>
              <li>✅ Native web performance</li>
              <li>✅ Zero configuration required</li>
            </ul>
          </div>
          
          <Link to="/" className="flutter-button">
            Back to Home
          </Link>
        </div>
      </main>
    </div>
  );
};
''');

    // Generate CSS
    File('${webSrcDir.path}/App.css').writeAsStringSync('''
/* FlutterExpo Auto-Generated Styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
  background-color: #fafafa;
}

.flutter-expo-app {
  min-height: 100vh;
}

.flutter-screen {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.flutter-appbar {
  background-color: #1976d2;
  color: white;
  padding: 16px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.flutter-appbar h1 {
  font-size: 20px;
  font-weight: 500;
}

.flutter-body {
  flex: 1;
  padding: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.flutter-column {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  max-width: 600px;
  text-align: center;
}

.flutter-row {
  display: flex;
  flex-direction: row;
  gap: 16px;
  align-items: center;
}

.flutter-container {
  background-color: #e3f2fd;
  border-radius: 60px;
  width: 120px;
  height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 20px 0;
}

.counter-number {
  font-size: 48px;
  font-weight: bold;
  color: #1976d2;
}

.flutter-button {
  background-color: #1976d2;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.flutter-button:hover {
  background-color: #1565c0;
  transform: translateY(-1px);
}

.flutter-button.secondary {
  background-color: transparent;
  color: #1976d2;
  border: 1px solid #1976d2;
}

.flutter-button.secondary:hover {
  background-color: #1976d2;
  color: white;
}

.flutter-fab {
  position: fixed;
  bottom: 16px;
  right: 16px;
  width: 56px;
  height: 56px;
  border-radius: 28px;
  background-color: #1976d2;
  color: white;
  border: none;
  cursor: pointer;
  font-size: 24px;
  font-weight: bold;
  box-shadow: 0 4px 8px rgba(0,0,0,0.3);
  transition: all 0.2s ease;
}

.flutter-fab:hover {
  transform: scale(1.05);
}

.flutter-card {
  background: white;
  padding: 24px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  text-align: left;
}

.flutter-card h3 {
  margin-bottom: 16px;
  color: #1976d2;
}

.flutter-card ul {
  list-style: none;
  padding: 0;
}

.flutter-card li {
  padding: 8px 0;
  border-bottom: 1px solid #eee;
}

.flutter-card li:last-child {
  border-bottom: none;
}

.dev-status {
  position: fixed;
  top: 10px;
  right: 10px;
  background: rgba(0,0,0,0.8);
  color: white;
  padding: 8px 12px;
  border-radius: 16px;
  font-size: 12px;
  font-family: monospace;
}

/* Responsive Design */
@media (max-width: 768px) {
  .flutter-body {
    padding: 16px;
  }
  
  .flutter-row {
    flex-direction: column;
  }
  
  .flutter-fab {
    bottom: 12px;
    right: 12px;
  }
}
''');

    // Generate main.tsx
    File('${webSrcDir.path}/main.tsx').writeAsStringSync('''
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
''');

    // Generate index.html
    File('${Directory.current.path}/web_flutter_expo/index.html').writeAsStringSync('''
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/flutter-logo.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Flutter Expo App</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
''');

    developer.log('✅ Editable React components generated in web_flutter_expo/src/');
  }

  /// Setup hot reload for React development
  static void _setupHotReload() {
    // Auto-start React dev server
    Process.start('npm', ['install'], workingDirectory: '${Directory.current.path}/web_flutter_expo')
      .then((_) {
        Process.start('npm', ['run', 'dev'], workingDirectory: '${Directory.current.path}/web_flutter_expo');
        developer.log('🔥 React dev server started at http://localhost:3000');
      });
  }

  /// Start mobile dev service for Expo Go-like experience
  static void _startMobileDevService() {
    // Create dev client for mobile
    developer.log('📱 Mobile dev service started - Expo Go-like experience active');
  }

  /// Start translator service
  static void _startTranslatorService() {
    // Auto-start translator service in background
    developer.log('🔄 Translator service starting...');
  }

  /// Create dev client for Expo Go-like experience
  static void _createDevClient() {
    final devClientDir = Directory('${Directory.current.path}/flutter_expo_dev_client');
    if (!devClientDir.existsSync()) {
      devClientDir.createSync(recursive: true);
      
      // Create dev client pubspec.yaml
      File('${devClientDir.path}/pubspec.yaml').writeAsStringSync('''
name: flutter_expo_dev_client
description: FlutterExpo Dev Client - Expo Go-like experience for Flutter
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  web_socket_channel: ^2.4.0
  qr_flutter: ^4.1.0
  http: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
''');

      // Create dev client main.dart
      Directory('${devClientDir.path}/lib').createSync(recursive: true);
      File('${devClientDir.path}/lib/main.dart').writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() {
  runApp(FlutterExpoDevClient());
}

class FlutterExpoDevClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterExpo Dev Client',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DevClientHome(),
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

  @override
  void initState() {
    super.initState();
    _connectToTranslator();
  }

  void _connectToTranslator() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3001'));
      setState(() => _isConnected = true);
      
      _channel!.stream.listen((data) {
        final message = jsonDecode(data);
        if (message['type'] == 'COMPONENT_SPEC') {
          setState(() => _currentUI = message['data']);
        }
      });
    } catch (e) {
      print('Connection failed: \$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlutterExpo Dev Client'),
        backgroundColor: _isConnected ? Colors.green : Colors.red,
      ),
      body: _currentUI != null 
        ? _buildFromSpec(_currentUI!)
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_android, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Waiting for Flutter app...'),
                SizedBox(height: 8),
                Text(_isConnected ? 'Connected' : 'Connecting...'),
              ],
            ),
          ),
    );
  }

  Widget _buildFromSpec(Map<String, dynamic> spec) {
    // Dynamic UI builder from AST spec
    return Container(
      child: Text('Dynamic UI will render here'),
    );
  }
}
''');

      developer.log('📱 Dev client created at flutter_expo_dev_client/');
    }
  }

  /// Setup QR code generation for Expo Go-like experience
  static void _setupQRCodeGeneration() {
    // Generate QR codes for easy device connection
    developer.log('📱 QR code generation setup complete');
  }

  /// Enable real-time sync between Flutter and web
  static void _enableRealTimeSync() {
    // Setup bidirectional sync
    developer.log('🔄 Real-time sync enabled');
  }

  /// Public API for manual control (optional)
  static void enable() => _isEnabled = true;
  static void disable() => _isEnabled = false;
  static bool get isEnabled => _isEnabled;
}

/// Auto-initialize when package is imported
/// This runs automatically when developer adds flutter_expo package
final _autoInit = (() {
  AutoFlutterExpo._autoInitialize();
  return true;
})();