library flutter_expo_wrappers;

// Auto-initialize FlutterExpo when package is imported
export 'src/core/auto_flutter_expo.dart';

// Core functionality (automatically handled)
export 'src/core/ui_ast.dart';
export 'src/core/websocket_emitter.dart';
export 'src/core/flutter_expo_app.dart';
export 'src/core/universal_interceptor.dart';

// Optional wrapper widgets (not required for auto-mode)
export 'src/widgets/t_text.dart';
export 'src/widgets/t_button.dart';
export 'src/widgets/t_container.dart';
export 'src/widgets/t_image.dart';
export 'src/widgets/t_row.dart';
export 'src/widgets/t_column.dart';