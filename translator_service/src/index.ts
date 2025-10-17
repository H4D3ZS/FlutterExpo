/**
 * Main entry point for the FlutterExpo Translator Service
 */

import express from 'express';
import { createServer } from 'http';
import { WebSocketServer } from 'ws';
import { UITranslator } from './services/ui-translator';
import { ReactCodeGenerator } from './services/react-code-generator';
import { WebSocketMessage, MessageType, UIUpdateMessage, ComponentSpecMessage } from './types/websocket-messages';
import { AppConfig, AppConfigMessage } from './types/app-config';

const app = express();
const server = createServer(app);
const wss = new WebSocketServer({ server });
const uiTranslator = new UITranslator();
const reactCodeGenerator = new ReactCodeGenerator('./generated_react_app');

const PORT = process.env.PORT || 3001;

// Store connected clients and app state
const clients = new Map<string, any>();
let currentAppConfig: AppConfig | null = null;

// Basic health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// WebSocket connection handling
wss.on('connection', (ws) => {
  const sessionId = generateSessionId();
  clients.set(sessionId, ws);
  
  console.log(`New WebSocket connection established: ${sessionId}`);
  
  // Send connection acknowledgment
  const ackMessage = {
    type: MessageType.CONNECTION_ACK,
    timestamp: new Date().toISOString(),
    data: {
      sessionId,
      supportedFeatures: ['ui-translation', 'real-time-updates', 'multi-language']
    }
  };
  
  ws.send(JSON.stringify(ackMessage));
  
  ws.on('message', (data) => {
    try {
      const message: WebSocketMessage = JSON.parse(data.toString());
      handleMessage(message, sessionId);
    } catch (error) {
      console.error('Error parsing WebSocket message:', error);
      sendError(sessionId, 'PARSE_ERROR', 'Invalid JSON message');
    }
  });
  
  ws.on('close', () => {
    console.log(`WebSocket connection closed: ${sessionId}`);
    clients.delete(sessionId);
  });
});

function handleMessage(message: any, sessionId: string) {
  console.log(`Received message type: ${message.type} from session: ${sessionId}`);
  
  switch (message.type) {
    case 'APP_CONFIG':
      handleAppConfig(message as AppConfigMessage, sessionId);
      break;
    case MessageType.UI_UPDATE:
      handleUIUpdate(message as UIUpdateMessage, sessionId);
      break;
    case MessageType.PING:
      sendPong(sessionId);
      break;
    default:
      console.log(`Unhandled message type: ${message.type}`);
  }
}

function handleAppConfig(message: AppConfigMessage, sessionId: string) {
  try {
    console.log('Received app configuration...');
    currentAppConfig = message.data;
    
    // Broadcast app config to all React renderers
    const appConfigMessage = {
      type: 'APP_CONFIG',
      timestamp: new Date().toISOString(),
      sessionId,
      data: currentAppConfig
    };
    
    broadcastToRenderers(appConfigMessage);
    console.log(`App configuration broadcasted: ${currentAppConfig.title}`);
  } catch (error) {
    console.error('Error handling app config:', error);
    sendError(sessionId, 'APP_CONFIG_ERROR', 'Failed to process app configuration');
  }
}

function handleUIUpdate(message: UIUpdateMessage, sessionId: string) {
  try {
    console.log('🎨 Translating Flutter UI to React...');
    
    // 1. Translate Flutter UI AST to React component specification (runtime)
    const reactComponents = uiTranslator.translateUIAST(message.data);
    
    // 2. Generate editable React source code files
    reactCodeGenerator.generateReactApp(message.data);
    
    // 3. Create component specification message with app context
    const componentSpecMessage: ComponentSpecMessage = {
      type: MessageType.COMPONENT_SPEC,
      timestamp: new Date().toISOString(),
      sessionId,
      data: {
        screenId: message.data.screenId,
        route: message.data.route,
        language: message.data.language,
        components: reactComponents,
        timestamp: new Date().toISOString(),
        appConfig: currentAppConfig
      }
    };
    
    // 4. Broadcast to all connected React renderers
    broadcastToRenderers(componentSpecMessage);
    
    console.log(`✅ UI translated and React code generated for screen: ${message.data.screenId}`);
    console.log(`📁 Editable React files available at: ./generated_react_app/src/`);
  } catch (error) {
    console.error('Error translating UI:', error);
    sendError(sessionId, 'TRANSLATION_ERROR', 'Failed to translate UI AST');
  }
}

function broadcastToRenderers(message: any) {
  const messageStr = JSON.stringify(message);
  
  clients.forEach((ws) => {
    if (ws.readyState === ws.OPEN) {
      ws.send(messageStr);
    }
  });
}

function sendError(sessionId: string, code: string, message: string) {
  const client = clients.get(sessionId);
  if (client && client.readyState === client.OPEN) {
    const errorMessage = {
      type: MessageType.ERROR,
      timestamp: new Date().toISOString(),
      data: { code, message }
    };
    client.send(JSON.stringify(errorMessage));
  }
}

function sendPong(sessionId: string) {
  const client = clients.get(sessionId);
  if (client && client.readyState === client.OPEN) {
    const pongMessage = {
      type: MessageType.PONG,
      timestamp: new Date().toISOString()
    };
    client.send(JSON.stringify(pongMessage));
  }
}

function generateSessionId(): string {
  return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
}

server.listen(PORT, () => {
  console.log(`FlutterExpo Translator Service running on port ${PORT}`);
  console.log(`WebSocket server ready for Flutter and React connections`);
});

export default app;