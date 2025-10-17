"use strict";
/**
 * WebSocket message type definitions
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.MessageType = void 0;
var MessageType;
(function (MessageType) {
    MessageType["UI_UPDATE"] = "UI_UPDATE";
    MessageType["STATE_DELTA"] = "STATE_DELTA";
    MessageType["EVENT"] = "EVENT";
    MessageType["COMPONENT_SPEC"] = "COMPONENT_SPEC";
    MessageType["CONNECTION_ACK"] = "CONNECTION_ACK";
    MessageType["ERROR"] = "ERROR";
    MessageType["PING"] = "PING";
    MessageType["PONG"] = "PONG";
})(MessageType || (exports.MessageType = MessageType = {}));
//# sourceMappingURL=websocket-messages.js.map