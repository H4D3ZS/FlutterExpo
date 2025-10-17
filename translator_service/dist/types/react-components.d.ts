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
    style?: Record<string, any>;
}
export interface ComponentMapping {
    flutterType: string;
    reactType: string;
    propMapping?: Record<string, string>;
    styleMapping?: Record<string, string>;
    defaultProps?: Record<string, any>;
}
export interface WidgetMappingConfig {
    mappings: ComponentMapping[];
    fallbackComponent: string;
}
//# sourceMappingURL=react-components.d.ts.map