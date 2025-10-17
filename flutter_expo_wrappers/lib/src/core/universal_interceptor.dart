import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:developer' as developer;
import 'ui_ast.dart';
import 'websocket_emitter.dart';

/// Universal Flutter Widget Interceptor
/// Automatically captures and translates ANY Flutter widget tree
class UniversalFlutterInterceptor {
  static WebSocketEmitter? _emitter;
  static bool _isEnabled = false;
  static String? _currentRoute;
  static Map<String, dynamic> _appConfig = {};

  /// Initialize FlutterExpo for any Flutter app
  static void initialize({
    String wsUrl = 'ws://localhost:3001',
    bool autoStart = true,
  }) {
    _emitter = WebSocketEmitter(wsUrl);
    _isEnabled = true;
    
    if (autoStart) {
      _connectToTranslator();
    }
    
    developer.log('FlutterExpo initialized - automatic web translation enabled');
  }

  static Future<void> _connectToTranslator() async {
    if (_emitter == null) return;
    
    try {
      await _emitter!.connect();
      developer.log('FlutterExpo connected to translator service');
    } catch (e) {
      developer.log('FlutterExpo connection failed: $e');
    }
  }

  /// Capture and translate any widget tree
  static void captureWidgetTree(BuildContext context, Widget widget, {String? route}) {
    if (!_isEnabled || _emitter == null || !_emitter!.isConnected) return;

    try {
      _currentRoute = route ?? ModalRoute.of(context)?.settings.name ?? '/';
      
      // Extract app configuration from MaterialApp if available
      final materialApp = _findMaterialApp(context);
      if (materialApp != null) {
        _extractAppConfig(materialApp);
      }

      // Convert widget tree to UI AST
      final uiDocument = UIASTDocument(
        screenId: _generateScreenId(_currentRoute!),
        route: _currentRoute!,
        timestamp: DateTime.now().toIso8601String(),
        language: Localizations.localeOf(context).languageCode,
        tree: _convertAnyWidget(widget, context),
        state: _extractWidgetState(widget),
        assets: _extractAssets(widget),
        events: _extractEvents(widget),
      );

      _emitter!.emitUIUpdate(uiDocument);
      developer.log('FlutterExpo: Captured screen ${_currentRoute}');
    } catch (e) {
      developer.log('FlutterExpo capture error: $e');
    }
  }

  /// Find MaterialApp in widget tree
  static MaterialApp? _findMaterialApp(BuildContext context) {
    MaterialApp? materialApp;
    context.visitAncestorElements((element) {
      if (element.widget is MaterialApp) {
        materialApp = element.widget as MaterialApp;
        return false;
      }
      return true;
    });
    return materialApp;
  }

  /// Extract app configuration from MaterialApp
  static void _extractAppConfig(MaterialApp app) {
    final newConfig = {
      'title': app.title,
      'theme': _extractThemeData(app.theme),
      'darkTheme': _extractThemeData(app.darkTheme),
      'routes': app.routes?.keys.toList() ?? [],
      'initialRoute': app.initialRoute ?? '/',
      'supportedLocales': app.supportedLocales.map((l) => '${l.languageCode}_${l.countryCode}').toList(),
    };

    // Only emit if config changed
    if (_appConfig.toString() != newConfig.toString()) {
      _appConfig = newConfig;
      _emitter?.emitRawMessage({
        'type': 'APP_CONFIG',
        'timestamp': DateTime.now().toIso8601String(),
        'data': _appConfig,
      });
    }
  }

  /// Convert ANY Flutter widget to UI AST
  static UIASTNode _convertAnyWidget(Widget widget, BuildContext context) {
    // Handle all common Flutter widgets
    switch (widget.runtimeType.toString()) {
      case 'Scaffold':
        return _convertScaffold(widget as Scaffold, context);
      case 'AppBar':
        return _convertAppBar(widget as AppBar, context);
      case 'FloatingActionButton':
        return _convertFAB(widget as FloatingActionButton, context);
      case 'Column':
        return _convertColumn(widget as Column, context);
      case 'Row':
        return _convertRow(widget as Row, context);
      case 'Container':
        return _convertContainer(widget as Container, context);
      case 'Text':
        return _convertText(widget as Text, context);
      case 'ElevatedButton':
      case 'TextButton':
      case 'OutlinedButton':
        return _convertButton(widget, context);
      case 'Image':
        return _convertImage(widget as Image, context);
      case 'Icon':
        return _convertIcon(widget as Icon, context);
      case 'Card':
        return _convertCard(widget as Card, context);
      case 'ListTile':
        return _convertListTile(widget as ListTile, context);
      case 'ListView':
        return _convertListView(widget as ListView, context);
      case 'GridView':
        return _convertGridView(widget as GridView, context);
      case 'Stack':
        return _convertStack(widget as Stack, context);
      case 'Positioned':
        return _convertPositioned(widget as Positioned, context);
      case 'Expanded':
        return _convertExpanded(widget as Expanded, context);
      case 'Flexible':
        return _convertFlexible(widget as Flexible, context);
      case 'Padding':
        return _convertPadding(widget as Padding, context);
      case 'Center':
        return _convertCenter(widget as Center, context);
      case 'Align':
        return _convertAlign(widget as Align, context);
      case 'SizedBox':
        return _convertSizedBox(widget as SizedBox, context);
      case 'TextField':
        return _convertTextField(widget as TextField, context);
      case 'Checkbox':
        return _convertCheckbox(widget as Checkbox, context);
      case 'Switch':
        return _convertSwitch(widget as Switch, context);
      case 'Slider':
        return _convertSlider(widget as Slider, context);
      default:
        return _convertGenericWidget(widget, context);
    }
  }

  // Scaffold conversion
  static UIASTNode _convertScaffold(Scaffold scaffold, BuildContext context) {
    final children = <UIASTNode>[];
    
    if (scaffold.appBar != null) {
      children.add(_convertAnyWidget(scaffold.appBar!, context));
    }
    
    if (scaffold.body != null) {
      children.add(_convertAnyWidget(scaffold.body!, context));
    }
    
    if (scaffold.floatingActionButton != null) {
      children.add(_convertAnyWidget(scaffold.floatingActionButton!, context));
    }
    
    if (scaffold.drawer != null) {
      children.add(_convertDrawer(scaffold.drawer!, context));
    }
    
    if (scaffold.bottomNavigationBar != null) {
      children.add(_convertBottomNavBar(scaffold.bottomNavigationBar!, context));
    }

    return UIASTNode(
      type: 'Scaffold',
      props: {
        'resizeToAvoidBottomInset': scaffold.resizeToAvoidBottomInset ?? true,
      },
      style: {
        'display': 'flex',
        'flexDirection': 'column',
        'minHeight': '100vh',
        'backgroundColor': _colorToHex(scaffold.backgroundColor) ?? '#ffffff',
      },
      children: children,
    );
  }

  // AppBar conversion
  static UIASTNode _convertAppBar(AppBar appBar, BuildContext context) {
    final children = <UIASTNode>[];
    
    if (appBar.title != null) {
      children.add(_convertAnyWidget(appBar.title!, context));
    }
    
    // Add actions
    if (appBar.actions != null) {
      for (final action in appBar.actions!) {
        children.add(_convertAnyWidget(action, context));
      }
    }

    return UIASTNode(
      type: 'AppBar',
      props: {
        'elevation': appBar.elevation ?? 4.0,
        'centerTitle': appBar.centerTitle ?? false,
      },
      style: {
        'backgroundColor': _colorToHex(appBar.backgroundColor) ?? '#2196f3',
        'color': _colorToHex(appBar.foregroundColor) ?? '#ffffff',
        'padding': '0 16px',
        'display': 'flex',
        'alignItems': 'center',
        'justifyContent': 'space-between',
        'minHeight': '56px',
        'boxShadow': '0 2px 4px rgba(0,0,0,0.2)',
      },
      children: children,
    );
  }

  // Button conversion (handles all button types)
  static UIASTNode _convertButton(Widget button, BuildContext context) {
    String buttonType = 'Button';
    Map<String, dynamic> props = {'disabled': false};
    Map<String, dynamic> style = {
      'padding': '12px 24px',
      'borderRadius': '4px',
      'cursor': 'pointer',
      'border': 'none',
      'fontSize': '14px',
      'fontWeight': '500',
    };

    Widget? child;
    VoidCallback? onPressed;

    if (button is ElevatedButton) {
      buttonType = 'ElevatedButton';
      child = button.child;
      onPressed = button.onPressed;
      style.addAll({
        'backgroundColor': '#1976d2',
        'color': 'white',
        'boxShadow': '0 2px 4px rgba(0,0,0,0.2)',
      });
    } else if (button is TextButton) {
      buttonType = 'TextButton';
      child = button.child;
      onPressed = button.onPressed;
      style.addAll({
        'backgroundColor': 'transparent',
        'color': '#1976d2',
      });
    } else if (button is OutlinedButton) {
      buttonType = 'OutlinedButton';
      child = button.child;
      onPressed = button.onPressed;
      style.addAll({
        'backgroundColor': 'transparent',
        'color': '#1976d2',
        'border': '1px solid #1976d2',
      });
    }

    props['disabled'] = onPressed == null;

    return UIASTNode(
      type: buttonType,
      props: props,
      style: style,
      children: child != null ? [_convertAnyWidget(child, context)] : null,
    );
  }

  // Text conversion
  static UIASTNode _convertText(Text text, BuildContext context) {
    return UIASTNode(
      type: 'Text',
      props: {
        'data': text.data ?? '',
        'textAlign': text.textAlign?.toString() ?? 'left',
      },
      style: _convertTextStyle(text.style, context),
      text: text.data,
    );
  }

  // Container conversion
  static UIASTNode _convertContainer(Container container, BuildContext context) {
    final style = <String, dynamic>{};
    
    if (container.width != null) style['width'] = '${container.width}px';
    if (container.height != null) style['height'] = '${container.height}px';
    if (container.color != null) style['backgroundColor'] = _colorToHex(container.color);
    if (container.padding != null) style['padding'] = _convertEdgeInsets(container.padding!);
    if (container.margin != null) style['margin'] = _convertEdgeInsets(container.margin!);
    
    // Handle decoration
    if (container.decoration != null && container.decoration is BoxDecoration) {
      final decoration = container.decoration as BoxDecoration;
      if (decoration.color != null) style['backgroundColor'] = _colorToHex(decoration.color);
      if (decoration.borderRadius != null) {
        style['borderRadius'] = _convertBorderRadius(decoration.borderRadius!);
      }
      if (decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty) {
        style['boxShadow'] = _convertBoxShadow(decoration.boxShadow!);
      }
    }

    return UIASTNode(
      type: 'Container',
      props: {},
      style: style,
      children: container.child != null ? [_convertAnyWidget(container.child!, context)] : null,
    );
  }

  // Column conversion
  static UIASTNode _convertColumn(Column column, BuildContext context) {
    return UIASTNode(
      type: 'Column',
      props: {
        'mainAxisAlignment': column.mainAxisAlignment.toString(),
        'crossAxisAlignment': column.crossAxisAlignment.toString(),
        'mainAxisSize': column.mainAxisSize.toString(),
      },
      style: {
        'display': 'flex',
        'flexDirection': 'column',
        'justifyContent': _mapMainAxisAlignment(column.mainAxisAlignment),
        'alignItems': _mapCrossAxisAlignment(column.crossAxisAlignment),
      },
      children: column.children.map((child) => _convertAnyWidget(child, context)).toList(),
    );
  }

  // Row conversion
  static UIASTNode _convertRow(Row row, BuildContext context) {
    return UIASTNode(
      type: 'Row',
      props: {
        'mainAxisAlignment': row.mainAxisAlignment.toString(),
        'crossAxisAlignment': row.crossAxisAlignment.toString(),
        'mainAxisSize': row.mainAxisSize.toString(),
      },
      style: {
        'display': 'flex',
        'flexDirection': 'row',
        'justifyContent': _mapMainAxisAlignment(row.mainAxisAlignment),
        'alignItems': _mapCrossAxisAlignment(row.crossAxisAlignment),
      },
      children: row.children.map((child) => _convertAnyWidget(child, context)).toList(),
    );
  }

  // Generic widget fallback
  static UIASTNode _convertGenericWidget(Widget widget, BuildContext context) {
    final widgetType = widget.runtimeType.toString();
    
    // Try to extract children if it's a multi-child widget
    List<UIASTNode>? children;
    try {
      if (widget is MultiChildRenderObjectWidget) {
        children = widget.children.map((child) => _convertAnyWidget(child, context)).toList();
      } else if (widget is SingleChildRenderObjectWidget && widget.child != null) {
        children = [_convertAnyWidget(widget.child!, context)];
      }
    } catch (e) {
      // Ignore extraction errors
    }

    return UIASTNode(
      type: widgetType,
      props: {
        'originalType': widgetType,
      },
      style: {
        'display': 'block',
      },
      children: children,
    );
  }

  // Helper methods for other widget types
  static UIASTNode _convertFAB(FloatingActionButton fab, BuildContext context) {
    return UIASTNode(
      type: 'FloatingActionButton',
      props: {'disabled': fab.onPressed == null},
      style: {
        'position': 'fixed',
        'bottom': '16px',
        'right': '16px',
        'width': '56px',
        'height': '56px',
        'borderRadius': '28px',
        'backgroundColor': _colorToHex(fab.backgroundColor) ?? '#2196f3',
        'border': 'none',
        'cursor': 'pointer',
        'display': 'flex',
        'alignItems': 'center',
        'justifyContent': 'center',
        'boxShadow': '0 4px 8px rgba(0,0,0,0.3)',
      },
      children: fab.child != null ? [_convertAnyWidget(fab.child!, context)] : null,
    );
  }

  static UIASTNode _convertImage(Image image, BuildContext context) {
    String? src;
    if (image.image is NetworkImage) {
      src = (image.image as NetworkImage).url;
    } else if (image.image is AssetImage) {
      src = (image.image as AssetImage).assetName;
    }

    return UIASTNode(
      type: 'Image',
      props: {
        'src': src ?? '',
        'alt': image.semanticLabel ?? '',
      },
      style: {
        if (image.width != null) 'width': '${image.width}px',
        if (image.height != null) 'height': '${image.height}px',
        'objectFit': _mapBoxFit(image.fit),
      },
    );
  }

  static UIASTNode _convertIcon(Icon icon, BuildContext context) {
    return UIASTNode(
      type: 'Icon',
      props: {
        'icon': icon.icon?.codePoint.toString() ?? '',
        'fontFamily': icon.icon?.fontFamily ?? 'MaterialIcons',
      },
      style: {
        'fontSize': '${icon.size ?? 24}px',
        'color': _colorToHex(icon.color) ?? 'currentColor',
      },
    );
  }

  // Additional widget converters would go here...
  static UIASTNode _convertCard(Card card, BuildContext context) => _convertGenericWidget(card, context);
  static UIASTNode _convertListTile(ListTile listTile, BuildContext context) => _convertGenericWidget(listTile, context);
  static UIASTNode _convertListView(ListView listView, BuildContext context) => _convertGenericWidget(listView, context);
  static UIASTNode _convertGridView(GridView gridView, BuildContext context) => _convertGenericWidget(gridView, context);
  static UIASTNode _convertStack(Stack stack, BuildContext context) => _convertGenericWidget(stack, context);
  static UIASTNode _convertPositioned(Positioned positioned, BuildContext context) => _convertGenericWidget(positioned, context);
  static UIASTNode _convertExpanded(Expanded expanded, BuildContext context) => _convertGenericWidget(expanded, context);
  static UIASTNode _convertFlexible(Flexible flexible, BuildContext context) => _convertGenericWidget(flexible, context);
  static UIASTNode _convertPadding(Padding padding, BuildContext context) => _convertGenericWidget(padding, context);
  static UIASTNode _convertCenter(Center center, BuildContext context) => _convertGenericWidget(center, context);
  static UIASTNode _convertAlign(Align align, BuildContext context) => _convertGenericWidget(align, context);
  static UIASTNode _convertSizedBox(SizedBox sizedBox, BuildContext context) => _convertGenericWidget(sizedBox, context);
  static UIASTNode _convertTextField(TextField textField, BuildContext context) => _convertGenericWidget(textField, context);
  static UIASTNode _convertCheckbox(Checkbox checkbox, BuildContext context) => _convertGenericWidget(checkbox, context);
  static UIASTNode _convertSwitch(Switch switchWidget, BuildContext context) => _convertGenericWidget(switchWidget, context);
  static UIASTNode _convertSlider(Slider slider, BuildContext context) => _convertGenericWidget(slider, context);
  static UIASTNode _convertDrawer(Widget drawer, BuildContext context) => _convertGenericWidget(drawer, context);
  static UIASTNode _convertBottomNavBar(Widget bottomNavBar, BuildContext context) => _convertGenericWidget(bottomNavBar, context);

  // Helper methods
  static Map<String, dynamic>? _extractThemeData(ThemeData? theme) {
    if (theme == null) return null;
    
    return {
      'primaryColor': _colorToHex(theme.primaryColor),
      'colorScheme': {
        'primary': _colorToHex(theme.colorScheme.primary),
        'secondary': _colorToHex(theme.colorScheme.secondary),
        'surface': _colorToHex(theme.colorScheme.surface),
      },
    };
  }

  static Map<String, dynamic>? _convertTextStyle(TextStyle? style, BuildContext context) {
    if (style == null) return null;
    
    return {
      if (style.fontSize != null) 'fontSize': '${style.fontSize}px',
      if (style.color != null) 'color': _colorToHex(style.color),
      if (style.fontWeight != null) 'fontWeight': _convertFontWeight(style.fontWeight!),
      if (style.fontStyle != null) 'fontStyle': style.fontStyle == FontStyle.italic ? 'italic' : 'normal',
    };
  }

  static String? _colorToHex(Color? color) {
    if (color == null) return null;
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static String _convertFontWeight(FontWeight weight) {
    switch (weight) {
      case FontWeight.w100: return '100';
      case FontWeight.w200: return '200';
      case FontWeight.w300: return '300';
      case FontWeight.w400: return '400';
      case FontWeight.w500: return '500';
      case FontWeight.w600: return '600';
      case FontWeight.w700: return '700';
      case FontWeight.w800: return '800';
      case FontWeight.w900: return '900';
      default: return '400';
    }
  }

  static String _convertEdgeInsets(EdgeInsetsGeometry insets) {
    if (insets is EdgeInsets) {
      return '${insets.top}px ${insets.right}px ${insets.bottom}px ${insets.left}px';
    }
    return '0px';
  }

  static String _convertBorderRadius(BorderRadiusGeometry borderRadius) {
    if (borderRadius is BorderRadius) {
      final topLeft = borderRadius.topLeft.x;
      return '${topLeft}px';
    }
    return '0px';
  }

  static String _convertBoxShadow(List<BoxShadow> shadows) {
    final shadow = shadows.first;
    return '${shadow.offset.dx}px ${shadow.offset.dy}px ${shadow.blurRadius}px ${_colorToHex(shadow.color)}';
  }

  static String _mapMainAxisAlignment(MainAxisAlignment alignment) {
    switch (alignment) {
      case MainAxisAlignment.start: return 'flex-start';
      case MainAxisAlignment.end: return 'flex-end';
      case MainAxisAlignment.center: return 'center';
      case MainAxisAlignment.spaceBetween: return 'space-between';
      case MainAxisAlignment.spaceAround: return 'space-around';
      case MainAxisAlignment.spaceEvenly: return 'space-evenly';
    }
  }

  static String _mapCrossAxisAlignment(CrossAxisAlignment alignment) {
    switch (alignment) {
      case CrossAxisAlignment.start: return 'flex-start';
      case CrossAxisAlignment.end: return 'flex-end';
      case CrossAxisAlignment.center: return 'center';
      case CrossAxisAlignment.stretch: return 'stretch';
      case CrossAxisAlignment.baseline: return 'baseline';
    }
  }

  static String _mapBoxFit(BoxFit? fit) {
    switch (fit) {
      case BoxFit.contain: return 'contain';
      case BoxFit.cover: return 'cover';
      case BoxFit.fill: return 'fill';
      case BoxFit.fitHeight: return 'cover';
      case BoxFit.fitWidth: return 'cover';
      case BoxFit.scaleDown: return 'scale-down';
      default: return 'cover';
    }
  }

  static Map<String, dynamic> _extractWidgetState(Widget widget) {
    // Extract state from StatefulWidget if possible
    return {};
  }

  static List<AssetReference> _extractAssets(Widget widget) {
    // Extract asset references from widget tree
    return [];
  }

  static List<EventBinding> _extractEvents(Widget widget) {
    // Extract event bindings from widget tree
    return [];
  }

  static String _generateScreenId(String route) {
    return route.replaceAll('/', '_').replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }
}