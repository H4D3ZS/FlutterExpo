"use strict";
/**
 * Main entry point for the FlutterExpo Translator Service
 */
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const http_1 = require("http");
const ws_1 = require("ws");
const ui_translator_1 = require("./services/ui-translator");
const websocket_messages_1 = require("./types/websocket-messages");
const app = (0, express_1.default)();
const server = (0, http_1.createServer)(app);
const wss = new ws_1.WebSocketServer({ server });
const uiTranslator = new ui_translator_1.UITranslator();
const PORT = process.env.PORT || 3001;
// Store connected clients and app state
const clients = new Map();
let currentAppConfig = null;
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
        type: websocket_messages_1.MessageType.CONNECTION_ACK,
        timestamp: new Date().toISOString(),
        data: {
            sessionId,
            supportedFeatures: ['ui-translation', 'real-time-updates', 'multi-language']
        }
    };
    ws.send(JSON.stringify(ackMessage));
    ws.on('message', (data) => {
        try {
            const message = JSON.parse(data.toString());
            handleMessage(message, sessionId);
        }
        catch (error) {
            console.error('Error parsing WebSocket message:', error);
            sendError(sessionId, 'PARSE_ERROR', 'Invalid JSON message');
        }
    });
    ws.on('close', () => {
        console.log(`WebSocket connection closed: ${sessionId}`);
        clients.delete(sessionId);
    });
});
function handleMessage(message, sessionId) {
    console.log(`Received message type: ${message.type} from session: ${sessionId}`);
    switch (message.type) {
        case 'APP_CONFIG':
            handleAppConfig(message, sessionId);
            break;
        case websocket_messages_1.MessageType.UI_UPDATE:
            handleUIUpdate(message, sessionId);
            break;
        case websocket_messages_1.MessageType.PING:
            sendPong(sessionId);
            break;
        default:
            console.log(`Unhandled message type: ${message.type}`);
    }
}
function handleAppConfig(message, sessionId) {
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
    }
    catch (error) {
        console.error('Error handling app config:', error);
        sendError(sessionId, 'APP_CONFIG_ERROR', 'Failed to process app configuration');
    }
}
function handleUIUpdate(message, sessionId) {
    try {
        console.log('Translating UI AST to React components...');
        // Translate Flutter UI AST to React component specification
        const reactComponents = uiTranslator.translateUIAST(message.data);
        // Create component specification message with app context
        const componentSpecMessage = {
            type: websocket_messages_1.MessageType.COMPONENT_SPEC,
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
        // Broadcast to all connected React renderers
        broadcastToRenderers(componentSpecMessage);
        console.log(`UI translated and broadcasted for screen: ${message.data.screenId}`);
    }
    catch (error) {
        console.error('Error translating UI:', error);
        sendError(sessionId, 'TRANSLATION_ERROR', 'Failed to translate UI AST');
    }
}
function broadcastToRenderers(message) {
    const messageStr = JSON.stringify(message);
    clients.forEach((ws) => {
        if (ws.readyState === ws.OPEN) {
            ws.send(messageStr);
        }
    });
}
function sendError(sessionId, code, message) {
    const client = clients.get(sessionId);
    if (client && client.readyState === client.OPEN) {
        const errorMessage = {
            type: websocket_messages_1.MessageType.ERROR,
            timestamp: new Date().toISOString(),
            data: { code, message }
        };
        client.send(JSON.stringify(errorMessage));
    }
}
function sendPong(sessionId) {
    const client = clients.get(sessionId);
    if (client && client.readyState === client.OPEN) {
        const pongMessage = {
            type: websocket_messages_1.MessageType.PONG,
            timestamp: new Date().toISOString()
        };
        client.send(JSON.stringify(pongMessage));
    }
}
function generateSessionId() {
    return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
}
server.listen(PORT, () => {
    console.log(`FlutterExpo Translator Service running on port ${PORT}`);
    console.log(`WebSocket server ready for Flutter and React connections`);
});
exports.default = app;
//# sourceMappingURL=index.js.map