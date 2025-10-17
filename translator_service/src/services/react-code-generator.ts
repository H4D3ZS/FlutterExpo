/**
 * React Code Generator - Generates editable React/TypeScript source files
 * This creates actual React components that developers can edit
 */

import { UIASTDocument, UIASTNode } from '../types/ui-ast';
import { ReactComponentSpec } from '../types/react-components';
import * as fs from 'fs';
import * as path from 'path';

export class ReactCodeGenerator {
  private outputDir: string;
  private generatedComponents: Map<string, string> = new Map();

  constructor(outputDir: string = './generated_react_app') {
    this.outputDir = outputDir;
    this.ensureOutputDirectory();
  }

  /**
   * Generate complete React application from Flutter UI AST
   */
  generateReactApp(document: UIASTDocument): void {
    console.log(`🎨 Generating React app for screen: ${document.screenId}`);
    
    // Generate screen component
    const screenComponent = this.generateScreenComponent(document);
    this.writeScreenComponent(document.screenId, document.route, screenComponent);
    
    // Update routing
    this.updateAppRouting(document.screenId, document.route);
    
    // Generate styles
    this.generateStyles(document);
    
    console.log(`✅ React app generated at ${this.outputDir}`);
  }

  /**
   * Generate a complete React screen component
   */
  private generateScreenComponent(document: UIASTDocument): string {
    const componentName = this.getComponentName(document.screenId);
    const reactCode = this.generateReactCode(document.tree, 0);
    
    return `import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './styles/${componentName}.css';

export const ${componentName}: React.FC = () => {
  const navigate = useNavigate();
  
  // State management (auto-generated from Flutter state)
  ${this.generateStateHooks(document.state)}
  
  // Event handlers (auto-generated from Flutter events)
  ${this.generateEventHandlers(document.events)}
  
  // Effects for real-time sync
  useEffect(() => {
    // Connect to FlutterExpo for real-time updates
    const ws = new WebSocket('ws://localhost:3001');
    
    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      if (message.type === 'STATE_UPDATE' && message.screenId === '${document.screenId}') {
        // Update state from Flutter app
        ${this.generateStateUpdaters(document.state)}
      }
    };
    
    return () => ws.close();
  }, []);

  return (
    <div className="${this.getCSSClassName(document.screenId)}">
      ${reactCode}
    </div>
  );
};

export default ${componentName};
`;
  }

  /**
   * Generate React JSX code from UI AST node
   */
  private generateReactCode(node: UIASTNode, depth: number): string {
    const indent = '  '.repeat(depth + 3); // Base indentation for JSX
    const tag = this.getReactTag(node.type);
    const props = this.generateProps(node);
    const styles = this.generateInlineStyles(node.style);
    
    let jsx = `${indent}<${tag}`;
    
    // Add props
    if (props) {
      jsx += ` ${props}`;
    }
    
    // Add styles
    if (styles) {
      jsx += ` style={${styles}}`;
    }
    
    // Add CSS class
    jsx += ` className="${this.getCSSClassName(node.type)}"`;
    
    // Handle children
    if (node.children && node.children.length > 0) {
      jsx += '>\n';
      
      // Generate children
      for (const child of node.children) {
        jsx += this.generateReactCode(child, depth + 1) + '\n';
      }
      
      jsx += `${indent}</${tag}>`;
    } else if (node.text) {
      jsx += `>\n${indent}  {${JSON.stringify(node.text)}}\n${indent}</${tag}>`;
    } else {
      jsx += ' />';
    }
    
    return jsx;
  }

  /**
   * Generate React props from Flutter props
   */
  private generateProps(node: UIASTNode): string {
    const props: string[] = [];
    
    // Handle common props
    if (node.id) {
      props.push(`id="${node.id}"`);
    }
    
    // Handle specific widget props
    switch (node.type) {
      case 'Button':
      case 'ElevatedButton':
      case 'TextButton':
      case 'OutlinedButton':
        if (node.props.disabled !== undefined) {
          props.push(`disabled={${node.props.disabled}}`);
        }
        props.push(`onClick={handleButtonClick}`);
        break;
        
      case 'TextField':
        props.push(`onChange={handleTextChange}`);
        if (node.props.placeholder) {
          props.push(`placeholder="${node.props.placeholder}"`);
        }
        break;
        
      case 'Image':
        if (node.props.src) {
          props.push(`src="${node.props.src}"`);
        }
        if (node.props.alt) {
          props.push(`alt="${node.props.alt}"`);
        }
        break;
    }
    
    return props.join(' ');
  }

  /**
   * Generate inline styles object
   */
  private generateInlineStyles(style?: Record<string, any>): string | null {
    if (!style || Object.keys(style).length === 0) return null;
    
    const styleEntries = Object.entries(style).map(([key, value]) => {
      const camelKey = this.toCamelCase(key);
      const cssValue = typeof value === 'string' ? `'${value}'` : value;
      return `${camelKey}: ${cssValue}`;
    });
    
    return `{${styleEntries.join(', ')}}`;
  }

  /**
   * Generate state hooks from Flutter state
   */
  private generateStateHooks(state: Record<string, any>): string {
    const hooks: string[] = [];
    
    for (const [key, value] of Object.entries(state)) {
      const initialValue = typeof value === 'string' ? `'${value}'` : value;
      hooks.push(`const [${key}, set${this.capitalize(key)}] = useState(${initialValue});`);
    }
    
    return hooks.join('\n  ');
  }

  /**
   * Generate event handlers
   */
  private generateEventHandlers(events: any[]): string {
    const handlers: string[] = [];
    
    // Common handlers
    handlers.push(`const handleButtonClick = (event: React.MouseEvent) => {
    // Send event to Flutter app
    console.log('Button clicked:', event.currentTarget.id);
  };`);
  
  handlers.push(`const handleTextChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    // Send text change to Flutter app
    console.log('Text changed:', event.target.value);
  };`);
    
    return handlers.join('\n\n  ');
  }

  /**
   * Generate state updaters
   */
  private generateStateUpdaters(state: Record<string, any>): string {
    const updaters: string[] = [];
    
    for (const key of Object.keys(state)) {
      updaters.push(`if (message.state.${key} !== undefined) set${this.capitalize(key)}(message.state.${key});`);
    }
    
    return updaters.join('\n        ');
  }

  /**
   * Write screen component to file
   */
  private writeScreenComponent(screenId: string, route: string, componentCode: string): void {
    const componentName = this.getComponentName(screenId);
    const screensDir = path.join(this.outputDir, 'src', 'screens');
    
    if (!fs.existsSync(screensDir)) {
      fs.mkdirSync(screensDir, { recursive: true });
    }
    
    const filePath = path.join(screensDir, `${componentName}.tsx`);
    fs.writeFileSync(filePath, componentCode);
    
    console.log(`📄 Generated ${componentName}.tsx`);
  }

  /**
   * Update App.tsx routing
   */
  private updateAppRouting(screenId: string, route: string): void {
    const componentName = this.getComponentName(screenId);
    const appPath = path.join(this.outputDir, 'src', 'App.tsx');
    
    // Read existing App.tsx or create new one
    let appContent = '';
    if (fs.existsSync(appPath)) {
      appContent = fs.readFileSync(appPath, 'utf-8');
    } else {
      appContent = this.generateBaseAppComponent();
    }
    
    // Add import if not exists
    const importLine = `import { ${componentName} } from './screens/${componentName}';`;
    if (!appContent.includes(importLine)) {
      const importSection = appContent.match(/(import.*from.*;\n)+/)?.[0] || '';
      appContent = appContent.replace(importSection, importSection + importLine + '\n');
    }
    
    // Add route if not exists
    const routeLine = `            <Route path="${route}" element={<${componentName} />} />`;
    if (!appContent.includes(routeLine)) {
      const routesSection = appContent.indexOf('</Routes>');
      if (routesSection !== -1) {
        appContent = appContent.slice(0, routesSection) + 
                   routeLine + '\n' + 
                   appContent.slice(routesSection);
      }
    }
    
    fs.writeFileSync(appPath, appContent);
    console.log(`🔄 Updated routing for ${route}`);
  }

  /**
   * Generate styles for the component
   */
  private generateStyles(document: UIASTDocument): void {
    const componentName = this.getComponentName(document.screenId);
    const stylesDir = path.join(this.outputDir, 'src', 'styles');
    
    if (!fs.existsSync(stylesDir)) {
      fs.mkdirSync(stylesDir, { recursive: true });
    }
    
    const css = this.generateCSSFromAST(document.tree, componentName);
    const filePath = path.join(stylesDir, `${componentName}.css`);
    
    fs.writeFileSync(filePath, css);
    console.log(`🎨 Generated ${componentName}.css`);
  }

  /**
   * Generate CSS from UI AST
   */
  private generateCSSFromAST(node: UIASTNode, componentName: string): string {
    let css = `/* Auto-generated styles for ${componentName} */\n\n`;
    
    css += `.${this.getCSSClassName(componentName)} {\n`;
    css += `  min-height: 100vh;\n`;
    css += `  display: flex;\n`;
    css += `  flex-direction: column;\n`;
    css += `}\n\n`;
    
    // Generate styles for each node type
    css += this.generateNodeStyles(node);
    
    return css;
  }

  /**
   * Generate CSS styles for a node and its children
   */
  private generateNodeStyles(node: UIASTNode): string {
    let css = '';
    
    const className = this.getCSSClassName(node.type);
    css += `.${className} {\n`;
    
    // Convert Flutter styles to CSS
    if (node.style) {
      for (const [key, value] of Object.entries(node.style)) {
        const cssProperty = this.toKebabCase(key);
        css += `  ${cssProperty}: ${value};\n`;
      }
    }
    
    css += `}\n\n`;
    
    // Generate styles for children
    if (node.children) {
      for (const child of node.children) {
        css += this.generateNodeStyles(child);
      }
    }
    
    return css;
  }

  /**
   * Generate base App component
   */
  private generateBaseAppComponent(): string {
    return `import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import './App.css';

function App() {
  return (
    <Router>
      <div className="flutter-expo-app">
        <Routes>
          {/* Routes will be auto-generated here */}
        </Routes>
      </div>
    </Router>
  );
}

export default App;
`;
  }

  /**
   * Ensure output directory exists
   */
  private ensureOutputDirectory(): void {
    if (!fs.existsSync(this.outputDir)) {
      fs.mkdirSync(this.outputDir, { recursive: true });
    }
    
    // Create src directory
    const srcDir = path.join(this.outputDir, 'src');
    if (!fs.existsSync(srcDir)) {
      fs.mkdirSync(srcDir, { recursive: true });
    }
  }

  // Helper methods
  private getReactTag(flutterType: string): string {
    const tagMap: Record<string, string> = {
      'Scaffold': 'div',
      'AppBar': 'header',
      'Container': 'div',
      'Column': 'div',
      'Row': 'div',
      'Text': 'span',
      'Button': 'button',
      'ElevatedButton': 'button',
      'TextButton': 'button',
      'OutlinedButton': 'button',
      'FloatingActionButton': 'button',
      'Image': 'img',
      'TextField': 'input',
      'Icon': 'i'
    };
    
    return tagMap[flutterType] || 'div';
  }

  private getComponentName(screenId: string): string {
    return screenId.split('_').map(this.capitalize).join('') + 'Screen';
  }

  private getCSSClassName(type: string): string {
    return `flutter-${this.toKebabCase(type)}`;
  }

  private capitalize(str: string): string {
    return str.charAt(0).toUpperCase() + str.slice(1);
  }

  private toCamelCase(str: string): string {
    return str.replace(/-([a-z])/g, (g) => g[1].toUpperCase());
  }

  private toKebabCase(str: string): string {
    return str.replace(/([A-Z])/g, '-$1').toLowerCase().replace(/^-/, '');
  }
}