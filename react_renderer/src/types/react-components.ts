/**
 * React component specification interfaces
 */

export interface EventHandler {
  event: string;
  handler: string;
  parameters?: Record<string, any>;
}

export interface ReactComponentSpec {
  type: string;
  props: Record<string, any>;
  children?: ReactComponentSpec[];
  events?: EventHandler[];
  style?: React.CSSProperties;
}

export interface ComponentRegistryEntry {
  component: React.ComponentType<any>;
  propMapping?: Record<string, string>;
  eventMapping?: Record<string, string>;
}