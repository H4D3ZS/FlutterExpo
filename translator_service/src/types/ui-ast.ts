/**
 * Core UI AST interfaces for the translator service
 */

export interface UIASTNode {
  id?: string;
  type: string;
  props: Record<string, any>;
  style?: Record<string, any>;
  children?: UIASTNode[];
  textId?: string;
  text?: string;
}

export interface EventBinding {
  componentId: string;
  event: string;
  action: string;
  parameters?: Record<string, any>;
}

export interface AssetReference {
  id: string;
  type: string;
  url: string;
  metadata?: Record<string, any>;
}

export interface UIASTDocument {
  screenId: string;
  route: string;
  timestamp: string;
  language: string;
  tree: UIASTNode;
  state: Record<string, any>;
  assets: AssetReference[];
  events: EventBinding[];
}

export interface StateChange {
  path: string;
  value: any;
  timestamp: string;
}

export interface UIEvent {
  componentId: string;
  event: string;
  data: Record<string, any>;
  timestamp: string;
}