/**
 * WebSocket message type definitions
 */

import { UIASTDocument, StateChange, UIEvent } from './ui-ast.js';
import { ReactComponentSpec } from './react-components.js';

export enum MessageType {
  UI_UPDATE = 'UI_UPDATE',
  STATE_DELTA = 'STATE_DELTA',
  EVENT = 'EVENT',
  COMPONENT_SPEC = 'COMPONENT_SPEC',
  CONNECTION_ACK = 'CONNECTION_ACK',
  ERROR = 'ERROR',
  PING = 'PING',
  PONG = 'PONG'
}

export interface BaseMessage {
  type: MessageType;
  timestamp: string;
  sessionId?: string;
}

export interface UIUpdateMessage extends BaseMessage {
  type: MessageType.UI_UPDATE;
  data: UIASTDocument;
}

export interface StateDeltaMessage extends BaseMessage {
  type: MessageType.STATE_DELTA;
  data: {
    screenId: string;
    changes: StateChange[];
  };
}

export interface EventMessage extends BaseMessage {
  type: MessageType.EVENT;
  data: UIEvent;
}

export interface ComponentSpecMessage extends BaseMessage {
  type: MessageType.COMPONENT_SPEC;
  data: {
    screenId: string;
    route: string;
    language: string;
    components: ReactComponentSpec;
    timestamp: string;
    appConfig?: any;
  };
}

export interface ConnectionAckMessage extends BaseMessage {
  type: MessageType.CONNECTION_ACK;
  data: {
    sessionId: string;
    supportedFeatures: string[];
  };
}

export interface ErrorMessage extends BaseMessage {
  type: MessageType.ERROR;
  data: {
    code: string;
    message: string;
    details?: Record<string, any>;
  };
}

export interface PingMessage extends BaseMessage {
  type: MessageType.PING;
  data?: Record<string, any>;
}

export interface PongMessage extends BaseMessage {
  type: MessageType.PONG;
  data?: Record<string, any>;
}

export type WebSocketMessage = 
  | UIUpdateMessage
  | StateDeltaMessage
  | EventMessage
  | ComponentSpecMessage
  | ConnectionAckMessage
  | ErrorMessage
  | PingMessage
  | PongMessage;