"use strict";
/**
 * UI AST to React Component Translator
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.UITranslator = void 0;
class UITranslator {
    constructor() {
        this.componentMappings = [
            {
                flutterType: 'Scaffold',
                reactType: 'div',
                styleMapping: {
                    'display': 'display',
                    'flexDirection': 'flexDirection',
                    'minHeight': 'minHeight',
                    'backgroundColor': 'backgroundColor'
                },
                defaultProps: { className: 'flutter-scaffold' }
            },
            {
                flutterType: 'AppBar',
                reactType: 'header',
                styleMapping: {
                    'backgroundColor': 'backgroundColor',
                    'color': 'color',
                    'padding': 'padding',
                    'display': 'display',
                    'alignItems': 'alignItems',
                    'minHeight': 'minHeight'
                },
                defaultProps: { className: 'flutter-appbar' }
            },
            {
                flutterType: 'FloatingActionButton',
                reactType: 'button',
                propMapping: { 'enabled': 'disabled' },
                styleMapping: {
                    'position': 'position',
                    'bottom': 'bottom',
                    'right': 'right',
                    'width': 'width',
                    'height': 'height',
                    'borderRadius': 'borderRadius',
                    'backgroundColor': 'backgroundColor',
                    'border': 'border',
                    'cursor': 'cursor',
                    'display': 'display',
                    'alignItems': 'alignItems',
                    'justifyContent': 'justifyContent'
                },
                defaultProps: { className: 'flutter-fab' }
            },
            {
                flutterType: 'Text',
                reactType: 'span',
                propMapping: { 'data': 'children' },
                styleMapping: {
                    'fontSize': 'fontSize',
                    'color': 'color',
                    'fontWeight': 'fontWeight',
                    'fontStyle': 'fontStyle'
                },
                defaultProps: { className: 'flutter-text' }
            },
            {
                flutterType: 'Button',
                reactType: 'button',
                propMapping: { 'enabled': 'disabled' },
                styleMapping: {
                    'backgroundColor': 'backgroundColor',
                    'color': 'color',
                    'padding': 'padding',
                    'borderRadius': 'borderRadius',
                    'border': 'border',
                    'cursor': 'cursor'
                },
                defaultProps: { type: 'button', className: 'flutter-button' }
            },
            {
                flutterType: 'Container',
                reactType: 'div',
                styleMapping: {
                    'backgroundColor': 'backgroundColor',
                    'padding': 'padding',
                    'margin': 'margin',
                    'width': 'width',
                    'height': 'height',
                    'borderRadius': 'borderRadius'
                },
                defaultProps: { className: 'flutter-container' }
            },
            {
                flutterType: 'Row',
                reactType: 'div',
                styleMapping: {
                    'display': 'display',
                    'flexDirection': 'flexDirection',
                    'justifyContent': 'justifyContent',
                    'alignItems': 'alignItems'
                },
                defaultProps: { className: 'flutter-row' }
            },
            {
                flutterType: 'Column',
                reactType: 'div',
                styleMapping: {
                    'display': 'display',
                    'flexDirection': 'flexDirection',
                    'justifyContent': 'justifyContent',
                    'alignItems': 'alignItems'
                },
                defaultProps: { className: 'flutter-column' }
            }
        ];
    }
    /**
     * Translate Flutter UI AST to React Component Specification
     */
    translateUIAST(document) {
        return this.translateNode(document.tree);
    }
    /**
     * Translate a single UI AST node to React component spec
     */
    translateNode(node) {
        const mapping = this.componentMappings.find(m => m.flutterType === node.type);
        if (!mapping) {
            console.warn(`No mapping found for Flutter type: ${node.type}`);
            return {
                type: 'div',
                props: { className: `unknown-${node.type.toLowerCase()}` },
                children: node.children?.map(child => this.translateNode(child))
            };
        }
        const reactSpec = {
            type: mapping.reactType,
            props: this.translateProps(node.props, mapping),
            style: this.translateStyle(node.style, mapping),
            children: node.children?.map(child => this.translateNode(child))
        };
        // Handle text content
        if (node.text && mapping.flutterType === 'Text') {
            reactSpec.props.children = node.text;
        }
        // Handle button disabled state (Flutter enabled -> React disabled)
        if (mapping.flutterType === 'Button' && node.props.enabled !== undefined) {
            reactSpec.props.disabled = !node.props.enabled;
        }
        return reactSpec;
    }
    /**
     * Translate Flutter props to React props
     */
    translateProps(flutterProps, mapping) {
        const reactProps = { ...mapping.defaultProps };
        if (mapping.propMapping) {
            for (const [flutterProp, reactProp] of Object.entries(mapping.propMapping)) {
                if (flutterProps[flutterProp] !== undefined) {
                    reactProps[reactProp] = flutterProps[flutterProp];
                }
            }
        }
        // Copy unmapped props directly
        for (const [key, value] of Object.entries(flutterProps)) {
            if (!mapping.propMapping || !mapping.propMapping[key]) {
                reactProps[key] = value;
            }
        }
        return reactProps;
    }
    /**
     * Translate Flutter styles to React CSS styles
     */
    translateStyle(flutterStyle, mapping) {
        if (!flutterStyle || !mapping.styleMapping)
            return flutterStyle;
        const reactStyle = {};
        for (const [flutterStyleProp, reactStyleProp] of Object.entries(mapping.styleMapping)) {
            if (flutterStyle[flutterStyleProp] !== undefined) {
                reactStyle[reactStyleProp] = flutterStyle[flutterStyleProp];
            }
        }
        // Copy unmapped styles directly
        for (const [key, value] of Object.entries(flutterStyle)) {
            if (!mapping.styleMapping[key]) {
                reactStyle[key] = value;
            }
        }
        return reactStyle;
    }
}
exports.UITranslator = UITranslator;
//# sourceMappingURL=ui-translator.js.map