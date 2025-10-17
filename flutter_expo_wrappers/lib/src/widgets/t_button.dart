import 'package:flutter/material.dart';
import '../core/ui_ast.dart';

/// FlutterExpo wrapper for Button widget that emits UI AST
class TButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final String? id;

  const TButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.style,
    this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Emit UI AST for this button widget
    
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }

  /// Generate UI AST node for this button widget
  UIASTNode toUIASTNode() {
    return UIASTNode(
      id: id,
      type: 'Button',
      props: {
        'enabled': onPressed != null,
      },
      style: _convertButtonStyle(style),
      children: _convertChild(child),
    );
  }

  List<UIASTNode>? _convertChild(Widget child) {
    // TODO: Implement proper child conversion
    if (child is Text) {
      return [
        UIASTNode(
          type: 'Text',
          props: {'data': child.data ?? ''},
          text: child.data,
        )
      ];
    }
    return null;
  }

  Map<String, dynamic>? _convertButtonStyle(ButtonStyle? style) {
    if (style == null) return null;
    
    // TODO: Implement proper ButtonStyle conversion
    return {};
  }
}