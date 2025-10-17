/**
 * UI AST to React Component Translator
 */
import { UIASTDocument } from '../types/ui-ast';
import { ReactComponentSpec } from '../types/react-components';
export declare class UITranslator {
    private componentMappings;
    /**
     * Translate Flutter UI AST to React Component Specification
     */
    translateUIAST(document: UIASTDocument): ReactComponentSpec;
    /**
     * Translate a single UI AST node to React component spec
     */
    private translateNode;
    /**
     * Translate Flutter props to React props
     */
    private translateProps;
    /**
     * Translate Flutter styles to React CSS styles
     */
    private translateStyle;
}
//# sourceMappingURL=ui-translator.d.ts.map