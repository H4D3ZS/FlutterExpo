# FlutterExpo Project Structure

This document describes the project structure and setup for the FlutterExpo platform.

## Project Structure

```
├── flutter_expo_wrappers/          # Flutter wrapper widgets package
│   ├── lib/
│   │   ├── src/
│   │   │   ├── core/               # Core functionality
│   │   │   │   ├── ui_ast.dart     # UI AST data structures
│   │   │   │   └── websocket_emitter.dart  # WebSocket communication
│   │   │   └── widgets/            # FlutterExpo wrapper widgets
│   │   │       ├── t_text.dart     # Text wrapper
│   │   │       ├── t_button.dart   # Button wrapper
│   │   │       ├── t_container.dart # Container wrapper
│   │   │       ├── t_image.dart    # Image wrapper
│   │   │       ├── t_row.dart      # Row wrapper
│   │   │       └── t_column.dart   # Column wrapper
│   │   └── flutter_expo_wrappers.dart  # Main library export
│   └── pubspec.yaml                # Flutter package configuration
│
├── translator_service/             # Backend translator service
│   ├── src/
│   │   ├── types/                  # TypeScript type definitions
│   │   │   ├── ui-ast.ts          # UI AST interfaces
│   │   │   ├── react-components.ts # React component specs
│   │   │   ├── websocket-messages.ts # WebSocket message types
│   │   │   └── translation.ts      # Translation system types
│   │   └── index.ts               # Main service entry point
│   ├── package.json               # Node.js dependencies
│   └── tsconfig.json              # TypeScript configuration
│
└── react_renderer/                # React web renderer
    ├── src/
    │   ├── types/                 # TypeScript type definitions
    │   │   ├── ui-ast.ts         # UI AST interfaces
    │   │   ├── react-components.ts # React component types
    │   │   └── websocket-messages.ts # WebSocket message types
    │   ├── App.tsx               # Main React application
    │   ├── App.css               # Application styles
    │   ├── main.tsx              # React entry point
    │   └── index.css             # Global styles
    ├── index.html                # HTML template
    ├── package.json              # React dependencies
    ├── tsconfig.json             # TypeScript configuration
    ├── tsconfig.node.json        # Node TypeScript configuration
    └── vite.config.ts            # Vite build configuration
```

## Development Environment Setup

### Prerequisites

- Flutter SDK (>=3.0.0)
- Node.js (>=18.0.0)
- npm or yarn
- Redis (for translation caching)

### Flutter Wrapper Package

```bash
cd flutter_expo_wrappers
flutter pub get
```

### Translator Service

```bash
cd translator_service
npm install
npm run build
npm run dev  # Development mode
```

### React Renderer

```bash
cd react_renderer
npm install
npm run dev  # Development mode
```

## Core Interfaces

### UI AST Structure

The UI AST (Abstract Syntax Tree) is the core data structure that represents Flutter UI in a platform-agnostic format:

- **UIASTNode**: Individual UI component representation
- **UIASTDocument**: Complete screen representation with metadata
- **EventBinding**: User interaction event definitions
- **AssetReference**: Media and resource references

### WebSocket Communication

Real-time communication between components uses structured WebSocket messages:

- **UI_UPDATE**: Full UI tree updates from Flutter
- **STATE_DELTA**: Incremental state changes
- **EVENT**: User interaction events from web
- **COMPONENT_SPEC**: React component specifications to web

### Translation System

Multi-language support through configurable translation providers:

- **TranslationEntry**: Cached translation data
- **TranslationProvider**: Abstract translation service interface
- **TranslationConfig**: System configuration

## Next Steps

1. Implement Flutter runtime instrumentation (Task 2)
2. Build translator service core functionality (Task 3)
3. Implement translation and localization system (Task 4)
4. Create React renderer and web client (Task 5)
5. Implement SSR engine for SEO optimization (Task 6)

## Development Workflow

1. Start the translator service: `cd translator_service && npm run dev`
2. Start the React renderer: `cd react_renderer && npm run dev`
3. Integrate Flutter wrapper package in your Flutter app
4. Use TText, TButton, TContainer, etc. instead of standard Flutter widgets
5. Connect to translator service WebSocket endpoint

The system is designed to be incrementally adoptable - you can start by wrapping individual widgets and gradually expand coverage.