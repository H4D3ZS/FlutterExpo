import 'package:flutter/material.dart';
import 'ui_ast.dart';
import 'websocket_emitter.dart';

/// FlutterExpo wrapper for MaterialApp that captures the entire app structure
class FlutterExpoApp extends StatefulWidget {
  final String title;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final Widget? home;
  final Map<String, WidgetBuilder>? routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final String wsUrl;
  final Locale? locale;
  final List<Locale> supportedLocales;
  final LocalizationsDelegate<dynamic>? localizationsDelegates;

  const FlutterExpoApp({
    Key? key,
    required this.title,
    this.theme,
    this.darkTheme,
    this.home,
    this.routes,
    this.initialRoute,
    this.onGenerateRoute,
    required this.wsUrl,
    this.locale,
    this.supportedLocales = const [Locale('en', 'US')],
    this.localizationsDelegates,
  }) : super(key: key);

  @override
  State<FlutterExpoApp> createState() => _FlutterExpoAppState();
}

class _FlutterExpoAppState extends State<FlutterExpoApp> with WidgetsBindingObserver {
  late WebSocketEmitter _emitter;
  late NavigatorObserver _navigatorObserver;
  String _currentRoute = '/';
  Map<String, dynamic> _appState = {};

  @override
  void initState() {
    super.initState();
    _emitter = WebSocketEmitter(widget.wsUrl);
    _navigatorObserver = FlutterExpoNavigatorObserver(_onRouteChanged);
    _connectToTranslator();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emitter.disconnect();
    super.dispose();
  }

  Future<void> _connectToTranslator() async {
    try {
      await _emitter.connect();
      _emitAppStructure();
    } catch (e) {
      print('Failed to connect to FlutterExpo translator: $e');
    }
  }

  void _onRouteChanged(String route) {
    setState(() {
      _currentRoute = route;
    });
    _emitCurrentScreen();
  }

  void _emitAppStructure() {
    if (!_emitter.isConnected) return;

    // Emit app-level configuration
    final appConfig = {
      'type': 'APP_CONFIG',
      'timestamp': DateTime.now().toIso8601String(),
      'data': {
        'title': widget.title,
        'theme': _extractThemeData(widget.theme),
        'darkTheme': _extractThemeData(widget.darkTheme),
        'routes': widget.routes?.keys.toList() ?? [],
        'initialRoute': widget.initialRoute ?? '/',
        'supportedLocales': widget.supportedLocales.map((l) => '${l.languageCode}_${l.countryCode}').toList(),
        'currentLocale': widget.locale?.toString() ?? 'en_US',
      }
    };

    _emitter.emitRawMessage(appConfig);
    _emitCurrentScreen();
  }

  void _emitCurrentScreen() {
    if (!_emitter.isConnected) return;

    // Get current screen widget tree
    if (!mounted) return;

    final screenWidget = _getCurrentScreenWidget();
    if (screenWidget == null) return;

    final uiDocument = UIASTDocument(
      screenId: _generateScreenId(_currentRoute),
      route: _currentRoute,
      timestamp: DateTime.now().toIso8601String(),
      language: widget.locale?.languageCode ?? 'en',
      tree: _buildScreenAST(screenWidget),
      state: _appState,
      assets: [],
      events: [],
    );

    _emitter.emitUIUpdate(uiDocument);
  }

  Widget? _getCurrentScreenWidget() {
    // This would need to be implemented to extract the current screen widget
    // For now, return the home widget or a placeholder
    return widget.home;
  }

  UIASTNode _buildScreenAST(Widget widget) {
    // Convert the current screen widget to UI AST
    return _convertWidgetToAST(widget);
  }

  UIASTNode _convertWidgetToAST(Widget widget) {
    // This is a simplified conversion - in a real implementation,
    // this would need to handle all Flutter widget types
    if (widget is Scaffold) {
      return _convertScaffold(widget);
    } else if (widget is Column) {
      return _convertColumn(widget);
    } else if (widget is Row) {
      return _convertRow(widget);
    } else if (widget is Container) {
      return _convertContainer(widget);
    } else if (widget is Text) {
      return _convertText(widget);
    } else {
      // Fallback for unknown widgets
      return UIASTNode(
        type: widget.runtimeType.toString(),
        props: {},
      );
    }
  }

  UIASTNode _convertScaffold(Scaffold scaffold) {
    final children = <UIASTNode>[];
    
    if (scaffold.appBar != null) {
      children.add(_convertAppBar(scaffold.appBar!));
    }
    
    if (scaffold.body != null) {
      children.add(_convertWidgetToAST(scaffold.body!));
    }
    
    if (scaffold.floatingActionButton != null) {
      children.add(_convertFloatingActionButton(scaffold.floatingActionButton!));
    }

    return UIASTNode(
      type: 'Scaffold',
      props: {},
      style: {
        'display': 'flex',
        'flexDirection': 'column',
        'minHeight': '100vh',
        'backgroundColor': scaffold.backgroundColor?.toString() ?? '#ffffff',
      },
      children: children,
    );
  }

  UIASTNode _convertAppBar(PreferredSizeWidget appBar) {
    if (appBar is AppBar) {
      return UIASTNode(
        type: 'AppBar',
        props: {
          'title': appBar.title is Text ? (appBar.title as Text).data : '',
        },
        style: {
          'backgroundColor': appBar.backgroundColor?.toString() ?? '#2196f3',
          'color': appBar.foregroundColor?.toString() ?? '#ffffff',
          'padding': '16px',
          'display': 'flex',
          'alignItems': 'center',
          'minHeight': '56px',
        },
        children: appBar.title != null ? [_convertWidgetToAST(appBar.title!)] : null,
      );
    }
    
    return UIASTNode(type: 'AppBar', props: {});
  }

  UIASTNode _convertFloatingActionButton(Widget? fab) {
    if (fab is FloatingActionButton) {
      return UIASTNode(
        type: 'FloatingActionButton',
        props: {
          'enabled': fab.onPressed != null,
        },
        style: {
          'position': 'fixed',
          'bottom': '16px',
          'right': '16px',
          'width': '56px',
          'height': '56px',
          'borderRadius': '28px',
          'backgroundColor': fab.backgroundColor?.toString() ?? '#2196f3',
          'border': 'none',
          'cursor': 'pointer',
          'display': 'flex',
          'alignItems': 'center',
          'justifyContent': 'center',
        },
        children: fab.child != null ? [_convertWidgetToAST(fab.child!)] : null,
      );
    }
    
    return UIASTNode(type: 'FloatingActionButton', props: {});
  }

  UIASTNode _convertColumn(Column column) {
    return UIASTNode(
      type: 'Column',
      props: {
        'mainAxisAlignment': column.mainAxisAlignment.toString(),
        'crossAxisAlignment': column.crossAxisAlignment.toString(),
      },
      style: {
        'display': 'flex',
        'flexDirection': 'column',
        'justifyContent': _mapMainAxisAlignment(column.mainAxisAlignment),
        'alignItems': _mapCrossAxisAlignment(column.crossAxisAlignment),
      },
      children: column.children.map(_convertWidgetToAST).toList(),
    );
  }

  UIASTNode _convertRow(Row row) {
    return UIASTNode(
      type: 'Row',
      props: {
        'mainAxisAlignment': row.mainAxisAlignment.toString(),
        'crossAxisAlignment': row.crossAxisAlignment.toString(),
      },
      style: {
        'display': 'flex',
        'flexDirection': 'row',
        'justifyContent': _mapMainAxisAlignment(row.mainAxisAlignment),
        'alignItems': _mapCrossAxisAlignment(row.crossAxisAlignment),
      },
      children: row.children.map(_convertWidgetToAST).toList(),
    );
  }

  UIASTNode _convertContainer(Container container) {
    return UIASTNode(
      type: 'Container',
      props: {
        if (container.constraints?.maxWidth != null) 'width': container.constraints!.maxWidth,
        if (container.constraints?.maxHeight != null) 'height': container.constraints!.maxHeight,
      },
      style: {
        if (container.color != null) 'backgroundColor': container.color.toString(),
        if (container.padding != null) 'padding': _convertEdgeInsets(container.padding!),
        if (container.margin != null) 'margin': _convertEdgeInsets(container.margin!),
      },
      children: container.child != null ? [_convertWidgetToAST(container.child!)] : null,
    );
  }

  UIASTNode _convertText(Text text) {
    return UIASTNode(
      type: 'Text',
      props: {
        'data': text.data ?? '',
      },
      style: _convertTextStyle(text.style),
      text: text.data,
    );
  }

  Map<String, dynamic>? _extractThemeData(ThemeData? theme) {
    if (theme == null) return null;
    
    return {
      'primaryColor': theme.primaryColor.toString(),
      'colorScheme': {
        'primary': theme.colorScheme.primary.toString(),
        'secondary': theme.colorScheme.secondary.toString(),
        'surface': theme.colorScheme.surface.toString(),
        'surface': theme.colorScheme.surface.toString(),
      },
      'textTheme': {
        'headlineLarge': _convertTextStyle(theme.textTheme.headlineLarge),
        'bodyLarge': _convertTextStyle(theme.textTheme.bodyLarge),
        'bodyMedium': _convertTextStyle(theme.textTheme.bodyMedium),
      },
    };
  }

  Map<String, dynamic>? _convertTextStyle(TextStyle? style) {
    if (style == null) return null;
    
    return {
      if (style.fontSize != null) 'fontSize': '${style.fontSize}px',
      if (style.color != null) 'color': style.color.toString(),
      if (style.fontWeight != null) 'fontWeight': _convertFontWeight(style.fontWeight!),
      if (style.fontStyle != null) 'fontStyle': style.fontStyle == FontStyle.italic ? 'italic' : 'normal',
    };
  }

  String _convertFontWeight(FontWeight weight) {
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

  String _convertEdgeInsets(EdgeInsetsGeometry insets) {
    if (insets is EdgeInsets) {
      return '${insets.top}px ${insets.right}px ${insets.bottom}px ${insets.left}px';
    }
    return '0px';
  }

  String _mapMainAxisAlignment(MainAxisAlignment alignment) {
    switch (alignment) {
      case MainAxisAlignment.start: return 'flex-start';
      case MainAxisAlignment.end: return 'flex-end';
      case MainAxisAlignment.center: return 'center';
      case MainAxisAlignment.spaceBetween: return 'space-between';
      case MainAxisAlignment.spaceAround: return 'space-around';
      case MainAxisAlignment.spaceEvenly: return 'space-evenly';
    }
  }

  String _mapCrossAxisAlignment(CrossAxisAlignment alignment) {
    switch (alignment) {
      case CrossAxisAlignment.start: return 'flex-start';
      case CrossAxisAlignment.end: return 'flex-end';
      case CrossAxisAlignment.center: return 'center';
      case CrossAxisAlignment.stretch: return 'stretch';
      case CrossAxisAlignment.baseline: return 'baseline';
    }
  }

  String _generateScreenId(String route) {
    return route.replaceAll('/', '_').replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: widget.theme,
      darkTheme: widget.darkTheme,
      home: widget.home,
      routes: widget.routes ?? {},
      initialRoute: widget.initialRoute,
      onGenerateRoute: widget.onGenerateRoute,
      locale: widget.locale,
      supportedLocales: widget.supportedLocales,
      navigatorObservers: [_navigatorObserver],
    );
  }
}

/// Custom navigator observer to track route changes
class FlutterExpoNavigatorObserver extends NavigatorObserver {
  final Function(String) onRouteChanged;

  FlutterExpoNavigatorObserver(this.onRouteChanged);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      onRouteChanged(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      onRouteChanged(previousRoute!.settings.name!);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      onRouteChanged(newRoute!.settings.name!);
    }
  }
}