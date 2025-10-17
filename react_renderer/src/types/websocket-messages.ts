/**
 * WebSocket message types for React renderer
 */

import { ReactComponentSpec } from './react-components';

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

export interface EventMessage extends BaseMessage {
  type: MessageType.EVENT;
  data: {
    componentId: string;
    event: string;
    data: Record<string, any>;
    timestamp: string;
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

export type WebSocketMessage = 
  | ComponentSpecMessage
  | EventMessage
  | ConnectionAckMessage
  | ErrorMessage;