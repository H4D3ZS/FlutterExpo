import 'dart:convert';

/// Represents a node in the UI Abstract Syntax Tree
class UIASTNode {
  final String? id;
  final String type;
  final Map<String, dynamic> props;
  final Map<String, dynamic>? style;
  final List<UIASTNode>? children;
  final String? textId;
  final String? text;

  const UIASTNode({
    this.id,
    required this.type,
    required this.props,
    this.style,
    this.children,
    this.textId,
    this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'props': props,
      if (style != null) 'style': style,
      if (children != null) 'children': children?.map((child) => child.toJson()).toList(),
      if (textId != null) 'textId': textId,
      if (text != null) 'text': text,
    };
  }

  factory UIASTNode.fromJson(Map<String, dynamic> json) {
    return UIASTNode(
      id: json['id'],
      type: json['type'],
      props: json['props'] ?? {},
      style: json['style'],
      children: json['children']?.map<UIASTNode>((child) => UIASTNode.fromJson(child)).toList(),
      textId: json['textId'],
      text: json['text'],
    );
  }
}

/// Represents an event binding for UI components
class EventBinding {
  final String componentId;
  final String event;
  final String action;
  final Map<String, dynamic>? parameters;

  const EventBinding({
    required this.componentId,
    required this.event,
    required this.action,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'componentId': componentId,
      'event': event,
      'action': action,
      if (parameters != null) 'parameters': parameters,
    };
  }

  factory EventBinding.fromJson(Map<String, dynamic> json) {
    return EventBinding(
      componentId: json['componentId'],
      event: json['event'],
      action: json['action'],
      parameters: json['parameters'],
    );
  }
}

/// Represents an asset reference in the UI
class AssetReference {
  final String id;
  final String type;
  final String url;
  final Map<String, dynamic>? metadata;

  const AssetReference({
    required this.id,
    required this.type,
    required this.url,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory AssetReference.fromJson(Map<String, dynamic> json) {
    return AssetReference(
      id: json['id'],
      type: json['type'],
      url: json['url'],
      metadata: json['metadata'],
    );
  }
}

/// Complete UI AST document representing a screen
class UIASTDocument {
  final String screenId;
  final String route;
  final String timestamp;
  final String language;
  final UIASTNode tree;
  final Map<String, dynamic> state;
  final List<AssetReference> assets;
  final List<EventBinding> events;

  const UIASTDocument({
    required this.screenId,
    required this.route,
    required this.timestamp,
    required this.language,
    required this.tree,
    required this.state,
    required this.assets,
    required this.events,
  });

  Map<String, dynamic> toJson() {
    return {
      'screenId': screenId,
      'route': route,
      'timestamp': timestamp,
      'language': language,
      'tree': tree.toJson(),
      'state': state,
      'assets': assets.map((asset) => asset.toJson()).toList(),
      'events': events.map((event) => event.toJson()).toList(),
    };
  }

  factory UIASTDocument.fromJson(Map<String, dynamic> json) {
    return UIASTDocument(
      screenId: json['screenId'],
      route: json['route'],
      timestamp: json['timestamp'],
      language: json['language'],
      tree: UIASTNode.fromJson(json['tree']),
      state: json['state'] ?? {},
      assets: (json['assets'] as List?)?.map((asset) => AssetReference.fromJson(asset)).toList() ?? [],
      events: (json['events'] as List?)?.map((event) => EventBinding.fromJson(event)).toList() ?? [],
    );
  }

  String toJsonString() => jsonEncode(toJson());
}